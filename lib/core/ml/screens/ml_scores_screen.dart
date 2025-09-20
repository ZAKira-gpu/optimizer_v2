import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ml_score_provider.dart';
import '../widgets/ml_score_display.dart';

/// ML Scores Screen
///
/// A dedicated screen for displaying and managing ML-calculated scores
class MLScoresScreen extends StatefulWidget {
  const MLScoresScreen({super.key});

  @override
  State<MLScoresScreen> createState() => _MLScoresScreenState();
}

class _MLScoresScreenState extends State<MLScoresScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProvider();
    });
  }

  Future<void> _initializeProvider() async {
    final provider = Provider.of<MLScoreProvider>(context, listen: false);
    if (!provider.isInitialized) {
      await provider.initialize();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Scores'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Consumer<MLScoreProvider>(
            builder: (context, provider, child) {
              return IconButton(
                onPressed: provider.isCalculating
                    ? null
                    : () => provider.calculateCurrentScores(),
                icon: provider.isCalculating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                tooltip: 'Refresh Scores',
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'AI-Powered Health Analysis',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Your personalized scores based on your daily activities and habits',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),

            // Score display
            const MLScoreDisplay(showHistory: true, showRecommendations: true),

            const SizedBox(height: 24),

            // Statistics section
            _StatisticsSection(),

            const SizedBox(height: 24),

            // Action buttons
            _ActionButtons(),
          ],
        ),
      ),
    );
  }
}

/// Statistics section
class _StatisticsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MLScoreProvider>(
      builder: (context, provider, child) {
        final stats = provider.getScoreStatistics();

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Statistics',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Average Health',
                      value:
                          stats['averageHealth']?.toStringAsFixed(1) ?? '0.0',
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Average Efficiency',
                      value:
                          stats['averageEfficiency']?.toStringAsFixed(1) ??
                          '0.0',
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Average Lifestyle',
                      value:
                          stats['averageLifestyle']?.toStringAsFixed(1) ??
                          '0.0',
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Average Overall',
                      value:
                          stats['averageOverall']?.toStringAsFixed(1) ?? '0.0',
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Stat card
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Action buttons
class _ActionButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Navigate to detailed history
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Detailed history coming soon!'),
                    ),
                  );
                },
                icon: const Icon(Icons.timeline),
                label: const Text('View History'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Navigate to recommendations
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Detailed recommendations coming soon!'),
                    ),
                  );
                },
                icon: const Icon(Icons.lightbulb),
                label: const Text('Get Tips'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
