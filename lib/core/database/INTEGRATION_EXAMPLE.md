# Hive Integration Example

This example shows how to update your existing screens to use the enhanced providers with automatic Hive synchronization.

## Example: Updating SimpleMealLoggingScreen

### Before (Original Provider)
```dart
class _SimpleMealLoggingScreenState extends State<SimpleMealLoggingScreen> {
  @override
  void initState() {
    super.initState();
    _loadNutritionGoals();
    // ... other initialization
  }

  Future<void> _loadNutritionGoals() async {
    final provider = Provider.of<SimpleMealLoggingProvider>(
      context,
      listen: false,
    );
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await provider.loadNutritionGoals(user.uid);
      await provider.loadTodayNutrition(user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SimpleMealLoggingProvider>(
      builder: (context, provider, child) {
        // ... UI implementation
      },
    );
  }
}
```

### After (Enhanced Provider with Hive Sync)
```dart
class _SimpleMealLoggingScreenState extends State<SimpleMealLoggingScreen> {
  @override
  void initState() {
    super.initState();
    _initializeProviders();
    // ... other initialization
  }

  Future<void> _initializeProviders() async {
    final mealProvider = Provider.of<EnhancedMealLoggingProvider>(
      context,
      listen: false,
    );
    final syncProvider = Provider.of<HiveSyncProvider>(
      context,
      listen: false,
    );
    
    // Initialize both providers
    await mealProvider.initialize();
    await syncProvider.initialize();
    
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await mealProvider.loadNutritionGoals(user.uid);
      await mealProvider.loadTodayNutrition(user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EnhancedMealLoggingProvider>(
      builder: (context, provider, child) {
        // Same UI implementation - no changes needed!
        // The enhanced provider maintains the same API
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ... existing UI code
            ],
          ),
        );
      },
    );
  }
}
```

## Example: Updating App.dart

### Before
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => SimpleMealLoggingProvider()),
    ChangeNotifierProvider(create: (_) => StepTrackerProvider()),
    ChangeNotifierProvider(create: (_) => EfficiencyProvider()),
    ChangeNotifierProvider(create: (_) => HiveDatabaseProvider()),
  ],
  child: MaterialApp(
    // ... app configuration
  ),
)
```

### After
```dart
MultiProvider(
  providers: [
    // Enhanced providers with automatic Hive sync
    ChangeNotifierProvider(create: (_) => EnhancedMealLoggingProvider()),
    ChangeNotifierProvider(create: (_) => EnhancedStepTrackerProvider()),
    ChangeNotifierProvider(create: (_) => EnhancedEfficiencyProvider()),
    
    // Core providers
    ChangeNotifierProvider(create: (_) => HiveDatabaseProvider()),
    ChangeNotifierProvider(create: (_) => HiveSyncProvider()),
  ],
  child: MaterialApp(
    // ... app configuration
  ),
)
```

## Example: Using Sync Provider Directly

```dart
class DataSyncExample extends StatefulWidget {
  @override
  _DataSyncExampleState createState() => _DataSyncExampleState();
}

class _DataSyncExampleState extends State<DataSyncExample> {
  @override
  void initState() {
    super.initState();
    _initializeSync();
  }

  Future<void> _initializeSync() async {
    final syncProvider = Provider.of<HiveSyncProvider>(context, listen: false);
    await syncProvider.initialize();
  }

  Future<void> _syncAllData() async {
    final syncProvider = Provider.of<HiveSyncProvider>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser;
    
    if (user != null) {
      // Force sync all data
      await syncProvider.forceSyncAll(user.uid);
      
      // Get all user data from Hive
      final allData = await syncProvider.getAllUserData(user.uid);
      print('Synced data: $allData');
    }
  }

  Future<void> _clearUserData() async {
    final syncProvider = Provider.of<HiveSyncProvider>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser;
    
    if (user != null) {
      await syncProvider.clearUserData(user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HiveSyncProvider>(
      builder: (context, syncProvider, child) {
        return Column(
          children: [
            if (syncProvider.isSyncing)
              CircularProgressIndicator(),
            
            if (syncProvider.error.isNotEmpty)
              Text('Error: ${syncProvider.error}'),
            
            ElevatedButton(
              onPressed: _syncAllData,
              child: Text('Sync All Data'),
            ),
            
            ElevatedButton(
              onPressed: _clearUserData,
              child: Text('Clear User Data'),
            ),
            
            // Display sync statistics
            Text('Sync Stats: ${syncProvider.getSyncStats()}'),
          ],
        );
      },
    );
  }
}
```

## Example: Monitoring Sync Status

```dart
class SyncStatusWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<HiveSyncProvider>(
      builder: (context, syncProvider, child) {
        return Container(
          padding: EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sync Status'),
              if (syncProvider.isSyncing)
                Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 8),
                    Text('Syncing...'),
                  ],
                ),
              
              if (syncProvider.error.isNotEmpty)
                Text(
                  'Error: ${syncProvider.error}',
                  style: TextStyle(color: Colors.red),
                ),
              
              Text('Last Sync Times:'),
              ...syncProvider.lastSyncTimes.entries.map(
                (entry) => Text('${entry.key}: ${entry.value}'),
              ),
            ],
          ),
        );
      },
    );
  }
}
```

## Migration Checklist

### ✅ Completed
- [x] Hive dependencies added to pubspec.yaml
- [x] Hive models created for all data types
- [x] Hive adapters generated with build_runner
- [x] HiveSyncService implemented
- [x] HiveSyncProvider created
- [x] Enhanced providers created
- [x] App.dart updated with new providers
- [x] Database initialization updated

### 🔄 Next Steps
- [ ] Update existing screens to use enhanced providers
- [ ] Test offline functionality
- [ ] Verify data synchronization
- [ ] Monitor performance improvements
- [ ] Add error handling for sync failures

## Testing the Integration

### 1. Test Offline Functionality
```dart
// Disable network and test data access
final mealProvider = Provider.of<EnhancedMealLoggingProvider>(context, listen: false);
await mealProvider.loadTodayNutrition(userId); // Should work offline
```

### 2. Test Data Sync
```dart
// Add data and verify sync
await mealProvider.addFoodItem(suggestion, 1.0);
await mealProvider.saveMeal(userId);

// Check if data is in Hive
final syncProvider = Provider.of<HiveSyncProvider>(context, listen: false);
final allData = await syncProvider.getAllUserData(userId);
```

### 3. Test Performance
```dart
// Measure data access speed
final stopwatch = Stopwatch()..start();
await mealProvider.loadTodayNutrition(userId);
stopwatch.stop();
print('Data load time: ${stopwatch.elapsedMilliseconds}ms');
```

## Benefits You'll See

1. **Faster App Startup**: Data loads from local Hive database
2. **Offline Functionality**: App works without internet connection
3. **Better User Experience**: Instant data updates and persistence
4. **Reduced Network Usage**: Intelligent caching reduces API calls
5. **Data Reliability**: Automatic sync ensures data consistency

The integration is designed to be backward-compatible, so your existing code will continue to work while gaining the benefits of local data storage and automatic synchronization.
