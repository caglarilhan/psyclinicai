import 'package:flutter/material.dart';
import '../../models/case_models.dart';
import '../../utils/app_theme.dart';
import '../../utils/date_utils.dart';

class CaseListWidget extends StatelessWidget {
  final List<Case> cases;
  final Function(Case) onCaseSelected;
  final Case? selectedCase;
  final VoidCallback onRefresh;

  const CaseListWidget({
    super.key,
    required this.cases,
    required this.onCaseSelected,
    this.selectedCase,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (cases.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Henüz vaka bulunmuyor',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Yeni vaka eklemek için + butonuna tıklayın',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: cases.length,
        itemBuilder: (context, index) {
          final case_ = cases[index];
          final isSelected = selectedCase?.id == case_.id;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildCaseCard(case_, isSelected, context),
          );
        },
      ),
    );
  }

  Widget _buildCaseCard(Case case_, bool isSelected, BuildContext context) {
    return Card(
      elevation: isSelected ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: AppTheme.primaryColor, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => onCaseSelected(case_),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık ve durum
              Row(
                children: [
                  Expanded(
                    child: Text(
                      case_.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildStatusChip(case_.status),
                ],
              ),
              const SizedBox(height: 8),
              
              // Açıklama
              if (case_.description.isNotEmpty) ...[
                Text(
                  case_.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
              ],
              
              // Meta bilgiler
              Row(
                children: [
                  _buildInfoChip(
                    Icons.priority_high,
                    case_.priorityText,
                    case_.priorityColor,
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    Icons.category,
                    case_.typeText,
                    Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    Icons.trending_up,
                    case_.progressText,
                    case_.progressColor,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // İlerleme ve seans bilgileri
              Row(
                children: [
                  _buildProgressIndicator(case_),
                  const Spacer(),
                  _buildSessionInfo(case_),
                ],
              ),
              const SizedBox(height: 12),
              
              // Alt bilgiler
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Başlangıç: ${AppDateUtils.formatDate(case_.startDate)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  if (case_.lastSessionDate != null) ...[
                    Icon(
                      Icons.event,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Son seans: ${AppDateUtils.formatDate(case_.lastSessionDate!)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
              
              // Tanı bilgisi
              if (case_.diagnosis != null && case_.diagnosis!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.medical_services,
                        size: 16,
                        color: Colors.blue[700],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          case_.diagnosis!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(CaseStatus status) {
    Color backgroundColor;
    Color textColor;
    String text;
    
    switch (status) {
      case CaseStatus.active:
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        text = 'Aktif';
        break;
      case CaseStatus.onHold:
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[800]!;
        text = 'Beklemede';
        break;
      case CaseStatus.completed:
        backgroundColor = Colors.blue[100]!;
        textColor = Colors.blue[800]!;
        text = 'Tamamlandı';
        break;
      case CaseStatus.transferred:
        backgroundColor = Colors.purple[100]!;
        textColor = Colors.purple[800]!;
        text = 'Transfer';
        break;
      case CaseStatus.closed:
        backgroundColor = Colors.grey[100]!;
        textColor = Colors.grey[800]!;
        text = 'Kapatıldı';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            text,
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

  Widget _buildProgressIndicator(Case case_) {
    return Row(
      children: [
        Icon(
          Icons.circle,
          size: 12,
          color: case_.progressColor,
        ),
        const SizedBox(width: 4),
        Text(
          'İlerleme: ${case_.progressText}',
          style: TextStyle(
            fontSize: 12,
            color: case_.progressColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSessionInfo(Case case_) {
    return Row(
      children: [
        Icon(
          Icons.meeting_room,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Text(
          '${case_.totalSessions} seans',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
