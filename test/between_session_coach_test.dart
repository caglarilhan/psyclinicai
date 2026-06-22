import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/coach_conversation.dart';
import 'package:psyclinicai/services/copilot/between_session_coach_service.dart';
import 'package:psyclinicai/services/copilot/risk_signal_service.dart';

CoachConversation _seed({String modality = 'cbt'}) {
  return CoachConversation(
    id: 'conv-1',
    patientId: 'p-1',
    clinicianId: 'u-1',
    treatmentPlanId: 'plan-1',
    modality: modality,
  );
}

void main() {
  group('CoachConversation model', () {
    test('append preserves immutability + returns a new instance', () {
      final c0 = _seed();
      expect(c0.messages, isEmpty);
      final c1 = c0.append(
        CoachMessage(
          id: 'm1',
          role: CoachRole.user,
          text: 'hello',
          at: DateTime.utc(2026, 6, 21, 9),
        ),
      );
      expect(c0.messages, isEmpty); // original untouched
      expect(c1.messages, hasLength(1));
      expect(c1.id, c0.id);
    });

    test('hasRiskFlag is true when any turn is flagged', () {
      final c = _seed().append(
        CoachMessage(
          id: 'm1',
          role: CoachRole.user,
          text: 'I want to die',
          at: DateTime.utc(2026, 6, 21),
          riskFlagged: true,
        ),
      );
      expect(c.hasRiskFlag, isTrue);
    });

    test('lastTurn skips system priming', () {
      final c = _seed().append(
        CoachMessage(
          id: 'sys',
          role: CoachRole.system,
          text: 'priming',
          at: DateTime.utc(2026, 6, 21, 9),
        ),
      );
      expect(c.lastTurn, isNull);
      final c2 = c.append(
        CoachMessage(
          id: 'u1',
          role: CoachRole.user,
          text: 'hi',
          at: DateTime.utc(2026, 6, 21, 10),
        ),
      );
      expect(c2.lastTurn?.id, 'u1');
    });

    test('JSON round-trip preserves every field', () {
      final c = _seed().append(
        CoachMessage(
          id: 'm1',
          role: CoachRole.assistant,
          text: 'breath',
          at: DateTime.utc(2026, 6, 21, 9),
          modality: 'cbt',
        ),
      );
      final round = CoachConversation.fromJson(c.toJson());
      expect(round.id, 'conv-1');
      expect(round.patientId, 'p-1');
      expect(round.messages, hasLength(1));
      expect(round.messages.first.role, CoachRole.assistant);
      expect(round.messages.first.modality, 'cbt');
    });
  });

  group('CoachRole.fromWire', () {
    test('round-trips known values', () {
      for (final r in CoachRole.values) {
        expect(CoachRole.fromWire(r.wire), r);
      }
    });
    test('unknown wire defaults to user (least privilege)', () {
      expect(CoachRole.fromWire('root'), CoachRole.user);
      expect(CoachRole.fromWire(''), CoachRole.user);
    });
  });

  group('BetweenSessionCoachService.send', () {
    late RiskSignalService risk;
    setUp(() => risk = RiskSignalService());
    tearDown(() => risk.dispose());

    test(
      'benign turn appends user message + (no relay) no assistant',
      () async {
        final svc = BetweenSessionCoachService(risk: risk);
        final reply = await svc.send(
          conversation: _seed(),
          patientText: 'I had a good week and practiced the thought record.',
          patientMessageId: 'm1',
          at: DateTime.utc(2026, 6, 21, 9),
        );
        expect(reply.escalated, isFalse);
        expect(reply.signals, isEmpty);
        expect(reply.assistantTurn, isNull); // no relay wired
        expect(reply.conversation.messages, hasLength(1));
        expect(reply.conversation.messages.first.role, CoachRole.user);
      },
    );

    test(
      'SI lexicon hit escalates + fires the hook + skips the relay',
      () async {
        CoachMessage? trigger;
        List<RiskSignal>? captured;
        final svc = BetweenSessionCoachService(
          risk: risk,
          escalationHook: (conv, msg, sigs) {
            trigger = msg;
            captured = sigs;
          },
          relayInvoke: (sys, msgs) async => 'should-not-call',
        );
        final reply = await svc.send(
          conversation: _seed(),
          patientText: 'I want to die.',
          patientMessageId: 'm1',
          at: DateTime.utc(2026, 6, 21, 9),
        );
        expect(reply.escalated, isTrue);
        expect(reply.signals, isNotEmpty);
        expect(reply.assistantTurn, isNull);
        expect(reply.conversation.messages.first.riskFlagged, isTrue);
        expect(trigger?.id, 'm1');
        expect(
          captured?.any((s) => s.category == RiskCategory.suicidalIdeation),
          isTrue,
        );
      },
    );

    test('Turkish SI also escalates (multilingual lexicon)', () async {
      final svc = BetweenSessionCoachService(risk: risk);
      final reply = await svc.send(
        conversation: _seed(),
        patientText: 'Kendimi öldürmek istiyorum',
        patientMessageId: 'm1',
        at: DateTime.utc(2026, 6, 21, 9),
      );
      expect(reply.escalated, isTrue);
    });

    test('benign turn with relay wired produces an assistant turn', () async {
      String? capturedSystem;
      final svc = BetweenSessionCoachService(
        risk: risk,
        relayInvoke: (sys, msgs) async {
          capturedSystem = sys;
          return 'Try a thought record now.';
        },
      );
      final reply = await svc.send(
        conversation: _seed(),
        patientText: 'Anxious about a meeting tomorrow.',
        patientMessageId: 'm1',
        at: DateTime.utc(2026, 6, 21, 9),
      );
      expect(reply.escalated, isFalse);
      expect(reply.assistantTurn?.role, CoachRole.assistant);
      expect(reply.assistantTurn?.text, 'Try a thought record now.');
      expect(reply.conversation.messages, hasLength(2));
      expect(capturedSystem, contains('CBT thought record'));
    });
  });

  group('BetweenSessionCoachService.buildSystemPrompt', () {
    test('CBT modality directive references thought record', () {
      final p = BetweenSessionCoachService.buildSystemPrompt(
        modality: 'cbt',
        treatmentPlanId: 'plan-1',
      );
      expect(p, contains('CBT thought record'));
      expect(p, contains('plan-1'));
      expect(p, contains('Never present yourself as a replacement therapist'));
    });

    test('EMDR directive forbids target-memory recall', () {
      final p = BetweenSessionCoachService.buildSystemPrompt(
        modality: 'emdr',
        treatmentPlanId: 'plan-2',
      );
      expect(p, contains('Do NOT prompt target'));
      expect(p, contains('resourcing exercises'));
    });

    test('unknown modality falls back to a safe generic directive', () {
      final p = BetweenSessionCoachService.buildSystemPrompt(
        modality: 'mystery',
        treatmentPlanId: 'plan-3',
      );
      expect(p, contains('No modality-specific protocol is configured'));
    });

    test('every prompt carries the crisis instruction', () {
      for (final m in ['cbt', 'dbt', 'ifs', 'general']) {
        final p = BetweenSessionCoachService.buildSystemPrompt(
          modality: m,
          treatmentPlanId: 'plan',
        );
        expect(p, contains('regional crisis number'));
      }
    });
  });
}
