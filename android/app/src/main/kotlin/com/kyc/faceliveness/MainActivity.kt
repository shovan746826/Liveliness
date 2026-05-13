// android/app/src/main/kotlin/com/kyc/faceliveness/MainActivity.kt
// Minimal MainActivity — Flutter handles everything via the embedding.
// Extend FlutterFragmentActivity (instead of FlutterActivity) so that
// camera plugin's fragment-based preview works correctly on Android.

package com.kyc.faceliveness

import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity()
