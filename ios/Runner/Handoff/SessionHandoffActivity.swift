//
//  SessionHandoffActivity.swift
//  Apple Hand-off / NSUserActivity bridge for clinician multi-device
//  workflow (iPhone → iPad → Mac). Sprint 26 W2.
//
//  PHI policy: the activity's `userInfo` carries ONLY:
//    - `route`   : the in-app route string (e.g. "/session/active")
//    - `ctxHash` : a SHA-256 hash of the active session id, never
//                   the raw id or any clinical content.
//  Apple's Hand-off transport is encrypted device-to-device through
//  iCloud, but the activity title is rendered in the dock — keep it
//  generic so a passer-by cannot read patient identifiers.
//

import Flutter
import Foundation

public final class SessionHandoffActivity: NSObject {
  public static let activityType =
      "ai.psyclinic.session.continue"
  private static let channelName = "psyclinicai/handoff"

  private static var current: NSUserActivity?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: channelName,
      binaryMessenger: registrar.messenger()
    )
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "publish": publish(args: call.arguments, result: result)
      case "clear": clear(result: result)
      default: result(FlutterMethodNotImplemented)
      }
    }
  }

  /// Called from `AppDelegate.application(_:continue:restorationHandler:)`
  /// when iOS asks the app to continue an activity arriving from
  /// another device. Surfaces a route string back to Flutter so the
  /// router can `pushNamed` it.
  public static func handleContinuation(
    _ userActivity: NSUserActivity,
    channel: FlutterMethodChannel
  ) -> Bool {
    guard userActivity.activityType == activityType else { return false }
    guard
      let info = userActivity.userInfo,
      let route = info["route"] as? String,
      route.hasPrefix("/")
    else {
      return false
    }
    channel.invokeMethod("onContinuation", arguments: [
      "route": route,
      "ctxHash": (info["ctxHash"] as? String) ?? "",
    ])
    return true
  }

  private static func publish(args: Any?, result: @escaping FlutterResult) {
    guard
      let dict = args as? [String: Any],
      let route = dict["route"] as? String,
      route.hasPrefix("/")
    else {
      result(FlutterError(code: "bad_args",
                          message: "route required",
                          details: nil))
      return
    }
    let title = (dict["title"] as? String) ?? "Continue session"
    let ctxHash = (dict["ctxHash"] as? String) ?? ""
    let activity = NSUserActivity(activityType: activityType)
    activity.title = title
    activity.isEligibleForHandoff = true
    activity.isEligibleForSearch = false
    activity.isEligibleForPublicIndexing = false
    activity.userInfo = ["route": route, "ctxHash": ctxHash]
    activity.becomeCurrent()
    current = activity
    result(true)
  }

  private static func clear(result: @escaping FlutterResult) {
    current?.invalidate()
    current = nil
    result(true)
  }
}
