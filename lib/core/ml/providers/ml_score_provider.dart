import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ml_models.dart';
import '../services/ml_score_service.dart';

/// ML Score Provider for managing score calculations and caching
class MLScoreProvider extends ChangeNotifier {
  final MLScoreService _mlService = MLScoreService.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // State variables
  bool _isInitialized = false;
  bool _isCalculating = false;
  String _error = '';

  // Current scores
  ScoreCalculationResult? _currentScores;
  List<ScoreCalculationResult> _scoreHistory = [];
  Map<String, double> _scoreTrends = {};

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isCalculating => _isCalculating;
  String get error => _error;
  ScoreCalculationResult? get currentScores => _currentScores;
  List<ScoreCalculationResult> get scoreHistory =>
      List.unmodifiable(_scoreHistory);
  Map<String, double> get scoreTrends => Map.unmodifiable(_scoreTrends);

  /// Initialize the ML provider
  Future<bool> initialize() async {
    try {
      if (_isInitialized) return true;

      _clearError();
      _isCalculating = true;
      notifyListeners();

      // Initialize ML service
      final success = await _mlService.initialize();
      if (!success) {
        _setError('Failed to initialize ML service: ${_mlService.error}');
        _isCalculating = false;
        notifyListeners();
        return false;
      }

      _isInitialized = true;
      _isCalculating = false;
      notifyListeners();

      if (kDebugMode) {
        print('✅ ML Score Provider initialized successfully');
        final modelInfo = _mlService.getModelInfo();
        print('🤖 Model info: $modelInfo');
      }

      return true;
    } catch (e) {
      _setError('Failed to initialize ML provider: $e');
      _isCalculating = false;
      notifyListeners();
      return false;
    }
  }

