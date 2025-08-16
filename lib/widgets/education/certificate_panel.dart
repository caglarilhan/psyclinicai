import 'package:flutter/material.dart';
import '../../models/education_model.dart';

class CertificatePanel extends StatefulWidget {
  final List<EducationModel> userProgress;

  const CertificatePanel({
    super.key,
    required this.userProgress,
  });

  @override
  State<CertificatePanel> createState() => _CertificatePanelState();
}

class _CertificatePanelState extends State<CertificatePanel> {
  @override
  Widget build(BuildContext context) {
    final completedCourses = widget.userProgress
        .where((content) => content.progress == 1.0)
        .toList();

    final certificates = _generateCertificates(completedCourses);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sertifikalarınız',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: 16),

          // Sertifika istatistikleri
          _buildCertificateStats(completedCourses.length, certificates.length),

          const SizedBox(height: 24),

          // Sertifika listesi
          if (certificates.isNotEmpty) ...[
            Text(
              'Kazanılan Sertifikalar',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: certificates.length,
                itemBuilder: (context, index) {
                  return _buildCertificateCard(certificates[index]);
                },
              ),
            ),
          ] else ...[
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.school_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Henüz sertifika kazanmadınız',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Eğitim içeriklerini tamamlayarak\nsertifika kazanmaya başlayın',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCertificateStats(int completedCourses, int certificates) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Tamamlanan Kurs',
            '$completedCourses',
            Icons.check_circle,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Kazanılan Sertifika',
            '$certificates',
            Icons.verified,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Başarı Oranı',
            '${completedCourses > 0 ? (certificates / completedCourses * 100).toInt() : 0}%',
            Icons.trending_up,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCertificateCard(Certificate certificate) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Sertifika başlığı
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: certificate.type.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    certificate.type.icon,
                    size: 32,
                    color: certificate.type.color,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        certificate.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        certificate.category,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                      ),
                    ],
                  ),
                ),

                // Sertifika rozeti
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.verified,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Sertifika detayları
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    'Veriliş Tarihi',
                    _formatDate(certificate.issuedDate),
                    Icons.calendar_today,
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    'Geçerlilik',
                    'Süresiz',
                    Icons.all_inclusive,
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    'Süre',
                    '${certificate.duration} dakika',
                    Icons.access_time,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Sertifika açıklaması
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceVariant
                    .withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                certificate.description,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 20),

            // Aksiyon butonları
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Sertifikayı indir
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              '${certificate.title} sertifikası indiriliyor...'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('PDF İndir'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Sertifikayı paylaş
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              '${certificate.title} sertifikası paylaşılıyor...'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Paylaş'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.outline,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  List<Certificate> _generateCertificates(
      List<EducationModel> completedCourses) {
    final certificates = <Certificate>[];

    for (final course in completedCourses) {
      if (course.progress == 1.0) {
        certificates.add(Certificate(
          id: 'cert_${course.id}',
          title: course.title,
          category: course.category,
          description:
              'Bu sertifika, ${course.title} eğitimini başarıyla tamamladığınızı belirtir.',
          type: course.type,
          duration: course.duration,
          issuedDate: course.lastAccessed ?? DateTime.now(),
          courseId: course.id,
        ));
      }
    }

    return certificates;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class Certificate {
  final String id;
  final String title;
  final String category;
  final String description;
  final EducationType type;
  final int duration;
  final DateTime issuedDate;
  final String courseId;

  const Certificate({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.type,
    required this.duration,
    required this.issuedDate,
    required this.courseId,
  });
}

extension EducationTypeExtension on EducationType {
  IconData get icon {
    switch (this) {
      case EducationType.video:
        return Icons.video_library;
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

  Color get color {
    switch (this) {
      case EducationType.video:
        return Colors.red;
      case EducationType.pdf:
        return Colors.orange;
      case EducationType.interactive:
        return Colors.green;
      case EducationType.audio:
        return Colors.purple;
      case EducationType.quiz:
        return Colors.blue;
    }
  }
}
