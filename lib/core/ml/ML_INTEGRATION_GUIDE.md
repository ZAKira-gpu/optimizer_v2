# ML Score Integration Guide

This guide explains how to integrate and use the TensorFlow Lite ML model for calculating health, efficiency, and lifestyle scores.

## Overview

The ML integration provides:
- **AI-powered score calculation** using TensorFlow Lite
- **Real-time score analysis** based on user data
- **Personalized recommendations** for improvement
- **Score tracking and trends** over time
- **Offline-capable** ML inference

## Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   User Data     │    │  MLScoreService  │    │   TFLite Model  │
│                 │    │                  │    │                 │
│ • Health Data   │───►│                  │───►│                 │
│ • Efficiency    │    │ • Data Preprocessing │ │ • Health Score  │
│ • Lifestyle     │    │ • Model Inference │   │ • Efficiency    │
└─────────────────┘    │ • Score Generation│   │ • Lifestyle     │
                       └──────────────────┘    │ • Overall       │
                                │               └─────────────────┘
                                ▼
                       ┌──────────────────┐
                       │ MLScoreProvider  │
                       │                  │
                       │ • State Management│
                       │ • Score Caching  │
                       │ • Firestore Sync │
                       └──────────────────┘
```

## Components

### 1. ML Models
- **MLInputData**: Input data structure for the ML model
- **MLOutputData**: Output data structure with scores and recommendations
- **ScoreCalculationRequest**: Request structure for score calculation
- **ScoreCalculationResult**: Result structure with metadata

### 2. Services
- **MLScoreService**: Core service for TensorFlow Lite model inference
- **Mock Implementation**: Development fallback when model isn't available

### 3. Providers
- **MLScoreProvider**: State management for score calculations and caching

### 4. UI Components
- **MLScoreDisplay**: Widget for displaying scores with trends
- **MLScoresScreen**: Dedicated screen for score management

## Setup Instructions

### 1. Add Your TFLite Model

Place your TensorFlow Lite model file in the assets directory:

```
assets/
  models/
    optimizer_scores_model.tflite  # Your ML model file
```

### 2. Model Requirements

Your TFLite model should:
- Accept 26 input features (see MLInputData.toList())
- Output 4 scores: [health, efficiency, lifestyle, overall]
- Use float32 data type
- Output values between 0.0 and 1.0 (will be scaled to 0-100)

### 3. Input Features (26 total)

The model expects these features in order:

**Health Metrics (10 features):**
1. Steps (daily step count)
2. Sleep hours
3. Calories in
4. Calories out
5. Water intake (liters)
6. Heart rate
7. Blood pressure
8. Weight (kg)
9. Height (m)
10. Age

**Efficiency Metrics (8 features):**
11. Completed tasks
12. Total tasks
13. Completed pomodoros
14. Total focus minutes
15. Efficiency score
16. Completed routines
17. Total routines
18. Gender (encoded: 1.0=male, 0.0=female, 0.5=other)

**Lifestyle Metrics (8 features):**
19. Screen time (hours)
20. Exercise minutes
21. Social interactions (count)
22. Stress level (1-5 scale)
23. Mood (encoded: 5.0=excellent, 1.0=terrible)
24. Productivity score
25. Meals logged
26. Nutrition score

## Usage Examples

### Basic Score Calculation

```dart
// Get the ML provider
final mlProvider = Provider.of<MLScoreProvider>(context, listen: false);

// Initialize the provider
await mlProvider.initialize();

// Calculate scores for current user
final result = await mlProvider.calculateCurrentScores();

if (result != null) {
  print('Health Score: ${result.scores.healthScore}');
  print('Efficiency Score: ${result.scores.efficiencyScore}');
  print('Lifestyle Score: ${result.scores.lifestyleScore}');
  print('Overall Score: ${result.scores.overallScore}');
  
  // Get recommendations
  for (final recommendation in result.scores.recommendations) {
    print('Recommendation: $recommendation');
  }
}
```

### Using the Score Display Widget

```dart
// Simple score display
MLScoreDisplay(
  showHistory: true,
  showRecommendations: true,
  onScoreCalculated: () {
    print('Scores calculated successfully!');
  },
)

