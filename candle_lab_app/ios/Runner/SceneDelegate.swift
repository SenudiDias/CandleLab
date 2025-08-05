import UIKit
import Flutter

@objc class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var flutterEngine: FlutterEngine?

    func scene(_ scene: UIScene, 
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        flutterEngine = FlutterEngine(name: "io.flutter", project: nil)
        flutterEngine?.run()
        
        if let flutterEngine = flutterEngine {
            GeneratedPluginRegistrant.register(with: flutterEngine)
        }
        
        let controller = FlutterViewController(engine: flutterEngine!, nibName: nil, bundle: nil)
        window?.rootViewController = controller
        window?.makeKeyAndVisible()
    }
}