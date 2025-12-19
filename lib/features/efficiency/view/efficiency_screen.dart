import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/glassmorphism_container.dart';
import '../viewmodel/efficiency_provider.dart';
import '../models/efficiency_models.dart';

/// Efficiency screen for productivity tracking and focus tools
///
/// This screen displays user's daily focus overview, Pomodoro timer,
/// task management, and productivity insights with a clean, modern layout.
class EfficiencyScreen extends StatefulWidget {
  const EfficiencyScreen({super.key});

  @override
  State<EfficiencyScreen> createState() => _EfficiencyScreenState();
}

class _EfficiencyScreenState extends State<EfficiencyScreen> {
  DateTime _selectedDate = DateTime.now();
  int _selectedTabIndex = 0; // 0: Tasks, 1: Focus, 2: Routine

  @override
  void initState() {
    super.initState();
    // Initialize the provider when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EfficiencyProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LiquidGlassBackground(
        child: SafeArea(
          child: Consumer<EfficiencyProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.spacing24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with glassmorphism design
                    _buildGlassmorphismHeader(context),
                    const SizedBox(height: AppDimensions.spacing32),

                    // Main Content Container
                    GlassmorphismContainer(
                      borderRadius: 25.0,
                      blur: 15.0,
                      opacity: 0.15,
                      borderColor: Colors.white,
                      borderWidth: 1.5,
                      padding: const EdgeInsets.all(AppDimensions.spacing24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            'Productivity Hub',
                            style: Theme.of(context).textTheme.headlineLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.5,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppDimensions.spacing8),
                          Text(
                            'Track your focus and achieve your goals',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: Colors.white.withOpacity(0.8),
                                  fontWeight: FontWeight.w400,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppDimensions.spacing32),

                          // Tab Selection
                          _buildTabSelection(),
                          const SizedBox(height: AppDimensions.spacing24),

                          // Content based on selected tab
                          _buildContent(provider),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Build glassmorphism header
  Widget _buildGlassmorphismHeader(BuildContext context) {
    return GlassmorphismContainer(
      borderRadius: 20.0,
      blur: 10.0,
      opacity: 0.2,
      borderColor: Colors.white,
      borderWidth: 1.0,
      padding: const EdgeInsets.all(AppDimensions.spacing20),
      child: Row(
        children: [
          // Efficiency icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.trending_up_rounded,
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
                  'Efficiency',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Your productivity control center',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build tab selection with glassmorphism design
  Widget _buildTabSelection() {
    return GlassmorphismContainer(
      borderRadius: 15.0,
      blur: 8.0,
      opacity: 0.1,
      borderColor: Colors.white,
      borderWidth: 1.0,
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _buildTabButton('Tasks', 0, Icons.task_alt_rounded),
          _buildTabButton('Focus', 1, Icons.timer_rounded),
          _buildTabButton('Routine', 2, Icons.schedule_rounded),
        ],
      ),
    );
  }

  /// Build individual tab button
  Widget _buildTabButton(String title, int index, IconData icon) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.white.withOpacity(0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build content based on selected tab
  Widget _buildContent(EfficiencyProvider provider) {
    switch (_selectedTabIndex) {
      case 0: // Tasks
        return _buildTasksContent(provider);
      case 1: // Focus
        return _buildFocusContent(provider);
      case 2: // Routine
        return _buildRoutineContent(provider);
      default:
        return _buildTasksContent(provider);
    }
  }

  /// Build tasks content with glassmorphism design
  Widget _buildTasksContent(EfficiencyProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Add Task Button
        GlassmorphismButton(
          onPressed: () => _showAddTaskDialog(context),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                'Add New Task',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.spacing20),

        // Tasks List
        if (provider.tasks.isEmpty)
          _buildEmptyState(
            'No tasks yet',
            'Add your first task to get started!',
            Icons.task_alt_rounded,
          )
        else
          ...provider.tasks.map((task) => _buildTaskCard(task, provider)),
      ],
    );
  }

  /// Build focus content with glassmorphism design
  Widget _buildFocusContent(EfficiencyProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pomodoro Timer
        _buildPomodoroTimer(provider),
        const SizedBox(height: AppDimensions.spacing20),

        // Add Goal Button
        GlassmorphismButton(
          onPressed: () => _showAddGoalDialog(context, provider),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.flag_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                'Add New Goal',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.spacing20),

        // Goals List
        if (provider.goals.isEmpty)
          _buildEmptyState(
            'No goals yet',
            'Set your first goal to stay focused!',
            Icons.flag_rounded,
          )
        else
          ...provider.goals.map((goal) => _buildGoalCard(goal, provider)),
      ],
    );
  }

  /// Build routine content with glassmorphism design
  Widget _buildRoutineContent(EfficiencyProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Add Routine Button
        GlassmorphismButton(
          onPressed: () => _showAddRoutineDialog(context, provider),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.schedule_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                'Add New Routine',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.spacing20),

        // Routines List
        if (provider.routines.isEmpty)
          _buildEmptyState(
            'No routines yet',
            'Create your first routine to build habits!',
            Icons.schedule_rounded,
          )
        else
          ...provider.routines.map(
            (routine) => _buildRoutineCard(routine, provider),
          ),
      ],
    );
  }