  /// Calculate scores for current user
  Future<ScoreCalculationResult?> calculateCurrentScores() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _setError('User not authenticated');
        return null;
      }

      return await calculateScoresForUser(user.uid);
    } catch (e) {
      _setError('Failed to calculate current scores: $e');
      return null;
    }
  }

  /// Calculate scores for a specific user
  Future<ScoreCalculationResult?> calculateScoresForUser(String userId) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      _isCalculating = true;
      _clearError();
      notifyListeners();

      // Gather user data
      final inputData = await _gatherUserData(userId);
      if (inputData == null) {
        _setError('Failed to gather user data');
        _isCalculating = false;
        notifyListeners();
        return null;
      }

      // Create calculation request
      final request = ScoreCalculationRequest(
        userId: userId,
        date: DateTime.now(),
        inputData: inputData,
      );

      // Calculate scores
      final result = await _mlService.calculateScoresWithCache(request);

      // Update state
      _currentScores = result;
      _scoreHistory.insert(0, result); // Add to beginning of list

      // Keep only last 30 days of history
      if (_scoreHistory.length > 30) {
        _scoreHistory = _scoreHistory.take(30).toList();
      }

      // Calculate trends
      _calculateScoreTrends();

      // Save to Firestore
      await _saveScoresToFirestore(result);

      _isCalculating = false;
      notifyListeners();

      if (kDebugMode) {
        print('✅ Scores calculated successfully for user: $userId');
        print('📊 Health: ${result.scores.healthScore.toStringAsFixed(1)}');
        print(
          '📊 Efficiency: ${result.scores.efficiencyScore.toStringAsFixed(1)}',
        );
        print(
          '📊 Lifestyle: ${result.scores.lifestyleScore.toStringAsFixed(1)}',
        );
        print('📊 Overall: ${result.scores.overallScore.toStringAsFixed(1)}');
      }

      return result;
    } catch (e) {
      _setError('Failed to calculate scores: $e');
      _isCalculating = false;
      notifyListeners();
      return null;
    }
  }

  /// Gather user data for ML input
  Future<MLInputData?> _gatherUserData(String userId) async {
    try {
      // Get user profile
      final userDoc = await _firestore
          .collection('userProfiles')
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        _setError('User profile not found');
        return null;
      }

      final userData = userDoc.data()!;
      final today = DateTime.now();

      // Get today's health data
      final healthData = await _getTodayHealthData(userId, today);

      // Get today's efficiency data
      final efficiencyData = await _getTodayEfficiencyData(userId, today);

      // Get today's lifestyle data
      final lifestyleData = await _getTodayLifestyleData(userId, today);

      // Create ML input data
      return MLInputData.fromUserData(
        // Health metrics
        steps: healthData['steps'] ?? 0,
        sleepHours: healthData['sleepHours'] ?? 7.0,
        caloriesIn: healthData['caloriesIn'] ?? 2000.0,
        caloriesOut: healthData['caloriesOut'] ?? 1800.0,
        waterIntake: healthData['waterIntake'] ?? 2.0,
        heartRate: healthData['heartRate'] ?? 70.0,
        bloodPressure: healthData['bloodPressure'] ?? 120.0,
        weight: (userData['weight'] as num?)?.toDouble() ?? 70.0,
        height: (userData['height'] as num?)?.toDouble() ?? 1.75,
        age: userData['age'] ?? 25,
        gender: userData['gender'] ?? 'other',

        // Efficiency metrics
        completedTasks: efficiencyData['completedTasks'] ?? 0,
        totalTasks: efficiencyData['totalTasks'] ?? 0,
        completedPomodoros: efficiencyData['completedPomodoros'] ?? 0,
        totalFocusMinutes: efficiencyData['totalFocusMinutes'] ?? 0,
        efficiencyScore: efficiencyData['efficiencyScore'] ?? 50.0,
        completedRoutines: efficiencyData['completedRoutines'] ?? 0,
        totalRoutines: efficiencyData['totalRoutines'] ?? 0,

        // Lifestyle metrics
        screenTime: lifestyleData['screenTime'] ?? 4.0,
        exerciseMinutes: lifestyleData['exerciseMinutes'] ?? 30.0,
        socialInteractions: lifestyleData['socialInteractions'] ?? 5,
        stressLevel: lifestyleData['stressLevel'] ?? 3.0,
        mood: lifestyleData['mood'] ?? 'okay',
        productivityScore: lifestyleData['productivityScore'] ?? 50.0,
        mealsLogged: lifestyleData['mealsLogged'] ?? 3,
        nutritionScore: lifestyleData['nutritionScore'] ?? 50.0,
      );
    } catch (e) {
      _setError('Failed to gather user data: $e');
      return null;
    }
  }

  /// Get today's health data
  Future<Map<String, dynamic>> _getTodayHealthData(
    String userId,
    DateTime date,
  ) async {
    try {
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      final doc = await _firestore
          .collection('userProfiles')
          .doc(userId)
          .collection('healthData')
          .doc(dateStr)
          .get();

      if (doc.exists) {
        return doc.data()!;
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Failed to get health data: $e');
      }
    }

    return {};
  }

  /// Get today's efficiency data
  Future<Map<String, dynamic>> _getTodayEfficiencyData(
    String userId,
    DateTime date,
  ) async {
    try {
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      final doc = await _firestore
          .collection('userProfiles')
          .doc(userId)
          .collection('efficiency')
          .doc('dailySummaries')
          .collection('summaries')
          .doc(dateStr)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        return {
          'completedTasks': data['completedTasks'] ?? 0,
          'totalTasks': data['totalTasks'] ?? 0,
          'completedPomodoros': data['completedPomodoros'] ?? 0,
          'totalFocusMinutes': data['totalFocusMinutes'] ?? 0,
          'efficiencyScore': data['efficiencyScore'] ?? 50.0,
          'completedRoutines': data['completedRoutines'] ?? 0,
          'totalRoutines': data['totalRoutines'] ?? 0,
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Failed to get efficiency data: $e');
      }
    }

    return {};
  }

  /// Get today's lifestyle data
  Future<Map<String, dynamic>> _getTodayLifestyleData(
    String userId,
    DateTime date,
  ) async {
    try {
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      final doc = await _firestore
          .collection('userProfiles')
          .doc(userId)
          .collection('lifestyleData')
          .doc(dateStr)
          .get();

      if (doc.exists) {
        return doc.data()!;
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Failed to get lifestyle data: $e');
      }
    }

    return {};
  }

  /// Calculate score trends
  void _calculateScoreTrends() {
    if (_scoreHistory.length < 2) {
      _scoreTrends = {};
      return;
    }

    final current = _scoreHistory.first;
    final previous = _scoreHistory[1];

    _scoreTrends = {
      'health': current.scores.healthScore - previous.scores.healthScore,
      'efficiency':
          current.scores.efficiencyScore - previous.scores.efficiencyScore,
      'lifestyle':
          current.scores.lifestyleScore - previous.scores.lifestyleScore,
      'overall': current.scores.overallScore - previous.scores.overallScore,
    };
  }

  /// Save scores to Firestore
  Future<void> _saveScoresToFirestore(ScoreCalculationResult result) async {
    try {
      final dateStr =
          '${result.date.year}-${result.date.month.toString().padLeft(2, '0')}-${result.date.day.toString().padLeft(2, '0')}';

      await _firestore
          .collection('userProfiles')
          .doc(result.userId)
          .collection('mlScores')
          .doc(dateStr)
          .set(result.toJson());
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Failed to save scores to Firestore: $e');
      }
    }
  }

  /// Load score history from Firestore
  Future<void> loadScoreHistory(String userId, {int days = 30}) async {
    try {
      _clearError();

      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: days));

      final query = await _firestore
          .collection('userProfiles')
          .doc(userId)
          .collection('mlScores')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('date', descending: true)
          .get();

      _scoreHistory = query.docs
          .map((doc) => ScoreCalculationResult.fromJson(doc.data()))
          .toList();

      if (_scoreHistory.isNotEmpty) {
        _currentScores = _scoreHistory.first;
        _calculateScoreTrends();
      }

      notifyListeners();
    } catch (e) {
      _setError('Failed to load score history: $e');
      notifyListeners();
    }
  }

  /// Get score statistics
  Map<String, dynamic> getScoreStatistics() {
    if (_scoreHistory.isEmpty) {
      return {
        'averageHealth': 0.0,
        'averageEfficiency': 0.0,
        'averageLifestyle': 0.0,
        'averageOverall': 0.0,
        'bestHealth': 0.0,
        'bestEfficiency': 0.0,
        'bestLifestyle': 0.0,
        'bestOverall': 0.0,
        'improvementHealth': 0.0,
        'improvementEfficiency': 0.0,
        'improvementLifestyle': 0.0,
        'improvementOverall': 0.0,
      };
    }

    final healthScores = _scoreHistory
        .map((s) => s.scores.healthScore)
        .toList();
    final efficiencyScores = _scoreHistory
        .map((s) => s.scores.efficiencyScore)
        .toList();
    final lifestyleScores = _scoreHistory
        .map((s) => s.scores.lifestyleScore)
        .toList();
    final overallScores = _scoreHistory
        .map((s) => s.scores.overallScore)
        .toList();

    return {
      'averageHealth':
          healthScores.reduce((a, b) => a + b) / healthScores.length,
      'averageEfficiency':
          efficiencyScores.reduce((a, b) => a + b) / efficiencyScores.length,
      'averageLifestyle':
          lifestyleScores.reduce((a, b) => a + b) / lifestyleScores.length,
      'averageOverall':
          overallScores.reduce((a, b) => a + b) / overallScores.length,
      'bestHealth': healthScores.reduce((a, b) => a > b ? a : b),
      'bestEfficiency': efficiencyScores.reduce((a, b) => a > b ? a : b),
      'bestLifestyle': lifestyleScores.reduce((a, b) => a > b ? a : b),
      'bestOverall': overallScores.reduce((a, b) => a > b ? a : b),
      'improvementHealth': _scoreTrends['health'] ?? 0.0,
      'improvementEfficiency': _scoreTrends['efficiency'] ?? 0.0,
      'improvementLifestyle': _scoreTrends['lifestyle'] ?? 0.0,
      'improvementOverall': _scoreTrends['overall'] ?? 0.0,
    };
  }

  /// Clear error
  void _clearError() {
    _error = '';
  }

  /// Set error
  void _setError(String error) {
    _error = error;
    if (kDebugMode) {
      print('❌ ML Score Provider Error: $error');
    }
  }

  @override
  void dispose() {
    _mlService.dispose();
    super.dispose();
  }
}
