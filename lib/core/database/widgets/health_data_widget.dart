import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/hive_database_provider.dart';
import '../../constants/app_dimensions.dart';

/// Example widget demonstrating Hive database usage
class HealthDataWidget extends StatefulWidget {
  final String userId;

  const HealthDataWidget({super.key, required this.userId});

  @override
  State<HealthDataWidget> createState() => _HealthDataWidgetState();
}

class _HealthDataWidgetState extends State<HealthDataWidget> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final provider = Provider.of<HiveDatabaseProvider>(context, listen: false);
    await provider.loadTodayData(widget.userId);
    await provider.loadWeeklyData(widget.userId);
    await provider.loadMonthlyData(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HiveDatabaseProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error: ${provider.error}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadData,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Today's Data
              _buildTodayDataCard(provider),
              const SizedBox(height: AppDimensions.spacing16),

              // Weekly Summary
              _buildWeeklySummaryCard(provider),
              const SizedBox(height: AppDimensions.spacing16),

              // Monthly Summary
              _buildMonthlySummaryCard(provider),
              const SizedBox(height: AppDimensions.spacing16),

              // Action Buttons
              _buildActionButtons(provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTodayDataCard(HiveDatabaseProvider provider) {
    final todayData = provider.todayData;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Today\'s Data',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppDimensions.spacing12),
            if (todayData != null) ...[
              _buildDataRow(
                'Sleep Hours',
                '${todayData.sleepHours.toStringAsFixed(1)}h',
              ),
              _buildDataRow('Steps', '${todayData.steps}'),
              _buildDataRow(
                'Calories In',
                '${todayData.caloriesIn.toStringAsFixed(0)}',
              ),
              _buildDataRow(
                'Calories Out',
                '${todayData.caloriesOut.toStringAsFixed(0)}',
              ),
              _buildDataRow('Tasks Done', '${todayData.tasksDone}'),
              _buildDataRow(
                'Goal Progress',
                '${(todayData.goalProgress * 100).toStringAsFixed(0)}%',
              ),
              _buildDataRow(
                'Efficiency Score',
                '${todayData.efficiencyScore.toStringAsFixed(1)}',
              ),
              _buildDataRow(
                'Health Score',
                '${todayData.healthScore.toStringAsFixed(1)}',
              ),
            ] else ...[
              const Text('No data available for today'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklySummaryCard(HiveDatabaseProvider provider) {
    final summary = provider.weeklySummary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weekly Summary',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppDimensions.spacing12),
            if (summary.isNotEmpty) ...[
              _buildDataRow(
                'Avg Sleep',
                '${summary['avgSleepHours']?.toStringAsFixed(1)}h',
              ),
              _buildDataRow('Total Steps', '${summary['totalSteps']}'),
              _buildDataRow(
                'Avg Calories In',
                '${summary['avgCaloriesIn']?.toStringAsFixed(0)}',
              ),
              _buildDataRow('Total Tasks', '${summary['totalTasksDone']}'),
              _buildDataRow(
                'Avg Efficiency',
                '${summary['avgEfficiencyScore']?.toStringAsFixed(1)}',
              ),
              _buildDataRow(
                'Avg Health',
                '${summary['avgHealthScore']?.toStringAsFixed(1)}',
              ),
              _buildDataRow('Days Tracked', '${summary['daysTracked']}'),
            ] else ...[
              const Text('No weekly data available'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlySummaryCard(HiveDatabaseProvider provider) {
    final summary = provider.monthlySummary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Monthly Summary',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppDimensions.spacing12),
            if (summary.isNotEmpty) ...[
              _buildDataRow(
                'Avg Sleep',
                '${summary['avgSleepHours']?.toStringAsFixed(1)}h',
              ),
              _buildDataRow('Total Steps', '${summary['totalSteps']}'),
              _buildDataRow(
                'Avg Calories In',
                '${summary['avgCaloriesIn']?.toStringAsFixed(0)}',
              ),
              _buildDataRow('Total Tasks', '${summary['totalTasksDone']}'),
              _buildDataRow(
                'Avg Efficiency',
                '${summary['avgEfficiencyScore']?.toStringAsFixed(1)}',
              ),
              _buildDataRow(
                'Avg Health',
                '${summary['avgHealthScore']?.toStringAsFixed(1)}',
              ),
              _buildDataRow('Days Tracked', '${summary['daysTracked']}'),
            ] else ...[
              const Text('No monthly data available'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(HiveDatabaseProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppDimensions.spacing12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () => _updateSteps(provider),
                  child: const Text('Update Steps'),
                ),
                ElevatedButton(
                  onPressed: () => _updateSleep(provider),
                  child: const Text('Update Sleep'),
                ),
                ElevatedButton(
                  onPressed: () => _updateTasks(provider),
                  child: const Text('Update Tasks'),
                ),
                ElevatedButton(
                  onPressed: () => _updateScores(provider),
                  child: const Text('Update Scores'),
                ),
                ElevatedButton(
                  onPressed: () => _loadData(),
                  child: const Text('Refresh Data'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateSteps(HiveDatabaseProvider provider) async {
    await provider.updateSteps(widget.userId, 8500);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Steps updated to 8500')));
  }

  Future<void> _updateSleep(HiveDatabaseProvider provider) async {
    await provider.updateSleepHours(widget.userId, 7.5);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Sleep hours updated to 7.5')));
  }

  Future<void> _updateTasks(HiveDatabaseProvider provider) async {
    await provider.updateTasksDone(widget.userId, 5);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Tasks done updated to 5')));
  }

  Future<void> _updateScores(HiveDatabaseProvider provider) async {
    await provider.updateMultipleFields(
      widget.userId,
      efficiencyScore: 85.0,
      healthScore: 78.0,
      goalProgress: 0.8,
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Scores updated')));
  }
}
