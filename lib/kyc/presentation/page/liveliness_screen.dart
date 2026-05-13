import 'dart:io';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:face_liveness_kyc/kyc/controller/kyc_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../config/color_config.dart';

class LivelinessScreen extends ConsumerStatefulWidget {
  const LivelinessScreen({super.key});

  @override
  ConsumerState<LivelinessScreen> createState() => _LivelinessScreenState();
}

class _LivelinessScreenState extends ConsumerState<LivelinessScreen> {

  var controller = KycController();

  @override
  void initState() {
    // TODO: implement initState
    controller.onReady();
    super.initState();
  }



  @override
  Widget build(BuildContext context) {



    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black, // Pure black background
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Face Verification',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          centerTitle: true,
        ),

        body: Stack(
          alignment: Alignment.center,
          children: [
            // Full screen camera preview (clipped to circle)
            Obx(() => controller.isCameraReady.value
              ? Center(
                  child: ClipOval(
                    child: SizedBox(
                      width: 280.w,
                      height: 280.w,
                      child: Transform.scale(
                        scale: 1.5, // Zoom slightly to focus on face
                        child: Center(
                          child: AspectRatio(
                            aspectRatio: 1 / controller.cameraController.value.aspectRatio,
                            child: CameraPreview(controller.cameraController),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : controller.selfieImagePath.value.isEmpty ? const Center(child: CircularProgressIndicator(color: Colors.greenAccent)): Center(
              child: ClipOval(
                child: SizedBox(
                  width: 280.w,
                  height: 280.w,
                  child: Image.file(
                    File(controller.selfieImagePath.value),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            )),

            // Progress Ring
            Obx(() => CustomPaint(
              painter: FaceIdProgressPainter(
                completedSegments: controller.completedSegments,
                progress: controller.progress.value,
              ),
              size: Size(300.w, 300.w),
            )),

            // Scan line or face guide
            Container(
              width: 240.w,
              height: 240.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white12, width: 1),
              ),
            ),

            /// Instruction message below circle
            Positioned(
              bottom: 120.h,
              child: Obx(() => Container(
                width: 320.w,
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    Text(
                      controller.message.value,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text('Move your head slowly to complete the circle',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              )),
            ),
          ],
        ),

        bottomNavigationBar: Obx(() => controller.selfieImagePath.value.isNotEmpty ?
        Container(
            padding: EdgeInsets.symmetric(horizontal: 12.0.w, vertical: 12.0.h),
            margin: EdgeInsets.symmetric(horizontal: 12.0.w),
            height: 48.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: ColorConfig.orangeColor,
            ),
            child: InkWell(
                onTap: () async{
                  controller.selfieImagePath.value = '';
                  controller.onReady();
                },
              child: Center(
                child: Text('Retry',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            )
        ).paddingOnly(bottom: 12.h) : const SizedBox()),
      ),
    );
  }
}

class FaceIdProgressPainter extends CustomPainter {
  final List<bool> completedSegments;
  final double progress;

  FaceIdProgressPainter({
    required this.completedSegments,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const segmentCount = 60;
    const tickThickness = 3.5;
    const tickLength = 22.0;

    // Background circle for depth
    final ringPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius - tickLength / 2, ringPaint);

    final basePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..strokeWidth = tickThickness
      ..strokeCap = StrokeCap.round;

    final activePaint = Paint()
      ..color = const Color(0xFF00FFC8) // Vibrant cyan/green
      ..strokeWidth = tickThickness + 0.5
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = const Color(0xFF00FFC8).withValues(alpha: 0.4)
      ..strokeWidth = tickThickness + 4
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    for (int i = 0; i < segmentCount; i++) {
      // Offset by -pi/2 to start from the top (12 o'clock)
      final angle = (i * 360 / segmentCount) * math.pi / 180 - math.pi / 2;
      
      // Calculate start and end points of the tick
      final start = Offset(
        center.dx + (radius - tickLength) * math.cos(angle),
        center.dy + (radius - tickLength) * math.sin(angle),
      );
      final end = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );

      bool isCompleted = i < completedSegments.length && completedSegments[i];
      
      if (isCompleted) {
        canvas.drawLine(start, end, glowPaint);
        canvas.drawLine(start, end, activePaint);
      } else {
        canvas.drawLine(start, end, basePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant FaceIdProgressPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.completedSegments != completedSegments;
  }
}
