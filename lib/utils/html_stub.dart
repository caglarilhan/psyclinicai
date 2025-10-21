// Stub implementations for non-web platforms. These are NO-OPs used only
// to satisfy conditional imports. They are never executed on mobile/desktop.

class Blob {
  final List<dynamic> parts;
  final String? type;
  Blob(this.parts, [this.type]);
}

class Url {
  static String createObjectUrlFromBlob(Blob blob) => '';
  static void revokeObjectUrl(String url) {}
}

class AnchorElement {
  final String? href;
  AnchorElement({this.href});
  void setAttribute(String name, String value) {}
  void click() {}
}


