import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../config/color_config.dart';


Widget customCameraPreview(CameraController controller){
  return Center(
    child:SizedBox(
      width: 230.w,
      height: 230.h,
      child:ClipOval(
        child: CameraPreview(controller),
      ),

    ),
  );
}


class CirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = ColorConfig.primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0;

    canvas.drawCircle(size.center(Offset.zero), size.width / 2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}