/// Email + SMS template + sequence builder substrate. Sprint 25 W2.
enum EmailTemplateKind {
  reminder72h('reminder_72h', 'Reminder · 72 hours before'),
  reminder24h('reminder_24h', 'Reminder · 24 hours before'),
  reminder2h('reminder_2h', 'Reminder · 2 hours before'),
  intakeLink('intake_link', 'Intake form invite'),
  noShowFollowUp('no_show_follow_up', 'No-show follow-up'),
  reviewRequest('review_request', 'Review request (post-session)'),
  birthday('birthday', 'Birthday note'),
  reactivation('reactivation', 'Reactivation (90-day dormant)');

  const EmailTemplateKind(this.id, this.label);
  final String id;
  final String label;

  static EmailTemplateKind fromId(String id) => values.firstWhere(
    (k) => k.id == id,
    orElse: () => EmailTemplateKind.reminder24h,
  );
}

const Set<String> kEmailTemplateTokens = {
  'patient_first_name',
  'patient_full_name',
  'session_date',
  'session_time',
  'session_link',
  'clinician_name',
  'clinic_name',
  'intake_link',
  'review_link',
  'reactivation_offer',
  'crisis_hotline_local',
  'safety_plan_link',
};

/// Per-kind narrowing on top of [kEmailTemplateTokens] — HIPAA
/// minimum-necessary. Non-clinical kinds (birthday, reactivation,
/// review_request) must NEVER mix `patient_full_name` with
/// `clinic_name` in a single envelope that may land in a shared inbox.
const Map<EmailTemplateKind, Set<String>> kPerKindTokenAllowList = {
  EmailTemplateKind.reminder72h: {
    'patient_first_name',
    'session_date',
    'session_time',
    'session_link',
    'clinician_name',
    'clinic_name',
  },
  EmailTemplateKind.reminder24h: {
    'patient_first_name',
    'session_date',
    'session_time',
    'session_link',
    'clinician_name',
    'clinic_name',
  },
  EmailTemplateKind.reminder2h: {
    'patient_first_name',
    'session_time',
    'session_link',
    'clinician_name',
  },
  EmailTemplateKind.intakeLink: {
    'patient_first_name',
    'intake_link',
    'clinician_name',
    'clinic_name',
  },
  EmailTemplateKind.noShowFollowUp: {
    'patient_first_name',
    'clinician_name',
    'crisis_hotline_local',
    'safety_plan_link',
  },
  EmailTemplateKind.reviewRequest: {'patient_first_name', 'review_link'},
  EmailTemplateKind.birthday: {'patient_first_name'},
  EmailTemplateKind.reactivation: {'patient_first_name', 'reactivation_offer'},
};

class EmailTemplate {
  EmailTemplate({
    required this.id,
    required this.kind,
    required this.subject,
    required this.bodyMarkdown,
    this.enabled = true,
    this.abVariantId,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now().toUtc();

  final String id;
  final EmailTemplateKind kind;
  final String subject;
  final String bodyMarkdown;
  final bool enabled;
  final String? abVariantId;
  final DateTime updatedAt;

  String render(Map<String, String> tokens) {
    final perKind = kPerKindTokenAllowList[kind] ?? kEmailTemplateTokens;
    return bodyMarkdown.replaceAllMapped(
      RegExp(r'\{\{\s*([a-zA-Z_]+)\s*\}\}'),
      (m) {
        final key = m.group(1)!;
        if (!kEmailTemplateTokens.contains(key)) {
          return '[unknown:$key]';
        }
        if (!perKind.contains(key)) {
          // Per-kind minimum-necessary — a clinical token slipping
          // into a birthday email is surfaced for QA, never silently
          // rendered.
          return '[blocked:$key]';
        }
        return tokens[key] ?? '';
      },
    );
  }

  EmailTemplate copyWith({
    String? subject,
    String? bodyMarkdown,
    bool? enabled,
    String? abVariantId,
    DateTime? updatedAt,
  }) => EmailTemplate(
    id: id,
    kind: kind,
    subject: subject ?? this.subject,
    bodyMarkdown: bodyMarkdown ?? this.bodyMarkdown,
    enabled: enabled ?? this.enabled,
    abVariantId: abVariantId ?? this.abVariantId,
    updatedAt: updatedAt ?? DateTime.now().toUtc(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'kind': kind.id,
    'subject': subject,
    'body_md': bodyMarkdown,
    'enabled': enabled,
    if (abVariantId != null) 'ab_variant_id': abVariantId,
    'updated_at': updatedAt.toIso8601String(),
  };

  factory EmailTemplate.fromJson(Map<String, dynamic> json) => EmailTemplate(
    id: json['id'] as String,
    kind: EmailTemplateKind.fromId(json['kind'] as String),
    subject: json['subject'] as String,
    bodyMarkdown: json['body_md'] as String,
    enabled: json['enabled'] as bool? ?? true,
    abVariantId: json['ab_variant_id'] as String?,
    updatedAt: DateTime.parse(json['updated_at'] as String),
  );
}

class EmailSequence {
  const EmailSequence({
    required this.id,
    required this.name,
    required this.steps,
    this.enabled = true,
  });

  final String id;
  final String name;
  final List<EmailSequenceStep> steps;
  final bool enabled;

  bool get isCanonicallyOrdered {
    for (var i = 1; i < steps.length; i++) {
      if (steps[i].offset < steps[i - 1].offset) return false;
    }
    return true;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'enabled': enabled,
    'steps': steps.map((s) => s.toJson()).toList(),
  };

  factory EmailSequence.fromJson(Map<String, dynamic> json) => EmailSequence(
    id: json['id'] as String,
    name: json['name'] as String,
    enabled: json['enabled'] as bool? ?? true,
    steps: (json['steps'] as List)
        .map((s) => EmailSequenceStep.fromJson(s as Map<String, dynamic>))
        .toList(),
  );
}

class EmailSequenceStep {
  const EmailSequenceStep({required this.kind, required this.offset});

  final Duration offset;
  final EmailTemplateKind kind;

  Map<String, dynamic> toJson() => {
    'offset_minutes': offset.inMinutes,
    'kind': kind.id,
  };

  factory EmailSequenceStep.fromJson(Map<String, dynamic> json) =>
      EmailSequenceStep(
        offset: Duration(minutes: json['offset_minutes'] as int),
        kind: EmailTemplateKind.fromId(json['kind'] as String),
      );
}
