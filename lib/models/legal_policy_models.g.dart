// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'legal_policy_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PolicyCondition _$PolicyConditionFromJson(Map<String, dynamic> json) =>
    PolicyCondition(
      key: json['key'] as String,
      operator: json['operator'] as String,
      value: json['value'],
    );

Map<String, dynamic> _$PolicyConditionToJson(PolicyCondition instance) =>
    <String, dynamic>{
      'key': instance.key,
      'operator': instance.operator,
      'value': instance.value,
    };

PolicyAction _$PolicyActionFromJson(Map<String, dynamic> json) => PolicyAction(
  id: json['id'] as String,
  obligation: $enumDecode(_$LegalObligationTypeEnumMap, json['obligation']),
  severity: $enumDecode(_$LegalActionSeverityEnumMap, json['severity']),
  title: json['title'] as String,
  description: json['description'] as String,
  templateKey: json['templateKey'] as String,
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$PolicyActionToJson(PolicyAction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'obligation': _$LegalObligationTypeEnumMap[instance.obligation]!,
      'severity': _$LegalActionSeverityEnumMap[instance.severity]!,
      'title': instance.title,
      'description': instance.description,
      'templateKey': instance.templateKey,
      'metadata': instance.metadata,
    };

const _$LegalObligationTypeEnumMap = {
  LegalObligationType.dutyToWarn: 'duty_to_warn',
  LegalObligationType.mandatoryReporting: 'mandatory_reporting',
  LegalObligationType.involuntaryHold: 'involuntary_hold',
  LegalObligationType.safetyPlanRequired: 'safety_plan_required',
};

const _$LegalActionSeverityEnumMap = {
  LegalActionSeverity.info: 'info',
  LegalActionSeverity.low: 'low',
  LegalActionSeverity.medium: 'medium',
  LegalActionSeverity.high: 'high',
  LegalActionSeverity.critical: 'critical',
};

LegalRule _$LegalRuleFromJson(Map<String, dynamic> json) => LegalRule(
  id: json['id'] as String,
  name: json['name'] as String,
  allOf: (json['allOf'] as List<dynamic>)
      .map((e) => PolicyCondition.fromJson(e as Map<String, dynamic>))
      .toList(),
  actions: (json['actions'] as List<dynamic>)
      .map((e) => PolicyAction.fromJson(e as Map<String, dynamic>))
      .toList(),
  priority: (json['priority'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$LegalRuleToJson(LegalRule instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'allOf': instance.allOf,
  'actions': instance.actions,
  'priority': instance.priority,
};

StateLegalPolicy _$StateLegalPolicyFromJson(Map<String, dynamic> json) =>
    StateLegalPolicy(
      id: json['id'] as String,
      state: $enumDecode(_$UsStateCodeEnumMap, json['state']),
      version: json['version'] as String,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      rules: (json['rules'] as List<dynamic>)
          .map((e) => LegalRule.fromJson(e as Map<String, dynamic>))
          .toList(),
      notificationTemplates: Map<String, String>.from(
        json['notificationTemplates'] as Map,
      ),
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$StateLegalPolicyToJson(StateLegalPolicy instance) =>
    <String, dynamic>{
      'id': instance.id,
      'state': _$UsStateCodeEnumMap[instance.state]!,
      'version': instance.version,
      'updatedAt': instance.updatedAt.toIso8601String(),
      'rules': instance.rules,
      'notificationTemplates': instance.notificationTemplates,
      'metadata': instance.metadata,
    };

const _$UsStateCodeEnumMap = {
  UsStateCode.ca: 'CA',
  UsStateCode.ny: 'NY',
  UsStateCode.tx: 'TX',
  UsStateCode.fl: 'FL',
  UsStateCode.il: 'IL',
};

LegalEvaluationContext _$LegalEvaluationContextFromJson(
  Map<String, dynamic> json,
) => LegalEvaluationContext(
  state: $enumDecode(_$UsStateCodeEnumMap, json['state']),
  facts: json['facts'] as Map<String, dynamic>,
);

Map<String, dynamic> _$LegalEvaluationContextToJson(
  LegalEvaluationContext instance,
) => <String, dynamic>{
  'state': _$UsStateCodeEnumMap[instance.state]!,
  'facts': instance.facts,
};

LegalDecision _$LegalDecisionFromJson(Map<String, dynamic> json) =>
    LegalDecision(
      state: $enumDecode(_$UsStateCodeEnumMap, json['state']),
      requiredActions: (json['requiredActions'] as List<dynamic>)
          .map((e) => PolicyAction.fromJson(e as Map<String, dynamic>))
          .toList(),
      notifications: (json['notifications'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      reasoning: json['reasoning'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$LegalDecisionToJson(LegalDecision instance) =>
    <String, dynamic>{
      'state': _$UsStateCodeEnumMap[instance.state]!,
      'requiredActions': instance.requiredActions,
      'notifications': instance.notifications,
      'reasoning': instance.reasoning,
    };
