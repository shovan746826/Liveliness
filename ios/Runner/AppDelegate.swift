import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)

        // Lock to portrait orientation
        UIDevice.current.setValue(
            UIInterfaceOrientation.portrait.rawValue,
            forKey: "orientation"
        )

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // Enforce portrait-only
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}
