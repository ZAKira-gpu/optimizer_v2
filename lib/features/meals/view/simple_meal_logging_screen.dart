import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../viewmodel/simple_meal_logging_provider.dart';
import '../models/food_models.dart';
import 'meal_history_screen.dart';

/// Simplified meal logging screen for testing without camera
class SimpleMealLoggingScreen extends StatefulWidget {
  const SimpleMealLoggingScreen({super.key});

  @override
  State<SimpleMealLoggingScreen> createState() =>
      _SimpleMealLoggingScreenState();
}

class _SimpleMealLoggingScreenState extends State<SimpleMealLoggingScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadNutritionGoals();
    _searchController.addListener(() {
      setState(() {
        // This will trigger a rebuild when the search text changes
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
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

  void _focusSearchField() {
    _searchFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D2D2D),
        elevation: 0,
        title: const Text(
          'Log Meal',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MealHistoryScreen(),
                ),
              );
            },
            icon: const Icon(Icons.history, color: Colors.white),
          ),
        ],
      ),
      body: Consumer<SimpleMealLoggingProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Meal Type Selector
                _buildSimpleMealTypeSelector(provider),
                const SizedBox(height: 24),

                // Food Search Section
                _buildSimpleFoodSearch(provider),
                const SizedBox(height: 16),

                // Search Results
                if (provider.recognitionResult?.suggestions.isNotEmpty == true)
                  _buildSimpleSearchResults(provider),

                // Current Meal
                if (provider.currentMealItems.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildSimpleCurrentMeal(provider),
                ],

                // Save Button
                if (provider.currentMealItems.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildSimpleSaveButton(provider),
                ],

                // Progress Section
                const SizedBox(height: 24),
                _buildSimpleProgress(provider),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Simple Meal Type Selector
  Widget _buildSimpleMealTypeSelector(SimpleMealLoggingProvider provider) {
    final mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];
    final icons = [
      Icons.wb_sunny_rounded,
      Icons.wb_sunny_outlined,
      Icons.nights_stay_rounded,
      Icons.local_cafe_rounded,
    ];
    final colors = [
      const Color(0xFFFFB74D),
      const Color(0xFF4CAF50),
      const Color(0xFF2196F3),
      const Color(0xFF9C27B0),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Meal Type',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            for (int i = 0; i < mealTypes.length; i++)
              Expanded(
                child: _buildMealTypeCard(
                  mealTypes[i],
                  icons[i],
                  colors[i],
                  provider.selectedMealType == mealTypes[i].toLowerCase(),
                  () => provider.setMealType(mealTypes[i].toLowerCase()),
                ),
              ),
          ],
        ),
      ],
    );
  }

  /// Meal Type Card
  Widget _buildMealTypeCard(
    String type,
    IconData icon,
    Color color,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.2)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.white.withOpacity(0.6),
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              type,
              style: TextStyle(
                color: isSelected ? color : Colors.white.withOpacity(0.8),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Simple Food Search
  Widget _buildSimpleFoodSearch(SimpleMealLoggingProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.search_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Add Food',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Camera and Search Buttons
        Row(
          children: [
            Expanded(child: _buildCameraButton()),
            const SizedBox(width: 12),
            Expanded(child: _buildSearchButton()),
          ],
        ),
        const SizedBox(height: 16),

        // Search Field
        TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            hintText: 'Search for food...',
            hintStyle: TextStyle(color: Colors.grey.withOpacity(0.7)),
            prefixIcon: Icon(Icons.search, color: Colors.grey.withOpacity(0.7)),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: Colors.grey.withOpacity(0.7),
                    ),
                    onPressed: () {
                      _searchController.clear();
                      provider.reset();
                    },
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          onChanged: (value) {
            if (value.isNotEmpty) {
              provider.searchFoods(value);
            } else {
              provider.reset();
            }
          },
        ),
      ],
    );
  }

  /// Camera Button
  Widget _buildCameraButton() {
    return GestureDetector(
      onTap: _showCameraOptions,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2196F3).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Camera',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Search Button
  Widget _buildSearchButton() {
    return GestureDetector(
      onTap: _focusSearchField,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4CAF50).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Search',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show Camera Options
  void _showCameraOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2D2D2D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCameraOption(
              Icons.camera_alt_rounded,
              'Take Photo',
              'Capture a new photo',
              const Color(0xFF2196F3),
              () {
                Navigator.pop(context);
                // TODO: Implement camera functionality
              },
            ),
            const SizedBox(height: 12),
            _buildCameraOption(
              Icons.photo_library_rounded,
              'Gallery',
              'Choose from gallery',
              const Color(0xFF4CAF50),
              () {
                Navigator.pop(context);
                // TODO: Implement gallery functionality
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Camera Option
  Widget _buildCameraOption(
    IconData icon,
    String title,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Simple Search Results
  Widget _buildSimpleSearchResults(SimpleMealLoggingProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Search Results',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...provider.recognitionResult!.suggestions.map(
          (suggestion) => _buildSimpleFoodCard(suggestion, provider),
        ),
      ],
    );
  }

  /// Simple Food Card
  Widget _buildSimpleFoodCard(
    FoodSuggestion suggestion,
    SimpleMealLoggingProvider provider,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Food Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.restaurant_rounded,
              color: Color(0xFF4CAF50),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Food Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  suggestion.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(suggestion.confidence * 500).toInt()} cal per serving',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Confidence Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getConfidenceColor(
                suggestion.confidence,
              ).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getConfidenceColor(
                  suggestion.confidence,
                ).withOpacity(0.3),
              ),
            ),
            child: Text(
              '${(suggestion.confidence * 100).toInt()}%',
              style: TextStyle(
                color: _getConfidenceColor(suggestion.confidence),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Add Button
          GestureDetector(
            onTap: () => _addFoodWithAnimation(suggestion, provider),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4CAF50).withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Get Confidence Color
  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return const Color(0xFF4CAF50);
    if (confidence >= 0.6) return const Color(0xFFFF9800);
    return const Color(0xFFF44336);
  }

  /// Add Food with Animation
  void _addFoodWithAnimation(
    FoodSuggestion suggestion,
    SimpleMealLoggingProvider provider,
  ) {
    provider.addFoodItem(suggestion, 1.0);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${suggestion.name} to meal'),
        backgroundColor: const Color(0xFF4CAF50),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  /// Simple Current Meal
  Widget _buildSimpleCurrentMeal(SimpleMealLoggingProvider provider) {
    final currentMealNutrition = provider.currentMealNutrition;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.restaurant_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Current Meal',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Meal Items
        ...provider.currentMealItems.map(
          (item) => _buildSimpleMealItem(item, provider),
        ),

        const SizedBox(height: 16),

        // Current Meal Nutrition Summary
        if (provider.currentMealItems.isNotEmpty)
          _buildCurrentMealNutrition(currentMealNutrition),
      ],
    );
  }

  /// Current Meal Nutrition Summary
  Widget _buildCurrentMealNutrition(NutritionInfo currentMealNutrition) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.analytics_rounded,
                  color: Color(0xFF4CAF50),
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Meal Nutrition',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Calories - Full Width
          _buildExpandedCaloriesRow(
            'Calories',
            '${currentMealNutrition.calories.toStringAsFixed(0)}',
            'cal',
            const Color(0xFFFF6B6B),
          ),
          const SizedBox(height: 12),

          // Enhanced Macros Row
          Row(
            children: [
              Expanded(
                child: _buildEnhancedMacroCard(
                  'Protein',
                  '${currentMealNutrition.protein.toStringAsFixed(1)}',
                  'g',
                  const Color(0xFF4ECDC4),
                  Icons.fitness_center_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildEnhancedMacroCard(
                  'Carbs',
                  '${currentMealNutrition.carbs.toStringAsFixed(1)}',
                  'g',
                  const Color(0xFF45B7D1),
                  Icons.grain_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildEnhancedMacroCard(
                  'Fat',
                  '${currentMealNutrition.fat.toStringAsFixed(1)}',
                  'g',
                  const Color(0xFF96CEB4),
                  Icons.opacity_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Nutrition Row Widget
  Widget _buildNutritionRow(
    String label,
    String value,
    String unit,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$label ($unit)',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Expanded Calories Row Widget
  Widget _buildExpandedCaloriesRow(
    String label,
    String value,
    String unit,
    Color color,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Label and Unit
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                unit,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          // Value
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Enhanced Macro Card Widget
  Widget _buildEnhancedMacroCard(
    String label,
    String value,
    String unit,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.15), color.withOpacity(0.08)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 8),

          // Value
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),

          // Label and Unit
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            unit,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Simple Meal Item
  Widget _buildSimpleMealItem(
    MealItem item,
    SimpleMealLoggingProvider provider,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
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
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.portionMultiplier.toStringAsFixed(1)}x serving',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => provider.removeFoodItem(item.id),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.delete_rounded,
                color: Colors.red,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Simple Save Button
  Widget _buildSimpleSaveButton(SimpleMealLoggingProvider provider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            final success = await provider.saveMeal(user.uid);
            if (success) {
              // Refresh today's nutrition data
              await provider.loadTodayNutrition(user.uid);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Meal saved successfully!'),
                  backgroundColor: Color(0xFF4CAF50),
                  duration: Duration(seconds: 2),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to save meal: ${provider.error}'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please log in to save meals'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4CAF50),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Save Meal',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// Simple Progress
  Widget _buildSimpleProgress(SimpleMealLoggingProvider provider) {
    final todayNutrition = provider.todayNutrition;
    final goals = provider.dailyGoals;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Today\'s Progress',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        // Calories
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Calories',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  Text(
                    '${(todayNutrition?.totalNutrition.calories ?? 0).toStringAsFixed(0)} / ${goals.calories.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value:
                    (todayNutrition?.totalNutrition.calories ?? 0) /
                    goals.calories,
                backgroundColor: Colors.white.withOpacity(0.1),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFFFF6B6B),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Macros
        Row(
          children: [
            Expanded(
              child: _buildMacroProgress(
                'Protein',
                (todayNutrition?.totalNutrition.protein ?? 0),
                goals.protein,
                const Color(0xFF4ECDC4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMacroProgress(
                'Carbs',
                (todayNutrition?.totalNutrition.carbs ?? 0),
                goals.carbs,
                const Color(0xFF45B7D1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMacroProgress(
                'Fat',
                (todayNutrition?.totalNutrition.fat ?? 0),
                goals.fat,
                const Color(0xFF96CEB4),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Macro Progress
  Widget _buildMacroProgress(
    String label,
    double current,
    double goal,
    Color color,
  ) {
    final progress = goal > 0 ? (current / goal).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${current.toStringAsFixed(1)}g',
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }
}
