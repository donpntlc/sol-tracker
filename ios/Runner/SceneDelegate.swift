import Flutter
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?
  private let engine = FlutterEngine(name: "sol")

  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    engine.run()
    GeneratedPluginRegistrant.register(with: engine)
    guard let windowScene = scene as? UIWindowScene else { return }
    let window = UIWindow(windowScene: windowScene)
    window.rootViewController = FlutterViewController(engine: engine, nibName: nil, bundle: nil)
    window.makeKeyAndVisible()
    self.window = window
  }
}
