import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class TeamCollaborationService {
  static final TeamCollaborationService _instance = TeamCollaborationService._internal();
  factory TeamCollaborationService() => _instance;
  TeamCollaborationService._internal();

  // Team data
  List<Map<String, dynamic>> _teamMembers = [];
  List<Map<String, dynamic>> _sharedNotes = [];
  List<Map<String, dynamic>> _comments = [];
  List<Map<String, dynamic>> _collaborationHistory = [];
  
  // Stream controllers
  final StreamController<List<Map<String, dynamic>>> _teamController = StreamController<List<Map<String, dynamic>>>.broadcast();
  final StreamController<Map<String, dynamic>> _noteController = StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _commentController = StreamController<Map<String, dynamic>>.broadcast();

  // Streams
  Stream<List<Map<String, dynamic>>> get teamStream => _teamController.stream;
  Stream<Map<String, dynamic>> get noteStream => _noteController.stream;
  Stream<Map<String, dynamic>> get commentStream => _commentController.stream;

  // Getter'lar
  List<Map<String, dynamic>> get teamMembers => List.unmodifiable(_teamMembers);
  List<Map<String, dynamic>> get sharedNotes => List.unmodifiable(_sharedNotes);
  List<Map<String, dynamic>> get comments => List.unmodifiable(_comments);
  List<Map<String, dynamic>> get collaborationHistory => List.unmodifiable(_collaborationHistory);

  // Servisi başlat
  Future<void> initialize() async {
    await _loadTeamData();
    await _loadSharedNotes();
    await _loadComments();
    await _loadCollaborationHistory();
    
    // Simulate real-time updates
    _startRealTimeUpdates();
  }

  // Real-time updates başlat
  void _startRealTimeUpdates() {
    Timer.periodic(const Duration(seconds: 30), (_) {
      _simulateTeamActivity();
    });
  }

  // Team activity simülasyonu
  void _simulateTeamActivity() {
    final activities = [
      'Yeni not eklendi',
      'Yorum yapıldı',
      'Dosya paylaşıldı',
      'Görev tamamlandı',
      'Toplantı planlandı',
    ];
    
    final randomActivity = activities[DateTime.now().millisecondsSinceEpoch % activities.length];
    
    final activity = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'type': 'activity',
      'message': randomActivity,
      'timestamp': DateTime.now().toIso8601String(),
      'userId': _getRandomTeamMember()['id'],
    };
    
    _collaborationHistory.insert(0, activity);
    _saveCollaborationHistory();
  }

  // Team members
  Future<void> addTeamMember(Map<String, dynamic> member) async {
    member['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    member['joinedAt'] = DateTime.now().toIso8601String();
    member['status'] = 'active';
    
    _teamMembers.add(member);
    _teamController.add(_teamMembers);
    _saveTeamData();
  }

  Future<void> updateTeamMember(String id, Map<String, dynamic> updates) async {
    final index = _teamMembers.indexWhere((member) => member['id'] == id);
    if (index != -1) {
      _teamMembers[index].addAll(updates);
      _teamMembers[index]['updatedAt'] = DateTime.now().toIso8601String();
      
      _teamController.add(_teamMembers);
      _saveTeamData();
    }
  }

  Future<void> removeTeamMember(String id) async {
    _teamMembers.removeWhere((member) => member['id'] == id);
    _teamController.add(_teamMembers);
    _saveTeamData();
  }

  // Shared notes
  Future<void> createSharedNote(Map<String, dynamic> note) async {
    note['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    note['createdAt'] = DateTime.now().toIso8601String();
    note['updatedAt'] = DateTime.now().toIso8601String();
    note['version'] = 1;
    note['collaborators'] = note['collaborators'] ?? [];
    
    _sharedNotes.add(note);
    _noteController.add(note);
    _saveSharedNotes();
  }

  Future<void> updateSharedNote(String id, Map<String, dynamic> updates) async {
    final index = _sharedNotes.indexWhere((note) => note['id'] == id);
    if (index != -1) {
      final currentVersion = _sharedNotes[index]['version'] ?? 1;
      _sharedNotes[index].addAll(updates);
      _sharedNotes[index]['updatedAt'] = DateTime.now().toIso8601String();
      _sharedNotes[index]['version'] = currentVersion + 1;
      
      _noteController.add(_sharedNotes[index]);
      _saveSharedNotes();
    }
  }

  Future<void> deleteSharedNote(String id) async {
    _sharedNotes.removeWhere((note) => note['id'] == id);
    _saveSharedNotes();
  }

  // Comments
  Future<void> addComment(String noteId, Map<String, dynamic> comment) async {
    comment['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    comment['noteId'] = noteId;
    comment['createdAt'] = DateTime.now().toIso8601String();
    comment['replies'] = comment['replies'] ?? [];
    
    _comments.add(comment);
    _commentController.add(comment);
    _saveComments();
  }

  Future<void> replyToComment(String commentId, Map<String, dynamic> reply) async {
    final index = _comments.indexWhere((comment) => comment['id'] == commentId);
    if (index != -1) {
      reply['id'] = DateTime.now().millisecondsSinceEpoch.toString();
      reply['createdAt'] = DateTime.now().toIso8601String();
      
      _comments[index]['replies'].add(reply);
      _commentController.add(_comments[index]);
      _saveComments();
    }
  }

  Future<void> deleteComment(String id) async {
    _comments.removeWhere((comment) => comment['id'] == id);
    _saveComments();
  }

  // Version control
  List<Map<String, dynamic>> getNoteVersions(String noteId) {
    final note = _sharedNotes.firstWhere((note) => note['id'] == noteId);
    final versions = <Map<String, dynamic>>[];
    
    // Simulate version history
    for (int i = 1; i <= (note['version'] ?? 1); i++) {
      versions.add({
        'version': i,
        'timestamp': DateTime.now().subtract(Duration(hours: i)).toIso8601String(),
        'author': _getRandomTeamMember()['name'],
        'changes': 'Değişiklik $i',
      });
    }
    
    return versions;
  }

  // Collaboration tracking
  Map<String, dynamic> getCollaborationStats() {
    return {
      'totalMembers': _teamMembers.length,
      'activeMembers': _teamMembers.where((m) => m['status'] == 'active').length,
      'totalNotes': _sharedNotes.length,
      'totalComments': _comments.length,
      'recentActivity': _collaborationHistory.take(10).toList(),
    };
  }

  // Team member activity
  List<Map<String, dynamic>> getMemberActivity(String memberId) {
    return _collaborationHistory.where((activity) => activity['userId'] == memberId).toList();
  }

  // Search functionality
  List<Map<String, dynamic>> searchNotes(String query) {
    return _sharedNotes.where((note) {
      final title = note['title']?.toString().toLowerCase() ?? '';
      final content = note['content']?.toString().toLowerCase() ?? '';
      final searchQuery = query.toLowerCase();
      
      return title.contains(searchQuery) || content.contains(searchQuery);
    }).toList();
  }

  List<Map<String, dynamic>> searchComments(String query) {
    return _comments.where((comment) {
      final content = comment['content']?.toString().toLowerCase() ?? '';
      final searchQuery = query.toLowerCase();
      
      return content.contains(searchQuery);
    }).toList();
  }

  // Notifications
  List<Map<String, dynamic>> getNotifications() {
    final notifications = <Map<String, dynamic>>[];
    
    // Recent comments
    for (final comment in _comments.take(5)) {
      notifications.add({
        'id': 'comment_${comment['id']}',
        'type': 'comment',
        'message': '${comment['author']} yorum yaptı',
        'timestamp': comment['createdAt'],
        'read': false,
      });
    }
    
    // Recent notes
    for (final note in _sharedNotes.take(3)) {
      notifications.add({
        'id': 'note_${note['id']}',
        'type': 'note',
        'message': '${note['title']} güncellendi',
        'timestamp': note['updatedAt'],
        'read': false,
      });
    }
    
    return notifications;
  }

  // Data persistence
  Future<void> _saveTeamData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('team_members', json.encode(_teamMembers));
  }

  Future<void> _loadTeamData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('team_members');
    if (data != null) {
      _teamMembers = List<Map<String, dynamic>>.from(json.decode(data));
    } else {
      // Demo team members
      _teamMembers = [
        {
          'id': '1',
          'name': 'Dr. Ahmet Yılmaz',
          'role': 'Psikolog',
          'email': 'ahmet@psycliniciai.com',
          'status': 'active',
          'joinedAt': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
        },
        {
          'id': '2',
          'name': 'Dr. Ayşe Demir',
          'role': 'Psikiyatrist',
          'email': 'ayse@psycliniciai.com',
          'status': 'active',
          'joinedAt': DateTime.now().subtract(const Duration(days: 25)).toIso8601String(),
        },
        {
          'id': '3',
          'name': 'Mehmet Kaya',
          'role': 'Terapist',
          'email': 'mehmet@psycliniciai.com',
          'status': 'active',
          'joinedAt': DateTime.now().subtract(const Duration(days: 20)).toIso8601String(),
        },
      ];
    }
  }

  Future<void> _saveSharedNotes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('shared_notes', json.encode(_sharedNotes));
  }

  Future<void> _loadSharedNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('shared_notes');
    if (data != null) {
      _sharedNotes = List<Map<String, dynamic>>.from(json.decode(data));
    }
  }

  Future<void> _saveComments() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('comments', json.encode(_comments));
  }

  Future<void> _loadComments() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('comments');
    if (data != null) {
      _comments = List<Map<String, dynamic>>.from(json.decode(data));
    }
  }

  Future<void> _saveCollaborationHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('collaboration_history', json.encode(_collaborationHistory));
  }

  Future<void> _loadCollaborationHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('collaboration_history');
    if (data != null) {
      _collaborationHistory = List<Map<String, dynamic>>.from(json.decode(data));
    }
  }

  // Helper methods
  Map<String, dynamic> _getRandomTeamMember() {
    if (_teamMembers.isEmpty) {
      return {
        'id': 'unknown',
        'name': 'Bilinmeyen Kullanıcı',
        'role': 'Üye',
      };
    }
    
    final random = DateTime.now().millisecondsSinceEpoch % _teamMembers.length;
    return _teamMembers[random];
  }

  // Export collaboration data
  Future<String> exportCollaborationData() async {
    final data = {
      'teamMembers': _teamMembers,
      'sharedNotes': _sharedNotes,
      'comments': _comments,
      'collaborationHistory': _collaborationHistory,
      'exportedAt': DateTime.now().toIso8601String(),
    };
    
    return json.encode(data);
  }

  // Import collaboration data
  Future<void> importCollaborationData(String data) async {
    try {
      final importedData = json.decode(data);
      
      if (importedData['teamMembers'] != null) {
        _teamMembers = List<Map<String, dynamic>>.from(importedData['teamMembers']);
      }
      
      if (importedData['sharedNotes'] != null) {
        _sharedNotes = List<Map<String, dynamic>>.from(importedData['sharedNotes']);
      }
      
      if (importedData['comments'] != null) {
        _comments = List<Map<String, dynamic>>.from(importedData['comments']);
      }
      
      if (importedData['collaborationHistory'] != null) {
        _collaborationHistory = List<Map<String, dynamic>>.from(importedData['collaborationHistory']);
      }
      
      await _saveTeamData();
      await _saveSharedNotes();
      await _saveComments();
      await _saveCollaborationHistory();
      
    } catch (e) {
      throw Exception('Import failed: $e');
    }
  }

  // Dispose
  void dispose() {
    _teamController.close();
    _noteController.close();
    _commentController.close();
  }
}
