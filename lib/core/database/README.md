# Hive Database for Health & Productivity Data

This Hive database implementation stores daily health and productivity metrics including:

- **sleep_hours**: Hours of sleep per day
- **steps**: Daily step count
- **calories_in**: Calories consumed
- **calories_out**: Calories burned
- **tasks_done**: Number of completed tasks
- **goal_progress**: Progress towards daily goals (0.0 - 1.0)
- **efficiency_score**: Daily productivity score (0.0 - 100.0)
- **health_score**: Daily health score (0.0 - 100.0)

## Setup

### 1. Add Dependencies

Add these to your `pubspec.yaml`:

```yaml
dependencies:
  hive: ^2.2.3
  hive_flutter: ^1.1.0

dev_dependencies:
  hive_generator: ^2.0.1
  build_runner: ^2.4.7
```

### 2. Generate Adapters

Run the build runner to generate Hive adapters:

```bash
flutter packages pub run build_runner build
```

### 3. Initialize Database

In your `main.dart`:

```dart
import 'package:flutter/material.dart';
import 'core/database/database_init.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive database
  await DatabaseInit.initialize();
  
  runApp(MyApp());
}
```

### 4. Add Provider to App

In your `app.dart`:

```dart
import 'package:provider/provider.dart';
import 'core/database/providers/hive_database_provider.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HiveDatabaseProvider()),
        // ... other providers
      ],
      child: MaterialApp(
        // ... your app configuration
      ),
    );
  }
}
```

## Usage Examples

### Basic Operations

```dart
// Get the provider
final dbProvider = Provider.of<HiveDatabaseProvider>(context, listen: false);

// Initialize and load today's data
await dbProvider.initialize();
await dbProvider.loadTodayData('user123');

// Update individual fields
await dbProvider.updateSteps('user123', 8500);
await dbProvider.updateSleepHours('user123', 7.5);
await dbProvider.updateCaloriesIn('user123', 2200.0);
await dbProvider.updateTasksDone('user123', 5);
await dbProvider.updateEfficiencyScore('user123', 85.0);
await dbProvider.updateHealthScore('user123', 78.0);

// Update multiple fields at once
await dbProvider.updateMultipleFields(
  'user123',
  sleepHours: 8.0,
  steps: 10000,
  caloriesIn: 2000.0,
  caloriesOut: 500.0,
  tasksDone: 6,
  goalProgress: 0.8,
  efficiencyScore: 90.0,
  healthScore: 85.0,
);
```

### Loading Data

```dart
// Load today's data
await dbProvider.loadTodayData('user123');
final todayData = dbProvider.todayData;

// Load weekly data
await dbProvider.loadWeeklyData('user123');
final weeklyData = dbProvider.weeklyData;
final weeklySummary = dbProvider.weeklySummary;

// Load monthly data
await dbProvider.loadMonthlyData('user123');
final monthlyData = dbProvider.monthlyData;
final monthlySummary = dbProvider.monthlySummary;

// Get data for specific date
final specificDate = DateTime(2024, 1, 15);
final dateData = dbProvider.getDataForDate('user123', specificDate);

// Get data range
final startDate = DateTime(2024, 1, 1);
final endDate = DateTime(2024, 1, 31);
final rangeData = dbProvider.getDataRange('user123', startDate, endDate);
```

### UI Integration

```dart
class HealthDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<HiveDatabaseProvider>(
      builder: (context, dbProvider, child) {
        if (dbProvider.isLoading) {
          return CircularProgressIndicator();
        }

        final todayData = dbProvider.todayData;
        if (todayData == null) {
          return Text('No data available');
        }

        return Column(
          children: [
            Text('Steps: ${todayData.steps}'),
            Text('Sleep: ${todayData.sleepHours}h'),
            Text('Calories In: ${todayData.caloriesIn}'),
            Text('Calories Out: ${todayData.caloriesOut}'),
            Text('Tasks Done: ${todayData.tasksDone}'),
            Text('Goal Progress: ${(todayData.goalProgress * 100).toInt()}%'),
            Text('Efficiency Score: ${todayData.efficiencyScore.toInt()}'),
            Text('Health Score: ${todayData.healthScore.toInt()}'),
          ],
        );
      },
    );
  }
}
```

