import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/utils/pii_redaction.dart';

void main() {
  group('redactEmail', () {
    test('masks the local part, keeps the first letter + domain', () {
      expect(redactEmail('jane.doe@example.com'), 'j***@example.com');
    });

    test('returns null when input is null', () {
      expect(redactEmail(null), isNull);
    });

    test('leaves non-email strings untouched', () {
      expect(redactEmail('service-bot'), 'service-bot');
      expect(redactEmail(''), '');
    });

    test('preserves the full domain, including a subdomain', () {
      expect(
        redactEmail('jane@mail.eu.example.com'),
        'j***@mail.eu.example.com',
      );
    });

    test('one-character local parts pass through (nothing to mask)', () {
      // local = "a" → leaving as-is is acceptable; we only redact
      // when there is more than one local character.
      expect(redactEmail('a@example.com'), 'a@example.com');
    });
  });

  group('redactIpv4', () {
    test('masks the last two octets of dotted-quad IPv4', () {
      expect(redactIpv4('92.184.10.20'), '92.184.··.··');
    });

    test('returns null when input is null', () {
      expect(redactIpv4(null), isNull);
    });

    test('returns empty string unchanged', () {
      expect(redactIpv4(''), '');
    });

    test('passes through non-IPv4 shapes untouched', () {
      expect(redactIpv4('::1'), '::1');
      expect(redactIpv4('not-an-ip'), 'not-an-ip');
    });
  });

  group('truncateForExport', () {
    test('shorter than the cap passes through', () {
      expect(truncateForExport('hello'), 'hello');
    });

    test('longer than the cap gets an ellipsis tail', () {
      final out = truncateForExport('x' * 40, maxChars: 10);
      expect(out.length, 11); // 10 chars + ellipsis
      expect(out.endsWith('…'), isTrue);
    });
  });
}
