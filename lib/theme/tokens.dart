import 'package:flutter/animation.dart';

/// Spacing scale (4-pt base). Use as `PsySpacing.md` etc.
class PsySpacing {
  const PsySpacing._();
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
  static const double huge = 64;
  static const double gigantic = 96;
}

/// Corner radius scale — tuned for web-native feel (sharper than Material
/// Android defaults). Stripe / Linear / Vercel sit in the 6-14px range.
class PsyRadius {
  const PsyRadius._();
  static const double none = 0;
  static const double xs = 4;
  static const double sm = 6;
  static const double md = 8;
  static const double lg = 12;
  static const double xl = 14;
  static const double full = 999;
}

/// Elevation tokens.
class PsyElevation {
  const PsyElevation._();
  static const double flat = 0;
  static const double card = 2;
  static const double raised = 6;
  static const double modal = 16;
}

/// Animation durations + curves.
class PsyMotion {
  const PsyMotion._();
  static const Duration instant = Duration(milliseconds: 80);
  static const Duration fast = Duration(milliseconds: 160);
  static const Duration normal = Duration(milliseconds: 240);
  static const Duration slow = Duration(milliseconds: 360);
  static const Duration ambient = Duration(milliseconds: 800);

  static const Curve emphasized = Curves.easeOutCubic;
  static const Curve standard = Curves.easeOut;
  static const Curve gentle = Curves.easeInOut;
}

/// Layout breakpoints (CSS-style).
class PsyBreakpoints {
  const PsyBreakpoints._();
  static const double sm = 640;
  static const double md = 768;
  static const double lg = 1024;
  static const double xl = 1280;
  static const double xxl = 1536;
}
