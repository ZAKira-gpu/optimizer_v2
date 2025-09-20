import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';
import '../models/ml_models.dart';

/// ML Score Service for calculating health, efficiency, and lifestyle scores
///
/// This service uses TensorFlow Lite to run ML model inference
class MLScoreService {
  static MLScoreService? _instance;
  static MLScoreService get instance => _instance ??= MLScoreService._();

  MLScoreService._();

  // Model and interpreter
  Interpreter? _interpreter;
  bool _isInitialized = false;
  String? _modelPath;
  String? _error;

  // Model configuration
  static const String _modelFileName = 'optimizer_scores_model.tflite';
  static const int _inputSize = 26; // Number of input features
  static const int _outputSize =
      4; // Health, Efficiency, Lifestyle, Overall scores

  // Getters
  bool get isInitialized => _isInitialized;
  String? get error => _error;
  String? get modelPath => _modelPath;

  /// Initialize the ML service
  Future<bool> initialize() async {
    try {
      if (_isInitialized) return true;

      _clearError();

      // Load the model
      await _loadModel();

      if (_interpreter == null) {
        _setError('Failed to load TensorFlow Lite model');
        return false;
      }

      // Validate model input/output shapes
      final inputShape = _interpreter!.getInputTensor(0).shape;
      final outputShape = _interpreter!.getOutputTensor(0).shape;

      if (kDebugMode) {
        print('🤖 ML Model loaded successfully');
        print('📊 Input shape: $inputShape');
        print('📊 Output shape: $outputShape');
        print('📁 Model path: $_modelPath');
      }

      _isInitialized = true;
      return true;
    } catch (e) {
      _setError('Failed to initialize ML service: $e');
      if (kDebugMode) {
        print('❌ ML Service initialization failed: $e');
      }
      return false;
    }
  }

  /// Load the TensorFlow Lite model
  Future<void> _loadModel() async {
    try {
      // Try to load from assets first
      _modelPath = await _loadModelFromAssets();

      if (_modelPath == null) {
        // Fallback: create a mock model for development
        if (kDebugMode) {
          print('⚠️ Model file not found, using mock model for development');
        }
        _createMockModel();
        return;
      }

      // Load the actual model
      _interpreter = await Interpreter.fromFile(File(_modelPath!));

      if (kDebugMode) {
        print('✅ TensorFlow Lite model loaded from: $_modelPath');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Failed to load model from assets: $e');
        print('🔄 Creating mock model for development');
      }
      _createMockModel();
    }
  }

  /// Load model from assets
  Future<String?> _loadModelFromAssets() async {
    try {
      // Copy model from assets to temporary directory
      final tempDir = Directory.systemTemp;
      final modelFile = File('${tempDir.path}/$_modelFileName');

      if (await modelFile.exists()) {
        return modelFile.path;
      }

      // Try to load from assets
      final modelData = await rootBundle.load('assets/models/$_modelFileName');
      await modelFile.writeAsBytes(modelData.buffer.asUint8List());

      return modelFile.path;
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Could not load model from assets: $e');
      }
      return null;
    }
  }

  /// Create a mock model for development/testing
  void _createMockModel() {
    // Create a mock interpreter that returns predictable scores
    // This is useful for development when the actual model isn't available
    _interpreter = _MockInterpreter();
    _modelPath = 'mock_model';

    if (kDebugMode) {
      print('🎭 Mock model created for development');
    }
  }

  /// Calculate scores using the ML model
  Future<MLOutputData> calculateScores(MLInputData inputData) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      if (_interpreter == null) {
        throw Exception('ML model not initialized');
      }

      // Prepare input data
      final inputList = inputData.toList();
      if (inputList.length != _inputSize) {
        throw Exception(
          'Invalid input size: ${inputList.length}, expected: $_inputSize',
        );
      }

      // Create input tensor
      final input = [inputList];
      final output = List.filled(1, List.filled(_outputSize, 0.0));

      // Run inference
      _interpreter!.run(input, output);

      // Extract scores from output
      final scores = List<double>.from(output[0]);

      // Create output data
      final result = MLOutputData.fromModelOutput(scores);

      if (kDebugMode) {
        print('🤖 ML Scores calculated:');
        print('   Health: ${result.healthScore.toStringAsFixed(1)}');
        print('   Efficiency: ${result.efficiencyScore.toStringAsFixed(1)}');
        print('   Lifestyle: ${result.lifestyleScore.toStringAsFixed(1)}');
        print('   Overall: ${result.overallScore.toStringAsFixed(1)}');
      }

      return result;
    } catch (e) {
      _setError('Failed to calculate scores: $e');
      if (kDebugMode) {
        print('❌ Score calculation failed: $e');
      }

      // Return default scores in case of error
      return _getDefaultScores();
    }
  }

  /// Get default scores when calculation fails
  MLOutputData _getDefaultScores() {
    return MLOutputData(
      healthScore: 50.0,
      efficiencyScore: 50.0,
      lifestyleScore: 50.0,
      overallScore: 50.0,
      recommendations: [
        'Unable to calculate scores. Please check your data.',
        'Ensure all required metrics are available.',
        'Try again later or contact support.',
      ],
      scoreBreakdown: {
        'health': 50.0,
        'efficiency': 50.0,
        'lifestyle': 50.0,
        'overall': 50.0,
      },
    );
  }

  /// Calculate scores with caching
  Future<ScoreCalculationResult> calculateScoresWithCache(
    ScoreCalculationRequest request,
  ) async {
    try {
      // Check if we have cached results for today
      final cachedResult = await _getCachedResult(request.userId, request.date);
      if (cachedResult != null) {
        return cachedResult.copyWith(isCached: true);
      }

      // Calculate new scores
      final scores = await calculateScores(request.inputData);

      // Create result
      final result = ScoreCalculationResult(
        userId: request.userId,
        date: request.date,
        scores: scores,
        modelVersion: request.modelVersion,
        calculatedAt: DateTime.now(),
      );

      // Cache the result
      await _cacheResult(result);

      return result;
    } catch (e) {
      _setError('Failed to calculate scores with cache: $e');
      rethrow;
    }
  }

  /// Get cached result
  Future<ScoreCalculationResult?> _getCachedResult(
    String userId,
    DateTime date,
  ) async {
    // TODO: Implement caching logic (Hive, SharedPreferences, etc.)
    // For now, return null to always calculate fresh scores
    return null;
  }

  /// Cache result
  Future<void> _cacheResult(ScoreCalculationResult result) async {
    // TODO: Implement caching logic
    // For now, do nothing
  }

  /// Get model information
  Map<String, dynamic> getModelInfo() {
    if (!_isInitialized || _interpreter == null) {
      return {'initialized': false, 'error': _error};
    }

    return {
      'initialized': true,
      'modelPath': _modelPath,
      'inputSize': _inputSize,
      'outputSize': _outputSize,
      'inputShape': _interpreter!.getInputTensor(0).shape,
      'outputShape': _interpreter!.getOutputTensor(0).shape,
    };
  }

  /// Dispose resources
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isInitialized = false;
    _modelPath = null;
    _error = null;
  }

  // Private helper methods
  void _clearError() {
    _error = null;
  }

  void _setError(String error) {
    _error = error;
    if (kDebugMode) {
      print('❌ ML Service Error: $error');
    }
  }
}

