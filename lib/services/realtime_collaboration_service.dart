import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class RealtimeCollaborationService {
  static const String _sessionsKey = 'collaboration_sessions';
  static const String _messagesKey = 'collaboration_messages';
  static const String _participantsKey = 'collaboration_participants';
  
  // Singleton pattern
  static final RealtimeCollaborationService _instance = RealtimeCollaborationService._internal();
  factory RealtimeCollaborationService() => _instance;
  RealtimeCollaborationService._internal();

  // Stream controllers for real-time updates
  final StreamController<CollaborationEvent> _eventStreamController = 
      StreamController<CollaborationEvent>.broadcast();
  
  final StreamController<CollaborationMessage> _messageStreamController = 
      StreamController<CollaborationMessage>.broadcast();
  
  final StreamController<ParticipantStatus> _participantStreamController = 
      StreamController<ParticipantStatus>.broadcast();

  // Get streams
  Stream<CollaborationEvent> get eventStream => _eventStreamController.stream;
  Stream<CollaborationMessage> get messageStream => _messageStreamController.stream;
  Stream<ParticipantStatus> get participantStream => _participantStreamController.stream;

  // Active collaboration sessions
  final Map<String, CollaborationSession> _activeSessions = {};
  final Map<String, List<CollaborationMessage>> _sessionMessages = {};
  final Map<String, List<CollaborationParticipant>> _sessionParticipants = {};

  // Initialize collaboration service
  Future<void> initialize() async {
    try {
      print('✅ Realtime Collaboration service initialized');
    } catch (e) {
      print('Error initializing collaboration service: $e');
    }
  }

  // Create collaboration session
  Future<CollaborationSession> createSession({
    required String sessionId,
    required String title,
    required String creatorId,
    required String creatorName,
    required CollaborationType type,
    String? description,
    List<String>? invitedUserIds,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final session = CollaborationSession(
        id: sessionId,
        title: title,
        description: description ?? '',
        creatorId: creatorId,
        creatorName: creatorName,
        type: type,
        status: CollaborationStatus.active,
        participants: [
          CollaborationParticipant(
            userId: creatorId,
            userName: creatorName,
            role: ParticipantRole.host,
            status: ParticipantStatus.online,
            joinedAt: DateTime.now(),
            lastActivity: DateTime.now(),
          ),
        ],
        invitedUserIds: invitedUserIds ?? [],
        metadata: metadata ?? {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Add to active sessions
      _activeSessions[sessionId] = session;
      _sessionMessages[sessionId] = [];
      _sessionParticipants[sessionId] = List.from(session.participants);

      // Save to local storage
      await _saveSession(session);

      // Send session created event
      _eventStreamController.add(CollaborationEvent(
        id: _generateSecureId(),
        sessionId: sessionId,
        eventType: CollaborationEventType.session_created,
        userId: creatorId,
        userName: creatorName,
        timestamp: DateTime.now(),
        data: {
          'sessionTitle': title,
          'sessionType': type.name,
        },
      ));

      print('✅ Collaboration session created: $sessionId');
      return session;

    } catch (e) {
      print('Error creating collaboration session: $e');
      rethrow;
    }
  }

  // Join collaboration session
  Future<bool> joinSession({
    required String sessionId,
    required String userId,
    required String userName,
    ParticipantRole role = ParticipantRole.participant,
  }) async {
    try {
      final session = _activeSessions[sessionId];
      if (session == null) return false;

      // Check if user is already in session
      final existingParticipant = _sessionParticipants[sessionId]!
          .firstWhere((p) => p.userId == userId, orElse: () => CollaborationParticipant.empty());

      if (existingParticipant.userId.isNotEmpty) {
        // Update existing participant status
        final updatedParticipant = existingParticipant.copyWith(
          status: ParticipantStatus.online,
          lastActivity: DateTime.now(),
        );
        
        final index = _sessionParticipants[sessionId]!.indexWhere((p) => p.userId == userId);
        _sessionParticipants[sessionId]![index] = updatedParticipant;
      } else {
        // Add new participant
        final newParticipant = CollaborationParticipant(
          userId: userId,
          userName: userName,
          role: role,
          status: ParticipantStatus.online,
          joinedAt: DateTime.now(),
          lastActivity: DateTime.now(),
        );

        _sessionParticipants[sessionId]!.add(newParticipant);
        session.participants.add(newParticipant);
      }

      // Update session
      session.updatedAt = DateTime.now();
      await _saveSession(session);

      // Send participant joined event
      _participantStreamController.add(ParticipantStatus(
        id: _generateSecureId(),
        sessionId: sessionId,
        userId: userId,
        userName: userName,
        status: ParticipantStatus.online,
        timestamp: DateTime.now(),
        action: ParticipantAction.joined,
      ));

      print('✅ User joined session: $userId in $sessionId');
      return true;

    } catch (e) {
      print('Error joining collaboration session: $e');
      return false;
    }
  }

  // Leave collaboration session
  Future<bool> leaveSession({
    required String sessionId,
    required String userId,
  }) async {
    try {
      final session = _activeSessions[sessionId];
      if (session == null) return false;

      // Update participant status
      final participantIndex = _sessionParticipants[sessionId]!
          .indexWhere((p) => p.userId == userId);
      
      if (participantIndex >= 0) {
        final participant = _sessionParticipants[sessionId]![participantIndex];
        final updatedParticipant = participant.copyWith(
          status: ParticipantStatus.offline,
          lastActivity: DateTime.now(),
        );
        
        _sessionParticipants[sessionId]![participantIndex] = updatedParticipant;
        
        // Update in session
        final sessionParticipantIndex = session.participants.indexWhere((p) => p.userId == userId);
        if (sessionParticipantIndex >= 0) {
          session.participants[sessionParticipantIndex] = updatedParticipant;
        }
      }

      // Update session
      session.updatedAt = DateTime.now();
      await _saveSession(session);

      // Send participant left event
      _participantStreamController.add(ParticipantStatus(
        id: _generateSecureId(),
        sessionId: sessionId,
        userId: userId,
        userName: _getParticipantName(sessionId, userId),
        status: ParticipantStatus.offline,
        timestamp: DateTime.now(),
        action: ParticipantAction.left,
      ));

      print('✅ User left session: $userId from $sessionId');
      return true;

    } catch (e) {
      print('Error leaving collaboration session: $e');
      return false;
    }
  }

  // Send message in collaboration session
  Future<CollaborationMessage> sendMessage({
    required String sessionId,
    required String userId,
    required String userName,
    required String content,
    MessageType type = MessageType.text,
    Map<String, dynamic>? metadata,
    String? replyToMessageId,
  }) async {
    try {
      final message = CollaborationMessage(
        id: _generateSecureId(),
        sessionId: sessionId,
        userId: userId,
        userName: userName,
        content: content,
        type: type,
        metadata: metadata ?? {},
        replyToMessageId: replyToMessageId,
        timestamp: DateTime.now(),
        isEdited: false,
        isDeleted: false,
      );

      // Add to session messages
      _sessionMessages[sessionId]!.add(message);

      // Save message to local storage
      await _saveMessage(message);

      // Send message to all participants
      _messageStreamController.add(message);

      // Send message event
      _eventStreamController.add(CollaborationEvent(
        id: _generateSecureId(),
        sessionId: sessionId,
        eventType: CollaborationEventType.message_sent,
        userId: userId,
        userName: userName,
        timestamp: DateTime.now(),
        data: {
          'messageId': message.id,
          'messageType': type.name,
          'content': content,
        },
      ));

      print('✅ Message sent in session: $sessionId');
      return message;

    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }

  // Edit message
  Future<bool> editMessage({
    required String sessionId,
    required String messageId,
    required String newContent,
    required String userId,
  }) async {
    try {
      final messages = _sessionMessages[sessionId];
      if (messages == null) return false;

      final messageIndex = messages.indexWhere((m) => m.id == messageId);
      if (messageIndex < 0) return false;

      final message = messages[messageIndex];
      if (message.userId != userId) return false; // Only message owner can edit

      // Update message
      final updatedMessage = message.copyWith(
        content: newContent,
        isEdited: true,
        timestamp: DateTime.now(),
      );

      messages[messageIndex] = updatedMessage;
      await _saveMessage(updatedMessage);

      // Send message updated event
      _eventStreamController.add(CollaborationEvent(
        id: _generateSecureId(),
        sessionId: sessionId,
        eventType: CollaborationEventType.message_edited,
        userId: userId,
        userName: message.userName,
        timestamp: DateTime.now(),
        data: {
          'messageId': messageId,
          'oldContent': message.content,
          'newContent': newContent,
        },
      ));

      print('✅ Message edited: $messageId');
      return true;

    } catch (e) {
      print('Error editing message: $e');
      return false;
    }
  }

  // Delete message
  Future<bool> deleteMessage({
    required String sessionId,
    required String messageId,
    required String userId,
  }) async {
    try {
      final messages = _sessionMessages[sessionId];
      if (messages == null) return false;

      final messageIndex = messages.indexWhere((m) => m.id == messageId);
      if (messageIndex < 0) return false;

      final message = messages[messageIndex];
      if (message.userId != userId) return false; // Only message owner can delete

      // Mark message as deleted
      final updatedMessage = message.copyWith(
        isDeleted: true,
        timestamp: DateTime.now(),
      );

      messages[messageIndex] = updatedMessage;
      await _saveMessage(updatedMessage);

      // Send message deleted event
      _eventStreamController.add(CollaborationEvent(
        id: _generateSecureId(),
        sessionId: sessionId,
        eventType: CollaborationEventType.message_deleted,
        userId: userId,
        userName: message.userName,
        timestamp: DateTime.now(),
        data: {
          'messageId': messageId,
          'deletedContent': message.content,
        },
      ));

      print('✅ Message deleted: $messageId');
      return true;

    } catch (e) {
      print('Error deleting message: $e');
      return false;
    }
  }

  // Get session messages
  List<CollaborationMessage> getSessionMessages(String sessionId) {
    return _sessionMessages[sessionId] ?? [];
  }

  // Get session participants
  List<CollaborationParticipant> getSessionParticipants(String sessionId) {
    return _sessionParticipants[sessionId] ?? [];
  }

  // Get active session
  CollaborationSession? getActiveSession(String sessionId) {
    return _activeSessions[sessionId];
  }

  // Get all active sessions
  List<CollaborationSession> getAllActiveSessions() {
    return _activeSessions.values.toList();
  }

  // Update participant activity
  Future<void> updateParticipantActivity({
    required String sessionId,
    required String userId,
  }) async {
    try {
      final participants = _sessionParticipants[sessionId];
      if (participants == null) return;

      final participantIndex = participants.indexWhere((p) => p.userId == userId);
      if (participantIndex >= 0) {
        final participant = participants[participantIndex];
        final updatedParticipant = participant.copyWith(
          lastActivity: DateTime.now(),
        );
        
        participants[participantIndex] = updatedParticipant;
        
        // Update in session
        final session = _activeSessions[sessionId];
        if (session != null) {
          final sessionParticipantIndex = session.participants.indexWhere((p) => p.userId == userId);
          if (sessionParticipantIndex >= 0) {
            session.participants[sessionParticipantIndex] = updatedParticipant;
          }
        }
      }
    } catch (e) {
      print('Error updating participant activity: $e');
    }
  }

  // Invite user to session
  Future<bool> inviteUserToSession({
    required String sessionId,
    required String userId,
    required String userName,
    required String invitedByUserId,
  }) async {
    try {
      final session = _activeSessions[sessionId];
      if (session == null) return false;

      // Add to invited users if not already invited
      if (!session.invitedUserIds.contains(userId)) {
        session.invitedUserIds.add(userId);
        session.updatedAt = DateTime.now();
        await _saveSession(session);
      }

      // Send invitation event
      _eventStreamController.add(CollaborationEvent(
        id: _generateSecureId(),
        sessionId: sessionId,
        eventType: CollaborationEventType.user_invited,
        userId: invitedByUserId,
        userName: _getParticipantName(sessionId, invitedByUserId),
        timestamp: DateTime.now(),
        data: {
          'invitedUserId': userId,
          'invitedUserName': userName,
        },
      ));

      print('✅ User invited to session: $userId in $sessionId');
      return true;

    } catch (e) {
      print('Error inviting user to session: $e');
      return false;
    }
  }

  // Get participant name
  String _getParticipantName(String sessionId, String userId) {
    final participants = _sessionParticipants[sessionId];
    if (participants == null) return 'Unknown User';
    
    final participant = participants.firstWhere(
      (p) => p.userId == userId,
      orElse: () => CollaborationParticipant.empty(),
    );
    
    return participant.userName.isNotEmpty ? participant.userName : 'Unknown User';
  }

  // Save session to local storage
  Future<void> _saveSession(CollaborationSession session) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessions = await _getSessions();
      
      final index = sessions.indexWhere((s) => s.id == session.id);
      if (index >= 0) {
        sessions[index] = session;
      } else {
        sessions.add(session);
      }
      
      await prefs.setString(_sessionsKey, json.encode(
        sessions.map((s) => s.toJson()).toList()
      ));
    } catch (e) {
      print('Error saving session: $e');
    }
  }

  // Get sessions from local storage
  Future<List<CollaborationSession>> _getSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionsJson = prefs.getString(_sessionsKey);
      
      if (sessionsJson != null) {
        final sessions = json.decode(sessionsJson) as List<dynamic>;
        return sessions.map((json) => CollaborationSession.fromJson(json)).toList();
      }
      
      return [];
    } catch (e) {
      print('Error getting sessions: $e');
      return [];
    }
  }

  // Save message to local storage
  Future<void> _saveMessage(CollaborationMessage message) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messages = await _getMessages();
      
      final index = messages.indexWhere((m) => m.id == message.id);
      if (index >= 0) {
        messages[index] = message;
      } else {
        messages.add(message);
      }
      
      await prefs.setString(_messagesKey, json.encode(
        messages.map((m) => m.toJson()).toList()
      ));
    } catch (e) {
      print('Error saving message: $e');
    }
  }

  // Get messages from local storage
  Future<List<CollaborationMessage>> _getMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = prefs.getString(_messagesKey);
      
      if (messagesJson != null) {
        final messages = json.decode(messagesJson) as List<dynamic>;
        return messages.map((json) => CollaborationMessage.fromJson(json)).toList();
      }
      
      return [];
    } catch (e) {
      print('Error getting messages: $e');
      return [];
    }
  }

  // Generate secure ID
  String _generateSecureId() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (i) => random.nextInt(256));
    return base64.encode(bytes);
  }

  // Dispose resources
  void dispose() {
    _eventStreamController.close();
    _messageStreamController.close();
    _participantStreamController.close();
  }
}

