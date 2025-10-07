import '../utils/data_retention.dart';
import 'assessment_service.dart';
import 'consent_service.dart';

class DataGovernanceService {
  final DataRetentionPolicy policy;
  DataGovernanceService({required this.policy});

  Future<void> purgeClientEverywhere(String clientName) async {
    await AssessmentService().purgeClient(clientName);
    await ConsentService().purgeClient(clientName);
  }

  Future<void> anonymizeClientEverywhere(String clientName) async {
    final anonymized = DataAnonymizer.anonymizeName(clientName);
    await AssessmentService().anonymizeClient(clientName, anonymized);
    await ConsentService().anonymizeClient(clientName, anonymized);
  }
}


