class IdentityValidation {
  static bool isValidEmail(String email) {
    final re = RegExp(r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');
    return re.hasMatch(email);
  }

  // TR: 11 haneli, ilk hane 0 olamaz; 10. ve 11. hanede kontrol
  static bool isValidTCKN(String s) {
    if (s.length != 11) return false;
    if (!RegExp(r'^\d{11}
$').hasMatch(s)) return false;
    if (s[0] == '0') return false;
    final digits = s.split('').map(int.parse).toList();
    final oddSum = digits[0] + digits[2] + digits[4] + digits[6] + digits[8];
    final evenSum = digits[1] + digits[3] + digits[5] + digits[7];
    final digit10 = ((oddSum * 7) - evenSum) % 10;
    if (digit10 != digits[9]) return false;
    final totalSum = digits.take(10).reduce((a, b) => a + b);
    final digit11 = totalSum % 10;
    return digit11 == digits[10];
  }

  // US: SSN (çok basit kontrol: 3-2-4 numeric) — gerçek doğrulama için servis gerekir
  static bool isValidUSSSN(String s) {
    return RegExp(r'^\d{3}-?\d{2}-?\d{4}$').hasMatch(s);
  }

  // UK: NHS Number (10 hane, mod11) — basit biçim kontrol
  static bool isValidUKNHS(String s) {
    return RegExp(r'^\d{10}$').hasMatch(s);
  }

  // DE: Versicherungsnummer (yalnız biçim kontrol)
  static bool isValidDEInsurance(String s) {
    return RegExp(r'^[A-Z]\d{9}$').hasMatch(s);
  }

  // FR: INSEE (NIR) — yalnız biçim kontrol
  static bool isValidFRNIR(String s) {
    return RegExp(r'^[12]\d{2}\d{2}\d{2}\d{3}\d{3}\d{2}$').hasMatch(s);
  }
}


