import UIKit
import Flutter
import FirebaseCore

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Initialize Firebase first
        FirebaseApp.configure()
        
        // Initialize window if not present
        if window == nil {
            window = UIWindow(frame: UIScreen.main.bounds)
        }
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    // Scene delegate configuration
    override func application(_ application: UIApplication, 
                            configurationForConnecting connectingSceneSession: UISceneSession,
                            options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role
        )
    }
}