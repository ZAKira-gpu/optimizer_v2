import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/meal_logging_provider.dart';
import '../models/food_models.dart';
import '../services/vision_service.dart';

/// Screen for selecting food from recognition results
class FoodSelectionScreen extends StatefulWidget {
  final FoodRecognitionResult recognitionResult;

  const FoodSelectionScreen({super.key, required this.recognitionResult});

  @override
  State<FoodSelectionScreen> createState() => _FoodSelectionScreenState();
}

class _FoodSelectionScreenState extends State<FoodSelectionScreen> {
  double _portionMultiplier = 1.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Select Food',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recognition type indicator
            _buildRecognitionTypeIndicator(),
            const SizedBox(height: 20),

            // Food suggestions
            _buildFoodSuggestions(),
            const SizedBox(height: 20),

            // Portion size selector
            _buildPortionSizeSelector(),
            const SizedBox(height: 20),

            // Add to meal button
            _buildAddToMealButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecognitionTypeIndicator() {
    String typeText;
    IconData typeIcon;
    Color typeColor;

    switch (widget.recognitionResult.type) {
      case FoodRecognitionType.barcode:
        typeText = 'Barcode Scanned';
        typeIcon = Icons.qr_code_scanner;
        typeColor = const Color(0xFF4CAF50);
        break;
      case FoodRecognitionType.vision:
        typeText = 'AI Recognition';
        typeIcon = Icons.visibility;
        typeColor = const Color(0xFF2196F3);
        break;
      case FoodRecognitionType.manual:
        typeText = 'Manual Search';
        typeIcon = Icons.search;
        typeColor = const Color(0xFFFF9800);
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: typeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: typeColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(typeIcon, color: typeColor, size: 20),
          const SizedBox(width: 8),
          Text(
            typeText,
            style: TextStyle(
              color: typeColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          if (widget.recognitionResult.confidence > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Color(
                  VisionService.getConfidenceColor(
                    widget.recognitionResult.confidence,
                  ),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${(widget.recognitionResult.confidence * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFoodSuggestions() {
    if (widget.recognitionResult.suggestions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: const Center(
          child: Column(
            children: [
              Icon(Icons.search_off, color: Colors.white, size: 48),
              SizedBox(height: 12),
              Text(
                'No food suggestions found',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Food Suggestions',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...widget.recognitionResult.suggestions.map(
          (suggestion) => _buildFoodSuggestionCard(suggestion),
        ),
      ],
    );
  }

  Widget _buildFoodSuggestionCard(FoodSuggestion suggestion) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF2196F3),
          child: Text(
            suggestion.name.isNotEmpty ? suggestion.name[0].toUpperCase() : '?',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          suggestion.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (suggestion.category != null)
              Text(
                suggestion.category!,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            if (suggestion.description != null)
              Text(
                suggestion.description!,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Color(
              VisionService.getConfidenceColor(suggestion.confidence),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${(suggestion.confidence * 100).toStringAsFixed(0)}%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        onTap: () => _selectFood(suggestion),
      ),
    );
  }

  Widget _buildPortionSizeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Portion Size',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Multiplier',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  Text(
                    '${_portionMultiplier.toStringAsFixed(1)}x',
                    style: const TextStyle(
                      color: Color(0xFF2196F3),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Slider(
                value: _portionMultiplier,
                min: 0.1,
                max: 5.0,
                divisions: 49,
                activeColor: const Color(0xFF2196F3),
                inactiveColor: Colors.white.withOpacity(0.3),
                onChanged: (value) {
                  setState(() {
                    _portionMultiplier = value;
                  });
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '0.1x',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '5.0x',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
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

  Widget _buildAddToMealButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _addToMeal(),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add to Meal',
          style: TextStyle(
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

  void _selectFood(FoodSuggestion suggestion) {
    // You could show a dialog or navigate to a detailed view
    // For now, we'll just add it to the meal
    _addToMeal(suggestion);
  }

  Future<void> _addToMeal([FoodSuggestion? suggestion]) async {
    final provider = Provider.of<MealLoggingProvider>(context, listen: false);

    // Use the first suggestion if none is provided
    final selectedSuggestion =
        suggestion ?? widget.recognitionResult.suggestions.first;

    await provider.addFoodItem(selectedSuggestion, _portionMultiplier);

    if (provider.error.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Food added to meal!'),
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
