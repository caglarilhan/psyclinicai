import 'package:flutter/foundation.dart';
import '../models/legal_policy_models.dart';
import '../utils/ai_logger.dart';

/// LegalPolicyService - ABD eyalet bazlı hukuk motoru
class LegalPolicyService extends ChangeNotifier {
  static final LegalPolicyService _instance = LegalPolicyService._internal();
  factory LegalPolicyService() => _instance;
  LegalPolicyService._internal();

  final AILogger _logger = AILogger();

  final Map<UsStateCode, StateLegalPolicy> _policies = {};

  List<StateLegalPolicy> get policies => _policies.values.toList(growable: false);

  Future<void> initialize() async {
    _logger.info('LegalPolicyService initializing...', context: 'LegalPolicyService');
    _loadMockPolicies();
    _logger.info('LegalPolicyService initialized', context: 'LegalPolicyService');
  }

  void _loadMockPolicies() {
    // CA örnek politikası
    final caPolicy = StateLegalPolicy(
      id: 'policy_ca_001',
      state: UsStateCode.ca,
      version: '1.0.0',
      updatedAt: DateTime.now(),
      rules: [
        LegalRule(
          id: 'ca_rule_critical_suicide',
          name: 'Kritik intihar riskinde bildirim ve güvenlik planı',
          priority: 100,
          allOf: const [
            PolicyCondition(key: 'risk_level', operator: 'eq', value: 'Kritik'),
          ],
          actions: const [
            PolicyAction(
              id: 'act_report',
              obligation: LegalObligationType.mandatoryReporting,
              severity: LegalActionSeverity.critical,
              title: 'Zorunlu Bildirim',
              description: 'Kritik intihar riskinde zorunlu bildirim sürecini başlat.',
              templateKey: 'mandatory_report',
            ),
            PolicyAction(
              id: 'act_safety_plan',
              obligation: LegalObligationType.safetyPlanRequired,
              severity: LegalActionSeverity.high,
              title: 'Güvenlik Planı',
              description: 'Kişiselleştirilmiş güvenlik planı oluştur.',
              templateKey: 'safety_plan',
            ),
          ],
        ),
        LegalRule(
          id: 'ca_rule_threat_others',
          name: 'Başkasına tehdit varsa duty to warn',
          priority: 90,
          allOf: const [
            PolicyCondition(key: 'threat_to_others', operator: 'eq', value: true),
          ],
          actions: const [
            PolicyAction(
              id: 'act_warn',
              obligation: LegalObligationType.dutyToWarn,
              severity: LegalActionSeverity.high,
              title: 'Duty to Warn',
              description: 'İlgili kişileri/otoriteleri uyar.',
              templateKey: 'duty_to_warn',
            ),
          ],
        ),
      ],
      notificationTemplates: const {
        'mandatory_report': 'CA Zorunlu Bildirim: Hasta: {{patientId}}, Risk: {{risk_level}}',
        'safety_plan': 'CA Güvenlik Planı gerekli: Hasta: {{patientId}}',
        'duty_to_warn': 'CA Duty to Warn: Tehdit bildirimi, Hasta: {{patientId}}',
      },
      metadata: const {},
    );

    // NY örnek politikası (farklı eşik/aksiyon örneği)
    final nyPolicy = StateLegalPolicy(
      id: 'policy_ny_001',
      state: UsStateCode.ny,
      version: '1.0.0',
      updatedAt: DateTime.now(),
      rules: [
        LegalRule(
          id: 'ny_rule_high_or_critical',
          name: 'Yüksek/Kritik riskte bildirim',
          priority: 100,
          allOf: const [
            PolicyCondition(key: 'risk_level', operator: 'in', value: ['Yüksek', 'Kritik']),
          ],
          actions: const [
            PolicyAction(
              id: 'act_report',
              obligation: LegalObligationType.mandatoryReporting,
              severity: LegalActionSeverity.high,
              title: 'Zorunlu Bildirim',
              description: 'Yüksek veya kritik risklerde zorunlu bildirim.',
              templateKey: 'mandatory_report',
            ),
          ],
        ),
      ],
      notificationTemplates: const {
        'mandatory_report': 'NY Zorunlu Bildirim: Hasta: {{patientId}}, Risk: {{risk_level}}',
      },
      metadata: const {},
    );

    _policies[UsStateCode.ca] = caPolicy;
    _policies[UsStateCode.ny] = nyPolicy;
  }

  StateLegalPolicy? getPolicy(UsStateCode state) => _policies[state];

  /// Basit policy değerlendirme motoru
  Future<LegalDecision> evaluate(LegalEvaluationContext ctx) async {
    final policy = _policies[ctx.state];
    if (policy == null) {
      return LegalDecision(state: ctx.state, requiredActions: const [], notifications: const [], reasoning: {
        'error': 'No policy for state',
      });
    }

    // Öncelik sıralı kuralları değerlendir
    final sorted = [...policy.rules]..sort((a, b) => b.priority.compareTo(a.priority));
    final matchedActions = <PolicyAction>[];
    final matchedRules = <String>[];

    for (final rule in sorted) {
      final ok = _conditionsSatisfied(rule.allOf, ctx.facts);
      if (ok) {
        matchedActions.addAll(rule.actions);
        matchedRules.add(rule.id);
      }
    }

    // Bildirimleri üret
    final notifications = <String>[];
    for (final action in matchedActions) {
      final tpl = policy.notificationTemplates[action.templateKey];
      if (tpl != null && tpl.isNotEmpty) {
        notifications.add(_renderTemplate(tpl, ctx.facts));
      }
    }

    return LegalDecision(
      state: ctx.state,
      requiredActions: matchedActions,
      notifications: notifications,
      reasoning: {
        'matchedRules': matchedRules,
        'facts': ctx.facts,
      },
    );
  }

  bool _conditionsSatisfied(List<PolicyCondition> conds, Map<String, dynamic> facts) {
    for (final c in conds) {
      final dynamic fact = facts[c.key];
      switch (c.operator) {
        case 'eq':
          if (fact != c.value) return false;
          break;
        case 'ne':
          if (fact == c.value) return false;
          break;
        case 'exists':
          if (!facts.containsKey(c.key)) return false;
          break;
        case 'in':
          if (c.value is List) {
            if (!(c.value as List).contains(fact)) return false;
          } else {
            return false;
          }
          break;
        case 'not_in':
          if (c.value is List) {
            if ((c.value as List).contains(fact)) return false;
          } else {
            return false;
          }
          break;
        case 'gte':
          if (fact is num && c.value is num) {
            if (fact < c.value) return false;
          } else {
            return false;
          }
          break;
        case 'lte':
          if (fact is num && c.value is num) {
            if (fact > c.value) return false;
          } else {
            return false;
          }
          break;
        default:
          return false;
      }
    }
    return true;
  }

  String _renderTemplate(String tpl, Map<String, dynamic> facts) {
    var out = tpl;
    facts.forEach((k, v) {
      out = out.replaceAll('{{$k}}', '$v');
    });
    return out;
  }
}