### Weekly/Monthly Summaries

```dart
class SummaryWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<HiveDatabaseProvider>(
      builder: (context, dbProvider, child) {
        final weeklySummary = dbProvider.weeklySummary;
        final monthlySummary = dbProvider.monthlySummary;

        return Column(
          children: [
            // Weekly Summary
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Weekly Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('Avg Sleep: ${weeklySummary['avgSleepHours']?.toStringAsFixed(1)}h'),
                    Text('Total Steps: ${weeklySummary['totalSteps']}'),
                    Text('Avg Calories In: ${weeklySummary['avgCaloriesIn']?.toStringAsFixed(0)}'),
                    Text('Total Tasks: ${weeklySummary['totalTasksDone']}'),
                    Text('Avg Efficiency: ${weeklySummary['avgEfficiencyScore']?.toStringAsFixed(1)}'),
                    Text('Avg Health: ${weeklySummary['avgHealthScore']?.toStringAsFixed(1)}'),
                  ],
                ),
              ),
            ),
            
            // Monthly Summary
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Monthly Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('Avg Sleep: ${monthlySummary['avgSleepHours']?.toStringAsFixed(1)}h'),
                    Text('Total Steps: ${monthlySummary['totalSteps']}'),
                    Text('Avg Calories In: ${monthlySummary['avgCaloriesIn']?.toStringAsFixed(0)}'),
                    Text('Total Tasks: ${monthlySummary['totalTasksDone']}'),
                    Text('Avg Efficiency: ${monthlySummary['avgEfficiencyScore']?.toStringAsFixed(1)}'),
                    Text('Avg Health: ${monthlySummary['avgHealthScore']?.toStringAsFixed(1)}'),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
```

## Data Structure

### HealthDataModel

```dart
class HealthDataModel {
  final String id;              // Unique identifier
  final String userId;          // User identifier
  final DateTime date;          // Date of the data
  final double sleepHours;      // Hours of sleep (0.0 - 24.0)
  final int steps;              // Step count (0+)
  final double caloriesIn;      // Calories consumed (0.0+)
  final double caloriesOut;     // Calories burned (0.0+)
  final int tasksDone;          // Number of completed tasks (0+)
  final double goalProgress;    // Goal progress (0.0 - 1.0)
  final double efficiencyScore; // Efficiency score (0.0 - 100.0)
  final double healthScore;     // Health score (0.0 - 100.0)
  final DateTime createdAt;     // Creation timestamp
  final DateTime updatedAt;     // Last update timestamp
}
```

## Features

- ✅ **Local Storage**: Data stored locally using Hive
- ✅ **Real-time Updates**: Provider-based state management
- ✅ **Date-based Queries**: Get data for specific dates or ranges
- ✅ **Summary Calculations**: Weekly and monthly summaries
- ✅ **Error Handling**: Comprehensive error handling and logging
- ✅ **Type Safety**: Strongly typed models and operations
- ✅ **Performance**: Efficient local database operations
- ✅ **Flexibility**: Update individual fields or multiple fields at once

## Error Handling

The database includes comprehensive error handling:

```dart
try {
  await dbProvider.updateSteps('user123', 5000);
} catch (e) {
  print('Error updating steps: $e');
  // Handle error appropriately
}

// Check for errors
if (dbProvider.error.isNotEmpty) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(dbProvider.error)),
  );
}
```

## Performance Tips

1. **Initialize once**: Call `initialize()` only once in your app
2. **Batch updates**: Use `updateMultipleFields()` for multiple updates
3. **Load data as needed**: Only load data when required
4. **Use summaries**: Use weekly/monthly summaries for overview data
5. **Error handling**: Always handle errors gracefully

## Troubleshooting

### Common Issues

1. **Build runner errors**: Make sure to run `flutter packages pub run build_runner build`
2. **Initialization errors**: Ensure database is initialized before use
3. **Data not saving**: Check if user ID is provided correctly
4. **Performance issues**: Use summaries for large date ranges

### Debug Mode

Enable debug logging by setting `kDebugMode = true` in your app. This will show:
- Database initialization status
- Data save/load operations
- Error messages
- Performance statistics