// Data classes
class CollaborationSession {
  final String id;
  final String title;
  final String description;
  final String creatorId;
  final String creatorName;
  final CollaborationType type;
  final CollaborationStatus status;
  final List<CollaborationParticipant> participants;
  final List<String> invitedUserIds;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  DateTime updatedAt;

  CollaborationSession({
    required this.id,
    required this.title,
    required this.description,
    required this.creatorId,
    required this.creatorName,
    required this.type,
    required this.status,
    required this.participants,
    required this.invitedUserIds,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'type': type.name,
      'status': status.name,
      'participants': participants.map((p) => p.toJson()).toList(),
      'invitedUserIds': invitedUserIds,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory CollaborationSession.fromJson(Map<String, dynamic> json) {
    return CollaborationSession(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      creatorId: json['creatorId'],
      creatorName: json['creatorName'],
      type: CollaborationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => CollaborationType.general,
      ),
      status: CollaborationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => CollaborationStatus.active,
      ),
      participants: (json['participants'] as List<dynamic>)
          .map((p) => CollaborationParticipant.fromJson(p))
          .toList(),
      invitedUserIds: List<String>.from(json['invitedUserIds'] ?? []),
      metadata: json['metadata'] ?? {},
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

enum CollaborationType {
  general,
  clinical,
  research,
  training,
  consultation,
}

enum CollaborationStatus {
  active,
  paused,
  ended,
  archived,
}

class CollaborationParticipant {
  final String userId;
  final String userName;
  final ParticipantRole role;
  final ParticipantStatus status;
  final DateTime joinedAt;
  final DateTime lastActivity;

  const CollaborationParticipant({
    required this.userId,
    required this.userName,
    required this.role,
    required this.status,
    required this.joinedAt,
    required this.lastActivity,
  });

  CollaborationParticipant copyWith({
    String? userId,
    String? userName,
    ParticipantRole? role,
    ParticipantStatus? status,
    DateTime? joinedAt,
    DateTime? lastActivity,
  }) {
    return CollaborationParticipant(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      role: role ?? this.role,
      status: status ?? this.status,
      joinedAt: joinedAt ?? this.joinedAt,
      lastActivity: lastActivity ?? this.lastActivity,
    );
  }

  static CollaborationParticipant empty() {
    return const CollaborationParticipant(
      userId: '',
      userName: '',
      role: ParticipantRole.participant,
      status: ParticipantStatus.offline,
      joinedAt: null,
      lastActivity: null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'role': role.name,
      'status': status.name,
      'joinedAt': joinedAt.toIso8601String(),
      'lastActivity': lastActivity.toIso8601String(),
    };
  }

  factory CollaborationParticipant.fromJson(Map<String, dynamic> json) {
    return CollaborationParticipant(
      userId: json['userId'],
      userName: json['userName'],
      role: ParticipantRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => ParticipantRole.participant,
      ),
      status: ParticipantStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ParticipantStatus.offline,
      ),
      joinedAt: DateTime.parse(json['joinedAt']),
      lastActivity: DateTime.parse(json['lastActivity']),
    );
  }
}

enum ParticipantRole {
  host,
  moderator,
  participant,
  observer,
}

enum ParticipantStatus {
  online,
  away,
  busy,
  offline,
}

enum ParticipantAction {
  joined,
  left,
  status_changed,
}

class CollaborationMessage {
  final String id;
  final String sessionId;
  final String userId;
  final String userName;
  final String content;
  final MessageType type;
  final Map<String, dynamic> metadata;
  final String? replyToMessageId;
  final DateTime timestamp;
  final bool isEdited;
  final bool isDeleted;

