# 🔐 Face Liveness KYC — Flutter App

A production-ready **Face Liveness Verification** app inspired by iPhone Face ID setup, built with Flutter 3.29.x and on-device ML Kit + TFLite inference.

---

## 📁 Project Structure

```
face_liveness_kyc/
├── lib/
│   ├── main.dart                          # App entry point
│   ├── core/
│   │   ├── constants/app_constants.dart   # All thresholds & config
│   │   ├── errors/failures.dart           # Typed error hierarchy
│   │   ├── theme/app_theme.dart           # Dark premium theme
│   │   └── utils/
│   │       ├── app_logger.dart            # Structured logger
│   │       ├── image_utils.dart           # Camera frame conversion
│   │       └── permission_utils.dart      # Camera permission helpers
│   ├── data/
│   │   ├── datasources/
│   │   │   ├── face_detection_datasource.dart   # ML Kit face detection
│   │   │   └── anti_spoof_datasource.dart       # TFLite anti-spoofing
│   │   └── repositories/
│   │       └── liveness_repository_impl.dart    # Coordinates ML pipeline
│   ├── domain/
│   │   └── entities/
│   │       ├── face_analysis_result.dart   # Per-frame analysis output
│   │       └── liveness_state.dart         # Session state entity
│   └── presentation/
│       ├── providers/
│       │   └── liveness_provider.dart      # Riverpod state notifier
│       ├── screens/
│       │   ├── intro_screen.dart           # Onboarding / start screen
│       │   ├── liveness_screen.dart        # Main verification screen
│       │   └── result_screen.dart          # Post-verification result
│       └── widgets/
│           ├── face_oval_painter.dart      # Animated oval + glow
│           ├── face_dot_grid_painter.dart  # IR dot grid effect
│           ├── scan_ring.dart              # Rotating dashed rings
│           ├── particles_background.dart   # Floating particles
│           ├── instruction_banner.dart     # Animated step instructions
│           ├── step_progress_dots.dart     # Challenge progress dots
│           ├── face_guidance_arrows.dart   # Head-turn arrow guides
│           ├── low_light_warning.dart      # Low-light banner
│           └── success_overlay.dart        # Completion screen
├── assets/
│   ├── models/
│   │   └── anti_spoof.tflite              # ← Place your model here
│   └── animations/                        # Optional Lottie JSON files
├── android/
│   ├── app/
│   │   ├── build.gradle                   # App Gradle + ML Kit deps
│   │   └── src/main/
│   │       ├── AndroidManifest.xml        # Camera permissions
│   │       ├── kotlin/.../MainActivity.kt
│   │       └── res/values/styles.xml
│   ├── build.gradle                       # Root Gradle
│   ├── settings.gradle
│   └── gradle.properties                  # Performance flags
├── ios/
│   ├── Runner/Info.plist                  # Camera usage descriptions
│   └── Podfile                            # CocoaPods + Metal config
├── pubspec.yaml
└── analysis_options.yaml
```

---

## 🚀 Quick Start

### 1. Prerequisites

```bash
# Flutter 3.29.x
flutter --version   # should show 3.29.x

# Dart SDK ≥ 3.3.0
dart --version

# Android: NDK r26b, minSdk 21, compileSdk 34
# iOS: Xcode 15+, iOS 14+ deployment target
```

### 2. Clone & Install

```bash
git clone <repo-url> face_liveness_kyc
cd face_liveness_kyc
flutter pub get
```

### 3. Add the Anti-Spoof TFLite Model

The app works without the model (gracefully returns `isLive=true`), but for
production KYC you **must** add a real anti-spoof model.

**Option A — Silent-Face-Anti-Spoofing (recommended open-source)**
```bash
# 1. Download the ONNX model from:
#    https://github.com/minivision-ai/Silent-Face-Anti-Spoofing

# 2. Convert to TFLite (Python):
pip install onnx onnx-tf tensorflow
python -c "
import onnx
from onnx_tf.backend import prepare
import tensorflow as tf

onnx_model = onnx.load('2.7_80x80_MiniFASNetV2.onnx')
tf_rep = prepare(onnx_model)
tf_rep.export_graph('anti_spoof_saved')

converter = tf.lite.TFLiteConverter.from_saved_model('anti_spoof_saved')
converter.optimizations = [tf.lite.Optimize.DEFAULT]
tflite_model = converter.convert()
with open('assets/models/anti_spoof.tflite', 'wb') as f:
    f.write(tflite_model)
print('Done!')
"
```

**Option B — Use any binary-classifier TFLite model**
- Input: `[1, 128, 128, 3]` float32 RGB, normalised to `[-1, 1]`
- Output: `[1, 2]` softmax — index 1 = live probability

Place the file at: `assets/models/anti_spoof.tflite`

### 4. Android Setup

```bash
# Ensure local.properties has your SDK path:
echo "sdk.dir=$ANDROID_HOME" > android/local.properties
echo "flutter.sdk=$(flutter sdk-path)" >> android/local.properties

# Build & run
flutter run --release
```

If you hit **multidex** issues on Android < 5.0 (unlikely with minSdk 21):
```groovy
// Already enabled in android/app/build.gradle:
defaultConfig { multiDexEnabled true }
```

### 5. iOS Setup

```bash
cd ios && pod install && cd ..
flutter run --release
```

Enable camera capability in Xcode:
- Open `ios/Runner.xcworkspace`
- Target → Signing & Capabilities → + Capability → Camera

---

## ⚙️ Configuration

All tunable parameters are in `lib/core/constants/app_constants.dart`:

