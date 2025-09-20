import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../auth/viewmodel/auth_provider.dart';
import '../../profile/viewmodel/profile_provider.dart';
import '../viewmodel/step_tracker_provider.dart';
import '../viewmodel/sleep_provider.dart';
import '../viewmodel/health_database_provider.dart';
import '../models/health_models.dart';
import '../../meals/view/simple_meal_logging_screen.dart';

/// Health screen for step tracking and health metrics
///
/// This screen displays real-time step tracking, distance, calories,
/// and health progress with daily goals and statistics.
class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  @override
  void initState() {
    super.initState();
    // Defer initialization until after the build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeStepTracking();
      _initializeSleepTracking();
      _initializeHealthDatabase();
    });
    _startPeriodicSave();
  }

  @override
  void dispose() {
    _periodicSaveTimer?.cancel();
    _sleepUpdateTimer?.cancel();
    super.dispose();
  }

  Timer? _periodicSaveTimer;
  Timer? _sleepUpdateTimer;

  void _startPeriodicSave() {
    // Save step data and update points every 5 minutes
    _periodicSaveTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _saveStepDataAndUpdatePoints();
    });

    // Update sleep duration every minute while sleeping
    _sleepUpdateTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _updateSleepDuration();
    });
  }

  void _updateSleepDuration() {
    final sleepProvider = Provider.of<SleepProvider>(context, listen: false);
    sleepProvider.updateCurrentSleepDuration();
  }

  Future<void> _saveStepDataAndUpdatePoints() async {
    if (!mounted) return;

    final stepTrackerProvider = Provider.of<StepTrackerProvider>(
      context,
      listen: false,
    );
    final sleepProvider = Provider.of<SleepProvider>(context, listen: false);
    final healthDatabaseProvider = Provider.of<HealthDatabaseProvider>(
      context,
      listen: false,
    );
    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final user = authProvider.user;
    final profile = profileProvider.userProfile;

    if (user != null && profile != null && mounted) {
      // Create comprehensive health data
      final today = DateTime.now();
      final stepData = StepData(
        steps: stepTrackerProvider.currentSteps,
        distance: stepTrackerProvider.currentDistance,
        calories: stepTrackerProvider.currentCalories,
        status: stepTrackerProvider.status,
        goal: stepTrackerProvider.getStepGoal(profile.level),
        goalAchieved: stepTrackerProvider.isDailyGoalAchieved(profile.level),
        lastUpdated: DateTime.now(),
      );

      final sleepData = SleepData(
        sleepStart: sleepProvider.currentSleepStart,
        sleepEnd: sleepProvider.currentSleepEnd,
        duration: sleepProvider.currentSleepDuration,
        quality: sleepProvider.currentSleepQuality,
        totalMovements: 0, // This would come from sleep service
        restlessPeriods: 0, // This would come from sleep service
        goal: sleepProvider.sleepGoal,
        goalAchieved:
            sleepProvider.currentSleepDuration >= sleepProvider.sleepGoal * 0.8,
        qualityDescription: sleepProvider.getSleepQualityDescription(),
        lastUpdated: DateTime.now(),
      );

      final healthMetrics = HealthMetrics(
        points: profile.points,
        streak: healthDatabaseProvider.currentHealthMetrics.streak,
        longestStreak:
            healthDatabaseProvider.currentHealthMetrics.longestStreak,
        weeklyAverageSteps:
            healthDatabaseProvider.weeklyAverages['steps'] ?? 0.0,
        weeklyAverageSleep:
            healthDatabaseProvider.weeklyAverages['sleep'] ?? 0.0,
        goalAchievementRate:
            healthDatabaseProvider.currentHealthMetrics.goalAchievementRate,
        level: profile.level,
        lastUpdated: DateTime.now(),
      );

      final healthData = HealthData(
        userId: user.id,
        date: today,
        stepData: stepData,
        sleepData: sleepData,
        metrics: healthMetrics,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to health database
      await healthDatabaseProvider.saveDailyHealthData(user.id, healthData);

      // Update points if goal achieved
      if (stepTrackerProvider.isDailyGoalAchieved(profile.level)) {
        await profileProvider.updatePointsFromSteps(
          user.id,
          stepTrackerProvider.currentSteps,
          profile.level,
        );
      }
    }
  }

  Future<void> _initializeStepTracking() async {
    final stepTrackerProvider = Provider.of<StepTrackerProvider>(
      context,
      listen: false,
    );
    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Initialize step tracking
    await stepTrackerProvider.initialize();

    // Set user metrics from profile
    final profile = profileProvider.userProfile;
    if (profile != null) {
      stepTrackerProvider.setUserMetrics(
        height: profile.height,
        weight: profile.weight,
      );
    }

    // Load today's data
    final user = authProvider.user;
    if (user != null && mounted) {
      await stepTrackerProvider.loadTodayData(user.id);
    }
  }

  Future<void> _initializeSleepTracking() async {
    final sleepProvider = Provider.of<SleepProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Initialize sleep tracking
    await sleepProvider.initialize();

    // Load weekly sleep data
    final user = authProvider.user;
    if (user != null && mounted) {
      await sleepProvider.loadWeeklyData(user.id);
    }
  }

  Future<void> _initializeHealthDatabase() async {
    final healthDatabaseProvider = Provider.of<HealthDatabaseProvider>(
      context,
      listen: false,
    );
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Initialize health database
    final user = authProvider.user;
    if (user != null && mounted) {
      await healthDatabaseProvider.initialize(user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LiquidGlassBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.spacing24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: AppDimensions.spacing24),
                _buildStepCounter(context),
                const SizedBox(height: AppDimensions.spacing24),
                _buildSleepTracker(context),
                const SizedBox(height: AppDimensions.spacing24),
                _buildHealthInsights(context),
                const SizedBox(height: AppDimensions.spacing24),
                _buildMealLoggingButton(context),
                const SizedBox(height: AppDimensions.spacing24),
                _buildMetricsCards(context),
                const SizedBox(height: AppDimensions.spacing24),
                _buildDailyGoal(context),
                const SizedBox(height: AppDimensions.spacing24),
                _buildWeeklyStats(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          ),
          child: const Icon(
            Icons.favorite_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(width: AppDimensions.spacing16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Health Tracker',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Track your daily activity',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepCounter(BuildContext context) {
    return Consumer<StepTrackerProvider>(
      builder: (context, stepTracker, child) {
        if (!stepTracker.isInitialized) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                const CircularProgressIndicator(color: Colors.white),
                const SizedBox(height: 16),
                Text(
                  'Initializing step tracking...',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          );
        }

        if (stepTracker.error.isNotEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.red.withOpacity(0.3), width: 1),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Step tracking unavailable',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  stepTracker.error,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.2),
                Colors.white.withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              // Steps counter
              Text(
                '${stepTracker.currentSteps}',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 64,
                ),
              ),
              Text(
                'Steps Today',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),

              // Status indicator
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(stepTracker.status).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _getStatusColor(stepTracker.status).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getStatusIcon(stepTracker.status),
                      color: _getStatusColor(stepTracker.status),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      stepTracker.status,
                      style: TextStyle(
                        color: _getStatusColor(stepTracker.status),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricsCards(BuildContext context) {
    return Consumer<StepTrackerProvider>(
      builder: (context, stepTracker, child) {
        return Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                context,
                'Distance',
                stepTracker.getFormattedDistance(),
                Icons.directions_walk_rounded,
                const Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                context,
                'Calories',
                stepTracker.getFormattedCalories(),
                Icons.local_fire_department_rounded,
                const Color(0xFFFF9800),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyGoal(BuildContext context) {
    return Consumer2<StepTrackerProvider, ProfileProvider>(
      builder: (context, stepTracker, profileProvider, child) {
        final level = profileProvider.userProfile?.level ?? 'Beginner';
        final goal = stepTracker.getStepGoal(level);
        final progress = stepTracker.getDailyGoalProgress(level);
        final isAchieved = stepTracker.isDailyGoalAchieved(level);

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.15),
                Colors.white.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Daily Goal',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isAchieved
                          ? const Color(0xFF4CAF50).withOpacity(0.2)
                          : Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      isAchieved
                          ? 'Achieved!'
                          : '${stepTracker.currentSteps}/$goal',
                      style: TextStyle(
                        color: isAchieved
                            ? const Color(0xFF4CAF50)
                            : Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isAchieved
                            ? [const Color(0xFF4CAF50), const Color(0xFF2E7D32)]
                            : [
                                const Color(0xFF2196F3),
                                const Color(0xFF1976D2),
                              ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${(progress * 100).toStringAsFixed(0)}% of your $level goal',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWeeklyStats(BuildContext context) {
    return Consumer<StepTrackerProvider>(
      builder: (context, stepTracker, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.15),
                Colors.white.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This Week',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      'Total Steps',
                      '${stepTracker.getWeeklyTotal()}',
                      Icons.trending_up_rounded,
                      const Color(0xFF2196F3),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatItem(
                      'Daily Average',
                      '${stepTracker.getWeeklyAverage().toStringAsFixed(0)}',
                      Icons.analytics_rounded,
                      const Color(0xFF9C27B0),
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

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'walking':
        return const Color(0xFF4CAF50);
      case 'running':
        return const Color(0xFFFF9800);
      case 'stopped':
        return const Color(0xFF9E9E9E);
      default:
        return const Color(0xFF2196F3);
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'walking':
        return Icons.directions_walk_rounded;
      case 'running':
        return Icons.directions_run_rounded;
      case 'stopped':
        return Icons.pause_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  Widget _buildSleepTracker(BuildContext context) {
    return Consumer<SleepProvider>(
      builder: (context, sleepProvider, child) {
        if (!sleepProvider.isInitialized) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.bedtime_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Sleep Tracking',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'Initializing sleep tracking...',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.bedtime_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Sleep Tracking',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: sleepProvider.isSleeping
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFF2196F3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      sleepProvider.getSleepStatus(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Sleep duration and quality
              Row(
                children: [
                  Expanded(
                    child: _buildSleepMetric(
                      context,
                      'Duration',
                      '${sleepProvider.currentSleepDuration.toStringAsFixed(1)}h',
                      Icons.access_time_rounded,
                      const Color(0xFF2196F3),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSleepMetric(
                      context,
                      'Quality',
                      '${sleepProvider.currentSleepQuality.toStringAsFixed(0)}%',
                      Icons.star_rounded,
                      Color(sleepProvider.getSleepQualityColor()),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Sleep goal and streak
              Row(
                children: [
                  Expanded(
                    child: _buildSleepMetric(
                      context,
                      'Goal',
                      '${sleepProvider.sleepGoal.toStringAsFixed(0)}h',
                      Icons.flag_rounded,
                      const Color(0xFFFF9800),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSleepMetric(
                      context,
                      'Streak',
                      '${sleepProvider.currentStreak} days',
                      Icons.local_fire_department_rounded,
                      const Color(0xFFFF5722),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Sleep tracking controls
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: sleepProvider.isSleeping
                          ? () => _stopSleepTracking()
                          : () => _startSleepTracking(),
                      icon: Icon(
                        sleepProvider.isSleeping
                            ? Icons.stop_rounded
                            : Icons.bedtime_rounded,
                        color: Colors.white,
                      ),
                      label: Text(
                        sleepProvider.isSleeping ? 'Stop Sleep' : 'Start Sleep',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: sleepProvider.isSleeping
                            ? const Color(0xFFF44336) // Red for stop
                            : const Color(0xFF4CAF50), // Green for start
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _resetSleepData(),
                      icon: const Icon(
                        Icons.refresh_rounded,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Reset',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white, width: 1),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              if (sleepProvider.error.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.red.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    sleepProvider.error,
                    style: TextStyle(color: Colors.red.shade300, fontSize: 12),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildSleepMetric(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthInsights(BuildContext context) {
    return Consumer<HealthDatabaseProvider>(
      builder: (context, healthDatabase, child) {
        if (!healthDatabase.isInitialized) {
          return const SizedBox.shrink();
        }

        final insights = healthDatabase.healthInsights;
        final healthScore = healthDatabase.healthScore;
        final healthLevel = healthDatabase.healthLevel;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.insights_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Health Insights',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getHealthScoreColor(healthScore).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getHealthScoreColor(
                          healthScore,
                        ).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '$healthScore',
                      style: TextStyle(
                        color: _getHealthScoreColor(healthScore),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                healthLevel,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),

              if (insights.isNotEmpty) ...[
                ...insights.map(
                  (insight) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.lightbulb_rounded,
                          color: Color(0xFFFFD700),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            insight,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                Text(
                  'Keep tracking your health to get personalized insights!',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Color _getHealthScoreColor(int score) {
    if (score >= 80) return const Color(0xFF4CAF50); // Green
    if (score >= 60) return const Color(0xFFFF9800); // Orange
    return const Color(0xFFF44336); // Red
  }

  /// Start manual sleep tracking
  Future<void> _startSleepTracking() async {
    final sleepProvider = Provider.of<SleepProvider>(context, listen: false);

    try {
      // Start manual sleep tracking
      await sleepProvider.startManualSleep();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sleep tracking started! 🌙'),
            backgroundColor: Color(0xFF4CAF50),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start sleep tracking: $e'),
            backgroundColor: const Color(0xFFF44336),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Stop manual sleep tracking
  Future<void> _stopSleepTracking() async {
    final sleepProvider = Provider.of<SleepProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      // Stop manual sleep tracking
      await sleepProvider.stopManualSleep();

      // Save current sleep session
      final user = authProvider.user;
      if (user != null) {
        final success = await sleepProvider.saveCurrentSession(user.id);
        if (success) {
          print('Sleep session saved successfully to Firestore');
        } else {
          print('Failed to save sleep session to Firestore');
        }
      }

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sleep tracking stopped! ☀️'),
            backgroundColor: Color(0xFF2196F3),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error in _stopSleepTracking: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to stop sleep tracking: $e'),
            backgroundColor: const Color(0xFFF44336),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Reset sleep data
  Future<void> _resetSleepData() async {
    final sleepProvider = Provider.of<SleepProvider>(context, listen: false);

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Reset Sleep Data',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to reset your current sleep data? This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Reset',
              style: TextStyle(color: Color(0xFFF44336)),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Stop manual sleep and reset data
        await sleepProvider.stopManualSleep();

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sleep data reset successfully! 🔄'),
              backgroundColor: Color(0xFF2196F3),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to reset sleep data: $e'),
              backgroundColor: const Color(0xFFF44336),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  /// Build meal logging button
  Widget _buildMealLoggingButton(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _navigateToMealLogging(context),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.restaurant,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Log Your Meal',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Track your nutrition with AI-powered food recognition',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Navigate to meal logging screen
  void _navigateToMealLogging(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SimpleMealLoggingScreen()),
    );
  }
}