  const CollaborationMessage({
    required this.id,
    required this.sessionId,
    required this.userId,
    required this.userName,
    required this.content,
    required this.type,
    required this.metadata,
    this.replyToMessageId,
    required this.timestamp,
    required this.isEdited,
    required this.isDeleted,
  });

  CollaborationMessage copyWith({
    String? id,
    String? sessionId,
    String? userId,
    String? userName,
    String? content,
    MessageType? type,
    Map<String, dynamic>? metadata,
    String? replyToMessageId,
    DateTime? timestamp,
    bool? isEdited,
    bool? isDeleted,
  }) {
    return CollaborationMessage(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      content: content ?? this.content,
      type: type ?? this.type,
      metadata: metadata ?? this.metadata,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      timestamp: timestamp ?? this.timestamp,
      isEdited: isEdited ?? this.isEdited,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionId': sessionId,
      'userId': userId,
      'userName': userName,
      'content': content,
      'type': type.name,
      'metadata': metadata,
      'replyToMessageId': replyToMessageId,
      'timestamp': timestamp.toIso8601String(),
      'isEdited': isEdited,
      'isDeleted': isDeleted,
    };
  }

  factory CollaborationMessage.fromJson(Map<String, dynamic> json) {
    return CollaborationMessage(
      id: json['id'],
      sessionId: json['sessionId'],
      userId: json['userId'],
      userName: json['userName'],
      content: json['content'],
      type: MessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MessageType.text,
      ),
      metadata: json['metadata'] ?? {},
      replyToMessageId: json['replyToMessageId'],
      timestamp: DateTime.parse(json['timestamp']),
      isEdited: json['isEdited'] ?? false,
      isDeleted: json['isDeleted'] ?? false,
    );
  }
}

enum MessageType {
  text,
  image,
  file,
  audio,
  video,
  system,
}

class CollaborationEvent {
  final String id;
  final String sessionId;
  final CollaborationEventType eventType;
  final String userId;
  final String userName;
  final DateTime timestamp;
  final Map<String, dynamic> data;

  const CollaborationEvent({
    required this.id,
    required this.sessionId,
    required this.eventType,
    required this.userId,
    required this.userName,
    required this.timestamp,
    required this.data,
  });
}

enum CollaborationEventType {
  session_created,
  session_joined,
  session_left,
  user_invited,
  message_sent,
  message_edited,
  message_deleted,
  participant_status_changed,
}

class ParticipantStatusEvent {
  final String id;
  final String sessionId;
  final String userId;
  final String userName;
  final ParticipantStatus status;
  final DateTime timestamp;
  final ParticipantAction action;

  const ParticipantStatusEvent({
    required this.id,
    required this.sessionId,
    required this.userId,
    required this.userName,
    required this.status,
    required this.timestamp,
    required this.action,
  });
}
