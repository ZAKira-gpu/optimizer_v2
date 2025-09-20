# ML Score Integration Example

This example shows how to integrate the ML score system into your existing screens.

## Example: Adding ML Scores to SimpleMealLoggingScreen

### Step 1: Update the Screen to Include ML Scores

```dart
// In your simple_meal_logging_screen.dart
import 'package:provider/provider.dart';
import '../../../core/ml/providers/ml_score_provider.dart';
import '../../../core/ml/widgets/ml_score_display.dart';

class _SimpleMealLoggingScreenState extends State<SimpleMealLoggingScreen> {
  @override
  void initState() {
    super.initState();
    _loadNutritionGoals();
    _initializeMLScores(); // Add this
  }

  // Add this method
  Future<void> _initializeMLScores() async {
    final mlProvider = Provider.of<MLScoreProvider>(context, listen: false);
    if (!mlProvider.isInitialized) {
      await mlProvider.initialize();
    }
  }

  // Update your existing saveMeal method
  Future<void> _saveMeal() async {
    final provider = Provider.of<SimpleMealLoggingProvider>(
      context,
      listen: false,
    );
    final user = FirebaseAuth.instance.currentUser;
    
    if (user != null) {
      final success = await provider.saveMeal(user.uid);
      
      if (success) {
        // Trigger ML score recalculation after saving meal
        final mlProvider = Provider.of<MLScoreProvider>(context, listen: false);
        await mlProvider.calculateCurrentScores();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Meal saved and scores updated!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SimpleMealLoggingProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Meal Logging'),
            actions: [
              // Add ML scores button
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MLScoresScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.analytics),
                tooltip: 'View AI Scores',
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Your existing meal logging UI
                // ... existing content ...
                
                // Add ML scores section at the bottom
                const SizedBox(height: 24),
                Container(
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
                          Icon(Icons.analytics, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            'AI Health Analysis',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.blue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Your personalized health, efficiency, and lifestyle scores',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 200,
                        child: MLScoreDisplay(
                          showHistory: false,
                          showRecommendations: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
```

### Step 2: Add ML Scores to Navigation

```dart
// In your main navigation screen
import '../../../core/ml/screens/ml_scores_screen.dart';

// Add to your navigation items
final List<NavigationItem> navigationItems = [
  // ... existing items ...
  NavigationItem(
    icon: Icons.analytics,
    label: 'AI Scores',
    screen: const MLScoresScreen(),
  ),
];
```

### Step 3: Update Enhanced Providers to Trigger Score Calculation

```dart
// In enhanced_meal_logging_provider.dart
import '../../../core/ml/providers/ml_score_provider.dart';

class EnhancedMealLoggingProvider extends ChangeNotifier {
  // ... existing code ...

  Future<bool> saveMeal(String userId) async {
    try {
      // ... existing meal saving logic ...

      if (saved) {
        // Trigger ML score recalculation
        try {
          final mlProvider = MLScoreProvider();
          await mlProvider.initialize();
          await mlProvider.calculateScoresForUser(userId);
          print('✅ ML scores updated after meal save');
        } catch (e) {
          print('⚠️ Failed to update ML scores: $e');
        }

        // ... rest of existing logic ...
      }
    } catch (e) {
      // ... error handling ...
    }
  }
}
```

## Example: Adding ML Scores to Home Screen

