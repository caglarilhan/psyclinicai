//
//  SessionActivityChannel.swift
//  Bridge from Flutter MethodChannel `psyclinicai/live_activity` to
//  ActivityKit's SessionLiveActivity.
//
//  Payload shape (all PHI-safe — patient name never crosses):
//    start    : { sessionTitle, modality, clinician, elapsedSeconds,
//                  isRecording, nextStepLabel? } → activityId:String
//    update   : { activityId, elapsedSeconds, isRecording, nextStepLabel? }
//    end      : { activityId }
//

import ActivityKit
import Flutter
import Foundation

@available(iOS 16.2, *)
public final class SessionActivityChannel: NSObject {
  private static let channelName = "psyclinicai/live_activity"
  private var activities: [String: Activity<SessionAttributes>] = [:]

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: channelName,
      binaryMessenger: registrar.messenger()
    )
    let instance = SessionActivityChannel()
    channel.setMethodCallHandler(instance.handle)
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any] else {
      result(FlutterError(code: "bad_args", message: "Map expected", details: nil))
      return
    }
    switch call.method {
    case "start": startActivity(args: args, result: result)
    case "update": updateActivity(args: args, result: result)
    case "end": endActivity(args: args, result: result)
    default: result(FlutterMethodNotImplemented)
    }
  }

  private func startActivity(args: [String: Any], result: @escaping FlutterResult) {
    guard ActivityAuthorizationInfo().areActivitiesEnabled else {
      result(FlutterError(code: "disabled",
        message: "Live Activities are not authorized on this device",
        details: nil))
      return
    }
    let attributes = SessionAttributes(
      clinicianDisplayName: (args["clinician"] as? String) ?? "Clinician",
      modality: (args["modality"] as? String) ?? "Session"
    )
    let content = SessionAttributes.SessionContentState(
      sessionTitle: (args["sessionTitle"] as? String) ?? "Session in progress",
      elapsedSeconds: (args["elapsedSeconds"] as? Int) ?? 0,
      isRecording: (args["isRecording"] as? Bool) ?? false,
      nextStepLabel: args["nextStepLabel"] as? String
    )
    do {
      let activity = try Activity.request(
        attributes: attributes,
        content: .init(state: content, staleDate: nil),
        pushType: nil
      )
      activities[activity.id] = activity
      result(activity.id)
    } catch {
      result(FlutterError(
        code: "start_failed",
        message: String(describing: error),
        details: nil
      ))
    }
  }

  private func updateActivity(args: [String: Any], result: @escaping FlutterResult) {
    guard
      let id = args["activityId"] as? String,
      let activity = activities[id]
    else {
      result(FlutterError(code: "unknown_activity", message: nil, details: nil))
      return
    }
    let next = SessionAttributes.SessionContentState(
      sessionTitle: (args["sessionTitle"] as? String)
        ?? activity.content.state.sessionTitle,
      elapsedSeconds: (args["elapsedSeconds"] as? Int)
        ?? activity.content.state.elapsedSeconds,
      isRecording: (args["isRecording"] as? Bool)
        ?? activity.content.state.isRecording,
      nextStepLabel: args["nextStepLabel"] as? String
    )
    Task {
      await activity.update(.init(state: next, staleDate: nil))
      result(true)
    }
  }

  private func endActivity(args: [String: Any], result: @escaping FlutterResult) {
    guard
      let id = args["activityId"] as? String,
      let activity = activities[id]
    else {
      result(false)
      return
    }
    Task {
      await activity.end(nil, dismissalPolicy: .immediate)
      activities.removeValue(forKey: id)
      result(true)
    }
  }
}
