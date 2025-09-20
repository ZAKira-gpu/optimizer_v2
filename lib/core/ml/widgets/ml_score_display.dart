import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ml_score_provider.dart';
import '../models/ml_models.dart';

/// ML Score Display Widget
///
/// Displays health, efficiency, and lifestyle scores with trends and recommendations
class MLScoreDisplay extends StatefulWidget {
  final String? userId;
  final bool showHistory;
  final bool showRecommendations;
  final VoidCallback? onScoreCalculated;

  const MLScoreDisplay({
    super.key,
    this.userId,
    this.showHistory = true,
    this.showRecommendations = true,
    this.onScoreCalculated,
  });

  @override
  State<MLScoreDisplay> createState() => _MLScoreDisplayState();
}

class _MLScoreDisplayState extends State<MLScoreDisplay> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeScores();
    });
  }

  Future<void> _initializeScores() async {
    final provider = Provider.of<MLScoreProvider>(context, listen: false);

    if (!provider.isInitialized) {
      await provider.initialize();
    }

    if (widget.userId != null) {
      await provider.calculateScoresForUser(widget.userId!);
      await provider.loadScoreHistory(widget.userId!);
    } else {
      await provider.calculateCurrentScores();
    }

    widget.onScoreCalculated?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MLScoreProvider>(
      builder: (context, provider, child) {
        if (provider.isCalculating) {
          return const _LoadingWidget();
        }

        if (provider.error.isNotEmpty) {
          return _ErrorWidget(
            error: provider.error,
            onRetry: () => _initializeScores(),
          );
        }

        if (provider.currentScores == null) {
          return _EmptyWidget(onCalculate: () => _initializeScores());
        }

        return _ScoreContent(
          scores: provider.currentScores!,
          trends: provider.scoreTrends,
          showHistory: widget.showHistory,
          showRecommendations: widget.showRecommendations,
          onRefresh: () => _initializeScores(),
        );
      },
    );
  }
}

/// Loading widget
class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Calculating your scores...',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Analyzing your health, efficiency, and lifestyle data',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Error widget
class _ErrorWidget extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorWidget({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'Failed to calculate scores',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}

/// Empty widget
class _EmptyWidget extends StatelessWidget {
  final VoidCallback onCalculate;

  const _EmptyWidget({required this.onCalculate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No scores available',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Calculate your health, efficiency, and lifestyle scores',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onCalculate,
            icon: const Icon(Icons.calculate),
            label: const Text('Calculate Scores'),
          ),
        ],
      ),
    );
  }
}

/// Score content widget
class _ScoreContent extends StatelessWidget {
  final ScoreCalculationResult scores;
  final Map<String, double> trends;
  final bool showHistory;
  final bool showRecommendations;
  final VoidCallback onRefresh;

  const _ScoreContent({
    required this.scores,
    required this.trends,
    required this.showHistory,
    required this.showRecommendations,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with refresh button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your Scores',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            IconButton(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh Scores',
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Overall score
        _OverallScoreCard(score: scores.scores.overallScore),
        const SizedBox(height: 16),

        // Individual scores
        Row(
          children: [
            Expanded(
              child: _ScoreCard(
                title: 'Health',
                score: scores.scores.healthScore,
                trend: trends['health'] ?? 0.0,
                icon: Icons.favorite,
                color: Colors.red,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ScoreCard(
                title: 'Efficiency',
                score: scores.scores.efficiencyScore,
                trend: trends['efficiency'] ?? 0.0,
                icon: Icons.work,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ScoreCard(
                title: 'Lifestyle',
                score: scores.scores.lifestyleScore,
                trend: trends['lifestyle'] ?? 0.0,
                icon: Icons.home,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ScoreCard(
                title: 'Overall',
                score: scores.scores.overallScore,
                trend: trends['overall'] ?? 0.0,
                icon: Icons.star,
                color: Colors.orange,
              ),
            ),
          ],
        ),

        if (showRecommendations) ...[
          const SizedBox(height: 24),
          _RecommendationsCard(recommendations: scores.scores.recommendations),
        ],

        if (showHistory) ...[const SizedBox(height: 24), _ScoreHistoryCard()],
      ],
    );
  }
}

/// Overall score card
class _OverallScoreCard extends StatelessWidget {
  final double score;

  const _OverallScoreCard({required this.score});

  @override
  Widget build(BuildContext context) {
    final level = _getScoreLevel(score);
    final color = _getScoreColor(score);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            'Overall Score',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            score.toStringAsFixed(1),
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            level,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  String _getScoreLevel(double score) {
    if (score >= 90) return 'Excellent';
    if (score >= 80) return 'Very Good';
    if (score >= 70) return 'Good';
    if (score >= 60) return 'Fair';
    if (score >= 50) return 'Poor';
    return 'Very Poor';
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }
}

/// Individual score card
class _ScoreCard extends StatelessWidget {
  final String title;
  final double score;
  final double trend;
  final IconData icon;
  final Color color;

  const _ScoreCard({
    required this.title,
    required this.score,
    required this.trend,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (trend != 0)
                Icon(
                  trend > 0 ? Icons.trending_up : Icons.trending_down,
                  color: trend > 0 ? Colors.green : Colors.red,
                  size: 16,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            score.toStringAsFixed(1),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (trend != 0)
            Text(
              '${trend > 0 ? '+' : ''}${trend.toStringAsFixed(1)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: trend > 0 ? Colors.green : Colors.red,
              ),
            ),
        ],
      ),
    );
  }
}

/// Recommendations card
class _RecommendationsCard extends StatelessWidget {
  final List<String> recommendations;

  const _RecommendationsCard({required this.recommendations});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              Text(
                'Recommendations',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...recommendations.map(
            (recommendation) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 6, right: 12),
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      recommendation,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Score history card
class _ScoreHistoryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history, color: Colors.grey[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'Score History',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Track your progress over time',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Navigate to detailed history screen
            },
            icon: const Icon(Icons.timeline),
            label: const Text('View History'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[700],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
