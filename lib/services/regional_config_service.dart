import 'package:flutter/foundation.dart';

enum Region { TR, US, EU }

typedef PromptSelector = String Function(Region region);

abstract class RegionalConfigService extends ChangeNotifier {
  static final RegionalConfigService _instance = _DefaultRegionalConfigService();
  static RegionalConfigService get instance => _instance;

  Region get currentRegion;
  void setRegion(Region region);

  String selectPsychiatryPrompt() {
    switch (currentRegion) {
      case Region.TR:
        return 'turkey_psychiatry_ai';
      case Region.US:
        return 'us_psychiatry_ai';
      case Region.EU:
        return 'eu_psychiatry_ai';
    }
  }
}

class _DefaultRegionalConfigService extends RegionalConfigService {
  Region _region = Region.TR;

  @override
  Region get currentRegion => _region;

  @override
  void setRegion(Region region) {
    _region = region;
    notifyListeners();
  }
}
