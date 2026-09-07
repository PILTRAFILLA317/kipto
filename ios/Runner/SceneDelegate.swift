import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  private var privacyCover: UIView?
  override func sceneWillResignActive(_ scene: UIScene) {
    super.sceneWillResignActive(scene)
    guard let window else { return }
    let cover = UIView(frame: window.bounds)
    cover.backgroundColor = UIColor(red: 0.047, green: 0.047, blue: 0.063, alpha: 1)
    cover.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    cover.isAccessibilityElement = true
    cover.accessibilityLabel = "Kipto"
    window.addSubview(cover)
    privacyCover = cover
  }
  override func sceneDidBecomeActive(_ scene: UIScene) {
    super.sceneDidBecomeActive(scene)
    privacyCover?.removeFromSuperview()
    privacyCover = nil
  }
}
