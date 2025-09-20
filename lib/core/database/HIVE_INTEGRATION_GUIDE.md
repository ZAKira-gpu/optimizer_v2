# Hive Database Integration Guide

This guide explains how the Hive database has been integrated with your existing providers to enable automatic data synchronization.

## Overview

The integration provides:
- **Automatic synchronization** between Firestore and Hive
- **Offline-first approach** with local data storage
- **Seamless data persistence** across app sessions
- **Enhanced performance** with local caching

## Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Providers     │    │  HiveSyncService │    │   Hive Local    │
│                 │    │                  │    │   Database      │
│ • MealProvider  │◄──►│                  │◄──►│                 │
│ • StepProvider  │    │ • Auto-sync      │    │ • Health Data   │
│ • Efficiency    │    │ • Conflict       │    │ • Meal Data     │
│   Provider      │    │   Resolution     │    │ • Step Data     │
└─────────────────┘    └──────────────────┘    │ • Efficiency    │
                                               │   Data          │
                                               └─────────────────┘
```

## Components

### 1. Hive Models
- **HealthDataModel**: Stores daily health metrics
- **MealDataModel**: Stores meal and nutrition data
- **EfficiencyDataModel**: Stores productivity and task data
- **StepDataModel**: Stores step tracking data

### 2. Services
- **HiveSyncService**: Handles automatic synchronization
- **HiveDatabaseService**: Manages Hive database operations
- **HiveSyncProvider**: Provider wrapper for sync operations

### 3. Enhanced Providers
- **EnhancedMealLoggingProvider**: Auto-syncs meal data
- **EnhancedStepTrackerProvider**: Auto-syncs step data
- **EnhancedEfficiencyProvider**: Auto-syncs productivity data

## Usage Examples

### Basic Data Sync

```dart
// Get the sync provider
final syncProvider = Provider.of<HiveSyncProvider>(context, listen: false);

// Sync health data
await syncProvider.syncHealthData(
  userId: 'user123',
  steps: 5000,
  sleepHours: 7.5,
  caloriesIn: 2000,
  caloriesOut: 1800,
);

// Sync meal data
await syncProvider.syncMealData(
  userId: 'user123',
  mealId: 'meal456',
  mealType: 'breakfast',
  items: mealItems,
);

// Sync efficiency data
await syncProvider.syncEfficiencyData(
  userId: 'user123',
  date: DateTime.now(),
  tasks: tasksData,
  routines: routinesData,
  goals: goalsData,
  completedTasks: 5,
  totalTasks: 10,
  completedPomodoros: 3,
  totalFocusMinutes: 90,
  efficiencyScore: 75.0,
);
```

### Using Enhanced Providers

```dart
// Enhanced Meal Logging Provider
final mealProvider = Provider.of<EnhancedMealLoggingProvider>(context, listen: false);

// Initialize the provider
await mealProvider.initialize();

// Add food item (automatically syncs to Hive)
await mealProvider.addFoodItem(suggestion, 1.0);

// Save meal (syncs to both Firestore and Hive)
await mealProvider.saveMeal(userId);

// Enhanced Step Tracker Provider
final stepProvider = Provider.of<EnhancedStepTrackerProvider>(context, listen: false);

// Initialize and start tracking
await stepProvider.initialize();
stepProvider.startTracking();

// Save daily steps (automatically syncs to Hive)
await stepProvider.saveDailySteps(userId, userLevel);

// Enhanced Efficiency Provider
final efficiencyProvider = Provider.of<EnhancedEfficiencyProvider>(context, listen: false);

// Initialize
await efficiencyProvider.initialize();

// Add task (automatically syncs to Hive)
await efficiencyProvider.addTask(
  title: 'Complete project',
  priority: TaskPriority.high,
  estimatedMinutes: 60,
);

// Complete task (automatically syncs to Hive)
await efficiencyProvider.completeTask(taskId);
```

### Data Retrieval

```dart
// Get all user data from Hive
final allData = await syncProvider.getAllUserData(userId);

