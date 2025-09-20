import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/viewmodel/auth_provider.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/glassmorphism_container.dart';
import '../../profile/view/profile_screen.dart';
import '../../profile/viewmodel/profile_provider.dart';
import '../../health/viewmodel/step_tracker_provider.dart';
import '../../health/viewmodel/sleep_provider.dart';
import '../../health/viewmodel/health_database_provider.dart';
import '../../efficiency/viewmodel/efficiency_provider.dart';
import '../../efficiency/models/efficiency_models.dart';
import '../../meals/view/simple_meal_logging_screen.dart';
import '../../efficiency/view/efficiency_screen.dart';
import '../../health/view/health_screen.dart';

/// HomeScreen widget for habit tracking and fitness dashboard
///
/// This widget provides the main dashboard interface with:
/// - User welcome message and points
/// - Daily habit tracking
/// - Quick fitness actions
/// - Progress overview
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _periodicUpdateTimer;

  @override
  void initState() {
    super.initState();
    // Initialize providers and start periodic updates
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProviders();
      _startPeriodicUpdates();
    });
  }

  @override
  void dispose() {
    _periodicUpdateTimer?.cancel();
    super.dispose();
  }

  /// Initialize all providers
  Future<void> _initializeProviders() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    if (user != null) {
      // Initialize health providers
      final stepProvider = Provider.of<StepTrackerProvider>(
        context,
        listen: false,
      );
      final sleepProvider = Provider.of<SleepProvider>(context, listen: false);
      final healthProvider = Provider.of<HealthDatabaseProvider>(
        context,
        listen: false,
      );
      final efficiencyProvider = Provider.of<EfficiencyProvider>(
        context,
        listen: false,
      );

      // Initialize step tracking
      await stepProvider.initialize();
      await stepProvider.loadTodayData(user.id);

      // Initialize sleep tracking
      await sleepProvider.initialize();
      await sleepProvider.loadWeeklyData(user.id);

      // Initialize health database
      await healthProvider.initialize(user.id);

      // Initialize efficiency provider
      efficiencyProvider.initialize();
    }
  }

  /// Start periodic updates for real-time data
  void _startPeriodicUpdates() {
    _periodicUpdateTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        setState(() {
          // Trigger UI updates
        });
      }
    });
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
                // Enhanced Header with glassmorphism
                _buildEnhancedHeader(context),
                const SizedBox(height: AppDimensions.spacing24),

                // Quick Health Overview
                _buildHealthOverview(context),
                const SizedBox(height: AppDimensions.spacing24),

                // Quick Actions Section
                _buildQuickActions(context),
                const SizedBox(height: AppDimensions.spacing24),

                // Productivity Overview
                _buildProductivityOverview(context),
                const SizedBox(height: AppDimensions.spacing24),

                // Enhanced Metrics Cards
                _buildEnhancedMetricsCards(context),
                const SizedBox(height: AppDimensions.spacing24),

                // Insights and Recommendations
                _buildInsightsSection(context),
                const SizedBox(height: AppDimensions.spacing24),

                // Date selector
                _buildDateSelector(context),
                const SizedBox(height: AppDimensions.spacing24),

                // Features section
                _buildFeaturesSection(context),
                const SizedBox(height: AppDimensions.spacing24),

                // Reminders section
                _buildRemindersSection(context),
                const SizedBox(height: AppDimensions.spacing24),

                // Monthly track
                _buildMonthlyTrack(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Enhanced Header with glassmorphism design
  Widget _buildEnhancedHeader(BuildContext context) {
    return Consumer2<AuthProvider, ProfileProvider>(
      builder: (context, authProvider, profileProvider, child) {
        final user = authProvider.user;
        final profile = profileProvider.userProfile;
        final userName = user != null
            ? user.email.split('@').first.toUpperCase()
            : 'USER';
        final currentHour = DateTime.now().hour;
        String greeting = 'Good Morning';
        if (currentHour >= 12 && currentHour < 17) {
          greeting = 'Good Afternoon';
        } else if (currentHour >= 17) {
          greeting = 'Good Evening';
        }

        return GlassmorphismContainer(
          borderRadius: 20.0,
          blur: 15.0,
          opacity: 0.15,
          borderColor: Colors.white,
          borderWidth: 1.5,
          padding: const EdgeInsets.all(AppDimensions.spacing20),
          child: Row(
            children: [
              // Profile Avatar
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.2),
                      Colors.white.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppDimensions.spacing16),

              // Greeting and User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      userName,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    if (profile != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${profile.points} Points',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Colors.white.withOpacity(0.8),
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getLevelColor(
                                profile.level,
                              ).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _getLevelColor(
                                  profile.level,
                                ).withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              profile.level,
                              style: TextStyle(
                                color: _getLevelColor(profile.level),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Menu Button
              GestureDetector(
                onTap: () => _showMenu(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: const Icon(
                    Icons.menu_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Get level color based on user level
  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'beginner':
        return const Color(0xFF4CAF50);
      case 'intermediate':
        return const Color(0xFF2196F3);
      case 'advanced':
        return const Color(0xFF9C27B0);
      case 'expert':
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFF4CAF50);
    }
  }

  /// Health Overview Section
  Widget _buildHealthOverview(BuildContext context) {
    return Consumer3<StepTrackerProvider, SleepProvider, ProfileProvider>(
      builder: (context, stepProvider, sleepProvider, profileProvider, child) {
        final profile = profileProvider.userProfile;
        final level = profile?.level ?? 'Beginner';
        final stepGoal = stepProvider.getStepGoal(level);
        final stepProgress = stepProvider.getDailyGoalProgress(level);
        final isStepGoalAchieved = stepProvider.isDailyGoalAchieved(level);

        return GlassmorphismContainer(
          borderRadius: 20.0,
          blur: 15.0,
          opacity: 0.15,
          borderColor: Colors.white,
          borderWidth: 1.5,
          padding: const EdgeInsets.all(AppDimensions.spacing20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.favorite_rounded,
                      color: Color(0xFF4CAF50),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Health Overview',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Steps Counter
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.1),
                      Colors.white.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    Text(
                      '${stepProvider.currentSteps}',
                      style: Theme.of(context).textTheme.displayMedium
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 48,
                          ),
                    ),
                    Text(
                      'Steps Today',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Progress Bar
                    Container(
                      width: double.infinity,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: stepProgress.clamp(0.0, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isStepGoalAchieved
                                  ? [
                                      const Color(0xFF4CAF50),
                                      const Color(0xFF2E7D32),
                                    ]
                                  : [
                                      const Color(0xFF2196F3),
                                      const Color(0xFF1976D2),
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(stepProgress * 100).toStringAsFixed(0)}% of ${stepGoal} goal',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Health Metrics Row
              Row(
                children: [
                  Expanded(
                    child: _buildHealthMetric(
                      'Distance',
                      stepProvider.getFormattedDistance(),
                      Icons.directions_walk_rounded,
                      const Color(0xFF4CAF50),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildHealthMetric(
                      'Calories',
                      stepProvider.getFormattedCalories(),
                      Icons.local_fire_department_rounded,
                      const Color(0xFFFF9800),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildHealthMetric(
                      'Sleep',
                      '${sleepProvider.currentSleepDuration.toStringAsFixed(1)}h',
                      Icons.bedtime_rounded,
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

  /// Health Metric Card
  Widget _buildHealthMetric(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Quick Actions Section
  Widget _buildQuickActions(BuildContext context) {
    return GlassmorphismContainer(
      borderRadius: 20.0,
      blur: 15.0,
      opacity: 0.15,
      borderColor: Colors.white,
      borderWidth: 1.5,
      padding: const EdgeInsets.all(AppDimensions.spacing20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.flash_on_rounded,
                  color: Color(0xFF2196F3),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Action Buttons Grid
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  'Log Meal',
                  Icons.restaurant_rounded,
                  const Color(0xFF4CAF50),
                  () => _navigateToMealLogging(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  'Start Focus',
                  Icons.timer_rounded,
                  const Color(0xFF9C27B0),
                  () => _navigateToEfficiency(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  'Health Tracker',
                  Icons.favorite_rounded,
                  const Color(0xFFF44336),
                  () => _navigateToHealth(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  'Sleep Track',
                  Icons.bedtime_rounded,
                  const Color(0xFF3F51B5),
                  () => _startSleepTracking(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Quick Action Button
  Widget _buildQuickActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
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
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Navigation Methods
  void _navigateToMealLogging(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SimpleMealLoggingScreen()),
    );
  }

  void _navigateToEfficiency(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EfficiencyScreen()),
    );
  }

  void _navigateToHealth(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HealthScreen()),
    );
  }

  void _startSleepTracking(BuildContext context) {
    final sleepProvider = Provider.of<SleepProvider>(context, listen: false);
    if (sleepProvider.isSleeping) {
      sleepProvider.stopManualSleep();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sleep tracking stopped! ☀️'),
          backgroundColor: Color(0xFF2196F3),
        ),
      );
    } else {
      sleepProvider.startManualSleep();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sleep tracking started! 🌙'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );
    }
  }

  /// Productivity Overview Section
  Widget _buildProductivityOverview(BuildContext context) {
    return Consumer<EfficiencyProvider>(
      builder: (context, efficiencyProvider, child) {
        return GlassmorphismContainer(
          borderRadius: 20.0,
          blur: 15.0,
          opacity: 0.15,
          borderColor: Colors.white,
          borderWidth: 1.5,
          padding: const EdgeInsets.all(AppDimensions.spacing20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF9C27B0).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.psychology_rounded,
                      color: Color(0xFF9C27B0),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Productivity Overview',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Productivity Metrics
              Row(
                children: [
                  Expanded(
                    child: _buildProductivityMetric(
                      'Focus Sessions',
                      '${efficiencyProvider.pomodoroService.completedPomodoros}',
                      Icons.timer_rounded,
                      const Color(0xFF9C27B0),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildProductivityMetric(
                      'Tasks Completed',
                      '${efficiencyProvider.tasks.where((task) => task.status == TaskStatus.completed).length}',
                      Icons.check_circle_rounded,
                      const Color(0xFF4CAF50),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildProductivityMetric(
                      'Routines',
                      '${efficiencyProvider.todayRoutines.length}',
                      Icons.repeat_rounded,
                      const Color(0xFF2196F3),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildProductivityMetric(
                      'Focus Time',
                      '${(efficiencyProvider.pomodoroService.completedPomodoros * 25)}m',
                      Icons.schedule_rounded,
                      const Color(0xFFFF9800),
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

  /// Productivity Metric Card
  Widget _buildProductivityMetric(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Enhanced Metrics Cards
  Widget _buildEnhancedMetricsCards(BuildContext context) {
    return Consumer2<StepTrackerProvider, ProfileProvider>(
      builder: (context, stepProvider, profileProvider, child) {
        final profile = profileProvider.userProfile;
        final level = profile?.level ?? 'Beginner';
        final stepGoal = stepProvider.getStepGoal(level);
        final stepProgress = stepProvider.getDailyGoalProgress(level);

        return GlassmorphismContainer(
          borderRadius: 20.0,
          blur: 15.0,
          opacity: 0.15,
          borderColor: Colors.white,
          borderWidth: 1.5,
          padding: const EdgeInsets.all(AppDimensions.spacing20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF9800).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.analytics_rounded,
                      color: Color(0xFFFF9800),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Daily Progress',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Progress Cards
              Row(
                children: [
                  Expanded(
                    child: _buildProgressCard(
                      'Steps Goal',
                      '${stepProvider.currentSteps}',
                      '$stepGoal',
                      stepProgress,
                      const Color(0xFF4CAF50),
                      Icons.directions_walk_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildProgressCard(
                      'Weekly Average',
                      '${stepProvider.getWeeklyAverage().toStringAsFixed(0)}',
                      'steps/day',
                      0.8, // Mock progress
                      const Color(0xFF2196F3),
                      Icons.trending_up_rounded,
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

  /// Progress Card
  Widget _buildProgressCard(
    String title,
    String current,
    String target,
    double progress,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
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
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            current,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            target,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Insights Section
  Widget _buildInsightsSection(BuildContext context) {
    return Consumer<HealthDatabaseProvider>(
      builder: (context, healthProvider, child) {
        final insights = healthProvider.healthInsights;
        final healthScore = healthProvider.healthScore;

        return GlassmorphismContainer(
          borderRadius: 20.0,
          blur: 15.0,
          opacity: 0.15,
          borderColor: Colors.white,
          borderWidth: 1.5,
          padding: const EdgeInsets.all(AppDimensions.spacing20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.lightbulb_rounded,
                      color: Color(0xFFFFD700),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Health Insights',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
                      ),
                    ),
                    child: Text(
                      'Score: $healthScore',
                      style: TextStyle(
                        color: _getHealthScoreColor(healthScore),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Insights List
              if (insights.isNotEmpty) ...[
                ...insights
                    .take(3)
                    .map(
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

  /// Get health score color
  Color _getHealthScoreColor(int score) {
    if (score >= 80) return const Color(0xFF4CAF50); // Green
    if (score >= 60) return const Color(0xFFFF9800); // Orange
    return const Color(0xFFF44336); // Red
  }

  Widget _buildHeader(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;
        final userName = user != null
            ? user.email.split('@').first.toUpperCase()
            : 'USER';
        final currentHour = DateTime.now().hour;
        String greeting = 'Good Morning';
        if (currentHour >= 12 && currentHour < 17) {
          greeting = 'Good Afternoon';
        } else if (currentHour >= 17) {
          greeting = 'Good Evening';
        }

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              // Hamburger menu with better styling
              GestureDetector(
                onTap: () => _showMenu(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.menu_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      userName,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              ),
              // Profile avatar
              GestureDetector(
                onTap: () => _navigateToProfile(context),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDateSelector(BuildContext context) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(7, (index) {
            final date = startOfWeek.add(Duration(days: index));
            final isToday =
                date.day == now.day &&
                date.month == now.month &&
                date.year == now.year;
            final dayName = _getDayAbbreviation(date.weekday);

            return Container(
              width: 50,
              height: 60,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: isToday
                    ? const Color(0xFF2196F3) // Brand blue for selected day
                    : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isToday
                      ? const Color(0xFF1976D2) // Darker blue border
                      : Colors.white.withOpacity(0.2),
                  width: isToday ? 2 : 1,
                ),
                boxShadow: isToday
                    ? [
                        BoxShadow(
                          color: const Color(0xFF2196F3).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isToday) ...[
                    const Icon(
                      Icons.notifications_active_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(height: 2),
                  ],
                  Text(
                    '${date.day}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isToday
                          ? Colors.white
                          : Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    dayName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isToday
                          ? Colors.white.withOpacity(0.9)
                          : Colors.white.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildMetricsCards(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Overview',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                context,
                'Steps',
                '0',
                Icons.directions_walk_rounded,
                const Color(0xFF4CAF50),
                const Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                context,
                'Distance',
                '0 m',
                Icons.straighten_rounded,
                const Color(0xFF9C27B0),
                const Color(0xFF6A1B9A),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                context,
                'Calories',
                '0 kcal',
                Icons.local_fire_department_rounded,
                const Color(0xFFFF9800),
                const Color(0xFFE65100),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color primaryColor,
    Color secondaryColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor.withOpacity(0.2),
            secondaryColor.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: primaryColor, size: 20),
              const Spacer(),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildFeatureCard(
                context,
                'Start Workout',
                Icons.fitness_center_rounded,
                const Color(0xFF2196F3),
                () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFeatureCard(
                context,
                'Track Water',
                Icons.water_drop_rounded,
                const Color(0xFF00BCD4),
                () {},
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemindersSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reminders',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        _buildReminderItem(
          'Drink water every 2 hours',
          Icons.water_drop_rounded,
          const Color(0xFF00BCD4),
        ),
        const SizedBox(height: 12),
        _buildReminderItem(
          'Take a 5-minute break',
          Icons.timer_rounded,
          const Color(0xFFFF9800),
        ),
        const SizedBox(height: 12),
        _buildReminderItem(
          'Stretch your body',
          Icons.accessibility_rounded,
          const Color(0xFF4CAF50),
        ),
      ],
    );
  }

  Widget _buildReminderItem(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyTrack(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Monthly Progress',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildProgressStat(
                      'Streak',
                      '0 days',
                      Icons.local_fire_department_rounded,
                      const Color(0xFFFF9800),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildProgressStat(
                      'Points',
                      '0',
                      Icons.stars_rounded,
                      const Color(0xFFFFD700),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressStat(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _getDayAbbreviation(int weekday) {
    const days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    return days[weekday - 1];
  }

  void _navigateToProfile(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const ProfileScreen()));
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            _buildMenuOption('Profile', Icons.person_rounded, () {
              Navigator.pop(context);
              _navigateToProfile(context);
            }),
            _buildMenuOption('Settings', Icons.settings_rounded, () {
              Navigator.pop(context);
              // Navigate to settings
            }),
            _buildMenuOption('Help', Icons.help_rounded, () {
              Navigator.pop(context);
              // Navigate to help
            }),
            _buildMenuOption(
              'Logout',
              Icons.logout_rounded,
              () => _handleLogout(context),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuOption(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white, size: 24),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }

  void _handleLogout(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.signOut();
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }
}