  /// Build date selection bar
  Widget _buildDateSelectionBar() {
    final today = DateTime.now();
    final dates = List.generate(7, (index) {
      final date = today.subtract(Duration(days: 3 - index));
      return date;
    });

    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected = _isSameDay(date, _selectedDate);
          final isToday = _isSameDay(date, today);
          final dayName = _getDayName(date.weekday);
          final dayNumber = date.day;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = date;
              });
            },
            child: Container(
              width: 60,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.3)
                    : Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isToday && isSelected)
                    const Icon(
                      Icons.notifications_active,
                      color: Colors.white,
                      size: 12,
                    ),
                  const SizedBox(height: 2),
                  Text(
                    dayNumber.toString(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    dayName,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Build today's progress section with dual circles
  Widget _buildTodayProgress(EfficiencyProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Today progress',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),

          // Dual progress circles
          Row(
            children: [
              // Tasks Progress Circle
              Expanded(
                child: _buildProgressCircle(
                  progress: provider.taskCompletionProgress,
                  percentage: (provider.taskCompletionProgress * 100).round(),
                  color: const Color(0xFF4CAF50),
                  label: 'Tasks',
                ),
              ),
              const SizedBox(width: 20),

              // Focus Progress Circle
              Expanded(
                child: _buildProgressCircle(
                  progress: _getFocusProgress(provider),
                  percentage: (_getFocusProgress(provider) * 100).round(),
                  color: const Color(0xFF2196F3),
                  label: 'Focus',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(Colors.white.withOpacity(0.3), 'Unfilled'),
              const SizedBox(width: 16),
              _buildLegendItem(const Color(0xFF2196F3), 'Filled routine'),
              const SizedBox(width: 16),
              _buildLegendItem(const Color(0xFF4CAF50), 'Filled tasks'),
            ],
          ),
        ],
      ),
    );
  }

  /// Build individual progress circle
  Widget _buildProgressCircle({
    required double progress,
    required int percentage,
    required Color color,
    required String label,
  }) {
    return Column(
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background circle
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF5F5F5),
                ),
              ),
              // Progress circle
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 6,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              // Percentage text
              Text(
                '$percentage%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF666666),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Build legend item
  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white)),
      ],
    );
  }

  /// Build main action buttons
  Widget _buildMainActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.wb_sunny_rounded,
            label: 'Routine',
            isSelected: _selectedTabIndex == 0,
            onTap: () => setState(() => _selectedTabIndex = 0),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            icon: Icons.list_rounded,
            label: 'Tasks',
            isSelected: _selectedTabIndex == 1,
            onTap: () => setState(() => _selectedTabIndex = 1),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            icon: Icons.rocket_launch_rounded,
            label: 'Goals',
            isSelected: _selectedTabIndex == 2,
            onTap: () => setState(() => _selectedTabIndex = 2),
          ),
        ),
      ],
    );
  }

  /// Build individual action button
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withOpacity(0.3)
              : Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build tasks content (DUPLICATE - COMMENTED OUT)
  /*Widget _buildTasksContent(EfficiencyProvider provider) {
    return Container(
                  width: double.infinity,
      padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Today\'s Tasks',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),

          // Task list
          ...provider.topThreeTasks.map(
            (task) => _buildTaskItem(task, provider),
          ),

          // Add task button
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _showAddTaskDialog(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: Colors.white.withOpacity(0.15),
                  width: 1,
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Add New Task',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }*/

  /// Build routine content with habit management (DUPLICATE - COMMENTED OUT)
  /*Widget _buildRoutineContent(EfficiencyProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.wb_sunny_rounded,
                  color: Color(0xFF4CAF50),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Daily Routines',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _showAddRoutineDialog(context, provider),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Today's routines
          if (provider.todayRoutines.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                    Icons.wb_sunny_rounded,
                    size: 32,
                    color: Colors.white54,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'No routines for today',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Add a routine to get started!',
                    style: TextStyle(fontSize: 12, color: Colors.white54),
                  ),
                ],
              ),
            )
          else
            ...provider.todayRoutines.map(
              (routine) => _buildRoutineItem(routine, provider),
            ),
        ],
      ),
    );
  }*/

  /// Build goals content with goal tracking (DUPLICATE - COMMENTED OUT)
  /*Widget _buildGoalsContent(EfficiencyProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.rocket_launch_rounded,
                  color: Color(0xFF2196F3),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Goals & Targets',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _showAddGoalDialog(context, provider),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Active goals
          if (provider.activeGoals.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.rocket_launch_rounded,
                    size: 32,
                    color: Colors.white54,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'No active goals',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Set a goal to start tracking progress!',
                    style: TextStyle(fontSize: 12, color: Colors.white54),
                  ),
                ],
              ),
            )
          else
            ...provider.activeGoals.map(
              (goal) => _buildGoalItem(goal, provider),
            ),
        ],
      ),
    );
  }*/

  /// Build fixed focus section (always visible) (DUPLICATE - COMMENTED OUT)
  /*Widget _buildFixedFocusSection(EfficiencyProvider provider) {
    final pomodoro = provider.pomodoroService;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.timer_rounded,
                  color: Color(0xFF2196F3),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Focus Timer',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Focus timer section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Timer icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC107),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.timer_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),

                // Timer info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pomodoro.sessionTypeDisplayName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        pomodoro.formattedTime,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),

                // Timer controls
                Row(
                  children: [
                    if (pomodoro.isRunning) ...[
                      _buildTimerButton(
                        icon: Icons.pause_rounded,
                        color: const Color(0xFFFF9800),
                        onTap: () => pomodoro.pauseTimer(),
                      ),
                      const SizedBox(width: 8),
                      _buildTimerButton(
                        icon: Icons.stop_rounded,
                        color: const Color(0xFFF44336),
                        onTap: () => pomodoro.stopTimer(),
                      ),
                    ] else ...[
                      _buildTimerButton(
                        icon: Icons.play_arrow_rounded,
                        color: const Color(0xFF4CAF50),
                        onTap: () => pomodoro.startTimer(),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build timer control button
  Widget _buildTimerButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }*/

  /// Build individual task item
  Widget _buildTaskItem(Task task, EfficiencyProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
      ),
      child: Row(
        children: [
          // Checkbox
          GestureDetector(
            onTap: () => provider.completeTask(task.id),
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: task.status == TaskStatus.completed
                    ? const Color(0xFF4CAF50)
                    : Colors.transparent,
                border: Border.all(
                  color: task.status == TaskStatus.completed
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFCCCCCC),
                  width: 2,
                ),
              ),
              child: task.status == TaskStatus.completed
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 12,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),

          // Task details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    color: task.status == TaskStatus.completed
                        ? Colors.white.withOpacity(0.6)
                        : Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    decoration: task.status == TaskStatus.completed
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                if (task.description != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    task.description!,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Priority indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: provider.getPriorityColor(task.priority).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              provider.getPriorityDisplayName(task.priority),
              style: TextStyle(
                color: provider.getPriorityColor(task.priority),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Show add task dialog
  void _showAddTaskDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final categoryController = TextEditingController();
    TaskPriority selectedPriority = TaskPriority.medium;
    int estimatedMinutes = 30;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.85,
            constraints: const BoxConstraints(maxWidth: 400, maxHeight: 700),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9800).withOpacity(0.2),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF9800).withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.task_alt_rounded,
                          color: Color(0xFFFF9800),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Add New Task',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Create a task to complete',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title Field
                        _buildEnhancedTextField(
                          controller: titleController,
                          label: 'Task Title',
                          hint: 'e.g., Review project proposal',
                          icon: Icons.edit_rounded,
                          isRequired: true,
                        ),
                        const SizedBox(height: 20),

                        // Description Field
                        _buildEnhancedTextField(
                          controller: descriptionController,
                          label: 'Description (Optional)',
                          hint: 'Add details about the task...',
                          icon: Icons.description_rounded,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 20),

                        // Priority Selection
                        _buildPrioritySelector(
                          selectedPriority,
                          context.read<EfficiencyProvider>(),
                          (priority) {
                            setState(() {
                              selectedPriority = priority;
                            });
                          },
                        ),
                        const SizedBox(height: 20),

                        // Category and Duration
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: _buildEnhancedTextField(
                                controller: categoryController,
                                label: 'Category',
                                hint: 'Work',
                                icon: Icons.category_rounded,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 1,
                              child: _buildDurationSelector(estimatedMinutes, (
                                minutes,
                              ) {
                                setState(() {
                                  estimatedMinutes = minutes;
                                });
                              }),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Actions
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildSecondaryButton(
                          'Cancel',
                          () => Navigator.of(context).pop(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildPrimaryButton(
                          'Create Task',
                          const Color(0xFFFF9800),
                          () {
                            if (titleController.text.isNotEmpty) {
                              context.read<EfficiencyProvider>().addTask(
                                title: titleController.text,
                                description: descriptionController.text.isEmpty
                                    ? null
                                    : descriptionController.text,
                                priority: selectedPriority,
                                estimatedMinutes: estimatedMinutes,
                                category: categoryController.text.isEmpty
                                    ? null
                                    : categoryController.text,
                              );
                              Navigator.of(context).pop();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Helper methods
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  double _getFocusProgress(EfficiencyProvider provider) {
    // Calculate focus progress based on completed pomodoros
    // Assuming 8 pomodoros per day is 100%
    return (provider.pomodoroService.completedPomodoros / 8.0).clamp(0.0, 1.0);
  }

  /// Build routine item
  Widget _buildRoutineItem(Routine routine, EfficiencyProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
      ),
      child: Row(
        children: [
          // Routine icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              _getIconData(routine.iconName),
              color: const Color(0xFF4CAF50),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Routine details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  routine.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (routine.description != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    routine.description!,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  'Days: ${routine.daysOfWeek.join(', ')}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          // Toggle switch
          Switch(
            value: routine.isActive,
            onChanged: (value) => provider.toggleRoutineStatus(routine.id),
            activeColor: const Color(0xFF4CAF50),
            inactiveThumbColor: Colors.white.withOpacity(0.3),
            inactiveTrackColor: Colors.white.withOpacity(0.1),
          ),
        ],
      ),
    );
  }

  /// Build goal item
  Widget _buildGoalItem(Goal goal, EfficiencyProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Goal icon
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  _getGoalIcon(goal.type),
                  color: const Color(0xFF2196F3),
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),

              // Goal details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (goal.description != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        goal.description!,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Progress percentage
              Text(
                '${(goal.progressPercentage * 100).round()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress bar
          LinearProgressIndicator(
            value: goal.progressPercentage,
            backgroundColor: Colors.white.withOpacity(0.1),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
            minHeight: 4,
          ),
          const SizedBox(height: 8),

          // Progress text
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${goal.currentValue} / ${goal.targetValue} ${goal.unit}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 11,
                ),
              ),
              Text(
                'Due: ${_formatDate(goal.targetDate)}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Show add routine dialog
  void _showAddRoutineDialog(
    BuildContext context,
    EfficiencyProvider provider,
  ) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedIcon = 'wb_sunny_rounded';
    List<String> selectedDays = [];
    TimeOfDay? reminderTime;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.85,
            constraints: const BoxConstraints(maxWidth: 400, maxHeight: 700),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.2),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.wb_sunny_rounded,
                          color: Color(0xFF4CAF50),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Add New Routine',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Create a daily habit to track',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title Field
                        _buildEnhancedTextField(
                          controller: titleController,
                          label: 'Routine Title',
                          hint: 'e.g., Morning Exercise',
                          icon: Icons.edit_rounded,
                          isRequired: true,
                        ),
                        const SizedBox(height: 20),

                        // Description Field
                        _buildEnhancedTextField(
                          controller: descriptionController,
                          label: 'Description (Optional)',
                          hint: 'Add details about your routine...',
                          icon: Icons.description_rounded,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 20),

                        // Icon Selection
                        _buildIconSelector(selectedIcon, (icon) {
                          setState(() {
                            selectedIcon = icon;
                          });
                        }),
                        const SizedBox(height: 20),

                        // Time Selection
                        _buildTimeSelector(reminderTime, (time) {
                          setState(() {
                            reminderTime = time;
                          });
                        }),
                        const SizedBox(height: 20),

                        // Days Selection
                        _buildDaysSelector(selectedDays, (days) {
                          setState(() {
                            selectedDays = days;
                          });
                        }),
                      ],
                    ),
                  ),
                ),

                // Actions
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildSecondaryButton(
                          'Cancel',
                          () => Navigator.of(context).pop(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildPrimaryButton(
                          'Create Routine',
                          const Color(0xFF4CAF50),
                          () {
                            if (titleController.text.isNotEmpty &&
                                selectedDays.isNotEmpty) {
                              provider.addRoutine(
                                title: titleController.text,
                                description: descriptionController.text.isEmpty
                                    ? null
                                    : descriptionController.text,
                                iconName: selectedIcon,
                                daysOfWeek: selectedDays,
                                reminderTime: reminderTime,
                              );
                              Navigator.of(context).pop();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Show add goal dialog
  void _showAddGoalDialog(BuildContext context, EfficiencyProvider provider) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final targetValueController = TextEditingController(text: '1');
    final unitController = TextEditingController(text: 'tasks');
    GoalType selectedType = GoalType.task;
    DateTime selectedDate = DateTime.now().add(const Duration(days: 30));

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.85,
            constraints: const BoxConstraints(maxWidth: 400, maxHeight: 700),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2196F3).withOpacity(0.2),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2196F3).withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.rocket_launch_rounded,
                          color: Color(0xFF2196F3),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Add New Goal',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Set a target to achieve',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title Field
                        _buildEnhancedTextField(
                          controller: titleController,
                          label: 'Goal Title',
                          hint: 'e.g., Complete 10 Tasks',
                          icon: Icons.flag_rounded,
                          isRequired: true,
                        ),
                        const SizedBox(height: 20),

                        // Description Field
                        _buildEnhancedTextField(
                          controller: descriptionController,
                          label: 'Description (Optional)',
                          hint: 'Add details about your goal...',
                          icon: Icons.description_rounded,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 20),

                        // Goal Type Selection
                        _buildGoalTypeSelector(selectedType, provider, (type) {
                          setState(() {
                            selectedType = type;
                          });
                        }),
                        const SizedBox(height: 20),

                        // Target and Unit
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: _buildEnhancedTextField(
                                controller: targetValueController,
                                label: 'Target',
                                hint: '10',
                                icon: Icons.numbers_rounded,
                                keyboardType: TextInputType.number,
                                isRequired: true,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 3,
                              child: _buildEnhancedTextField(
                                controller: unitController,
                                label: 'Unit',
                                hint: 'tasks',
                                icon: Icons.straighten_rounded,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Due Date
                        _buildDateSelector(selectedDate, (date) {
                          setState(() {
                            selectedDate = date;
                          });
                        }),
                      ],
                    ),
                  ),
                ),

                // Actions
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildSecondaryButton(
                          'Cancel',
                          () => Navigator.of(context).pop(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildPrimaryButton(
                          'Create Goal',
                          const Color(0xFF2196F3),
                          () {
                            if (titleController.text.isNotEmpty &&
                                targetValueController.text.isNotEmpty) {
                              provider.addGoal(
                                title: titleController.text,
                                description: descriptionController.text.isEmpty
                                    ? null
                                    : descriptionController.text,
                                type: selectedType,
                                targetDate: selectedDate,
                                targetValue:
                                    int.tryParse(targetValueController.text) ??
                                    1,
                                unit: unitController.text,
                              );
                              Navigator.of(context).pop();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Get icon data from string
  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'wb_sunny_rounded':
        return Icons.wb_sunny_rounded;
      case 'fitness_center_rounded':
        return Icons.fitness_center_rounded;
      case 'book_rounded':
        return Icons.book_rounded;
      case 'work_rounded':
        return Icons.work_rounded;
      case 'home_rounded':
        return Icons.home_rounded;
      case 'restaurant_rounded':
        return Icons.restaurant_rounded;
      case 'bedtime_rounded':
        return Icons.bedtime_rounded;
      default:
        return Icons.wb_sunny_rounded;
    }
  }

  /// Get goal icon based on type
  IconData _getGoalIcon(GoalType type) {
    switch (type) {
      case GoalType.task:
        return Icons.task_alt_rounded;
      case GoalType.pomodoro:
        return Icons.timer_rounded;
      case GoalType.routine:
        return Icons.wb_sunny_rounded;
      case GoalType.custom:
        return Icons.flag_rounded;
    }
  }

  /// Format date for display
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Build enhanced text field
  Widget _buildEnhancedTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isRequired = false,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white.withOpacity(0.7), size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              const Text(
                '*',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.black54,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  /// Build icon selector
  Widget _buildIconSelector(String selectedIcon, Function(String) onChanged) {
    final icons = [
      'wb_sunny_rounded',
      'fitness_center_rounded',
      'book_rounded',
      'work_rounded',
      'home_rounded',
      'restaurant_rounded',
      'bedtime_rounded',
      'self_improvement_rounded',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.palette_rounded,
              color: Colors.white.withOpacity(0.7),
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              'Icon',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: icons.map((iconName) {
            final isSelected = selectedIcon == iconName;
            return GestureDetector(
              onTap: () => onChanged(iconName),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF4CAF50).withOpacity(0.3)
                      : Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF4CAF50)
                        : Colors.white.withOpacity(0.15),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Icon(
                  _getIconData(iconName),
                  color: isSelected
                      ? const Color(0xFF4CAF50)
                      : Colors.white.withOpacity(0.7),
                  size: 20,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Build days selector
  Widget _buildDaysSelector(
    List<String> selectedDays,
    Function(List<String>) onChanged,
  ) {
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              color: Colors.white.withOpacity(0.7),
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              'Days of Week',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              '*',
              style: TextStyle(
                color: Colors.red,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: days.map((day) {
            final isSelected = selectedDays.contains(day.toLowerCase());
            return GestureDetector(
              onTap: () {
                final newDays = List<String>.from(selectedDays);
                if (isSelected) {
                  newDays.remove(day.toLowerCase());
                } else {
                  newDays.add(day.toLowerCase());
                }
                onChanged(newDays);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF4CAF50).withOpacity(0.3)
                      : Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF4CAF50)
                        : Colors.white.withOpacity(0.15),
                    width: 1,
                  ),
                ),
                child: Text(
                  day,
                  style: TextStyle(
                    color: isSelected
                        ? const Color(0xFF4CAF50)
                        : Colors.white.withOpacity(0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Build time selector
  Widget _buildTimeSelector(
    TimeOfDay? selectedTime,
    Function(TimeOfDay?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.access_time_rounded,
              color: Colors.white.withOpacity(0.7),
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              'Reminder Time (Optional)',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () async {
            final TimeOfDay? picked = await showTimePicker(
              context: context,
              initialTime: selectedTime ?? const TimeOfDay(hour: 9, minute: 0),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: Color(0xFF4CAF50),
                      onPrimary: Colors.white,
                      surface: Colors.white,
                      onSurface: Colors.black,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              onChanged(picked);
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  color: selectedTime != null
                      ? const Color(0xFF4CAF50)
                      : Colors.white.withOpacity(0.7),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  selectedTime != null
                      ? '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}'
                      : 'Select time',
                  style: TextStyle(
                    color: selectedTime != null
                        ? const Color(0xFF4CAF50)
                        : Colors.white.withOpacity(0.7),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                if (selectedTime != null)
                  GestureDetector(
                    onTap: () => onChanged(null),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.red,
                        size: 16,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build priority selector
  Widget _buildPrioritySelector(
    TaskPriority selectedPriority,
    EfficiencyProvider provider,
    Function(TaskPriority) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.flag_rounded,
              color: Colors.white.withOpacity(0.7),
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              'Priority',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: TaskPriority.values.map((priority) {
            final isSelected = selectedPriority == priority;
            return GestureDetector(
              onTap: () => onChanged(priority),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? provider.getPriorityColor(priority).withOpacity(0.3)
                      : Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? provider.getPriorityColor(priority)
                        : Colors.white.withOpacity(0.15),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.flag_rounded,
                      color: isSelected
                          ? provider.getPriorityColor(priority)
                          : Colors.white.withOpacity(0.7),
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      provider.getPriorityDisplayName(priority),
                      style: TextStyle(
                        color: isSelected
                            ? provider.getPriorityColor(priority)
                            : Colors.white.withOpacity(0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Build goal type selector
  Widget _buildGoalTypeSelector(
    GoalType selectedType,
    EfficiencyProvider provider,
    Function(GoalType) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.category_rounded,
              color: Colors.white.withOpacity(0.7),
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              'Goal Type',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: GoalType.values.map((type) {
            final isSelected = selectedType == type;
            return GestureDetector(
              onTap: () => onChanged(type),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF2196F3).withOpacity(0.3)
                      : Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF2196F3)
                        : Colors.white.withOpacity(0.15),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getGoalIcon(type),
                      color: isSelected
                          ? const Color(0xFF2196F3)
                          : Colors.white.withOpacity(0.7),
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      provider.getGoalTypeDisplayName(type),
                      style: TextStyle(
                        color: isSelected
                            ? const Color(0xFF2196F3)
                            : Colors.white.withOpacity(0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Build duration selector
  Widget _buildDurationSelector(int selectedMinutes, Function(int) onChanged) {
    final durations = [15, 30, 45, 60, 90, 120];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.timer_rounded,
              color: Colors.white.withOpacity(0.7),
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              'Duration',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
          ),
          child: DropdownButton<int>(
            value: selectedMinutes,
            dropdownColor: const Color(0xFF2E2E2E),
            style: const TextStyle(color: Colors.white, fontSize: 14),
            underline: const SizedBox(),
            isExpanded: true,
            items: durations.map((minutes) {
              return DropdownMenuItem(
                value: minutes,
                child: Text('${minutes}m'),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                onChanged(value);
              }
            },
          ),
        ),
      ],
    );
  }

  /// Build date selector
  Widget _buildDateSelector(
    DateTime selectedDate,
    Function(DateTime) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              color: Colors.white.withOpacity(0.7),
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              'Due Date',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.dark(
                      primary: Color(0xFF2196F3),
                      onPrimary: Colors.white,
                      surface: Color(0xFF2E2E2E),
                      onSurface: Colors.white,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (date != null) {
              onChanged(date);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  color: Colors.white.withOpacity(0.7),
                  size: 16,
                ),
                const SizedBox(width: 12),
                Text(
                  _formatDate(selectedDate),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_drop_down_rounded,
                  color: Colors.white.withOpacity(0.7),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build primary button
  Widget _buildPrimaryButton(String text, Color color, VoidCallback onPressed) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build secondary button
  Widget _buildSecondaryButton(String text, VoidCallback onPressed) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build empty state widget
  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return GlassmorphismContainer(
      borderRadius: 20.0,
      blur: 10.0,
      opacity: 0.1,
      borderColor: Colors.white,
      borderWidth: 1.0,
      padding: const EdgeInsets.all(AppDimensions.spacing32),
      child: Column(
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.6), size: 48),
          const SizedBox(height: AppDimensions.spacing16),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.spacing8),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build task card
  Widget _buildTaskCard(Task task, EfficiencyProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacing12),
      child: GlassmorphismContainer(
        borderRadius: 15.0,
        blur: 8.0,
        opacity: 0.1,
        borderColor: Colors.white,
        borderWidth: 1.0,
        padding: const EdgeInsets.all(AppDimensions.spacing16),
        child: Row(
          children: [
            // Checkbox
            GestureDetector(
              onTap: () => provider.completeTask(task.id),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: task.status == TaskStatus.completed
                      ? const Color(0xFF2196F3)
                      : Colors.transparent,
                  border: Border.all(
                    color: task.status == TaskStatus.completed
                        ? const Color(0xFF2196F3)
                        : Colors.white.withOpacity(0.5),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: task.status == TaskStatus.completed
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : null,
              ),
            ),
            const SizedBox(width: AppDimensions.spacing12),

            // Task content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      decoration: task.status == TaskStatus.completed
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  if (task.description?.isNotEmpty == true) ...[
                    const SizedBox(height: 4),
                    Text(
                      task.description!,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        _getPriorityIcon(task.priority),
                        color: _getPriorityColor(task.priority),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        provider.getPriorityDisplayName(task.priority),
                        style: TextStyle(
                          color: _getPriorityColor(task.priority),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Delete button
            GestureDetector(
              onTap: () => provider.deleteTask(task.id),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.delete_rounded,
                  color: Colors.red,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build goal card
  Widget _buildGoalCard(Goal goal, EfficiencyProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacing12),
      child: GlassmorphismContainer(
        borderRadius: 15.0,
        blur: 8.0,
        opacity: 0.1,
        borderColor: Colors.white,
        borderWidth: 1.0,
        padding: const EdgeInsets.all(AppDimensions.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getGoalIcon(goal.type),
                  color: const Color(0xFF2196F3),
                  size: 20,
                ),
                const SizedBox(width: AppDimensions.spacing8),
                Expanded(
                  child: Text(
                    goal.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => provider.deleteGoal(goal.id),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.delete_rounded,
                      color: Colors.red,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
            if (goal.description?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Text(
                goal.description!,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getGoalStatusColor(goal.status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    provider.getGoalStatusDisplayName(goal.status),
                    style: TextStyle(
                      color: _getGoalStatusColor(goal.status),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'Target: ${goal.targetValue}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build routine card
  Widget _buildRoutineCard(Routine routine, EfficiencyProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacing12),
      child: GlassmorphismContainer(
        borderRadius: 15.0,
        blur: 8.0,
        opacity: 0.1,
        borderColor: Colors.white,
        borderWidth: 1.0,
        padding: const EdgeInsets.all(AppDimensions.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getRoutineIcon(routine.iconName),
                  color: const Color(0xFF2196F3),
                  size: 20,
                ),
                const SizedBox(width: AppDimensions.spacing8),
                Expanded(
                  child: Text(
                    routine.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => provider.deleteRoutine(routine.id),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.delete_rounded,
                      color: Colors.red,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
            if (routine.description?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Text(
                routine.description!,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  color: Colors.white.withOpacity(0.7),
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  routine.reminderTime != null
                      ? '${routine.reminderTime!.hour.toString().padLeft(2, '0')}:${routine.reminderTime!.minute.toString().padLeft(2, '0')}'
                      : 'No time set',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.calendar_today_rounded,
                  color: Colors.white.withOpacity(0.7),
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  routine.daysOfWeek.join(', '),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build Pomodoro timer
  Widget _buildPomodoroTimer(EfficiencyProvider provider) {
    return GlassmorphismContainer(
      borderRadius: 20.0,
      blur: 10.0,
      opacity: 0.15,
      borderColor: Colors.white,
      borderWidth: 1.5,
      padding: const EdgeInsets.all(AppDimensions.spacing24),
      child: Column(
        children: [
          Text(
            'Focus Timer',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppDimensions.spacing16),
          Text(
            provider.pomodoroService.formattedTime,
            style: TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.w300,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: AppDimensions.spacing16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GlassmorphismButton(
                onPressed: provider.pomodoroService.isRunning
                    ? provider.pomodoroService.pauseTimer
                    : provider.pomodoroService.startTimer,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 20,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      provider.pomodoroService.isRunning
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      provider.pomodoroService.isRunning ? 'Pause' : 'Start',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              GlassmorphismButton(
                onPressed: provider.pomodoroService.stopTimer,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 20,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.stop_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Stop',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Helper methods for icons and colors
  IconData _getPriorityIcon(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Icons.keyboard_arrow_down_rounded;
      case TaskPriority.medium:
        return Icons.remove_rounded;
      case TaskPriority.high:
        return Icons.keyboard_arrow_up_rounded;
      case TaskPriority.urgent:
        return Icons.priority_high_rounded;
    }
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.urgent:
        return Colors.purple;
    }
  }

  Color _getGoalStatusColor(GoalStatus status) {
    switch (status) {
      case GoalStatus.active:
        return Colors.green;
      case GoalStatus.completed:
        return Colors.blue;
      case GoalStatus.paused:
        return Colors.orange;
      case GoalStatus.cancelled:
        return Colors.red;
    }
  }

  IconData _getRoutineIcon(String iconName) {
    switch (iconName) {
      case 'wb_sunny_rounded':
        return Icons.wb_sunny_rounded;
      case 'fitness_center_rounded':
        return Icons.fitness_center_rounded;
      case 'book_rounded':
        return Icons.book_rounded;
      case 'work_rounded':
        return Icons.work_rounded;
      case 'home_rounded':
        return Icons.home_rounded;
      case 'restaurant_rounded':
        return Icons.restaurant_rounded;
      case 'bedtime_rounded':
        return Icons.bedtime_rounded;
      case 'self_improvement_rounded':
        return Icons.self_improvement_rounded;
      // Legacy support for old icon names
      case 'morning':
        return Icons.wb_sunny_rounded;
      case 'exercise':
        return Icons.fitness_center_rounded;
      case 'work':
        return Icons.work_rounded;
      case 'study':
        return Icons.school_rounded;
      case 'sleep':
        return Icons.bedtime_rounded;
      default:
        return Icons.wb_sunny_rounded;
    }
  }
}
