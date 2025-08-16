import 'package:flutter/material.dart';

enum MessageType {
  text,
  image,
  file,
  audio,
  video,
  location,
  system
}

enum MessageStatus {
  sent,
  delivered,
  read,
  failed
}

enum NotificationType {
  message,
  appointment,
  session,
  invoice,
  system,
  urgent
}

enum NotificationPriority {
  low,
  normal,
  high,
  urgent
}

enum ChatType {
  direct,
  group,
  channel,
  announcement
}

class User {
  final String id;
  final String name;
  final String email;
  final String? avatar;
  final String role;
  final bool isOnline;
  final DateTime lastSeen;
  final Map<String, dynamic> metadata;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    required this.role,
    this.isOnline = false,
    required this.lastSeen,
    this.metadata = const {},
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? avatar,
    String? role,
    bool? isOnline,
    DateTime? lastSeen,
    Map<String, dynamic>? metadata,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      role: role ?? this.role,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
      'role': role,
      'isOnline': isOnline,
      'lastSeen': lastSeen.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      avatar: json['avatar'],
      role: json['role'],
      isOnline: json['isOnline'] ?? false,
      lastSeen: DateTime.parse(json['lastSeen']),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }
}

class Chat {
  final String id;
  final String name;
  final ChatType type;
  final List<String> participantIds;
  final List<User> participants;
  final String? lastMessageId;
  final Message? lastMessage;
  final int unreadCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;

  Chat({
    required this.id,
    required this.name,
    required this.type,
    required this.participantIds,
    required this.participants,
    this.lastMessageId,
    this.lastMessage,
    this.unreadCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.metadata = const {},
  });

  bool get isDirect => type == ChatType.direct;
  bool get isGroup => type == ChatType.group;
  bool get isChannel => type == ChatType.channel;
  bool get isAnnouncement => type == ChatType.announcement;

  Chat copyWith({
    String? id,
    String? name,
    ChatType? type,
    List<String>? participantIds,
    List<User>? participants,
    String? lastMessageId,
    Message? lastMessage,
    int? unreadCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return Chat(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      participantIds: participantIds ?? this.participantIds,
      participants: participants ?? this.participants,
      lastMessageId: lastMessageId ?? this.lastMessageId,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'participantIds': participantIds,
      'participants': participants.map((p) => p.toJson()).toList(),
      'lastMessageId': lastMessageId,
      'lastMessage': lastMessage?.toJson(),
      'unreadCount': unreadCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'],
      name: json['name'],
      type: ChatType.values.firstWhere((e) => e.name == json['type']),
      participantIds: List<String>.from(json['participantIds']),
      participants: (json['participants'] as List).map((p) => User.fromJson(p)).toList(),
      lastMessageId: json['lastMessageId'],
      lastMessage: json['lastMessage'] != null ? Message.fromJson(json['lastMessage']) : null,
      unreadCount: json['unreadCount'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }
}

class Message {
  final String id;
  final String chatId;
  final String senderId;
  final User sender;
  final MessageType type;
  final String content;
  final Map<String, dynamic>? mediaData;
  final List<String>? attachments;
  final MessageStatus status;
  final DateTime timestamp;
  final DateTime? editedAt;
  final String? replyToMessageId;
  final Message? replyToMessage;
  final List<String> readBy;
  final Map<String, dynamic> metadata;

  Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.sender,
    required this.type,
    required this.content,
    this.mediaData,
    this.attachments,
    this.status = MessageStatus.sent,
    required this.timestamp,
    this.editedAt,
    this.replyToMessageId,
    this.replyToMessage,
    this.readBy = const [],
    this.metadata = const {},
  });

  bool get isText => type == MessageType.text;
  bool get isMedia => type == MessageType.image || type == MessageType.audio || type == MessageType.video;
  bool get isFile => type == MessageType.file;
  bool get isEdited => editedAt != null;
  bool get isReply => replyToMessageId != null;

  Message copyWith({
    String? id,
    String? chatId,
    String? senderId,
    User? sender,
    MessageType? type,
    String? content,
    Map<String, dynamic>? mediaData,
    List<String>? attachments,
    MessageStatus? status,
    DateTime? timestamp,
    DateTime? editedAt,
    String? replyToMessageId,
    Message? replyToMessage,
    List<String>? readBy,
    Map<String, dynamic>? metadata,
  }) {
    return Message(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      sender: sender ?? this.sender,
      type: type ?? this.type,
      content: content ?? this.content,
      mediaData: mediaData ?? this.mediaData,
      attachments: attachments ?? this.attachments,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      editedAt: editedAt ?? this.editedAt,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      replyToMessage: replyToMessage ?? this.replyToMessage,
      readBy: readBy ?? this.readBy,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatId': chatId,
      'senderId': senderId,
      'sender': sender.toJson(),
      'type': type.name,
      'content': content,
      'mediaData': mediaData,
      'attachments': attachments,
      'status': status.name,
      'timestamp': timestamp.toIso8601String(),
      'editedAt': editedAt?.toIso8601String(),
      'replyToMessageId': replyToMessageId,
      'replyToMessage': replyToMessage?.toJson(),
      'readBy': readBy,
      'metadata': metadata,
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      chatId: json['chatId'],
      senderId: json['senderId'],
      sender: User.fromJson(json['sender']),
      type: MessageType.values.firstWhere((e) => e.name == json['type']),
      content: json['content'],
      mediaData: json['mediaData'] != null ? Map<String, dynamic>.from(json['mediaData']) : null,
      attachments: json['attachments'] != null ? List<String>.from(json['attachments']) : null,
      status: MessageStatus.values.firstWhere((e) => e.name == json['status']),
      timestamp: DateTime.parse(json['timestamp']),
      editedAt: json['editedAt'] != null ? DateTime.parse(json['editedAt']) : null,
      replyToMessageId: json['replyToMessageId'],
      replyToMessage: json['replyToMessage'] != null ? Message.fromJson(json['replyToMessage']) : null,
      readBy: List<String>.from(json['readBy'] ?? []),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }
}

class Notification {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final NotificationPriority priority;
  final String? targetUserId;
  final String? targetChatId;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;

  Notification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.priority = NotificationPriority.normal,
    this.targetUserId,
    this.targetChatId,
    this.data,
    this.isRead = false,
    required this.createdAt,
    this.readAt,
  });

