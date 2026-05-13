import 'dart:io';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/constants/app_strings.dart';
import '../model/response/kyc_process_step_model.dart';


class KycController extends GetxController{


  var kycLoginToken = '';

  /// Face Scan Verification
  late List<CameraDescription> cameras;
  late CameraController cameraController;
  RxBool isCameraReady = false.obs;
  // RxString selfieImagePath = "/data/user/0/com.red_cube.advance_business/cache/image_cropper_1701025731200.jpg".obs;
  RxString selfieImagePath = ''.obs;
  int _cameraIndex = -1;
  final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };
  FaceDetectorOptions options = FaceDetectorOptions(enableClassification: true, enableContours: true, enableLandmarks: true, enableTracking: true,);
  FaceDetector? faceDetector;

  RxString message = AppStrings.livenessInstruction.obs;
  var isFaceDetected = false;
  var isCameraShow = true;
  var isTakePhoto = true;
  Uint8List imageData = Uint8List(0);

  var selfieImage = ''.obs;
  var progressBarValue = 0.0.obs;
  var countEyeBlink = 0;
  var isEyeOpenClose = true;
  var startPhotoCaptureTimer = false.obs;

  /// Progress segments (60 segments = 6 degrees each)
  RxList<bool> completedSegments = List.generate(60, (_) => false).obs;
  RxDouble progress = 0.0.obs;
  RxBool isComplete = false.obs;

  var kycProcessStep = 0.obs;
  var kycProcessSteps = <KYCProcessStepModel>[].obs;

  void onReady() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async{
      faceDetector = FaceDetector(options: options);
      await Permission.camera.request();
      startCamera();
    });

  }


  void startCamera() async {
    cleanData();

    CameraLensDirection initialCameraLensDirection = CameraLensDirection.front;
    try {
      cameras = await availableCameras();
      for (var i = 0; i < cameras.length; i++) {
        if (cameras[i].lensDirection == initialCameraLensDirection) {
          _cameraIndex = i;
          break;
        }
      }
      cameraController = CameraController(
        cameras[_cameraIndex],
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888,
      );
      await cameraController.initialize().then((value) {
        isCameraReady.value = true;

        if (isCameraReady.value) {
          cameraController.startImageStream((image) async {
            await _liveNessFace(image);
          });
        }
      });
    } catch (e) {
      debugPrint('error-->$e');
    }
  }

  Future<InputImage?> _inputImageFromCameraImage(CameraImage image) async{
    final camera = cameras[_cameraIndex];
    final sensorOrientation = camera.sensorOrientation;
    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation =
      _orientations[cameraController.value.deviceOrientation];
      if (rotationCompensation == null) return null;
      if (camera.lensDirection == CameraLensDirection.front) {
        // front-facing
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        // back-facing
        rotationCompensation = (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
      // print('rotationCompensation: $rotationCompensation');
    }

    if (rotation == null) return null;
    // print('final rotation: $rotation');

    // get image format
    final format = InputImageFormatValue.fromRawValue(image.format.raw as int);
    // validate format depending on platform
    // only supported formats:
    // * nv21 for Android
    // * bgra8888 for iOS
    // debugPrint("format-> ${format?.name ?? "null"}");
    if (format == null || (Platform.isAndroid && format != InputImageFormat.nv21) || (Platform.isIOS && format != InputImageFormat.bgra8888)) return null;

    // since format is constraint to nv21 or bgra8888, both only have one plane

    if (image.planes.length != 1) return null;
    final plane = image.planes.first;

    // compose InputImage using bytes
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation, // used only in Android
        format: format, // used only in iOS
        bytesPerRow: plane.bytesPerRow, // used only in iOS
      ),
    );
  }


  var circleOffset = Offset.zero.obs;

  _liveNessFace(CameraImage image) async {
    if (isComplete.value) return;
    final inputImage = await _inputImageFromCameraImage(image);
    if(inputImage == null){
      return;
    }
    await faceDetector?.processImage(inputImage).then((List<Face> faces) async{
      if(faces.length == 1){
        final face = faces[0];
        
        // HeadEulerAngleY is yaw (left/right turn)
        // HeadEulerAngleX is pitch (up/down tilt)
        double leftEyeOpenProbability = face.leftEyeOpenProbability  ?? 0;
        double rightEyeOpenProbability = face.rightEyeOpenProbability ?? 0;
        double headEulerAngleY = face.headEulerAngleY ?? 0;
        final yaw = face.headEulerAngleY ?? 0;
        final pitch = face.headEulerAngleX ?? 0;

        // movement multiplier - adjust these values to control sensitivity
        // Yaw corresponds to horizontal movement (DX)
        // Pitch corresponds to vertical movement (DY)
        // On Android, front camera yaw might be inverted depending on sensor orientation
        final targetX = yaw * -4;
        final targetY = pitch * -4;

        /// smooth movement (interpolation)
        final smoothOffset = Offset(
          circleOffset.value.dx + (targetX - circleOffset.value.dx) * 0.12,
          circleOffset.value.dy + (targetY - circleOffset.value.dy) * 0.12,
        );

        circleOffset.value = smoothOffset;

        // Calculate circular progress based on head orientation
        // We use yaw and pitch to determine the angle on the circle
        final double distance = math.sqrt(yaw * yaw + pitch * pitch);
        if (distance > 8.0) {
          // Invert yaw for front camera mirroring
          // Invert pitch to match screen coordinates (down is positive Y in painter)
          final double targetYaw = -yaw;
          final double targetPitch = -pitch;

          final double angleRad = math.atan2(targetPitch, targetYaw);
          final double angleDeg = angleRad * 180 / math.pi;
          
          // Align with painter (which starts at top = -90 degrees)
          final double normalizedAngle = (angleDeg + 90 + 360) % 360;

          final int segmentCount = completedSegments.length;
          final int index = (normalizedAngle / (360 / segmentCount)).floor() % segmentCount;
          
          if (!completedSegments[index]) {
            completedSegments[index] = true;
            completedSegments.refresh();
            progress.value = completedSegments.where((s) => s).length / segmentCount;

          }
        }

        if (progress.value >= 1.0) {
          message.value = 'All set! Look straight and stay still for a moment.';
          if(isTakePhoto){
            if((leftEyeOpenProbability > 0.5 && rightEyeOpenProbability > 0.5) && (headEulerAngleY < 5 && headEulerAngleY > -5)){
              message.value = 'Verification Complete!';
              isTakePhoto = false;
              await takePhoto();
            }
          }
        }

      } else {
        message.value = 'Position your face in the circle';
      }
    }).catchError((e) {

    });
  }

  takePhoto() async {
    if (isComplete.value) return;
    isComplete.value = true;
    try {
      if (cameraController.value.isStreamingImages) {
        await cameraController.stopImageStream();
      }
      if (!cameraController.value.isTakingPicture) {
        final XFile photo = await cameraController.takePicture();
        if (kDebugMode) {
          debugPrint('Photo taken at: ${photo.path}');
        }
        isCameraReady.value = false;
        selfieImagePath.value = photo.path;
        message.value = '';
        kycProcessSteps[3].status = true;
        kycProcessSteps.refresh();

      } else {
        debugPrint('Camera is currently taking a picture, please wait...');
      }
    } catch (e) {
      debugPrint('Error taking photo: $e');
    }
    // Future.delayed(Duration(seconds: takePhotoInSeconds.value), () async {
    //
    // });
  }

  cleanData(){
    isFaceDetected = false;
    isTakePhoto = true;
    message.value = AppStrings.livenessInstructionShort;
    progressBarValue.value = 0.0;
    progress.value = 0.0;
    isComplete.value = false;
    completedSegments.value = List.generate(60, (_) => false);
    selfieImagePath.value = '';
    selfieImage.value = '';
  }




  @override
  void dispose() {
    stopCameraStream();
    super.dispose();
  }

  Future<void> stopCameraStream() async {
    if (cameraController.value.isStreamingImages) {
      await cameraController.stopImageStream();
    }
    await cameraController.dispose();
  }
}