import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegionService extends ChangeNotifier {
  static const String _regionKey = 'current_region_code';

  String _currentRegionCode = 'TR'; // TR | EU | US

  String get currentRegionCode => _currentRegionCode;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _currentRegionCode = prefs.getString(_regionKey) ?? _currentRegionCode;
    notifyListeners();
  }

  Future<void> setRegion(String code) async {
    _currentRegionCode = code;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_regionKey, code);
    notifyListeners();
  }
}



