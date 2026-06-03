import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var handoffChannel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    if #available(iOS 16.2, *) {
      if let registrar = self.registrar(forPlugin: "SessionLiveActivity") {
        SessionActivityChannel.register(with: registrar)
      }
    }

    if let registrar = self.registrar(forPlugin: "SessionHandoff") {
      SessionHandoffActivity.register(with: registrar)
      handoffChannel = FlutterMethodChannel(
        name: "psyclinicai/handoff",
        binaryMessenger: registrar.messenger()
      )
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(
    _ application: UIApplication,
    continue userActivity: NSUserActivity,
    restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
  ) -> Bool {
    if let channel = handoffChannel,
       SessionHandoffActivity.handleContinuation(userActivity,
                                                  channel: channel) {
      return true
    }
    return super.application(application,
                             continue: userActivity,
                             restorationHandler: restorationHandler)
  }
}
