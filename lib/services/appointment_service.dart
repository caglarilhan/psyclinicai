import 'dart:math';
import '../models/appointment_models.dart';

class AppointmentService {
  static final AppointmentService _instance = AppointmentService._internal();
  factory AppointmentService() => _instance;
  AppointmentService._internal();

  bool _isInitialized = false;
  final List<Appointment> _appointments = [];
  final List<AppointmentReminder> _reminders = [];
  final List<AppointmentConflict> _conflicts = [];
  final Random _random = Random();

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    // Demo randevu verileri
    _appointments.addAll([
      Appointment(
        id: '1',
        title: 'İlk Seans - Depresyon',
        description: 'Danışanın ilk seansı, depresyon belirtileri değerlendirilecek',
        clientName: 'Ayşe Yılmaz',
        dateTime: DateTime.now().add(const Duration(days: 1, hours: 10)),
        type: AppointmentType.individual,
        status: AppointmentStatus.confirmed,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        therapistId: 'therapist1',
        duration: const Duration(minutes: 60),
      ),
      Appointment(
        id: '2',
        title: 'Takip Seansı - Anksiyete',
        description: 'Anksiyete tedavisinin 3. haftası, ilerleme değerlendirmesi',
        clientName: 'Mehmet Demir',
        dateTime: DateTime.now().add(const Duration(days: 1, hours: 14)),
        type: AppointmentType.followUp,
        status: AppointmentStatus.scheduled,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        therapistId: 'therapist1',
        duration: const Duration(minutes: 45),
      ),
      Appointment(
        id: '3',
        title: 'Grup Terapisi - Sosyal Fobi',
        description: 'Sosyal fobi grubu, 5. hafta, maruz bırakma egzersizleri',
        clientName: 'Grup Terapisi',
        dateTime: DateTime.now().add(const Duration(days: 2, hours: 16)),
        type: AppointmentType.group,
        status: AppointmentStatus.confirmed,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        therapistId: 'therapist2',
        duration: const Duration(minutes: 90),
      ),
      Appointment(
        id: '4',
        title: 'Acil Seans - Kriz Müdahalesi',
        description: 'Acil kriz müdahalesi, intihar düşünceleri',
        clientName: 'Fatma Kaya',
        dateTime: DateTime.now().add(const Duration(hours: 2)),
        type: AppointmentType.emergency,
        status: AppointmentStatus.scheduled,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
        therapistId: 'therapist1',
        duration: const Duration(minutes: 60),
      ),
      Appointment(
        id: '5',
        title: 'İlk Seans - Travma',
        description: 'Travma sonrası stres bozukluğu değerlendirmesi',
        clientName: 'Ali Özkan',
        dateTime: DateTime.now().add(const Duration(days: 3, hours: 11)),
        type: AppointmentType.individual,
        status: AppointmentStatus.scheduled,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        therapistId: 'therapist3',
        duration: const Duration(minutes: 60),
      ),
      Appointment(
        id: '6',
        title: 'Takip Seansı - OKB',
        description: 'Obsesif kompulsif bozukluk tedavisi, 8. hafta',
        clientName: 'Zeynep Arslan',
        dateTime: DateTime.now().add(const Duration(days: 4, hours: 15)),
        type: AppointmentType.followUp,
        status: AppointmentStatus.confirmed,
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
        therapistId: 'therapist2',
        duration: const Duration(minutes: 45),
      ),
      Appointment(
        id: '7',
        title: 'Grup Terapisi - Depresyon',
        description: 'Depresyon grubu, 2. hafta, bilişsel davranışçı teknikler',
        clientName: 'Grup Terapisi',
        dateTime: DateTime.now().add(const Duration(days: 5, hours: 17)),
        type: AppointmentType.group,
        status: AppointmentStatus.scheduled,
        createdAt: DateTime.now().subtract(const Duration(days: 12)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
        therapistId: 'therapist1',
        duration: const Duration(minutes: 90),
      ),
      Appointment(
        id: '8',
        title: 'İlk Seans - Yeme Bozukluğu',
        description: 'Bulimia nervoza değerlendirmesi ve tedavi planı',
        clientName: 'Selin Yıldız',
        dateTime: DateTime.now().add(const Duration(days: 6, hours: 13)),
        type: AppointmentType.individual,
        status: AppointmentStatus.scheduled,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
        therapistId: 'therapist3',
        duration: const Duration(minutes: 60),
      ),
    ]);

    // Demo hatırlatıcı verileri
    _reminders.addAll([
      AppointmentReminder(
        id: '1',
        appointmentId: '1',
        reminderTime: DateTime.now().add(const Duration(hours: 23)),
        type: ReminderType.sms,
        message: 'Yarın saat 10:00\'da randevunuz var. Lütfen 15 dakika önce gelin.',
      ),
      AppointmentReminder(
        id: '2',
        appointmentId: '2',
        reminderTime: DateTime.now().add(const Duration(hours: 37)),
        type: ReminderType.email,
        message: 'Yarın saat 14:00\'da randevunuz var. Anksiyete günlüğünüzü getirmeyi unutmayın.',
      ),
      AppointmentReminder(
        id: '3',
        appointmentId: '3',
        reminderTime: DateTime.now().add(const Duration(hours: 61)),
        type: ReminderType.push,
        message: '2 gün sonra grup terapisi var. Sosyal fobi egzersizlerinizi hazırlayın.',
      ),
    ]);

    // Demo çakışma verileri
    _conflicts.addAll([
      AppointmentConflict(
        id: '1',
        appointmentId: '4',
        conflictingAppointmentId: '5',
        type: ConflictType.timeOverlap,
        description: 'Acil seans ile normal seans arasında zaman çakışması',
        detectedAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ]);

    _isInitialized = true;
  }

  // Randevuları getir
  Future<List<Appointment>> getAppointments() async {
    await initialize();
    return _appointments;
  }

  // Belirli tarih aralığındaki randevuları getir
  Future<List<Appointment>> getAppointmentsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    await initialize();
    
    return _appointments.where((appointment) {
      return appointment.dateTime.isAfter(startDate.subtract(const Duration(days: 1))) &&
             appointment.dateTime.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  // Belirli terapistin randevularını getir
  Future<List<Appointment>> getAppointmentsByTherapist(String therapistId) async {
    await initialize();
    
    return _appointments.where((appointment) {
      return appointment.therapistId == therapistId;
    }).toList();
  }

  // Belirli danışanın randevularını getir
  Future<List<Appointment>> getAppointmentsByClient(String clientName) async {
    await initialize();
    
    return _appointments.where((appointment) {
      return appointment.clientName.toLowerCase().contains(clientName.toLowerCase());
    }).toList();
  }

  // Randevu ekle
  Future<void> addAppointment(Appointment appointment) async {
    await initialize();
    
    // Çakışma kontrolü
    final conflicts = _checkConflicts(appointment);
    if (conflicts.isNotEmpty) {
      throw Exception('Randevu çakışması tespit edildi: ${conflicts.first.description}');
    }
    
    _appointments.add(appointment);
    
    // Otomatik hatırlatıcı oluştur
    await _createDefaultReminders(appointment);
  }

  // Randevu güncelle
  Future<void> updateAppointment(Appointment updatedAppointment) async {
    await initialize();
    
    final index = _appointments.indexWhere((a) => a.id == updatedAppointment.id);
    if (index == -1) {
      throw Exception('Randevu bulunamadı');
    }
    
    // Çakışma kontrolü (kendisi hariç)
    final conflicts = _checkConflicts(updatedAppointment, excludeId: updatedAppointment.id);
    if (conflicts.isNotEmpty) {
      throw Exception('Randevu çakışması tespit edildi: ${conflicts.first.description}');
    }
    
    _appointments[index] = updatedAppointment;
  }

  // Randevu sil
  Future<void> deleteAppointment(String appointmentId) async {
    await initialize();
    
    _appointments.removeWhere((a) => a.id == appointmentId);
    
    // İlgili hatırlatıcıları da sil
    _reminders.removeWhere((r) => r.appointmentId == appointmentId);
    
    // İlgili çakışmaları da sil
    _conflicts.removeWhere((c) => 
      c.appointmentId == appointmentId || c.conflictingAppointmentId == appointmentId);
  }

  // Randevu durumunu güncelle
  Future<void> updateAppointmentStatus(String appointmentId, AppointmentStatus status) async {
    await initialize();
    
    final index = _appointments.indexWhere((a) => a.id == appointmentId);
    if (index == -1) {
      throw Exception('Randevu bulunamadı');
    }
    
    final appointment = _appointments[index];
    _appointments[index] = appointment.copyWith(
      status: status,
      updatedAt: DateTime.now(),
    );
  }

  // Hatırlatıcıları getir
  Future<List<AppointmentReminder>> getReminders() async {
    await initialize();
    return _reminders;
  }

  // Belirli randevunun hatırlatıcılarını getir
  Future<List<AppointmentReminder>> getRemindersByAppointment(String appointmentId) async {
    await initialize();
    
    return _reminders.where((r) => r.appointmentId == appointmentId).toList();
  }

  // Hatırlatıcı ekle
  Future<void> addReminder(AppointmentReminder reminder) async {
    await initialize();
    _reminders.add(reminder);
  }

  // Hatırlatıcı güncelle
  Future<void> updateReminder(AppointmentReminder updatedReminder) async {
    await initialize();
    
    final index = _reminders.indexWhere((r) => r.id == updatedReminder.id);
    if (index == -1) {
      throw Exception('Hatırlatıcı bulunamadı');
    }
    
    _reminders[index] = updatedReminder;
  }

  // Hatırlatıcı sil
  Future<void> deleteReminder(String reminderId) async {
    await initialize();
    _reminders.removeWhere((r) => r.id == reminderId);
  }

  // Çakışmaları getir
  Future<List<AppointmentConflict>> getConflicts() async {
    await initialize();
    return _conflicts;
  }

  // Çakışma çözüldü olarak işaretle
  Future<void> resolveConflict(String conflictId) async {
    await initialize();
    
    final index = _conflicts.indexWhere((c) => c.id == conflictId);
    if (index == -1) {
      throw Exception('Çakışma bulunamadı');
    }
    
    final conflict = _conflicts[index];
    _conflicts[index] = conflict.copyWith(isResolved: true);
  }

  // İstatistikleri getir
  Future<AppointmentStatistics> getStatistics() async {
    await initialize();
    
    final total = _appointments.length;
    final completed = _appointments.where((a) => a.status == AppointmentStatus.completed).length;
    final cancelled = _appointments.where((a) => a.status == AppointmentStatus.cancelled).length;
    final noShow = _appointments.where((a) => a.status == AppointmentStatus.noShow).length;
    
    final completionRate = total > 0 ? (completed / total) * 100 : 0.0;
    final cancellationRate = total > 0 ? (cancelled / total) * 100 : 0.0;
    final noShowRate = total > 0 ? (noShow / total) * 100 : 0.0;
    
    // Ortalama süre hesapla
    final appointmentsWithDuration = _appointments.where((a) => a.duration != null).toList();
    final totalDuration = appointmentsWithDuration.fold<Duration>(
      Duration.zero,
      (total, appointment) => total + (appointment.duration ?? Duration.zero),
    );
    final averageDuration = appointmentsWithDuration.isNotEmpty
        ? Duration(minutes: totalDuration.inMinutes ~/ appointmentsWithDuration.length)
        : const Duration(minutes: 60);
    
    // Tür bazında grupla
    final appointmentsByType = <AppointmentType, int>{};
    for (final appointment in _appointments) {
      appointmentsByType[appointment.type] = (appointmentsByType[appointment.type] ?? 0) + 1;
    }
    
    // Terapist bazında grupla
    final appointmentsByTherapist = <String, int>{};
    for (final appointment in _appointments) {
      if (appointment.therapistId != null) {
        appointmentsByTherapist[appointment.therapistId!] = 
            (appointmentsByTherapist[appointment.therapistId!] ?? 0) + 1;
      }
    }
    
    return AppointmentStatistics(
      totalAppointments: total,
      completedAppointments: completed,
      cancelledAppointments: cancelled,
      noShowAppointments: noShow,
      completionRate: completionRate,
      cancellationRate: cancellationRate,
      noShowRate: noShowRate,
      averageDuration: averageDuration,
      appointmentsByType: appointmentsByType,
      appointmentsByTherapist: appointmentsByTherapist,
    );
  }

  // AI destekli randevu önerisi
  Future<List<DateTime>> getAISuggestedTimes({
    required Duration duration,
    required DateTime preferredDate,
    String? therapistId,
  }) async {
    await initialize();
    
    // Basit AI algoritması: Boş zaman dilimlerini bul
    final suggestions = <DateTime>[];
    final workingHours = [9, 10, 11, 14, 15, 16, 17]; // Çalışma saatleri
    
    for (int i = 0; i < 7; i++) { // 1 hafta içinde
      final date = preferredDate.add(Duration(days: i));
      
      for (final hour in workingHours) {
        final suggestedTime = DateTime(date.year, date.month, date.day, hour);
        
        // Çakışma kontrolü
        final hasConflict = _appointments.any((appointment) {
          if (therapistId != null && appointment.therapistId != therapistId) {
            return false; // Farklı terapist, çakışma yok
          }
          
          final appointmentEnd = appointment.dateTime.add(
            appointment.duration ?? const Duration(minutes: 60),
          );
          final suggestedEnd = suggestedTime.add(duration);
          
          return (suggestedTime.isBefore(appointmentEnd) && 
                  suggestedEnd.isAfter(appointment.dateTime));
        });
        
        if (!hasConflict) {
          suggestions.add(suggestedTime);
          if (suggestions.length >= 5) break; // En fazla 5 öneri
        }
      }
      
      if (suggestions.length >= 5) break;
    }
    
    return suggestions;
  }

  // Çakışma kontrolü
  List<AppointmentConflict> _checkConflicts(Appointment appointment, {String? excludeId}) {
    final conflicts = <AppointmentConflict>[];
    
    for (final existingAppointment in _appointments) {
      if (excludeId != null && existingAppointment.id == excludeId) continue;
      if (existingAppointment.status == AppointmentStatus.cancelled) continue;
      
      final existingEnd = existingAppointment.dateTime.add(
        existingAppointment.duration ?? const Duration(minutes: 60),
      );
      final newEnd = appointment.dateTime.add(
        appointment.duration ?? const Duration(minutes: 60),
      );
      
      // Zaman çakışması
      if (appointment.dateTime.isBefore(existingEnd) && newEnd.isAfter(existingAppointment.dateTime)) {
        conflicts.add(AppointmentConflict(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          appointmentId: appointment.id,
          conflictingAppointmentId: existingAppointment.id,
          type: ConflictType.timeOverlap,
          description: 'Zaman çakışması: ${existingAppointment.title} ile',
          detectedAt: DateTime.now(),
        ));
      }
      
      // Aynı terapist çakışması
      if (appointment.therapistId != null && 
          appointment.therapistId == existingAppointment.therapistId &&
          appointment.dateTime.isBefore(existingEnd) && 
          newEnd.isAfter(existingAppointment.dateTime)) {
        conflicts.add(AppointmentConflict(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          appointmentId: appointment.id,
          conflictingAppointmentId: existingAppointment.id,
          type: ConflictType.therapistUnavailable,
          description: 'Terapist müsait değil: ${existingAppointment.title} ile',
          detectedAt: DateTime.now(),
        ));
      }
    }
    
    return conflicts;
  }

  // Varsayılan hatırlatıcıları oluştur
  Future<void> _createDefaultReminders(Appointment appointment) async {
    // 24 saat önce SMS
    await addReminder(AppointmentReminder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      appointmentId: appointment.id,
      reminderTime: appointment.dateTime.subtract(const Duration(hours: 24)),
      type: ReminderType.sms,
      message: 'Yarın saat ${appointment.dateTime.hour}:${appointment.dateTime.minute.toString().padLeft(2, '0')} randevunuz var.',
    ));
    
    // 2 saat önce push notification
    await addReminder(AppointmentReminder(
      id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
      appointmentId: appointment.id,
      reminderTime: appointment.dateTime.subtract(const Duration(hours: 2)),
      type: ReminderType.push,
      message: '2 saat sonra randevunuz var: ${appointment.title}',
    ));
  }

  // Yaklaşan randevuları getir
  Future<List<Appointment>> getUpcomingAppointments({int limit = 5}) async {
    await initialize();
    
    final now = DateTime.now();
    final upcoming = _appointments
        .where((a) => a.dateTime.isAfter(now) && a.status != AppointmentStatus.cancelled)
        .toList();
    
    upcoming.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    
    return upcoming.take(limit).toList();
  }

  // Bugünkü randevuları getir
  Future<List<Appointment>> getTodayAppointments() async {
    await initialize();
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    
    return _appointments.where((a) {
      final appointmentDate = DateTime(a.dateTime.year, a.dateTime.month, a.dateTime.day);
      return appointmentDate.isAtSameMomentAs(today) && 
             a.status != AppointmentStatus.cancelled;
    }).toList();
  }

  // Geçmiş randevuları getir
  Future<List<Appointment>> getPastAppointments({int limit = 20}) async {
    await initialize();
    
    final now = DateTime.now();
    final past = _appointments
        .where((a) => a.dateTime.isBefore(now))
        .toList();
    
    past.sort((a, b) => b.dateTime.compareTo(a.dateTime)); // En yeni önce
    
    return past.take(limit).toList();
  }

  // Randevu arama
  Future<List<Appointment>> searchAppointments(String query) async {
    await initialize();
    
    if (query.isEmpty) return _appointments;
    
    final lowercaseQuery = query.toLowerCase();
    
    return _appointments.where((appointment) {
      return appointment.title.toLowerCase().contains(lowercaseQuery) ||
             appointment.clientName.toLowerCase().contains(lowercaseQuery) ||
             appointment.description.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // Randevu çakışmalarını kontrol et ve raporla
  Future<List<AppointmentConflict>> checkAllConflicts() async {
    await initialize();
    
    final conflicts = <AppointmentConflict>[];
    
    for (final appointment in _appointments) {
      if (appointment.status == AppointmentStatus.cancelled) continue;
      
      final appointmentConflicts = _checkConflicts(appointment, excludeId: appointment.id);
      conflicts.addAll(appointmentConflicts);
    }
    
    // Mevcut çakışmaları güncelle
    _conflicts.clear();
    _conflicts.addAll(conflicts);
    
    return conflicts;
  }

  // Hatırlatıcıları gönder
  Future<void> sendReminders() async {
    await initialize();
    
    final now = DateTime.now();
    final dueReminders = _reminders.where((r) => 
      r.reminderTime.isBefore(now) && !r.isSent
    ).toList();
    
    for (final reminder in dueReminders) {
      // Hatırlatıcıyı gönder (gerçek uygulamada SMS/email servisi kullanılır)
      final index = _reminders.indexWhere((r) => r.id == reminder.id);
      if (index != -1) {
        _reminders[index] = reminder.copyWith(
          isSent: true,
          sentAt: now,
        );
      }
    }
  }

  // Randevu istatistiklerini güncelle
  Future<void> updateStatistics() async {
    await initialize();
    // İstatistikler real-time hesaplandığı için güncelleme gerekmez
  }

  // Veri temizleme (test amaçlı)
  Future<void> clearAllData() async {
    _appointments.clear();
    _reminders.clear();
    _conflicts.clear();
    _isInitialized = false;
  }
}
