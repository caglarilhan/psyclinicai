import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart';

class KeyboardShortcutsService extends ChangeNotifier {
  static final KeyboardShortcutsService _instance = KeyboardShortcutsService._internal();
  factory KeyboardShortcutsService() => _instance;
  KeyboardShortcutsService._internal();

  // Kısayol tanımları
  static const Map<String, String> shortcuts = {
    'Ctrl+N': 'Yeni Danışan',
    'Ctrl+S': 'Kaydet',
    'Ctrl+Z': 'Geri Al',
    'Ctrl+Y': 'Yinele',
    'Ctrl+F': 'Ara',
    'Ctrl+A': 'Tümünü Seç',
    'Ctrl+C': 'Kopyala',
    'Ctrl+V': 'Yapıştır',
    'Ctrl+X': 'Kes',
    'Ctrl+P': 'Yazdır',
    'Ctrl+E': 'Düzenle',
    'Ctrl+D': 'Sil',
    'Ctrl+R': 'Yenile',
    'Ctrl+T': 'Yeni Sekme',
    'Ctrl+W': 'Sekmeyi Kapat',
    'Ctrl+Tab': 'Sekme Değiştir',
    'Ctrl+Shift+Tab': 'Önceki Sekme',
    'F1': 'Yardım',
    'F2': 'Yeniden Adlandır',
    'F5': 'Yenile',
    'F11': 'Tam Ekran',
    'Esc': 'İptal',
    'Enter': 'Onayla',
    'Space': 'Seç/Toggle',
    'Tab': 'Sonraki Alan',
    'Shift+Tab': 'Önceki Alan',
    'Arrow Up': 'Yukarı',
    'Arrow Down': 'Aşağı',
    'Arrow Left': 'Sol',
    'Arrow Right': 'Sağ',
    'Home': 'Başa Git',
    'End': 'Sona Git',
    'Page Up': 'Sayfa Yukarı',
    'Page Down': 'Sayfa Aşağı',
  };

  // Kısayol işleyicileri
  final Map<LogicalKeySet, VoidCallback> _handlers = {};
  bool _isInitialized = false;

  // Servis başlatma
  void initialize() {
    if (_isInitialized) return;
    _isInitialized = true;
    notifyListeners();
  }

  // Kısayol ekleme
  void addShortcut(LogicalKeySet keys, VoidCallback callback) {
    _handlers[keys] = callback;
  }

  // Kısayol kaldırma
  void removeShortcut(LogicalKeySet keys) {
    _handlers.remove(keys);
  }

  // Kısayol işleme
  bool handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      final keySet = LogicalKeySet(event.logicalKey);
      
      // Özel kısayollar
      if (_handlers.containsKey(keySet)) {
        _handlers[keySet]!();
        return true;
      }

      // Genel kısayollar
      return _handleGeneralShortcuts(event);
    }
    return false;
  }

  // Genel kısayol işleme
  bool _handleGeneralShortcuts(KeyDownEvent event) {
    final keySet = LogicalKeySet(event.logicalKey);
    
    // Ctrl+N - Yeni Danışan
    if (keySet == LogicalKeySet(LogicalKeyboardKey.keyN) && 
        HardwareKeyboard.instance.isControlPressed) {
      _showNewClientDialog();
      return true;
    }

    // Ctrl+S - Kaydet
    if (keySet == LogicalKeySet(LogicalKeyboardKey.keyS) && 
        HardwareKeyboard.instance.isControlPressed) {
      _saveCurrentData();
      return true;
    }

    // Ctrl+F - Ara
    if (keySet == LogicalKeySet(LogicalKeyboardKey.keyF) && 
        HardwareKeyboard.instance.isControlPressed) {
      _showSearchDialog();
      return true;
    }

    // Ctrl+P - Yazdır
    if (keySet == LogicalKeySet(LogicalKeyboardKey.keyP) && 
        HardwareKeyboard.instance.isControlPressed) {
      _printCurrentData();
      return true;
    }

    // F1 - Yardım
    if (keySet == LogicalKeySet(LogicalKeyboardKey.f1)) {
      _showHelpDialog();
      return true;
    }

    // F11 - Tam Ekran
    if (keySet == LogicalKeySet(LogicalKeyboardKey.f11)) {
      _toggleFullScreen();
      return true;
    }

    // Esc - İptal
    if (keySet == LogicalKeySet(LogicalKeyboardKey.escape)) {
      _cancelCurrentAction();
      return true;
    }

    return false;
  }

  // Kısayol yardımcı metodları
  void _showNewClientDialog() {
    // Yeni danışan dialog'u
    debugPrint('Ctrl+N: Yeni Danışan');
  }

  void _saveCurrentData() {
    // Mevcut veriyi kaydet
    debugPrint('Ctrl+S: Kaydet');
  }

  void _showSearchDialog() {
    // Arama dialog'u
    debugPrint('Ctrl+F: Ara');
  }

  void _printCurrentData() {
    // Mevcut veriyi yazdır
    debugPrint('Ctrl+P: Yazdır');
  }

  void _showHelpDialog() {
    // Yardım dialog'u
    debugPrint('F1: Yardım');
  }

  void _toggleFullScreen() {
    // Tam ekran toggle
    debugPrint('F11: Tam Ekran');
  }

  void _cancelCurrentAction() {
    // Mevcut aksiyonu iptal et
    debugPrint('Esc: İptal');
  }

  // Kısayol listesi alma
  Map<String, String> getShortcuts() {
    return shortcuts;
  }

  // Kısayol açıklaması alma
  String? getShortcutDescription(String key) {
    return shortcuts[key];
  }

  // Kısayol widget'ı oluşturma
  Widget buildShortcutsWidget(BuildContext context) {
    return AlertDialog(
      title: const Text('Klavye Kısayolları'),
      content: SizedBox(
        width: 400,
        height: 500,
        child: ListView.builder(
          itemCount: shortcuts.length,
          itemBuilder: (context, index) {
            final shortcut = shortcuts.entries.elementAt(index);
            return ListTile(
              leading: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  shortcut.key,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              title: Text(shortcut.value),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Kapat'),
        ),
      ],
    );
  }

  // Kısayol yardım butonu
  Widget buildShortcutsHelpButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.keyboard),
      tooltip: 'Klavye Kısayolları',
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => buildShortcutsWidget(context),
        );
      },
    );
  }

  // Kısayol durum çubuğu
  Widget buildShortcutsStatusBar(BuildContext context) {
    return Container(
      height: 24,
      color: Colors.grey.shade100,
      child: Row(
        children: [
          const SizedBox(width: 16),
          const Icon(Icons.keyboard, size: 16),
          const SizedBox(width: 8),
          const Text(
            'Kısayollar: Ctrl+N (Yeni), Ctrl+S (Kaydet), Ctrl+F (Ara), F1 (Yardım)',
            style: TextStyle(fontSize: 12),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => buildShortcutsWidget(context),
              );
            },
            child: const Text(
              'Tüm Kısayollar',
              style: TextStyle(fontSize: 12),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}
