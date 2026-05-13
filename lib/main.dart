// lib/main.dart
// App entry point — boots ProviderScope and applies dark Apple-style theme.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'config/size_config.dart';
import 'kyc/presentation/page/liveliness_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Full-screen immersive experience — hide status bar edges
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.dark,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
  ));

  // Force portrait
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(
    // Riverpod root — wraps entire widget tree
    const ProviderScope(
      child: FaceLivenessApp(),
    ),
  );
}

class FaceLivenessApp extends StatelessWidget {
  const FaceLivenessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 850),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        SizeConfig.screenHeight = MediaQuery.sizeOf(context).height;
        SizeConfig.screenWidth = MediaQuery.sizeOf(context).width;

        return const MaterialApp(
          title: 'Face Liveness KYC',
          debugShowCheckedModeBanner: false,
          home: LivelinessScreen(),
        );
      },
    );
  }
}
