import 'package:flutter/foundation.dart';
import 'services/hive_database_service.dart';
import 'services/hive_sync_service.dart';

/// Database initialization utility
class DatabaseInit {
  static bool _isInitialized = false;

  /// Initialize the database
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      if (kDebugMode) {
        print('🔄 Initializing Hive database...');
      }

      await HiveDatabaseService.initialize();
      await HiveSyncService.initialize();
      _isInitialized = true;

      if (kDebugMode) {
        print('✅ Database initialized successfully');
        final stats = HiveDatabaseService.getDatabaseStats();
        print('📊 Database stats: $stats');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Database initialization failed: $e');
      }
      rethrow;
    }
  }

  /// Check if database is initialized
  static bool get isInitialized => _isInitialized;

  /// Close database
  static Future<void> close() async {
    if (_isInitialized) {
      await HiveDatabaseService.close();
      _isInitialized = false;

      if (kDebugMode) {
        print('🔒 Database closed');
      }
    }
  }
}
