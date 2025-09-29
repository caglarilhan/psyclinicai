import 'package:flutter/material.dart';
import '../../models/security_models.dart';
import '../../utils/theme.dart';

class EncryptionWidget extends StatelessWidget {
  final EncryptionConfig config;
  final Function(EncryptionConfig)? onConfigUpdate;

  const EncryptionWidget({
    super.key,
    required this.config,
    this.onConfigUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lock,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Şifreleme Durumu',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Şifreleme algoritması
            _buildInfoRow('Algoritma', config.algorithm, Icons.security),
            
            // Anahtar boyutu
            _buildInfoRow('Anahtar Boyutu', '${config.keySize} bit', Icons.key),
            
            // Anahtar rotasyonu
            _buildInfoRow('Anahtar Rotasyonu', config.keyRotationPeriod, Icons.rotate_right),
            
            // Donanım hızlandırma
            _buildInfoRow(
              'Donanım Hızlandırma', 
              config.hardwareAcceleration ? 'Aktif' : 'Pasif',
              Icons.speed,
              color: config.hardwareAcceleration ? Colors.green : Colors.grey,
            ),
            
            // Desteklenen algoritmalar
            _buildAlgorithmsSection(),
            
            // Anahtar rotasyon zamanlaması
            _buildKeyRotationSection(),
            
            const SizedBox(height: 16),
            
            // Güvenlik skoru
            _buildSecurityScore(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: color ?? AppTheme.primaryColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: color ?? Colors.grey.shade700,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlgorithmsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.list,
                size: 20,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 12),
              Text(
                'Desteklenen Algoritmalar',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: config.supportedAlgorithms.map((algorithm) {
              final isActive = algorithm == config.algorithm;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isActive 
                      ? AppTheme.primaryColor.withOpacity(0.1)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isActive 
                        ? AppTheme.primaryColor
                        : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  algorithm,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isActive 
                        ? AppTheme.primaryColor
                        : Colors.grey.shade700,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyRotationSection() {
    final daysUntilRotation = config.nextKeyRotation.difference(DateTime.now()).inDays;
    final isOverdue = daysUntilRotation < 0;
    final isSoon = daysUntilRotation <= 7;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.schedule,
                size: 20,
                color: isOverdue ? Colors.red : (isSoon ? Colors.orange : Colors.green),
              ),
              const SizedBox(width: 12),
              Text(
                'Anahtar Rotasyon Zamanlaması',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Son rotasyon
          _buildRotationInfo(
            'Son Rotasyon',
            _formatDate(config.lastKeyRotation),
            Icons.history,
            Colors.grey,
          ),
          
          // Sonraki rotasyon
          _buildRotationInfo(
            'Sonraki Rotasyon',
            _formatDate(config.nextKeyRotation),
            Icons.schedule,
            isOverdue ? Colors.red : (isSoon ? Colors.orange : Colors.green),
          ),
          
          // Kalan süre
          if (!isOverdue) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSoon ? Colors.orange.shade50 : Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSoon ? Colors.orange.shade200 : Colors.green.shade200,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isSoon ? Icons.warning : Icons.check_circle,
                    color: isSoon ? Colors.orange : Colors.green,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isSoon 
                        ? 'Anahtar rotasyonu ${daysUntilRotation} gün içinde gerekli'
                        : 'Anahtar rotasyonu ${daysUntilRotation} gün sonra',
                    style: TextStyle(
                      color: isSoon ? Colors.orange.shade800 : Colors.green.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error,
                    color: Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Anahtar rotasyonu ${daysUntilRotation.abs()} gün gecikti!',
                    style: TextStyle(
                      color: Colors.red.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRotationInfo(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityScore() {
    // Şifreleme güvenlik skoru hesaplama
    double score = 0;
    
    // Algoritma skoru
    if (config.algorithm.contains('AES-256')) {
      score += 40;
    } else if (config.algorithm.contains('AES-128')) {
      score += 30;
    } else {
      score += 20;
    }
    
    // Anahtar boyutu skoru
    if (config.keySize >= 256) {
      score += 30;
    } else if (config.keySize >= 128) {
      score += 20;
    } else {
      score += 10;
    }
    
    // Donanım hızlandırma skoru
    if (config.hardwareAcceleration) {
      score += 20;
    }
    
    // Anahtar rotasyonu skoru
    final daysUntilRotation = config.nextKeyRotation.difference(DateTime.now()).inDays;
    if (daysUntilRotation > 30) {
      score += 10;
    } else if (daysUntilRotation > 0) {
      score += 5;
    }
    
    final color = _getScoreColor(score);
    final level = _getScoreLevel(score);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Şifreleme Güvenlik Skoru',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                '${score.toInt()}/100',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: score / 100,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                level,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
              Icon(
                _getScoreIcon(score),
                color: color,
                size: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 90) return Colors.green;
    if (score >= 80) return Colors.lightGreen;
    if (score >= 70) return Colors.orange;
    if (score >= 60) return Colors.deepOrange;
    return Colors.red;
  }

  String _getScoreLevel(double score) {
    if (score >= 90) return 'Mükemmel';
    if (score >= 80) return 'İyi';
    if (score >= 70) return 'Orta';
    if (score >= 60) return 'Zayıf';
    return 'Kritik';
  }

  IconData _getScoreIcon(double score) {
    if (score >= 90) return Icons.verified;
    if (score >= 80) return Icons.check_circle;
    if (score >= 70) return Icons.warning;
    if (score >= 60) return Icons.error;
    return Icons.dangerous;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }
}
