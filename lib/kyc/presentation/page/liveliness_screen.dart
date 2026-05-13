import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:face_liveness_kyc/kyc/controller/kyc_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

// ─────────────────────────────────────────────────────────────────────────────
// LivelinessScreen
// ─────────────────────────────────────────────────────────────────────────────

class LivelinessScreen extends ConsumerStatefulWidget {
  const LivelinessScreen({super.key});

  @override
  ConsumerState<LivelinessScreen> createState() => _LivelinessScreenState();
}

class _LivelinessScreenState extends ConsumerState<LivelinessScreen>
    with TickerProviderStateMixin {
  final KycController controller = KycController();

  // ── Intro animation controllers ──────────────────────────────────────────
  late final AnimationController _introCtrl;
  late final Animation<double> _iconFade;
  late final Animation<double> _iconScale;
  late final Animation<double> _titleFade;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _subtitleFade;
  late final Animation<Offset> _subtitleSlide;
  late final Animation<double> _cardFade;
  late final Animation<double> _buttonFade;

  // ── Oval pulse ───────────────────────────────────────────────────────────
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  // ── Scan line ────────────────────────────────────────────────────────────
  late final AnimationController _scanCtrl;
  late final Animation<double> _scanAnim;

  // ── Success burst ────────────────────────────────────────────────────────
  late final AnimationController _successCtrl;
  late final Animation<double> _successScale;
  late final Animation<double> _successFade;
  late final Animation<double> _successRingScale;

  bool _showIntro = true;
  bool _scanning = false;

  @override
  void initState() {
    super.initState();

    // ── Intro ──────────────────────────────────────────────────────────────
    _introCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _iconFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _introCtrl, curve: const Interval(0.0, 0.4, curve: Curves.easeOut)),
    );
    _iconScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _introCtrl, curve: const Interval(0.0, 0.45, curve: Curves.elasticOut)),
    );
    _titleFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _introCtrl, curve: const Interval(0.3, 0.6, curve: Curves.easeOut)),
    );
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _introCtrl, curve: const Interval(0.3, 0.6, curve: Curves.easeOut)),
    );
    _subtitleFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _introCtrl, curve: const Interval(0.45, 0.75, curve: Curves.easeOut)),
    );
    _subtitleSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _introCtrl, curve: const Interval(0.45, 0.75, curve: Curves.easeOut)),
    );
    _cardFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _introCtrl, curve: const Interval(0.6, 0.9, curve: Curves.easeOut)),
    );
    _buttonFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _introCtrl, curve: const Interval(0.8, 1.0, curve: Curves.easeOut)),
    );

    _introCtrl.forward();

    // ── Pulse ──────────────────────────────────────────────────────────────
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.97, end: 1.04).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    // ── Scan line ──────────────────────────────────────────────────────────
    _scanCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
    _scanAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _scanCtrl, curve: Curves.easeInOut),
    );

    // ── Success ────────────────────────────────────────────────────────────
    _successCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _successScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _successCtrl, curve: Curves.elasticOut),
    );
    _successFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _successCtrl, curve: const Interval(0.0, 0.5, curve: Curves.easeOut)),
    );
    _successRingScale = Tween<double>(begin: 0.8, end: 1.6).animate(
      CurvedAnimation(parent: _successCtrl, curve: Curves.easeOut),
    );

    // Listen for completion
    ever(controller.isComplete, (bool v) {
      if (v) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) _successCtrl.forward();
        });
      }
    });
  }

  @override
  void dispose() {
    _introCtrl.dispose();
    _pulseCtrl.dispose();
    _scanCtrl.dispose();
    _successCtrl.dispose();
    controller.dispose();
    super.dispose();
  }

  void _startScan() {
    setState(() {
      _showIntro = false;
      _scanning = true;
    });
    controller.onReady();
  }

  // ── Colours ───────────────────────────────────────────────────────────────
  static const Color _bg = Color(0xFF000000);
  static const Color _green = Color(0xFF30D158); // Apple system green
  static const Color _greenGlow = Color(0xFF30D15830);
  static const Color _white = Colors.white;
  static const Color _white70 = Colors.white70;
  static const Color _white30 = Colors.white30;
  static const Color _cardBg = Color(0xFF1C1C1E);

  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 600),
        transitionBuilder: (child, anim) =>
            FadeTransition(opacity: anim, child: child),
        child: _showIntro ? _buildIntro() : _buildScanner(),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // INTRO SCREEN  (mirrors the "Set Up Face ID" iOS screen)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildIntro() {
    return SafeArea(
      key: const ValueKey('intro'),
      child: Column(
        children: [
          const SizedBox(height: 8),

          // ── Nav bar ──────────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.maybePop(context),
                  child: Text('Cancel',
                      style: TextStyle(color: _green, fontSize: 16.sp)),
                ),
                Text('Face ID',
                    style: TextStyle(
                        color: _white,
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w600)),
                const SizedBox(width: 64),
              ],
            ),
          ),

          const Spacer(),

          // ── Animated Face-ID icon ─────────────────────────────────────────
          AnimatedBuilder(
            animation: _introCtrl,
            builder: (_, __) => FadeTransition(
              opacity: _iconFade,
              child: ScaleTransition(
                scale: _iconScale,
                child: _FaceIdIcon(size: 120.w),
              ),
            ),
          ),

          SizedBox(height: 36.h),

          // ── Title ─────────────────────────────────────────────────────────
          AnimatedBuilder(
            animation: _introCtrl,
            builder: (_, __) => FadeTransition(
              opacity: _titleFade,
              child: SlideTransition(
                position: _titleSlide,
                child: Text(
                  'Set Up\nFace Verification',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _white,
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 12.h),

          // ── Subtitle ──────────────────────────────────────────────────────
          AnimatedBuilder(
            animation: _introCtrl,
            builder: (_, __) => FadeTransition(
              opacity: _subtitleFade,
              child: SlideTransition(
                position: _subtitleSlide,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40.w),
                  child: Text(
                    'Quickly and securely verify your identity using your face.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _white70,
                      fontSize: 15.sp,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 36.h),

          // ── Steps card ────────────────────────────────────────────────────
          FadeTransition(
            opacity: _cardFade,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 24.w),
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: const Column(
                children: [
                  _StepRow(
                    icon: Icons.face_retouching_natural,
                    label: 'Position your face in the oval',
                    showDivider: true,
                  ),
                  _StepRow(
                    icon: Icons.remove_red_eye_outlined,
                    label: 'Move your head in a circle',
                    showDivider: true,
                  ),
                  _StepRow(
                    icon: Icons.rotate_left_rounded,
                    label: 'Turn your head slowly',
                    showDivider: true,
                  ),
                  _StepRow(
                    icon: Icons.lock_outline_rounded,
                    label: 'Your data stays on-device',
                    showDivider: false,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // ── Privacy note ──────────────────────────────────────────────────
          FadeTransition(
            opacity: _cardFade,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: Text(
                'All processing happens on-device. No biometric data is transmitted.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white38, fontSize: 12.sp, height: 1.5),
              ),
            ),
          ),

          const Spacer(),

          // ── CTA button ────────────────────────────────────────────────────
          FadeTransition(
            opacity: _buttonFade,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: _GreenButton(
                label: 'Get Started',
                onTap: _startScan,
              ),
            ),
          ),

          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SCANNER SCREEN  (Face-ID circular progress + camera)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildScanner() {
    return Stack(
      key: const ValueKey('scanner'),
      fit: StackFit.expand,
      children: [
        // ── Dark radial bg ─────────────────────────────────────────────────
        Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 0.85,
              colors: [Color(0xFF0A0A0A), Color(0xFF000000)],
            ),
          ),
        ),

        SafeArea(
          child: Column(
            children: [
              // ── Nav ──────────────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        controller.dispose();
                        setState(() {
                          _showIntro = true;
                          _scanning = false;
                          _successCtrl.reset();
                        });
                      },
                      child: Text('Cancel',
                          style: TextStyle(color: _green, fontSize: 16.sp)),
                    ),
                    Text('Face Verification',
                        style: TextStyle(
                            color: _white,
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(width: 64),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // ── Main oval + progress ring ─────────────────────────────────
              Obx(() {
                final isComplete = controller.isComplete.value;
                final hasSelfie = controller.selfieImagePath.value.isNotEmpty;

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer glow ring (success only)
                    if (isComplete)
                      AnimatedBuilder(
                        animation: _successCtrl,
                        builder: (_, __) => FadeTransition(
                          opacity: ReverseAnimation(_successFade),
                          child: Transform.scale(
                            scale: _successRingScale.value,
                            child: Container(
                              width: 320.w,
                              height: 320.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _green.withOpacity(0.25),
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                    // Progress ring
                    AnimatedBuilder(
                      animation: _pulseCtrl,
                      builder: (_, __) => Transform.scale(
                        scale: isComplete ? 1.0 : _pulseAnim.value,
                        child: CustomPaint(
                          size: Size(310.w, 310.w),
                          painter: _FaceIdRingPainter(
                            segments: controller.completedSegments,
                            progress: controller.progress.value,
                            isComplete: isComplete,
                          ),
                        ),
                      ),
                    ),

                    // Oval camera / image
                    _buildOvalContent(hasSelfie, isComplete),

                    // Scan line (only while scanning)
                    if (!isComplete && controller.isCameraReady.value)
                      AnimatedBuilder(
                        animation: _scanAnim,
                        builder: (_, __) => ClipOval(
                          child: SizedBox(
                            width: 250.w,
                            height: 290.w,
                            child: Stack(
                              children: [
                                Positioned(
                                  top: _scanAnim.value * 290.w - 1,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    height: 2,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.transparent,
                                          _green.withOpacity(0.7),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    // Corner dots (Face-ID guides)
                    if (!isComplete)
                      SizedBox(
                        width: 260.w,
                        height: 300.w,
                        child: const _CornerGuides(),
                      ),

                    // Success checkmark
                    if (isComplete)
                      AnimatedBuilder(
                        animation: _successCtrl,
                        builder: (_, __) => FadeTransition(
                          opacity: _successFade,
                          child: ScaleTransition(
                            scale: _successScale,
                            child: Container(
                              width: 72.w,
                              height: 72.w,
                              decoration: BoxDecoration(
                                color: _green,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: _green.withOpacity(0.5),
                                    blurRadius: 32,
                                    spreadRadius: 8,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.check_rounded,
                                color: Colors.black,
                                size: 40.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              }),

              const Spacer(flex: 1),

              // ── Instruction text ──────────────────────────────────────────
              Obx(() => AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(anim),
                    child: child,
                  ),
                ),
                child: Text(
                  controller.message.value,
                  key: ValueKey(controller.message.value),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
              )),

              SizedBox(height: 8.h),

              Obx(() => Opacity(
                opacity: controller.isComplete.value ? 0 : 1,
                child: Text(
                  'Move your head slowly to fill the ring',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _white70, fontSize: 13.sp),
                ),
              )),

              // ── Step indicators ───────────────────────────────────────────
              SizedBox(height: 20.h),
              Obx(() => _StepIndicators(steps: controller.kycProcessSteps.value)),

              const Spacer(flex: 2),

              // ── Retry button (post-capture) ───────────────────────────────
              Obx(() => AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: controller.selfieImagePath.value.isNotEmpty
                    ? Padding(
                  key: const ValueKey('retry'),
                  padding: EdgeInsets.only(
                      bottom: 32.h, left: 24.w, right: 24.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: _GreenButton(
                          label: 'Continue',
                          onTap: () {
                            // TODO: navigate to next KYC step
                          },
                        ),
                      ),
                      SizedBox(width: 12.w),
                      _OutlineButton(
                        label: 'Retry',
                        onTap: () {
                          _successCtrl.reset();
                          controller.selfieImagePath.value = '';
                          controller.onReady();
                        },
                      ),
                    ],
                  ),
                )
                    : const SizedBox(key: ValueKey('empty')),
              )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOvalContent(bool hasSelfie, bool isComplete) {
    return ClipPath(
      clipper: _OvalClipper(),
      child: SizedBox(
        width: 250.w,
        height: 290.w,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Camera or captured image
            Obx(() {
              if (controller.isCameraReady.value) {
                return Transform.scale(
                  scale: 1.6,
                  child: Center(
                    child: AspectRatio(
                      aspectRatio:
                      1 / controller.cameraController.value.aspectRatio,
                      child: CameraPreview(controller.cameraController),
                    ),
                  ),
                );
              }
              if (hasSelfie) {
                return Image.file(
                  File(controller.selfieImagePath.value),
                  fit: BoxFit.cover,
                );
              }
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF30D158),
                  strokeWidth: 2,
                ),
              );
            }),

            // Subtle inner vignette
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.8,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.25),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Oval clipper (taller than wide — Face-ID shape)
// ─────────────────────────────────────────────────────────────────────────────
class _OvalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..addOval(Rect.fromLTWH(0, 0, size.width, size.height));
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Face-ID Ring Painter  (60 tick-marks, Apple green fill, glow)
// ─────────────────────────────────────────────────────────────────────────────
class _FaceIdRingPainter extends CustomPainter {
  final List<bool> segments;
  final double progress;
  final bool isComplete;

  const _FaceIdRingPainter({
    required this.segments,
    required this.progress,
    required this.isComplete,
  });

  static const int _count = 60;
  static const double _tickLen = 16;
  static const double _tickW = 2.8;
  static const double _gap = 4; // gap between ticks

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    // Oval: radiusX < radiusY
    final double rx = size.width / 2;
    final double ry = size.height / 2 * 1.05; // slightly taller

    for (int i = 0; i < _count; i++) {
      final double angle =
          (i / _count) * 2 * math.pi - math.pi / 2; // start top

      // Point on oval boundary
      final double ox = center.dx + rx * math.cos(angle);
      final double oy = center.dy + ry * math.sin(angle);

      // Normal vector (outward)
      final double nx =
          rx * math.cos(angle) / math.sqrt((rx * math.cos(angle)) * (rx * math.cos(angle)) + (ry * math.sin(angle)) * (ry * math.sin(angle)));
      final double ny =
          ry * math.sin(angle) / math.sqrt((rx * math.cos(angle)) * (rx * math.cos(angle)) + (ry * math.sin(angle)) * (ry * math.sin(angle)));

      final Offset inner = Offset(ox - nx * _gap, oy - ny * _gap);
      final Offset outer =
      Offset(ox - nx * _gap + nx * _tickLen, oy - ny * _gap + ny * _tickLen);

      bool active = i < segments.length && segments[i];
      if (isComplete) active = true;

      if (active) {
        // Glow
        canvas.drawLine(
          inner,
          outer,
          Paint()
            ..color = const Color(0xFF30D158).withOpacity(0.35)
            ..strokeWidth = _tickW + 5
            ..strokeCap = StrokeCap.round
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
        );
        // Bright tick
        canvas.drawLine(
          inner,
          outer,
          Paint()
            ..color = const Color(0xFF30D158)
            ..strokeWidth = _tickW
            ..strokeCap = StrokeCap.round,
        );
      } else {
        canvas.drawLine(
          inner,
          outer,
          Paint()
            ..color = Colors.white.withOpacity(0.18)
            ..strokeWidth = _tickW
            ..strokeCap = StrokeCap.round,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FaceIdRingPainter old) =>
      old.progress != progress ||
          old.segments != segments ||
          old.isComplete != isComplete;
}

// ─────────────────────────────────────────────────────────────────────────────
// Face-ID animated icon (dotMatrix style)
// ─────────────────────────────────────────────────────────────────────────────
class _FaceIdIcon extends StatefulWidget {
  final double size;
  const _FaceIdIcon({required this.size});

  @override
  State<_FaceIdIcon> createState() => _FaceIdIconState();
}

class _FaceIdIconState extends State<_FaceIdIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _arc;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
    _arc = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _arc,
      builder: (_, __) => CustomPaint(
        size: Size(widget.size, widget.size),
        painter: _FaceIdIconPainter(t: _arc.value),
      ),
    );
  }
}

class _FaceIdIconPainter extends CustomPainter {
  final double t;
  const _FaceIdIconPainter({required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final Paint p = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.055
      ..strokeCap = StrokeCap.round;

    final double r = w * 0.14;

    // ── Oval face outline ─────────────────────────────────────────────────
    final ovalRect = Rect.fromCenter(
      center: Offset(w / 2, h / 2),
      width: w * 0.72,
      height: h * 0.85,
    );
    // animate draw fraction
    final double drawFrac = (math.sin(t * math.pi * 2) * 0.5 + 0.5).clamp(0.6, 1.0);
    final Path ovalPath = Path()..addOval(ovalRect);
    final PathMetric metric = ovalPath.computeMetrics().first;
    final Path partial = metric.extractPath(0, metric.length * drawFrac);
    canvas.drawPath(partial, p);

    // ── Eyes ──────────────────────────────────────────────────────────────
    final double eyeY = h * 0.4;
    final double blink = (math.sin(t * math.pi * 6 - 1.2)).clamp(0.0, 1.0);
    final double eyeH = r * 0.9 * (1 - blink * 0.85);

    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.36, eyeY), width: r * 0.9, height: eyeH),
      p,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.64, eyeY), width: r * 0.9, height: eyeH),
      p,
    );

    // ── Nose ──────────────────────────────────────────────────────────────
    final nosePath = Path()
      ..moveTo(w * 0.44, h * 0.5)
      ..quadraticBezierTo(w * 0.38, h * 0.62, w * 0.5, h * 0.63)
      ..quadraticBezierTo(w * 0.62, h * 0.62, w * 0.56, h * 0.5);
    canvas.drawPath(nosePath, p);

    // ── Smile ──────────────────────────────────────────────────────────────
    final smilePath = Path();
    smilePath.moveTo(w * 0.34, h * 0.72);
    smilePath.quadraticBezierTo(w * 0.5, h * 0.82, w * 0.66, h * 0.72);
    canvas.drawPath(smilePath, p);
  }

  @override
  bool shouldRepaint(covariant _FaceIdIconPainter old) => old.t != t;
}

// ─────────────────────────────────────────────────────────────────────────────
// Corner guides (4 L-shapes at oval corners, Face-ID reference markers)
// ─────────────────────────────────────────────────────────────────────────────
class _CornerGuides extends StatelessWidget {
  const _CornerGuides();

  @override
  Widget build(BuildContext context) {
    const color = Colors.white30;
    const len = 18.0;
    const thick = 2.5;

    Widget corner(bool flipX, bool flipY) {
      return Transform.scale(
        scaleX: flipX ? -1 : 1,
        scaleY: flipY ? -1 : 1,
        child: const SizedBox(
          width: len + thick,
          height: len + thick,
          child: CustomPaint(
            painter: _LPainter(color: color, len: len, thick: thick),
          ),
        ),
      );
    }

    return Stack(
      children: [
        Positioned(top: 0, left: 0, child: corner(false, false)),
        Positioned(top: 0, right: 0, child: corner(true, false)),
        Positioned(bottom: 0, left: 0, child: corner(false, true)),
        Positioned(bottom: 0, right: 0, child: corner(true, true)),
      ],
    );
  }
}

class _LPainter extends CustomPainter {
  final Color color;
  final double len;
  final double thick;

  const _LPainter(
      {required this.color, required this.len, required this.thick});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = thick
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(0, 0), Offset(len, 0), p);
    canvas.drawLine(const Offset(0, 0), Offset(0, len), p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Step row for intro card
// ─────────────────────────────────────────────────────────────────────────────
class _StepRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool showDivider;

  const _StepRow(
      {required this.icon, required this.label, required this.showDivider});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF30D158), size: 22.sp),
              SizedBox(width: 14.w),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            color: Colors.white.withOpacity(0.08),
            indent: 52.w,
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step indicators (progress dots below scanner)
// ─────────────────────────────────────────────────────────────────────────────
class _StepIndicators extends StatelessWidget {
  final List<dynamic> steps;
  const _StepIndicators({required this.steps});

  @override
  Widget build(BuildContext context) {
    if (steps.isEmpty) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(steps.length, (i) {
        final bool done = steps[i].status == true;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          width: done ? 20.w : 8.w,
          height: 8.w,
          decoration: BoxDecoration(
            color: done
                ? const Color(0xFF30D158)
                : Colors.white.withOpacity(0.25),
            borderRadius: BorderRadius.circular(4.r),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Green CTA button
// ─────────────────────────────────────────────────────────────────────────────
class _GreenButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _GreenButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54.h,
        decoration: BoxDecoration(
          color: const Color(0xFF30D158),
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF30D158).withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.black,
              fontSize: 17.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Outline secondary button
// ─────────────────────────────────────────────────────────────────────────────
class _OutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _OutlineButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54.h,
        width: 100.w,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white30, width: 1.5),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 17.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
