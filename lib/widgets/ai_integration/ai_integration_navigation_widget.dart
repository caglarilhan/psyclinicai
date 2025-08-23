import 'package:flutter/material.dart';
import 'package:psyclinicai/widgets/ai_analytics/advanced_analytics_dashboard_widget.dart';
import 'package:psyclinicai/widgets/ai_integration/ai_model_integration_dashboard_widget.dart';
import 'package:psyclinicai/widgets/ai_model_marketplace/ai_marketplace_widget.dart';
import 'package:psyclinicai/widgets/ai_model_training/ai_model_training_dashboard_widget.dart';
import 'package:psyclinicai/widgets/predictive_analytics/predictive_analytics_dashboard_widget.dart';
import 'package:psyclinicai/widgets/voice_analysis/voice_analysis_dashboard_widget.dart';
import 'package:psyclinicai/widgets/facial_analysis/facial_analysis_dashboard_widget.dart';
import 'package:psyclinicai/widgets/smart_notifications/smart_notifications_dashboard_widget.dart';
import 'package:psyclinicai/widgets/crisis_detection/crisis_detection_dashboard_widget.dart';
import 'package:psyclinicai/widgets/personalized_treatment/personalized_treatment_dashboard_widget.dart';

/// AI Integration Navigation Widget for PsyClinicAI
/// Provides easy access to all AI-related dashboards and services
class AIIntegrationNavigationWidget extends StatefulWidget {
  const AIIntegrationNavigationWidget({Key? key}) : super(key: key);

  @override
  State<AIIntegrationNavigationWidget> createState() => _AIIntegrationNavigationWidgetState();
}

class _AIIntegrationNavigationWidgetState extends State<AIIntegrationNavigationWidget> {
  final List<AIFeature> _aiFeatures = [
    AIFeature(
      title: 'Advanced AI Analytics',
      description: 'Comprehensive AI-powered analytics and insights',
      icon: Icons.analytics,
      color: Colors.blue,
      route: '/ai-analytics',
      widget: const AdvancedAnalyticsDashboardWidget(),
      category: 'Core AI',
    ),
    AIFeature(
      title: 'AI Model Integration',
      description: 'Integrate with GPT-4 and Claude AI models',
      icon: Icons.integration_instructions,
      color: Colors.green,
      route: '/ai-model-integration',
      widget: const AIModelIntegrationDashboardWidget(),
      category: 'Core AI',
    ),
    AIFeature(
      title: 'AI Model Marketplace',
      description: 'Browse and install third-party AI models',
      icon: Icons.store,
      color: Colors.orange,
      route: '/ai-marketplace',
      widget: const AIMarketplaceWidget(),
      category: 'AI Models',
    ),
    AIFeature(
      title: 'AI Model Training',
      description: 'Train and manage custom AI models',
      icon: Icons.model_training,
      color: Colors.purple,
      route: '/ai-training',
      widget: const AIModelTrainingDashboardWidget(),
      category: 'AI Models',
    ),
    AIFeature(
      title: 'Predictive Analytics',
      description: 'AI-powered predictions and forecasting',
      icon: Icons.trending_up,
      color: Colors.teal,
      route: '/predictive-analytics',
      widget: const PredictiveAnalyticsDashboardWidget(),
      category: 'Analytics',
    ),
    AIFeature(
      title: 'Voice Analysis',
      description: 'Real-time voice emotion and stress analysis',
      icon: Icons.mic,
      color: Colors.indigo,
      route: '/voice-analysis',
      widget: const VoiceAnalysisDashboardWidget(),
      category: 'Real-time AI',
    ),
    AIFeature(
      title: 'Facial Analysis',
      description: 'Facial expression and emotion recognition',
      icon: Icons.face,
      color: Colors.pink,
      route: '/facial-analysis',
      widget: const FacialAnalysisDashboardWidget(),
      category: 'Real-time AI',
    ),
    AIFeature(
      title: 'Smart Notifications',
      description: 'Context-aware intelligent notifications',
      icon: Icons.notifications_active,
      color: Colors.amber,
      route: '/smart-notifications',
      widget: const SmartNotificationsDashboardWidget(),
      category: 'Intelligence',
    ),
    AIFeature(
      title: 'Crisis Detection',
      description: 'Real-time crisis detection and intervention',
      icon: Icons.warning,
      color: Colors.red,
      route: '/crisis-detection',
      widget: const CrisisDetectionDashboardWidget(),
      category: 'Safety',
    ),
    AIFeature(
      title: 'Personalized Treatment',
      description: 'AI-driven personalized treatment plans',
      icon: Icons.healing,
      color: Colors.lightGreen,
      route: '/personalized-treatment',
      widget: const PersonalizedTreatmentDashboardWidget(),
      category: 'Treatment',
    ),
  ];