// With specific user ID
MLScoreDisplay(
  userId: 'user123',
  showHistory: false,
  showRecommendations: true,
)
```

### Custom Score Calculation

```dart
// Create custom input data
final inputData = MLInputData.fromUserData(
  // Health metrics
  steps: 8500,
  sleepHours: 7.5,
  caloriesIn: 2200.0,
  caloriesOut: 2000.0,
  waterIntake: 2.5,
  heartRate: 72.0,
  bloodPressure: 120.0,
  weight: 70.0,
  height: 1.75,
  age: 28,
  gender: 'male',
  
  // Efficiency metrics
  completedTasks: 8,
  totalTasks: 10,
  completedPomodoros: 6,
  totalFocusMinutes: 150,
  efficiencyScore: 75.0,
  completedRoutines: 3,
  totalRoutines: 4,
  
  // Lifestyle metrics
  screenTime: 3.5,
  exerciseMinutes: 45,
  socialInteractions: 8,
  stressLevel: 2.0,
  mood: 'good',
  productivityScore: 80.0,
  mealsLogged: 3,
  nutritionScore: 85.0,
);

// Calculate scores
final mlService = MLScoreService.instance;
await mlService.initialize();
final scores = await mlService.calculateScores(inputData);

print('Calculated scores: ${scores.toJson()}');
```

### Score History and Trends

```dart
// Load score history
await mlProvider.loadScoreHistory(userId, days: 30);

// Get score trends
final trends = mlProvider.scoreTrends;
print('Health trend: ${trends['health']}');
print('Efficiency trend: ${trends['efficiency']}');

// Get statistics
final stats = mlProvider.getScoreStatistics();
print('Average health score: ${stats['averageHealth']}');
print('Best overall score: ${stats['bestOverall']}');
```

## Integration with Existing Providers

### Update Enhanced Providers

The enhanced providers can automatically trigger score calculations:

```dart
// In EnhancedMealLoggingProvider
Future<bool> saveMeal(String userId) async {
  // ... existing meal saving logic ...
  
  // Trigger score recalculation
  final mlProvider = Provider.of<MLScoreProvider>(context, listen: false);
  await mlProvider.calculateScoresForUser(userId);
  
  return true;
}

// In EnhancedStepTrackerProvider
Future<bool> saveDailySteps(String userId, String userLevel) async {
  // ... existing step saving logic ...
  
  // Trigger score recalculation
  final mlProvider = Provider.of<MLScoreProvider>(context, listen: false);
  await mlProvider.calculateScoresForUser(userId);
  
  return true;
}
```

### Add Score Display to Existing Screens

```dart
// Add to any existing screen
class MyExistingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Existing content
          Expanded(
            child: YourExistingContent(),
          ),
          
          // Add score display at bottom
          Container(
            height: 200,
            child: MLScoreDisplay(
              showHistory: false,
              showRecommendations: true,
            ),
          ),
        ],
      ),
    );
  }
}
```

## Model Development

### Training Data Format

When training your model, use this data structure:

```python
# Example training data format
import pandas as pd

# Input features (26 columns)
input_features = [
    'steps', 'sleep_hours', 'calories_in', 'calories_out', 'water_intake',
    'heart_rate', 'blood_pressure', 'weight', 'height', 'age',
    'completed_tasks', 'total_tasks', 'completed_pomodoros', 'total_focus_minutes',
    'efficiency_score', 'completed_routines', 'total_routines', 'gender',
    'screen_time', 'exercise_minutes', 'social_interactions', 'stress_level',
    'mood', 'productivity_score', 'meals_logged', 'nutrition_score'
]

# Output targets (4 columns)
output_targets = [
    'health_score', 'efficiency_score', 'lifestyle_score', 'overall_score'
]

