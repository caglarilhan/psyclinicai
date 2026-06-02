import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/inbox_item.dart';

void main() {
  final base = InboxItem(
    id: 'i-1',
    kind: InboxItemKind.patientMessage,
    fromUid: 'p-1',
    subject: 'Question about meds',
    bodyPreview: 'Should I take my morning dose with food?',
    receivedAt: DateTime.utc(2026, 6, 2, 10),
    subjectPatientId: 'p-1',
    dueAt: DateTime.utc(2026, 6, 2, 14),
  );

  group('InboxItemKind', () {
    test('fromId fallback is team_note (least-privilege default)', () {
      expect(InboxItemKind.fromId('mystery'), InboxItemKind.teamNote);
      expect(InboxItemKind.fromId('patient_message'),
          InboxItemKind.patientMessage);
    });
  });

  group('InboxItem', () {
    test('unread until markRead', () {
      expect(base.unread, isTrue);
      final read = base.markRead(DateTime.utc(2026, 6, 2, 12));
      expect(read.unread, isFalse);
      expect(read.readAt, DateTime.utc(2026, 6, 2, 12));
    });

    test('isOverdue true when dueAt passed and still unread', () {
      expect(base.isOverdue(at: DateTime.utc(2026, 6, 2, 15)), isTrue);
      final read = base.markRead(DateTime.utc(2026, 6, 2, 13));
      expect(read.isOverdue(at: DateTime.utc(2026, 6, 2, 15)), isFalse);
    });

    test('JSON round-trip preserves all fields', () {
      final restored = InboxItem.fromJson(base.toJson());
      expect(restored.id, base.id);
      expect(restored.kind, base.kind);
      expect(restored.bodyPreview, base.bodyPreview);
      expect(restored.dueAt, base.dueAt);
    });
  });
}
