// Minimal geçici servis: UI bileşenlerinin derlenmesini sağlamak için basit mock.
class ConsentService {
  List<ConsentSummary> getActiveConsents(String scopeA, String scopeB) {
    return [
      ConsentSummary(
        patientId: 'PT-001',
        consentDate: DateTime.now().subtract(const Duration(days: 10)),
        isActive: true,
      ),
      ConsentSummary(
        patientId: 'PT-002',
        consentDate: DateTime.now().subtract(const Duration(days: 35)),
        isActive: true,
      ),
    ];
  }

  List<ConsentSummary> getExpiringConsents() {
    return [
      ConsentSummary(
        patientId: 'PT-003',
        consentDate: DateTime.now().subtract(const Duration(days: 350)),
        isActive: true,
      ),
    ];
  }

  Future<ComplianceReportLite> generateComplianceReport({required String region}) async {
    return ComplianceReportLite(
      complianceStatus: 'Compliant',
      generatedAt: DateTime.now(),
      recommendations: <String>[
        'Periyodik denetim kayıtlarını dışa aktarın',
        'Erişim kontrol politikalarını gözden geçirin',
      ],
    );
  }
}

class ConsentSummary {
  final String patientId;
  final DateTime consentDate;
  final bool isActive;

  ConsentSummary({required this.patientId, required this.consentDate, required this.isActive});
}

class ComplianceReportLite {
  final String complianceStatus;
  final DateTime generatedAt;
  final List<String> recommendations;

  ComplianceReportLite({
    required this.complianceStatus,
    required this.generatedAt,
    required this.recommendations,
  });
}
