import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/finance_service.dart';
import 'package:psyclinicai/services/appointment_service.dart';
import 'package:psyclinicai/models/appointment_models.dart';

void main() {
  group('Appointment -> Finance automation', () {
    test('creates income transaction and invoice on completed appointment', () async {
      final finance = FinanceService();
      finance.initialize();

      final initialTxnCount = finance.getAllTransactions().length;
      final initialInvCount = finance.getAllInvoices().length;

      final appt = Appointment(
        id: 't_appt_1',
        title: 'Bireysel Seans - Test',
        description: 'Test randevusu',
        clientName: 'Test Kullanıcı',
        dateTime: DateTime.now().subtract(const Duration(hours: 2)),
        type: AppointmentType.individual,
        status: AppointmentStatus.confirmed,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        therapistId: 'therapist_test',
        duration: const Duration(minutes: 60),
      );

      final result = finance.createFromAppointment(appointment: appt);
      expect(result['transaction'], isNotNull);
      expect(result['invoice'], isNotNull);

      final txns = finance.getAllTransactions();
      final invs = finance.getAllInvoices();
      expect(txns.length, initialTxnCount + 1);
      expect(invs.length, initialInvCount + 1);

      final lastTxn = txns.last;
      final lastInv = invs.last;
      expect(lastTxn.amount, greaterThan(0));
      expect(lastInv.totalAmount, greaterThan(0));
    });
  });
}