| Constant | Default | Description |
|----------|---------|-------------|
| `minFaceSizeRatio` | `0.35` | Minimum face width / frame width |
| `maxFaceSizeRatio` | `0.80` | Maximum face size (too close guard) |
| `headTurnLeftThreshold` | `-20°` | Yaw angle for left turn challenge |
| `headTurnRightThreshold` | `20°` | Yaw angle for right turn challenge |
| `blinkProbabilityThreshold` | `0.85` | ML Kit eye-open probability cutoff |
| `antiSpoofThreshold` | `0.70` | TFLite live-score minimum |
| `stepHoldDurationMs` | `800` | ms a step must be held before advancing |
| `frameProcessingInterval` | `2` | Process every Nth camera frame |
| `lowLightLuxThreshold` | `30.0` | Lux proxy below which warning shows |

---

## 🎨 UI/UX Features

| Feature | Implementation |
|---------|---------------|
| Animated oval guide | `FaceOvalPainter` (CustomPainter) |
| Glow rings | `maskFilter: MaskFilter.blur` |
| Progress arc | `Canvas.drawArc` with step fraction |
| Rotating scan rings | `ScanRing` widget + AnimationController |
| IR dot grid | `FaceDotGridPainter` (CustomPainter) |
| Floating particles | `ParticlesBackground` (CustomPainter) |
| Step progress dots | `StepProgressDots` with AnimatedContainer |
| Head-turn arrows | `FaceGuidanceArrows` with flutter_animate |
| Instruction cross-fade | `AnimatedSwitcher` + slide transition |
| Low-light warning | `LowLightWarning` animated banner |
| Success overlay | Scale + glow + checkmark animation |

---

## 🧠 ML Pipeline

```
Camera Frame (YUV420 / BGRA8888)
        │
        ▼
  ImageUtils.cameraImageToInputImage()
        │
        ▼
  ML Kit FaceDetector (on-device)
  ┌─────────────────────────────┐
  │  • Face bounding box        │
  │  • Head euler angles XYZ    │
  │  • Eye open probabilities   │
  │  • Smile probability        │
  │  • Face tracking ID         │
  └─────────────────────────────┘
        │
        ├── Every 15 frames ──▶  TFLite AntiSpoofModel
        │                        [1,128,128,3] → [1,2]
        │                        live_score = output[0][1]
        ▼
  FaceAnalysisResult (domain entity)
        │
        ▼
  LivenessNotifier._evaluateStep()
        │
        ▼
  LivenessState (Riverpod StateNotifier)
        │
        ▼
  UI rebuild (all layers)
```

### Challenge Sequence

```
faceDetected → faceAligned → blinkDetected → turnLeft → turnRight → lookStraight → complete
```

Each step must be satisfied continuously for `stepHoldDurationMs` (800 ms) before advancing.

---

## ⚡ Performance Optimisation

### Frame Rate
- `ResolutionPreset.medium` (720p) — best quality/CPU tradeoff
- Process every **2nd** frame (`frameProcessingInterval = 2`)
- Anti-spoof runs every **15th** frame (heavy model)
- Guard flag `_isProcessing` prevents frame queue buildup

### Memory
- `ImageFormatGroup.yuv420` on Android (efficient for ML Kit NV21)
- `ImageFormatGroup.bgra8888` on iOS (native format, no copy needed)
- `enableContours: false` on FaceDetector (saves ~30% ML Kit CPU)
- ABI splits in `build.gradle` → smaller APK per device

### Rendering
- All painters use `shouldRepaint()` guards
- `IgnorePointer` on decorative layers prevents hit-testing overhead
- `AnimatedBuilder` scoped to only what changes (not full tree rebuild)

### Battery
- `_sessionActive` flag immediately stops processing when session ends
- Camera stream stopped as soon as all challenges pass

---

## 🧪 Testing

### Unit Tests
```bash
flutter test test/unit/
```

### Integration Test (real device required for camera)
```bash
flutter test integration_test/liveness_integration_test.dart
```

### Manual Test Checklist
- [ ] Camera permission granted
- [ ] Camera permission denied → dialog shown
- [ ] Face too far → "Move closer" instruction
- [ ] Face too close → "Move further away" instruction
- [ ] Multiple faces → warning shown
- [ ] Low light (cover flash) → warning shown
- [ ] Blink challenge passes on genuine blink
- [ ] Left / right turn challenges advance correctly
- [ ] Anti-spoof blocks a photo held to camera
- [ ] Success screen shows after all challenges pass
- [ ] Result screen shows captured image + checks
- [ ] Try Again resets and restarts correctly

---

## 🔒 Security Considerations

1. **On-device only** — No biometric data is transmitted over the network.
2. **Anti-spoof model** — Defends against printed photos and screen replays.
3. **Multiple face guard** — Prevents a second person passing challenges.
4. **Step randomisation** (optional enhancement) — Randomise challenge order per session.
5. **Max retry limit** (optional) — Lock the session after N failed attempts.
6. **Certificate pinning** (optional) — If your backend verifies the final token.

---

## 📦 Key Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `camera` | ^0.10.5+9 | Real-time camera preview & capture |
| `google_mlkit_face_detection` | ^0.11.0 | On-device face landmarks & pose |
| `tflite_flutter` | ^0.10.4 | TFLite runtime for anti-spoof model |
| `flutter_riverpod` | ^2.5.1 | Reactive state management |
| `flutter_animate` | ^4.5.0 | Declarative animation chaining |
| `permission_handler` | ^11.3.1 | Camera permission management |
| `dartz` | ^0.10.1 | Functional Either error handling |

---

## 📄 License

MIT © 2024 — Free to use for commercial and non-commercial KYC integrations.