```dart
// In your home screen
import '../../../core/ml/widgets/ml_score_display.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Your existing home content
            // ... existing widgets ...

            // Add ML scores section
            Container(
              margin: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your AI Health Insights',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  MLScoreDisplay(
                    showHistory: true,
                    showRecommendations: true,
                    onScoreCalculated: () {
                      print('Scores calculated successfully!');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Example: Custom Score Display

```dart
// Custom score display for specific use cases
class CustomScoreDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MLScoreProvider>(
      builder: (context, provider, child) {
        if (provider.currentScores == null) {
          return const Center(
            child: Text('No scores available'),
          );
        }

        final scores = provider.currentScores!.scores;
        
        return Row(
          children: [
            Expanded(
              child: _ScoreIndicator(
                title: 'Health',
                score: scores.healthScore,
                color: Colors.red,
                icon: Icons.favorite,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ScoreIndicator(
                title: 'Efficiency',
                score: scores.efficiencyScore,
                color: Colors.blue,
                icon: Icons.work,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ScoreIndicator(
                title: 'Lifestyle',
                score: scores.lifestyleScore,
                color: Colors.green,
                icon: Icons.home,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ScoreIndicator extends StatelessWidget {
  final String title;
  final double score;
  final Color color;
  final IconData icon;

  const _ScoreIndicator({
    required this.title,
    required this.score,
    required this.color,
    required this.icon,
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
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            score.toStringAsFixed(1),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
```

## Example: Score-Based Recommendations

```dart
// Show recommendations based on scores
class ScoreRecommendations extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MLScoreProvider>(
      builder: (context, provider, child) {
        if (provider.currentScores == null) {
          return const SizedBox.shrink();
        }

        final recommendations = provider.currentScores!.scores.recommendations;
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.lightbulb, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text(
                    'AI Recommendations',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...recommendations.take(3).map((recommendation) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(top: 6, right: 12),
                      decoration: const BoxDecoration(
                        color: Colors.orange,
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
              )),
            ],
          ),
        );
      },
    );
  }
}
```

## Example: Score Trends Chart

```dart
// Simple score trends display
class ScoreTrends extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MLScoreProvider>(
      builder: (context, provider, child) {
        final trends = provider.scoreTrends;
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Score Trends',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _TrendIndicator(
                      title: 'Health',
                      trend: trends['health'] ?? 0.0,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TrendIndicator(
                      title: 'Efficiency',
                      trend: trends['efficiency'] ?? 0.0,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _TrendIndicator(
                      title: 'Lifestyle',
                      trend: trends['lifestyle'] ?? 0.0,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TrendIndicator(
                      title: 'Overall',
                      trend: trends['overall'] ?? 0.0,
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

class _TrendIndicator extends StatelessWidget {
  final String title;
  final double trend;
  final Color color;

  const _TrendIndicator({
    required this.title,
    required this.trend,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = trend > 0;
    final isNegative = trend < 0;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isPositive ? Icons.trending_up : 
                isNegative ? Icons.trending_down : Icons.trending_flat,
                color: isPositive ? Colors.green : 
                       isNegative ? Colors.red : Colors.grey,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '${trend > 0 ? '+' : ''}${trend.toStringAsFixed(1)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isPositive ? Colors.green : 
                         isNegative ? Colors.red : Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

## Integration Checklist

### ✅ Completed
- [x] TensorFlow Lite dependencies added
- [x] ML models and services created
- [x] ML provider implemented
- [x] UI components created
- [x] App.dart updated with ML provider

### 🔄 Next Steps
- [ ] Add your TFLite model file to `assets/models/`
- [ ] Update existing screens to include ML scores
- [ ] Test score calculation with real data
- [ ] Customize recommendations based on your model
- [ ] Add score-based features to your app

## Testing the Integration

### 1. Test with Mock Data
```dart
// The system includes a mock model for development
// It will automatically use mock scores when your model isn't available
```

### 2. Test Score Calculation
```dart
final mlProvider = Provider.of<MLScoreProvider>(context, listen: false);
await mlProvider.initialize();
final result = await mlProvider.calculateCurrentScores();
print('Scores: ${result?.scores.toJson()}');
```

### 3. Test UI Components
```dart
// Add MLScoreDisplay to any screen
MLScoreDisplay(
  showHistory: true,
  showRecommendations: true,
)
```

The ML integration is now ready to use! Just add your TFLite model file and start integrating the score displays into your existing screens.
