import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import '../../../config/asset_config.dart';
import '../../../config/color_config.dart';
import '../../../config/size_config.dart';
import '../../provider/kyc_provider.dart';

class KycProcessingScreen extends ConsumerStatefulWidget {
  const KycProcessingScreen({super.key});

  @override
  ConsumerState<KycProcessingScreen> createState() => _KycProcessingScreenState();
}

class _KycProcessingScreenState extends ConsumerState<KycProcessingScreen> {

  @override
  void initState() {

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    var kycVerified = ref.watch(kycVerifiedProvider);

    return SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text("KYC"),
          ),
          body: Padding(
              padding: EdgeInsets.all(16.0.sp),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [

                    Lottie.asset(
                      kycVerified == null ? AssetConfig.id_scanning_animation : kycVerified ? AssetConfig.success_animation : AssetConfig.failed_animation,
                      width: SizeConfig.screenWidth,
                      fit: BoxFit.fitWidth,
                    ),

                    SizedBox(
                      height: 24.0.h,
                    ),

                    Text(
                      kycVerified == null ? 'Please wait while we process your KYC' : kycVerified ? "KYC Verification Successful" : "KYC Verification Failed",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 24.0.sp,
                          fontWeight: FontWeight.w600,
                          color: ColorConfig.whiteColor
                      ),
                    ),

                  ]
              )
          ),

        )
    );
  }
}