  String _selectedCategory = 'All';
  String _searchQuery = '';

  List<String> get _categories {
    final categories = _aiFeatures.map((f) => f.category).toSet().toList();
    categories.insert(0, 'All');
    return categories;
  }

  List<AIFeature> get _filteredFeatures {
    return _aiFeatures.where((feature) {
      final matchesCategory = _selectedCategory == 'All' || feature.category == _selectedCategory;
      final matchesSearch = feature.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          feature.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Integration Hub'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchAndFilterBar(),
          Expanded(
            child: _buildFeatureGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.deepPurple,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Bar
          TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search AI features...',
              hintStyle: const TextStyle(color: Colors.white70),
              prefixIcon: const Icon(Icons.search, color: Colors.white70),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 16),
          // Category Filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = selected ? category : 'All';
                      });
                    },
                    backgroundColor: Colors.white.withOpacity(0.1),
                    selectedColor: Colors.white.withOpacity(0.3),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.deepPurple : Colors.white,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureGrid() {
    if (_filteredFeatures.isEmpty) {
      return _buildEmptyState();
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
      ),
      itemCount: _filteredFeatures.length,
      itemBuilder: (context, index) {
        final feature = _filteredFeatures[index];
        return _buildFeatureCard(feature);
      },
    );
  }

  Widget _buildFeatureCard(AIFeature feature) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _navigateToFeature(feature),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                feature.color.withOpacity(0.1),
                feature.color.withOpacity(0.05),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon and Category
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: feature.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        feature.icon,
                        color: feature.color,
                        size: 24,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: feature.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        feature.category,
                        style: TextStyle(
                          color: feature.color,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Title
                Text(
                  feature.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Description
                Expanded(
                  child: Text(
                    feature.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 16),
                // Action Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _navigateToFeature(feature),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: feature.color,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text(
                      'Open',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No AI features found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filter criteria',
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _searchQuery = '';
                _selectedCategory = 'All';
              });
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Clear Filters'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToFeature(AIFeature feature) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(feature.title),
            backgroundColor: feature.color,
            foregroundColor: Colors.white,
          ),
          body: feature.widget,
        ),
      ),
    );
  }
}

/// AI Feature Model
class AIFeature {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String route;
  final Widget widget;
  final String category;

  const AIFeature({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.route,
    required this.widget,
    required this.category,
  });
}

/// Voice Analysis Dashboard Widget (Placeholder)
class VoiceAnalysisDashboardWidget extends StatelessWidget {
  const VoiceAnalysisDashboardWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Voice Analysis Dashboard\n(Implementation in progress)',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}

/// Facial Analysis Dashboard Widget (Placeholder)
class FacialAnalysisDashboardWidget extends StatelessWidget {
  const FacialAnalysisDashboardWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Facial Analysis Dashboard\n(Implementation in progress)',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}

/// Smart Notifications Dashboard Widget (Placeholder)
class SmartNotificationsDashboardWidget extends StatelessWidget {
  const SmartNotificationsDashboardWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Smart Notifications Dashboard\n(Implementation in progress)',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}

/// Crisis Detection Dashboard Widget (Placeholder)
class CrisisDetectionDashboardWidget extends StatelessWidget {
  const CrisisDetectionDashboardWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Crisis Detection Dashboard\n(Implementation in progress)',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}

/// Personalized Treatment Dashboard Widget (Placeholder)
class PersonalizedTreatmentDashboardWidget extends StatelessWidget {
  const PersonalizedTreatmentDashboardWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Personalized Treatment Dashboard\n(Implementation in progress)',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}
