import 'dart:math';

/// PseudonymService
/// - Hastalar için kalıcı, anonim takma ad üretir.
/// - Aynı id için her zaman aynı nick döner (deterministik).
/// - Hasta arayüzlerinde gösterilmez; sadece klinik ekip, rapor/anonim paylaşımlarda kullanır.
class PseudonymService {
  static const List<String> _adjectives = [
    'Mor', 'Sakin', 'Hızlı', 'Zeki', 'Neşeli', 'Derin', 'Parlak', 'Sessiz', 'Güçlü', 'Nazik'
  ];
  static const List<String> _animals = [
    'Serçe', 'Kartal', 'Panda', 'Yunus', 'Kaplan', 'Koala', 'Ceylan', 'Kırlangıç', 'KutupAyısı', 'Zürafa'
  ];

  /// id (örn. hasta uuid) ve opsiyonel salt ile deterministik takma ad üretir.
  static String generate(String id, {String salt = 'psyclinic'}) {
    final hash = _stringHash(id + ':' + salt);
    final adj = _adjectives[hash % _adjectives.length];
    final animal = _animals[(hash ~/ 7) % _animals.length];
    final num = 10 + (hash % 90); // 10-99
    return adj + animal + num.toString();
  }

  static int _stringHash(String s) {
    int h = 0;
    for (int i = 0; i < s.length; i++) {
      h = 0x1fffffff & (h + s.codeUnitAt(i));
      h = 0x1fffffff & (h + ((0x0007ffff & h) << 10));
      h ^= (h >> 6);
    }
    h = 0x1fffffff & (h + ((0x03ffffff & h) << 3));
    h ^= (h >> 11);
    h = 0x1fffffff & (h + ((0x00003fff & h) << 15));
    return h.abs();
  }
}