/// Mock interpreter for development
class _MockInterpreter implements Interpreter {
  @override
  void run(Object input, Object output) {
    // Mock implementation that returns realistic scores based on input
    final inputList = (input as List<List<double>>)[0];

    // Simple scoring logic based on input values
    final steps = inputList[0];
    final sleepHours = inputList[1];
    final completedTasks = inputList[11];
    final totalTasks = inputList[12];
    final efficiencyScore = inputList[15];

    // Calculate mock scores
    final healthScore = _calculateMockHealthScore(inputList);
    final efficiencyScore = _calculateMockEfficiencyScore(inputList);
    final lifestyleScore = _calculateMockLifestyleScore(inputList);
    final overallScore = (healthScore + efficiencyScore + lifestyleScore) / 3;

    // Set output
    final outputList = output as List<List<double>>;
    outputList[0] = [
      healthScore / 100.0, // Normalize to 0-1
      efficiencyScore / 100.0,
      lifestyleScore / 100.0,
      overallScore / 100.0,
    ];
  }

  double _calculateMockHealthScore(List<double> input) {
    final steps = input[0];
    final sleepHours = input[1];
    final caloriesIn = input[2];
    final caloriesOut = input[3];
    final waterIntake = input[4];

    // Simple scoring based on health metrics
    double score = 50.0; // Base score

    // Steps contribution (0-20 points)
    score += (steps / 10000.0 * 20).clamp(0, 20);

    // Sleep contribution (0-20 points)
    if (sleepHours >= 7 && sleepHours <= 9) {
      score += 20;
    } else if (sleepHours >= 6 && sleepHours <= 10) {
      score += 15;
    } else {
      score += 10;
    }

    // Calorie balance contribution (0-10 points)
    final calorieBalance = (caloriesOut - caloriesIn) / caloriesIn;
    if (calorieBalance > 0) {
      score += 10;
    } else {
      score += 5;
    }

    return score.clamp(0, 100);
  }

  double _calculateMockEfficiencyScore(List<double> input) {
    final completedTasks = input[11];
    final totalTasks = input[12];
    final completedPomodoros = input[13];
    final efficiencyScore = input[15];

    double score = 50.0; // Base score

    // Task completion contribution (0-30 points)
    if (totalTasks > 0) {
      final taskCompletionRate = completedTasks / totalTasks;
      score += taskCompletionRate * 30;
    }

    // Pomodoro contribution (0-20 points)
    score += (completedPomodoros / 8.0 * 20).clamp(0, 20);

    return score.clamp(0, 100);
  }

  double _calculateMockLifestyleScore(List<double> input) {
    final screenTime = input[18];
    final exerciseMinutes = input[19];
    final socialInteractions = input[20];
    final stressLevel = input[21];
    final mood = input[22];

    double score = 50.0; // Base score

    // Exercise contribution (0-20 points)
    score += (exerciseMinutes / 60.0 * 20).clamp(0, 20);

    // Screen time contribution (0-15 points) - less is better
    if (screenTime <= 2) {
      score += 15;
    } else if (screenTime <= 4) {
      score += 10;
    } else if (screenTime <= 6) {
      score += 5;
    }

    // Social interactions contribution (0-15 points)
    score += (socialInteractions / 10.0 * 15).clamp(0, 15);

    return score.clamp(0, 100);
  }

  @override
  void close() {
    // Mock implementation - nothing to close
  }

  @override
  Tensor getInputTensor(int index) {
    return _MockTensor([1, 26]); // Mock input shape
  }

  @override
  Tensor getOutputTensor(int index) {
    return _MockTensor([1, 4]); // Mock output shape
  }

  @override
  int get inputTensorCount => 1;

  @override
  int get outputTensorCount => 1;

  @override
  void resizeInputTensor(int index, List<int> shape) {
    // Mock implementation
  }

  @override
  void allocateTensors() {
    // Mock implementation
  }
}

/// Mock tensor for development
class _MockTensor implements Tensor {
  final List<int> _shape;

  _MockTensor(this._shape);

  @override
  List<int> get shape => _shape;

  @override
  DataType get type => DataType.float32;

  @override
  int get numBytes => 0;

  @override
  int get numElements => 0;
}