# Normalize outputs to 0-1 range
df[output_targets] = df[output_targets] / 100.0
```

### Model Conversion

Convert your trained model to TensorFlow Lite:

```python
import tensorflow as tf

# Load your trained model
model = tf.keras.models.load_model('your_model.h5')

# Convert to TensorFlow Lite
converter = tf.lite.TFLiteConverter.from_keras_model(model)
converter.optimizations = [tf.lite.Optimize.DEFAULT]
tflite_model = converter.convert()

# Save the model
with open('optimizer_scores_model.tflite', 'wb') as f:
    f.write(tflite_model)
```

## Testing and Debugging

### Mock Model for Development

The service includes a mock model for development when your actual model isn't available:

```dart
// The mock model provides realistic scores based on input data
// It's automatically used when the actual model file isn't found
```

### Debug Information

```dart
// Get model information
final mlService = MLScoreService.instance;
final modelInfo = mlService.getModelInfo();
print('Model info: $modelInfo');

// Check initialization status
print('ML Service initialized: ${mlService.isInitialized}');
print('ML Service error: ${mlService.error}');
```

### Testing with Sample Data

```dart
// Test with sample data
final sampleData = MLInputData.fromUserData(
  steps: 10000,
  sleepHours: 8.0,
  caloriesIn: 2000.0,
  caloriesOut: 2200.0,
  waterIntake: 2.0,
  heartRate: 70.0,
  bloodPressure: 120.0,
  weight: 70.0,
  height: 1.75,
  age: 30,
  gender: 'male',
  completedTasks: 10,
  totalTasks: 10,
  completedPomodoros: 8,
  totalFocusMinutes: 200,
  efficiencyScore: 90.0,
  completedRoutines: 5,
  totalRoutines: 5,
  screenTime: 2.0,
  exerciseMinutes: 60,
  socialInteractions: 10,
  stressLevel: 1.0,
  mood: 'excellent',
  productivityScore: 95.0,
  mealsLogged: 3,
  nutritionScore: 90.0,
);

final scores = await mlService.calculateScores(sampleData);
print('Sample scores: ${scores.toJson()}');
```

## Performance Considerations

### Model Optimization

- Use TensorFlow Lite optimizations for smaller model size
- Consider quantization for faster inference
- Test on target devices for performance validation

### Caching Strategy

- Scores are cached to avoid unnecessary recalculations
- Cache is invalidated when underlying data changes
- Consider implementing longer-term caching for historical data

### Error Handling

- Graceful fallback to default scores on model errors
- Comprehensive error logging for debugging
- User-friendly error messages in the UI

## Future Enhancements

- **Real-time scoring**: Update scores as data changes
- **Personalized models**: User-specific model fine-tuning
- **Advanced recommendations**: ML-powered suggestion engine
- **Score predictions**: Forecast future score trends
- **A/B testing**: Compare different model versions
- **Federated learning**: Improve models with user data (privacy-preserving)

## Troubleshooting

### Common Issues

1. **Model not loading**
   - Check file path: `assets/models/optimizer_scores_model.tflite`
   - Verify model format and compatibility
   - Check TensorFlow Lite version compatibility

2. **Incorrect scores**
   - Verify input data format and ranges
   - Check model input/output shapes
   - Validate data preprocessing

3. **Performance issues**
   - Optimize model size and complexity
   - Consider model quantization
   - Profile inference time on target devices

### Debug Commands

```dart
// Check model status
print('Model initialized: ${MLScoreService.instance.isInitialized}');
print('Model path: ${MLScoreService.instance.modelPath}');
print('Model error: ${MLScoreService.instance.error}');

// Test with known data
final testResult = await MLScoreService.instance.calculateScores(testData);
print('Test result: ${testResult.toJson()}');
```

The ML integration is designed to be robust, scalable, and easy to use. It provides a solid foundation for AI-powered health and productivity insights in your app.
