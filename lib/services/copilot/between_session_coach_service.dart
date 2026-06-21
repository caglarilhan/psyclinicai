/// Between-Session AI Coach service (audit 2026-06-21, Winner
/// Portfolio bet F-1).
///
/// Drives a `CoachConversation` against the LLM relay, with:
///   - **Modality awareness:** the system prompt is built from the
///     conversation's `modality` so the coach asks CBT thought-record
///     questions for a CBT patient and IFS parts-mapping questions for
///     an IFS patient — never a generic chatbot reply.
///   - **Clinician-in-the-loop:** every patient turn is screened by
///     `RiskSignalService.scanSegment` (the multilingual lexicon
///     shipped in Sprint 1) before the assistant reply is requested.
///     Any high-severity hit triggers [CoachEscalationHook] which the
///     UI uses to (a) freeze the patient flow, (b) surface the safety
///     plan + crisis number, (c) alert the on-call clinician.
///   - **PHI off-device:** all egress goes through `CopilotEndpoint`
///     so the server-side consent gate + PHI scrub (KRİTİK-1 / -2 /
///     -4) apply automatically — the coach never reaches Anthropic
///     directly from the browser.
///
/// This scaffold ships the interface + escalation pipeline +
/// system-prompt builder + tests. The HTTP call site is intentionally
/// left as a pluggable `relayInvoke` — wiring it to the real relay
/// lands with F-1's UI surface in M4/M5 so we don't ship a half-
/// implemented chat panel.
library;

import 'dart:async';

import '../../models/coach_conversation.dart';
import 'risk_signal_service.dart';

/// Fires when the risk lexicon flags a patient turn. UI subscribes to
/// this hook to freeze the input field + surface the safety plan +
/// page the on-call clinician.
typedef CoachEscalationHook = FutureOr<void> Function(
  CoachConversation conversation,
  CoachMessage triggeringMessage,
  List<RiskSignal> signals,
);

/// Outcome of [BetweenSessionCoachService.send]. `escalated: true`
/// means the assistant reply was NOT requested — the patient hit a
/// risk threshold and the UI must run its crisis flow before any
/// further model turn.
class CoachReply {
  const CoachReply({
    required this.conversation,
    required this.escalated,
    this.assistantTurn,
    this.signals = const [],
  });

  /// The full conversation after the patient turn (and the assistant
  /// turn when not escalated) is appended.
  final CoachConversation conversation;

  /// True when the patient turn tripped the risk lexicon and no
  /// assistant reply was produced.
  final bool escalated;

  /// Assistant turn appended when [escalated] is false. Null when
  /// escalated or when the relay returned an empty body.
  final CoachMessage? assistantTurn;

  /// Risk signals the lexicon surfaced on the patient turn. Empty
  /// when no signal fired.
  final List<RiskSignal> signals;
}

class BetweenSessionCoachService {
  BetweenSessionCoachService({
    required this.risk,
    CoachEscalationHook? escalationHook,
    Future<String> Function(String systemPrompt, List<CoachMessage> messages)?
        relayInvoke,
  })  : _escalationHook = escalationHook,
        _relayInvoke = relayInvoke;

  final RiskSignalService risk;
  final CoachEscalationHook? _escalationHook;

  /// Pluggable relay invoker so the test suite + UI scaffold can run
  /// without booting an HTTP client. M4 wires the real
  /// `CopilotEndpoint` path here.
  final Future<String> Function(
    String systemPrompt,
    List<CoachMessage> messages,
  )? _relayInvoke;

