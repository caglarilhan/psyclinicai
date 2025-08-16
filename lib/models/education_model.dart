import 'package:flutter/material.dart';

enum EducationType {
  video,
  pdf,
  interactive,
  audio,
  quiz,
}

enum EducationDifficulty {
  beginner,
  intermediate,
  advanced,
}

class EducationModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final EducationType type;
  final int duration;
  final EducationDifficulty difficulty;
  final List<String> tags;
  final String thumbnail;
  final String contentUrl;
  final String author;
  final double rating;
  final int viewCount;
  final bool isPremium;

  // Kullanıcı ilerlemesi için
  final double? progress;
  final DateTime? lastAccessed;
  final List<String>? completedSections;
  final List<String>? remainingSections;

  const EducationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.type,
    required this.duration,
    required this.difficulty,
    required this.tags,
    required this.thumbnail,
    required this.contentUrl,
    required this.author,
    required this.rating,
    required this.viewCount,
    required this.isPremium,
    this.progress,
    this.lastAccessed,
    this.completedSections,
    this.remainingSections,
  });

  factory EducationModel.fromJson(Map<String, dynamic> json) {
    return EducationModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      type: EducationType.values.firstWhere(
        (e) => e.toString() == 'EducationType.${json['type']}',
        orElse: () => EducationType.video,
      ),
      duration: json['duration'] ?? 0,
      difficulty: EducationDifficulty.values.firstWhere(
        (e) => e.toString() == 'EducationDifficulty.${json['difficulty']}',
        orElse: () => EducationDifficulty.beginner,
      ),
      tags: List<String>.from(json['tags'] ?? []),
      thumbnail: json['thumbnail'] ?? '',
      contentUrl: json['contentUrl'] ?? '',
      author: json['author'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      viewCount: json['viewCount'] ?? 0,
      isPremium: json['isPremium'] ?? false,
      progress: json['progress']?.toDouble(),
      lastAccessed: json['lastAccessed'] != null
          ? DateTime.parse(json['lastAccessed'])
          : null,
      completedSections: List<String>.from(json['completedSections'] ?? []),
      remainingSections: List<String>.from(json['remainingSections'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'type': type.toString().split('.').last,
      'duration': duration,
      'difficulty': difficulty.toString().split('.').last,
      'tags': tags,
      'thumbnail': thumbnail,
      'contentUrl': contentUrl,
      'author': author,
      'rating': rating,
      'viewCount': viewCount,
      'isPremium': isPremium,
      'progress': progress,
      'lastAccessed': lastAccessed?.toIso8601String(),
      'completedSections': completedSections,
      'remainingSections': remainingSections,
    };
  }

  @override
  String toString() {
    return 'EducationModel(id: $id, title: $title, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EducationModel && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }

  // Kopyalama metodu
  EducationModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    EducationType? type,
    int? duration,
    EducationDifficulty? difficulty,
    List<String>? tags,
    String? thumbnail,
    String? contentUrl,
    String? author,
    double? rating,
    int? viewCount,
    bool? isPremium,
    double? progress,
    DateTime? lastAccessed,
    List<String>? completedSections,
    List<String>? remainingSections,
  }) {
    return EducationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      type: type ?? this.type,
      duration: duration ?? this.duration,
      difficulty: difficulty ?? this.difficulty,
      tags: tags ?? this.tags,
      thumbnail: thumbnail ?? this.thumbnail,
      contentUrl: contentUrl ?? this.contentUrl,
      author: author ?? this.author,
      rating: rating ?? this.rating,
      viewCount: viewCount ?? this.viewCount,
      isPremium: isPremium ?? this.isPremium,
      progress: progress ?? this.progress,
      lastAccessed: lastAccessed ?? this.lastAccessed,
      completedSections: completedSections ?? this.completedSections,
      remainingSections: remainingSections ?? this.remainingSections,
    );
  }

  // İçerik tipi ikonu
  IconData get typeIcon {
    switch (type) {
      case EducationType.video:
        return Icons.play_circle;
      case EducationType.pdf:
        return Icons.picture_as_pdf;
      case EducationType.interactive:
        return Icons.touch_app;
      case EducationType.audio:
        return Icons.headphones;
      case EducationType.quiz:
        return Icons.quiz;
    }
  }

  // İçerik tipi rengi
  Color get typeColor {
    switch (type) {
      case EducationType.video:
        return Colors.red;
      case EducationType.pdf:
        return Colors.blue;
      case EducationType.interactive:
        return Colors.green;
      case EducationType.audio:
        return Colors.orange;
      case EducationType.quiz:
        return Colors.purple;
    }
  }

  // Zorluk seviyesi rengi
  Color get difficultyColor {
    switch (difficulty) {
      case EducationDifficulty.beginner:
        return Colors.green;
      case EducationDifficulty.intermediate:
        return Colors.orange;
      case EducationDifficulty.advanced:
        return Colors.red;
    }
  }

  // Premium badge gösterimi
  bool get showPremiumBadge => isPremium;

  // İlerleme yüzdesi
  int get progressPercentage =>
      progress != null ? (progress! * 100).round() : 0;

  // Son erişim zamanı string'i
  String get lastAccessedText {
    if (lastAccessed == null) return 'Hiç erişilmedi';

    final now = DateTime.now();
    final difference = now.difference(lastAccessed!);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} dakika önce';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} saat önce';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün önce';
    } else {
      return '${lastAccessed!.day}/${lastAccessed!.month}/${lastAccessed!.year}';
    }
  }

  // Tamamlanan bölüm sayısı
  int get completedSectionsCount => completedSections?.length ?? 0;

  // Toplam bölüm sayısı
  int get totalSectionsCount =>
      (completedSections?.length ?? 0) + (remainingSections?.length ?? 0);

  // İçerik durumu
  String get contentStatus {
    if (progress == null || progress == 0) return 'Başlanmadı';
    if (progress! < 1) return 'Devam ediyor';
    return 'Tamamlandı';
  }

  // İçerik durumu rengi
  Color get contentStatusColor {
    if (progress == null || progress == 0) return Colors.grey;
    if (progress! < 1) return Colors.orange;
    return Colors.green;
  }
}
