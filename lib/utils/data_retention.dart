import 'dart:convert';

class DataRetentionPolicy {
  final Duration retentionPeriod; // e.g., Duration(days: 365*5)
  final bool allowAnonymization;

  const DataRetentionPolicy({required this.retentionPeriod, this.allowAnonymization = true});
}

class DataAnonymizer {
  static String anonymizeName(String name) {
    if (name.isEmpty) return name;
    final parts = name.split(' ');
    return parts.map((p) => p.isEmpty ? '' : p[0] + '***').join(' ');
  }

  static String anonymizeIdentifier(String id) {
    if (id.length <= 4) return '****';
    return '****' + id.substring(id.length - 4);
  }

  static String redactJson(String jsonStr, {List<String> keysToRedact = const ['name','email','phone']}) {
    try {
      final m = json.decode(jsonStr) as Map<String, dynamic>;
      for (final k in keysToRedact) {
        if (m.containsKey(k)) m[k] = 'REDACTED';
      }
      return json.encode(m);
    } catch (_) {
      return jsonStr;
    }
  }
}


