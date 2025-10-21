import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class VoiceNotesScreen extends StatefulWidget {
  const VoiceNotesScreen({super.key});

  @override
  State<VoiceNotesScreen> createState() => _VoiceNotesScreenState();
}

class _VoiceNotesScreenState extends State<VoiceNotesScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  bool _isRecording = false;
  bool _isPaused = false;
  bool _isPlaying = false;
  Duration _recordingDuration = Duration.zero;
  Duration _playbackDuration = Duration.zero;
  Timer? _recordingTimer;
  Timer? _playbackTimer;
  
  final List<VoiceNote> _voiceNotes = [
    VoiceNote(
      id: '1',
      title: 'Hasta Ahmet Yılmaz - Depresyon',
      duration: const Duration(minutes: 3, seconds: 45),
      date: DateTime(2024, 2, 15, 10, 30),
      transcription: 'Hasta depresyon belirtileri gösteriyor. Uyku sorunları ve iştah kaybı var. İlaç dozunu artırmayı düşünüyorum.',
      tags: ['Depresyon', 'İlaç', 'Uyku'],
    ),
    VoiceNote(
      id: '2',
      title: 'Randevu Notları - Ayşe Demir',
      duration: const Duration(minutes: 2, seconds: 15),
      date: DateTime(2024, 2, 14, 14, 20),
      transcription: 'Hasta anksiyete seviyesi azalmış. Gevşeme egzersizlerini düzenli yapıyor. Bir sonraki randevuda CBT tekniklerini uygulayacağız.',
      tags: ['Anksiyete', 'CBT', 'Gevşeme'],
    ),
    VoiceNote(
      id: '3',
      title: 'Tedavi Planı - Mehmet Kaya',
      duration: const Duration(minutes: 4, seconds: 30),
      date: DateTime(2024, 2, 13, 16, 45),
      transcription: 'Bipolar bozukluk hastası için yeni tedavi planı. Mood stabilizer dozunu ayarlayacağız. Aile ile görüşme planlanacak.',
      tags: ['Bipolar', 'Mood Stabilizer', 'Aile'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _recordingTimer?.cancel();
    _playbackTimer?.cancel();
    super.dispose();
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _isPaused = false;
      _recordingDuration = Duration.zero;
    });
    
    _animationController.repeat(reverse: true);
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordingDuration = Duration(seconds: timer.tick);
      });
    });
    
    // Haptic feedback
    HapticFeedback.mediumImpact();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Kayıt başlatıldı')),
    );
  }

  void _pauseRecording() {
    setState(() {
      _isPaused = !_isPaused;
    });
    
    if (_isPaused) {
      _animationController.stop();
      _recordingTimer?.cancel();
    } else {
      _animationController.repeat(reverse: true);
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _recordingDuration = Duration(seconds: timer.tick);
        });
      });
    }
    
    HapticFeedback.lightImpact();
  }

  void _stopRecording() {
    setState(() {
      _isRecording = false;
      _isPaused = false;
    });
    
    _animationController.stop();
    _recordingTimer?.cancel();
    
    HapticFeedback.mediumImpact();
    
    _showSaveDialog();
  }

  void _playNote(VoiceNote note) {
    setState(() {
      _isPlaying = true;
      _playbackDuration = Duration.zero;
    });
    
    _playbackTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _playbackDuration = Duration(seconds: timer.tick);
      });
      
      if (_playbackDuration >= note.duration) {
        _stopPlayback();
      }
    });
    
    HapticFeedback.lightImpact();
  }

  void _stopPlayback() {
    setState(() {
      _isPlaying = false;
      _playbackDuration = Duration.zero;
    });
    
    _playbackTimer?.cancel();
    HapticFeedback.lightImpact();
  }

  void _showSaveDialog() {
    final titleController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ses Notunu Kaydet'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Not Başlığı',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Kayıt Süresi: ${_formatDuration(_recordingDuration)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                final newNote = VoiceNote(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleController.text,
                  duration: _recordingDuration,
                  date: DateTime.now(),
                  transcription: 'Transkripsiyon işlemi devam ediyor...',
                  tags: [],
                );
                
                setState(() {
                  _voiceNotes.insert(0, newNote);
                });
                
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ses notu kaydedildi')),
                );
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '$twoDigitMinutes:$twoDigitSeconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sesli Notlar'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearch,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilters,
          ),
        ],
      ),
      body: Column(
        children: [
          // Kayıt kontrol paneli
          if (_isRecording || _isPaused) _buildRecordingPanel(),
          
          // Ses notları listesi
          Expanded(
            child: _voiceNotes.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _voiceNotes.length,
                    itemBuilder: (context, index) {
                      return _buildVoiceNoteCard(_voiceNotes[index]);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: _isRecording
          ? Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  heroTag: 'pause',
                  onPressed: _pauseRecording,
                  backgroundColor: _isPaused ? Colors.green : Colors.orange,
                  child: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
                ),
                const SizedBox(width: 16),
                FloatingActionButton(
                  heroTag: 'stop',
                  onPressed: _stopRecording,
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.stop),
                ),
              ],
            )
          : FloatingActionButton(
              onPressed: _startRecording,
              backgroundColor: colorScheme.primary,
              child: AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _isRecording ? _scaleAnimation.value : 1.0,
                    child: const Icon(Icons.mic, color: Colors.white),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildRecordingPanel() {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.red.withOpacity(0.1),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _isPaused ? 'Kayıt Duraklatıldı' : 'Kayıt Devam Ediyor',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const Spacer(),
              Text(
                _formatDuration(_recordingDuration),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _recordingDuration.inSeconds / 300, // 5 dakika max
            backgroundColor: Colors.red.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.mic_off,
            size: 64,
            color: colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz ses notu yok',
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'İlk ses notunuzu kaydetmek için\nmikrofon butonuna basın',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceNoteCard(VoiceNote note) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isCurrentlyPlaying = _isPlaying && _playbackDuration > Duration.zero;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    note.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  _formatDuration(note.duration),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${note.date.day}/${note.date.month}/${note.date.year} ${note.date.hour}:${note.date.minute.toString().padLeft(2, '0')}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              note.transcription,
              style: theme.textTheme.bodyMedium,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (note.tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: note.tags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                IconButton(
                  onPressed: () => _playNote(note),
                  icon: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: colorScheme.primary,
                  ),
                ),
                if (isCurrentlyPlaying) ...[
                  Expanded(
                    child: LinearProgressIndicator(
                      value: _playbackDuration.inSeconds / note.duration.inSeconds,
                      backgroundColor: colorScheme.primary.withOpacity(0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDuration(_playbackDuration),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
                const Spacer(),
                IconButton(
                  onPressed: () => _shareNote(note),
                  icon: const Icon(Icons.share),
                ),
                IconButton(
                  onPressed: () => _deleteNote(note),
                  icon: const Icon(Icons.delete),
                  color: Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSearch() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ses Notlarında Ara'),
        content: const TextField(
          decoration: InputDecoration(
            labelText: 'Arama terimi',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Arama özelliği yakında eklenecek')),
              );
            },
            child: const Text('Ara'),
          ),
        ],
      ),
    );
  }

  void _showFilters() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtreler'),
        content: const Text('Filtreleme seçenekleri burada olacak.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _shareNote(VoiceNote note) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${note.title} paylaşım özelliği yakında eklenecek')),
    );
  }

  void _deleteNote(VoiceNote note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ses Notunu Sil'),
        content: Text('${note.title} adlı ses notunu silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _voiceNotes.removeWhere((n) => n.id == note.id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ses notu silindi')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
}

class VoiceNote {
  final String id;
  final String title;
  final Duration duration;
  final DateTime date;
  final String transcription;
  final List<String> tags;

  VoiceNote({
    required this.id,
    required this.title,
    required this.duration,
    required this.date,
    required this.transcription,
    required this.tags,
  });
}