// Get specific data types
final healthData = HiveSyncService.getHealthData(userId, DateTime.now());
final mealData = await HiveSyncService.getMealData(userId, limit: 10);
final efficiencyData = await HiveSyncService.getEfficiencyData(userId, DateTime.now());
final stepData = await HiveSyncService.getStepData(userId, DateTime.now());
```

### Sync Management

```dart
// Check if data needs syncing
bool needsSync = syncProvider.needsSync('health', userId);

// Force sync all data
await syncProvider.forceSyncAll(userId);

// Clear user data
await syncProvider.clearUserData(userId);

// Get sync statistics
final stats = syncProvider.getSyncStats();
```

## Migration from Existing Providers

### Step 1: Update Provider Imports

Replace existing provider imports:
```dart
// Old
import 'features/meals/viewmodel/simple_meal_logging_provider.dart';

// New
import 'features/meals/viewmodel/enhanced_meal_logging_provider.dart';
```

### Step 2: Update Provider Registration

In your `app.dart`:
```dart
// Replace existing providers with enhanced versions
ChangeNotifierProvider(create: (_) => EnhancedMealLoggingProvider()),
ChangeNotifierProvider(create: (_) => EnhancedStepTrackerProvider()),
ChangeNotifierProvider(create: (_) => EnhancedEfficiencyProvider()),
```

### Step 3: Update Provider Usage

The enhanced providers maintain the same API as the original providers, so minimal code changes are needed:

```dart
// Old usage
final provider = Provider.of<SimpleMealLoggingProvider>(context, listen: false);

// New usage (same API)
final provider = Provider.of<EnhancedMealLoggingProvider>(context, listen: false);
```

## Data Flow

### 1. Data Creation/Update
```
User Action → Provider → Firestore → HiveSyncService → Hive Database
```

### 2. Data Retrieval
```
UI Request → Provider → Hive Database (fast) → Firestore (if needed)
```

### 3. Offline Support
```
No Network → Provider → Hive Database → Local Data Available
```

## Benefits

### Performance
- **Faster data access** with local Hive storage
- **Reduced network calls** with intelligent caching
- **Instant UI updates** with local data

### Reliability
- **Offline functionality** with local data persistence
- **Data consistency** with automatic synchronization
- **Conflict resolution** for concurrent updates

### User Experience
- **Seamless experience** regardless of network status
- **Data persistence** across app sessions
- **Real-time updates** with local caching

## Configuration

### Sync Thresholds
```dart
// Default sync threshold is 5 minutes
bool needsSync = syncProvider.needsSync('health', userId, 
  threshold: Duration(minutes: 10));
```

### Data Retention
```dart
// Clear old data
await syncProvider.clearUserData(userId);

// Get database statistics
final stats = HiveSyncService.getSyncStats();
```

## Troubleshooting

### Common Issues

1. **Sync Failures**
   - Check network connectivity
   - Verify user authentication
   - Check Firestore permissions

2. **Data Inconsistency**
   - Use `forceSyncAll()` to refresh data
   - Check sync timestamps
   - Verify data models match

3. **Performance Issues**
   - Monitor sync frequency
   - Check database size
   - Optimize data queries

### Debug Information

```dart
// Enable debug logging
if (kDebugMode) {
  print('Sync stats: ${syncProvider.getSyncStats()}');
  print('Last sync times: ${syncProvider.lastSyncTimes}');
}
```

## Best Practices

### 1. Initialize Early
```dart
// Initialize sync provider early in app lifecycle
await syncProvider.initialize();
```

### 2. Handle Errors Gracefully
```dart
try {
  await provider.saveData();
} catch (e) {
  // Handle sync errors without breaking user experience
  print('Sync failed: $e');
}
```

### 3. Monitor Sync Status
```dart
// Check sync status before critical operations
if (syncProvider.needsSync('critical_data', userId)) {
  await syncProvider.forceSyncAll(userId);
}
```

### 4. Clean Up Resources
```dart
// Clear data when user logs out
await syncProvider.clearUserData(userId);
```

## Future Enhancements

- **Background sync** with WorkManager
- **Conflict resolution** strategies
- **Data compression** for large datasets
- **Sync analytics** and monitoring
- **Multi-device synchronization**

## Support

For issues or questions about the Hive integration:
1. Check the debug logs for sync information
2. Verify data models and adapters
3. Test with different network conditions
4. Monitor sync statistics and performance
