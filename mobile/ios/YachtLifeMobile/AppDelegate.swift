import UIKit
import React_RCTAppDelegate
import React

@main
class AppDelegate: RCTAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    self.moduleName = "YachtLifeMobile"
    self.initialProps = [:]

#if DEBUG
    // Set Metro host explicitly
    RCTBundleURLProvider.sharedSettings().jsLocation = "localhost"
#endif

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func sourceURL(for bridge: RCTBridge!) -> URL! {
#if DEBUG
    let url = URL(string: "http://localhost:8081/index.bundle?platform=ios&dev=true&minify=false")
    print("📱 Bundle URL: \(String(describing: url))")
    return url
#else
    return Bundle.main.url(forResource: "main", withExtension: "jsbundle")
#endif
  }
}
