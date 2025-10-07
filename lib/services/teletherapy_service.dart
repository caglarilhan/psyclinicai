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

  TeletherapySession({
    required this.sessionId,
    required this.meetingUrl,
    required this.createdAt,
    required this.clientName,
    required this.therapistName,
  });
}

class TeletherapyService {
  static final TeletherapyService _instance = TeletherapyService._internal();
  factory TeletherapyService() => _instance;
  TeletherapyService._internal();

  Future<TeletherapySession> createSession({
    required String clientName,
    required String therapistName,
  }) async {
    final rnd = Random.secure().nextInt(1 << 32).toString();
    final slug = clientName.toLowerCase().replaceAll(' ', '-') + '-' + rnd;
    // Basit demo: Jitsi public
    final url = 'https://meet.jit.si/PsyClinicAI-' + slug;
    final session = TeletherapySession(
      sessionId: DateTime.now().millisecondsSinceEpoch.toString(),
      meetingUrl: url,
      createdAt: DateTime.now(),
      clientName: clientName,
      therapistName: therapistName,
    );
    // audit
    await AuditLogService().insertLog(
      action: 'tele.create',
      actor: therapistName,
      target: clientName + '|' + session.sessionId,
      metadataJson: jsonEncode({'meetingUrl': url}),
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
}