  bool get isUrgent => priority == NotificationPriority.urgent;
  bool get isHigh => priority == NotificationPriority.high;
  bool get isUnread => !isRead;

  Notification copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    NotificationPriority? priority,
    String? targetUserId,
    String? targetChatId,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? createdAt,
    DateTime? readAt,
  }) {
    return Notification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      targetUserId: targetUserId ?? this.targetUserId,
      targetChatId: targetChatId ?? this.targetChatId,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type.name,
      'priority': priority.name,
      'targetUserId': targetUserId,
      'targetChatId': targetChatId,
      'data': data,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
    };
  }

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      type: NotificationType.values.firstWhere((e) => e.name == json['type']),
      priority: NotificationPriority.values.firstWhere((e) => e.name == json['priority']),
      targetUserId: json['targetUserId'],
      targetChatId: json['targetChatId'],
      data: json['data'] != null ? Map<String, dynamic>.from(json['data']) : null,
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
    );
  }
}

class FileAttachment {
  final String id;
  final String name;
  final String originalName;
  final String mimeType;
  final int size;
  final String url;
  final String? thumbnailUrl;
  final String uploadedBy;
  final DateTime uploadedAt;
  final Map<String, dynamic> metadata;

  FileAttachment({
    required this.id,
    required this.name,
    required this.originalName,
    required this.mimeType,
    required this.size,
    required this.url,
    this.thumbnailUrl,
    required this.uploadedBy,
    required this.uploadedAt,
    this.metadata = const {},
  });

  bool get isImage => mimeType.startsWith('image/');
  bool get isVideo => mimeType.startsWith('video/');
  bool get isAudio => mimeType.startsWith('audio/');
  bool get isDocument => mimeType.startsWith('application/') || mimeType.startsWith('text/');
  String get sizeFormatted {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    if (size < 1024 * 1024 * 1024) return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  FileAttachment copyWith({
    String? id,
    String? name,
    String? originalName,
    String? mimeType,
    int? size,
    String? url,
    String? thumbnailUrl,
    String? uploadedBy,
    DateTime? uploadedAt,
    Map<String, dynamic>? metadata,
  }) {
    return FileAttachment(
      id: id ?? this.id,
      name: name ?? this.name,
      originalName: originalName ?? this.originalName,
      mimeType: mimeType ?? this.mimeType,
      size: size ?? this.size,
      url: url ?? this.url,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'originalName': originalName,
      'mimeType': mimeType,
      'size': size,
      'url': url,
      'thumbnailUrl': thumbnailUrl,
      'uploadedBy': uploadedBy,
      'uploadedAt': uploadedAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory FileAttachment.fromJson(Map<String, dynamic> json) {
    return FileAttachment(
      id: json['id'],
      name: json['name'],
      originalName: json['originalName'],
      mimeType: json['mimeType'],
      size: json['size'],
      url: json['url'],
      thumbnailUrl: json['thumbnailUrl'],
      uploadedBy: json['uploadedBy'],
      uploadedAt: DateTime.parse(json['uploadedAt']),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }
}

class ChatStatistics {
  final String chatId;
  final int totalMessages;
  final int totalParticipants;
  final DateTime lastActivity;
  final Map<String, int> participantMessageCounts;
  final Map<String, int> messageTypeCounts;
  final List<String> topContributors;

  ChatStatistics({
    required this.chatId,
    required this.totalMessages,
    required this.totalParticipants,
    required this.lastActivity,
    this.participantMessageCounts = const {},
    this.messageTypeCounts = const {},
    this.topContributors = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'chatId': chatId,
      'totalMessages': totalMessages,
      'totalParticipants': totalParticipants,
      'lastActivity': lastActivity.toIso8601String(),
      'participantMessageCounts': participantMessageCounts,
      'messageTypeCounts': messageTypeCounts,
      'topContributors': topContributors,
    };
  }

  factory ChatStatistics.fromJson(Map<String, dynamic> json) {
    return ChatStatistics(
      chatId: json['chatId'],
      totalMessages: json['totalMessages'],
      totalParticipants: json['totalParticipants'],
      lastActivity: DateTime.parse(json['lastActivity']),
      participantMessageCounts: Map<String, int>.from(json['participantMessageCounts'] ?? {}),
      messageTypeCounts: Map<String, int>.from(json['messageTypeCounts'] ?? {}),
      topContributors: List<String>.from(json['topContributors'] ?? []),
    );
  }
}