  /// Append the patient's [patientText] to [conversation] and return
  /// either an escalated outcome (no assistant turn) or a fresh
  /// assistant reply produced by the relay.
  ///
  /// Patient text is scanned with `risk.scanSegment` BEFORE the
  /// model call — a high-severity hit short-circuits the request so
  /// the model never sees the unsafe turn out of context (the safety
  /// plan + clinician handoff are the right primary response).
  Future<CoachReply> send({
    required CoachConversation conversation,
    required String patientText,
    required String patientMessageId,
    DateTime? at,
  }) async {
    final ts = at ?? DateTime.now();

    final signals = risk.scanSegment(patientText);
    final triggered = signals.any((s) => s.severity == RiskSeverity.high);

    final patientTurn = CoachMessage(
      id: patientMessageId,
      role: CoachRole.user,
      text: patientText,
      at: ts,
      riskFlagged: triggered,
      modality: conversation.modality,
    );
    final withPatient = conversation.append(patientTurn);

    if (triggered) {
      // Crisis pipeline — fire the hook (UI freezes + on-call alert)
      // and return without invoking the model. The assistant reply is
      // intentionally absent; the safety plan IS the response.
      if (_escalationHook != null) {
        await _escalationHook(withPatient, patientTurn, signals);
      }
      return CoachReply(
        conversation: withPatient,
        escalated: true,
        signals: signals,
      );
    }

    if (_relayInvoke == null) {
      // Scaffold mode — no relay wired yet. Return the conversation
      // with the patient turn appended so the UI can persist it; the
      // assistant reply lands when M4 wires the real invoker.
      return CoachReply(
        conversation: withPatient,
        escalated: false,
        signals: signals,
      );
    }

    final systemPrompt = buildSystemPrompt(
      modality: conversation.modality,
      treatmentPlanId: conversation.treatmentPlanId,
    );
    final body = await _relayInvoke(systemPrompt, withPatient.messages);
    final assistantTurn = CoachMessage(
      id: '$patientMessageId-reply',
      role: CoachRole.assistant,
      text: body,
      at: DateTime.now(),
      modality: conversation.modality,
    );
    final withAssistant = withPatient.append(assistantTurn);
    return CoachReply(
      conversation: withAssistant,
      escalated: false,
      assistantTurn: assistantTurn,
      signals: signals,
    );
  }

  /// Build the modality-specific system prompt. Pure function so the
  /// fidelity-scoring path (Winner Portfolio A4) can reuse the exact
  /// directive that drove a given conversation.
  static String buildSystemPrompt({
    required String modality,
    required String treatmentPlanId,
  }) {
    final directive = _modalityDirective(modality);
    return [
      'You are a between-session AI coach for a patient receiving '
          '$modality-informed psychotherapy. The treatment plan is '
          'identified by `$treatmentPlanId` and the licensed clinician '
          'reads every turn you produce.',
      directive,
      'Never present yourself as a replacement therapist. Use the '
          "patient's first name when known; otherwise neutral address. "
          'Decline politely if asked to diagnose, prescribe, or comment '
          'on medication — defer to the clinician.',
      'If the patient describes acute risk to self or others, respond '
          'with the safety plan, surface the regional crisis number, '
          'and tell them the on-call clinician has been alerted. Then '
          'stop — do not extend the conversation past that turn.',
    ].join('\n\n');
  }

  static String _modalityDirective(String modality) {
    switch (modality.toLowerCase()) {
      case 'cbt':
        return 'Guide the patient through a structured CBT thought '
            'record: trigger, automatic thought, evidence for, evidence '
            'against, balanced thought, mood shift. One question at a time.';
      case 'dbt':
        return 'Coach DBT diary-card entries (emotion intensity, urges, '
            'skills used). Reinforce skill practice; never debate the '
            'skill set.';
      case 'ifs':
        return 'Help the patient identify the part speaking right now '
            '(role, age, intent). Stay curious, never collapse parts '
            'into a single self.';
      case 'act':
        return 'Anchor responses in values + committed action. Notice '
            'fusion with thoughts; offer defusion exercises.';
      case 'emdr':
        return 'Patient is between EMDR sessions. Do NOT prompt target-'
            'memory recall — only support resourcing exercises (safe '
            'place, container, light stream) and grounding skills.';
      case 'schema':
        return 'Recognise active schema modes (vulnerable child, punitive '
            'parent, healthy adult). Coach from the healthy-adult voice.';
      case 'psychodynamic':
        return 'Reflect themes + transference cues back gently. Avoid '
            'directive technique; surface patterns for the next session.';
      case 'mi':
        return 'Motivational-interviewing stance: open questions, '
            'affirmations, reflections, summaries. Roll with resistance.';
      default:
        return 'No modality-specific protocol is configured for this '
            'conversation. Stay supportive, validate, and remind the '
            'patient when their next session is.';
    }
  }
}
