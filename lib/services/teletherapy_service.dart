import 'dart:math';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'audit_log_service.dart';

class TeletherapySession {
  final String sessionId;
  final String meetingUrl;
  final DateTime createdAt;
  final String clientName;
  final String therapistName;
  final bool locked;
  final String passcode;

  TeletherapySession({
    required this.sessionId,
    required this.meetingUrl,
    required this.createdAt,
    required this.clientName,
    required this.therapistName,
    required this.locked,
    required this.passcode,
  });
}

class TeletherapyService {
  static final TeletherapyService _instance = TeletherapyService._internal();
  factory TeletherapyService() => _instance;
  TeletherapyService._internal();

  Future<TeletherapySession> createSession({
    required String clientName,
    required String therapistName,
    bool locked = true,
  }) async {
    final rnd = Random.secure().nextInt(1 << 32).toString();
    final slug = clientName.toLowerCase().replaceAll(' ', '-') + '-' + rnd;
    // Basit demo: Jitsi public
    final url = 'https://meet.jit.si/PsyClinicAI-' + slug;
    final pass = (100000 + Random.secure().nextInt(900000)).toString();
    final session = TeletherapySession(
      sessionId: DateTime.now().millisecondsSinceEpoch.toString(),
      meetingUrl: url,
      createdAt: DateTime.now(),
      clientName: clientName,
      therapistName: therapistName,
      locked: locked,
      passcode: pass,
    );
    // audit
    await AuditLogService().insertLog(
      action: 'tele.create',
      actor: therapistName,
      target: clientName + '|' + session.sessionId,
      metadataJson: jsonEncode({'meetingUrl': url, 'locked': locked}),
    );
    return session;
  }

  Future<void> openMeetingUrl(String meetingUrl, {String? clientName, String? therapistName}) async {
    final uri = Uri.parse(meetingUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('URL açılamadı: ' + meetingUrl);
    }
    await AuditLogService().insertLog(
      action: 'tele.join',
      actor: therapistName ?? 'unknown',
      target: (clientName ?? 'unknown') + '|' + meetingUrl,
      metadataJson: '{}',
    );
  }

  Future<void> endSession(TeletherapySession session) async {
    await AuditLogService().insertLog(
      action: 'tele.end',
      actor: session.therapistName,
      target: session.clientName + '|' + session.sessionId,
      metadataJson: '{}',
    );
  }

  Future<TeletherapySession> toggleLock(TeletherapySession session, {required bool lock}) async {
    await AuditLogService().insertLog(
      action: lock ? 'tele.lock' : 'tele.unlock',
      actor: session.therapistName,
      target: session.clientName + '|' + session.sessionId,
      metadataJson: jsonEncode({'locked': lock}),
    );
    return TeletherapySession(
      sessionId: session.sessionId,
      meetingUrl: session.meetingUrl,
      createdAt: session.createdAt,
      clientName: session.clientName,
      therapistName: session.therapistName,
      locked: lock,
      passcode: session.passcode,
    );
  }
}


