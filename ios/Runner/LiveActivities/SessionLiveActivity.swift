//
//  SessionLiveActivity.swift
//  Lock-screen + Dynamic Island Live Activity for in-progress sessions.
//
//  ePHI is NEVER published — only an opaque session label and elapsed
//  timer. The Flutter side passes a sanitised `sessionTitle`
//  ("Session in progress · 14:00") and a derived `modality`
//  ("In-person" / "Telehealth"); the patient name is intentionally
//  omitted.
//
//  Activated via the Flutter MethodChannel
//  `psyclinicai/live_activity` — see SessionActivityChannel.swift.
//

import ActivityKit
import SwiftUI
import WidgetKit

@available(iOS 16.2, *)
public struct SessionAttributes: ActivityAttributes {
  public typealias ContentState = SessionContentState

  public struct SessionContentState: Codable, Hashable {
    public var sessionTitle: String
    public var elapsedSeconds: Int
    public var isRecording: Bool
    public var nextStepLabel: String?

    public init(
      sessionTitle: String,
      elapsedSeconds: Int,
      isRecording: Bool,
      nextStepLabel: String? = nil
    ) {
      self.sessionTitle = sessionTitle
      self.elapsedSeconds = elapsedSeconds
      self.isRecording = isRecording
      self.nextStepLabel = nextStepLabel
    }
  }

  public var clinicianDisplayName: String
  public var modality: String

  public init(clinicianDisplayName: String, modality: String) {
    self.clinicianDisplayName = clinicianDisplayName
    self.modality = modality
  }
}

@available(iOS 16.2, *)
struct SessionLiveActivity: Widget {
  var body: some WidgetConfiguration {
    ActivityConfiguration(for: SessionAttributes.self) { context in
      SessionLockScreenView(context: context)
        .padding(16)
        .activityBackgroundTint(Color(red: 0.043, green: 0.071, blue: 0.125))
        .activitySystemActionForegroundColor(Color.white)
    } dynamicIsland: { context in
      DynamicIsland {
        DynamicIslandExpandedRegion(.leading) {
          Text(context.attributes.modality)
            .font(.caption)
            .foregroundColor(.white.opacity(0.7))
        }
        DynamicIslandExpandedRegion(.trailing) {
          Text(formatElapsed(context.state.elapsedSeconds))
            .font(.system(.body, design: .monospaced))
            .foregroundColor(.white)
        }
        DynamicIslandExpandedRegion(.bottom) {
          Text(context.state.sessionTitle)
            .font(.subheadline)
            .foregroundColor(.white)
        }
      } compactLeading: {
        Image(systemName: context.state.isRecording ? "record.circle" : "circle")
          .foregroundColor(Color(red: 0.20, green: 0.83, blue: 0.60))
      } compactTrailing: {
        Text(formatElapsed(context.state.elapsedSeconds))
          .font(.system(.caption2, design: .monospaced))
      } minimal: {
        Image(systemName: "waveform")
          .foregroundColor(Color(red: 0.20, green: 0.83, blue: 0.60))
      }
    }
  }
}

@available(iOS 16.2, *)
struct SessionLockScreenView: View {
  let context: ActivityViewContext<SessionAttributes>

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Image(systemName: context.state.isRecording ? "record.circle.fill" : "circle")
          .foregroundColor(Color(red: 0.20, green: 0.83, blue: 0.60))
        Text(context.state.sessionTitle)
          .font(.headline)
          .foregroundColor(.white)
        Spacer()
        Text(formatElapsed(context.state.elapsedSeconds))
          .font(.system(.title3, design: .monospaced))
          .foregroundColor(.white)
      }
      if let next = context.state.nextStepLabel {
        Text(next)
          .font(.caption)
          .foregroundColor(.white.opacity(0.7))
      }
      Text("\(context.attributes.modality) · \(context.attributes.clinicianDisplayName)")
        .font(.caption2)
        .foregroundColor(.white.opacity(0.5))
    }
  }
}

private func formatElapsed(_ seconds: Int) -> String {
  let h = seconds / 3600
  let m = (seconds % 3600) / 60
  let s = seconds % 60
  if h > 0 {
    return String(format: "%d:%02d:%02d", h, m, s)
  }
  return String(format: "%02d:%02d", m, s)
}
