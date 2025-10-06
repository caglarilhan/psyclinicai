class AccessControl {
  // Basit rol listesi
  static const String roleAdmin = 'admin';
  static const String roleSupervisor = 'supervisor';
  static const String roleTherapist = 'therapist';
  static const String roleIntern = 'intern';

  // Eylem anahtarları
  static const String actPdfGenerate = 'pdf.generate';
  static const String actPdfOpen = 'pdf.open';
  static const String actPdfShare = 'pdf.share';

  // Rol -> izinli eylemler
  static const Map<String, Set<String>> _permissionsByRole = {
    roleAdmin: {actPdfGenerate, actPdfOpen, actPdfShare},
    roleSupervisor: {actPdfGenerate, actPdfOpen, actPdfShare},
    roleTherapist: {actPdfGenerate, actPdfOpen, actPdfShare},
    roleIntern: {actPdfGenerate, actPdfOpen}, // paylaşım yok
  };

  static bool isAllowed(String role, String action) {
    final allowed = _permissionsByRole[role] ?? const {};
    return allowed.contains(action);
  }
}


