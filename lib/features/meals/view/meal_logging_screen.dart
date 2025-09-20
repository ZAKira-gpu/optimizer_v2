import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/simple_meal_logging_provider.dart';
import '../models/food_models.dart';

/// Main meal logging screen with camera capture
class MealLoggingScreen extends StatefulWidget {
  const MealLoggingScreen({super.key});

  @override
  State<MealLoggingScreen> createState() => _MealLoggingScreenState();
}

class _MealLoggingScreenState extends State<MealLoggingScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Log Meal',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<SimpleMealLoggingProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Meal type selector
                _buildMealTypeSelector(provider),
                const SizedBox(height: 20),

                // Camera capture section
                _buildCameraSection(provider),
                const SizedBox(height: 20),

                // Manual search section
                _buildManualSearchSection(provider),
                const SizedBox(height: 20),

                // Current meal items
                if (provider.currentMealItems.isNotEmpty) ...[
                  _buildCurrentMealSection(provider),
                  const SizedBox(height: 20),
                ],

                // Save meal button
                if (provider.currentMealItems.isNotEmpty)
                  _buildSaveMealButton(provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMealTypeSelector(SimpleMealLoggingProvider provider) {
    final mealTypes = [
      {'value': 'breakfast', 'label': 'Breakfast', 'icon': Icons.wb_sunny},
      {'value': 'lunch', 'label': 'Lunch', 'icon': Icons.wb_sunny_outlined},
      {'value': 'dinner', 'label': 'Dinner', 'icon': Icons.nights_stay},
      {'value': 'snack', 'label': 'Snack', 'icon': Icons.local_cafe},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Meal Type',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: mealTypes.map((mealType) {
            final isSelected = provider.selectedMealType == mealType['value'];
            return Expanded(
              child: GestureDetector(
                onTap: () => provider.setMealType(mealType['value'] as String),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF2196F3)
                        : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF2196F3)
                          : Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        mealType['icon'] as IconData,
                        color: isSelected
                            ? Colors.white
                            : Colors.white.withOpacity(0.7),
                        size: 20,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mealType['label'] as String,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : Colors.white.withOpacity(0.7),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCameraSection(SimpleMealLoggingProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Capture Food',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),

        // Camera preview or captured image (disabled)
        _buildCameraPreview(),

        const SizedBox(height: 12),

        // Camera controls (disabled)
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: const Center(
            child: Column(
              children: [
                Icon(Icons.camera_alt_outlined, color: Colors.white, size: 48),
                SizedBox(height: 12),
                Text(
                  'Camera features are temporarily disabled',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'Use manual search below to log your meals',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCameraPreview() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt, color: Colors.white, size: 48),
            SizedBox(height: 8),
            Text(
              'Camera not available',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManualSearchSection(SimpleMealLoggingProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Or Search Manually',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          onSubmitted: (query) => provider.searchFoods(query),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search for food...',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
            prefixIcon: const Icon(Icons.search, color: Colors.white),
            suffixIcon: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: () {
                // Get current text and search
                final textField = context
                    .findAncestorStateOfType<State<TextField>>();
                if (textField != null) {
                  // This is a simplified approach - in a real app you'd use a TextEditingController
                }
              },
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentMealSection(SimpleMealLoggingProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Current Meal',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),

        // Meal items
        ...provider.currentMealItems.map(
          (item) => _buildMealItemCard(item, provider),
        ),

        const SizedBox(height: 12),

        // Total nutrition
        _buildTotalNutritionCard(provider),
      ],
    );
  }

  Widget _buildMealItemCard(MealItem item, SimpleMealLoggingProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.foodName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.actualNutrition.calories.toStringAsFixed(0)} cal • ${item.portionMultiplier.toStringAsFixed(1)}x serving',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => provider.removeFoodItem(item.id),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalNutritionCard(SimpleMealLoggingProvider provider) {
    final nutrition = provider.currentMealNutrition;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Nutrition',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNutritionItem(
                'Calories',
                '${nutrition.calories.toStringAsFixed(0)}',
                'cal',
              ),
              _buildNutritionItem(
                'Protein',
                '${nutrition.protein.toStringAsFixed(1)}',
                'g',
              ),
              _buildNutritionItem(
                'Carbs',
                '${nutrition.carbs.toStringAsFixed(1)}',
                'g',
              ),
              _buildNutritionItem(
                'Fat',
                '${nutrition.fat.toStringAsFixed(1)}',
                'g',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionItem(String label, String value, String unit) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          unit,
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildSaveMealButton(SimpleMealLoggingProvider provider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: provider.isLoading ? null : () => _saveMeal(provider),
        icon: provider.isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.save, color: Colors.white),
        label: Text(
          provider.isLoading ? 'Saving...' : 'Save Meal',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4CAF50),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Future<void> _saveMeal(SimpleMealLoggingProvider provider) async {
    // Get current user ID (you'll need to implement this)
    final userId = 'current_user_id'; // Replace with actual user ID

    final success = await provider.saveMeal(userId);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Meal saved successfully!'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error),
          backgroundColor: const Color(0xFFF44336),
        ),
      );
    }
  }
}
