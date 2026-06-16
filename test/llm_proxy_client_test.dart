import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/ai/llm_proxy_client.dart';

void main() {
  group('LlmModel', () {
    test('fromId falls back to sonnet46 for unknown ids', () {
      expect(LlmModel.fromId('mystery'), LlmModel.sonnet46);
      expect(LlmModel.fromId('claude-opus-4-7'), LlmModel.opus47);
    });

    test('cost ramps from haiku to opus', () {
      expect(LlmModel.haiku45.usdPer5Min,
          lessThan(LlmModel.sonnet46.usdPer5Min));
      expect(LlmModel.sonnet46.usdPer5Min,
          lessThan(LlmModel.opus47.usdPer5Min));
    });
  });

  group('LlmRequest.redacted', () {
    test('strips email + phone + name before egress', () {
      final req = LlmRequest(
        tenantId: 't-1',
        model: LlmModel.sonnet46,
        prompt: 'John Demo (jane@example.com, +905551112233) reports …',
        patientNames: const ['John Demo'],
      );
      final scrubbed = req.redacted();
      expect(scrubbed.prompt, contains('[EMAIL]'));
      expect(scrubbed.prompt, contains('[PHONE]'));
      expect(scrubbed.prompt, contains('[NAME]'));
      expect(scrubbed.prompt, isNot(contains('John Demo')));
    });
  });

  group('LlmProxyClientStub', () {
    test('default stub returns deterministic completion + cost', () async {
      final c = await LlmProxyClientStub().complete(
        request: const LlmRequest(
          tenantId: 't-1',
          model: LlmModel.sonnet46,
          prompt: 'hi',
        ),
      );
      expect(c.model, LlmModel.sonnet46);
      expect(c.tenantUsdCost, LlmModel.sonnet46.usdPer5Min);
      expect(c.text, contains('Stub response'));
    });

    test('responder seam returns structured tool-use payload', () async {
      final client = LlmProxyClientStub(
        responder: (req) => LlmCompletion(
          text: '',
          model: req.model,
          inputTokens: 10,
          outputTokens: 20,
          tenantUsdCost: req.model.usdPer5Min,
          toolUse: const {
            'name': 'differential_candidate',
            'candidates': [
              {'code': 'F32.1', 'confidence': 0.72},
            ],
          },
        ),
      );
      final c = await client.complete(
        request: const LlmRequest(
          tenantId: 't-1',
          model: LlmModel.opus47,
          prompt: '...',
        ),
      );
      expect(c.toolUse, isNotNull);
      expect(c.toolUse!['candidates'], isA<List<dynamic>>());
    });
  });
}
