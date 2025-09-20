import 'dart:io';
import 'dart:convert';
// import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:http/http.dart' as http;
import '../models/food_models.dart';

/// Service for barcode scanning and OpenFoodFacts integration
class BarcodeService {
  static const String _openFoodFactsBaseUrl =
      'https://world.openfoodfacts.org/api/v0';

  // final BarcodeScanner _barcodeScanner = BarcodeScanner();

  /// Scan barcode from image file (disabled - ML Kit not available)
  Future<BarcodeResult?> scanBarcode(File imageFile) async {
    // Barcode scanning is disabled since ML Kit dependencies are commented out
    print('Barcode scanning is not available - ML Kit dependencies disabled');
    return null;
  }

  /// Search for products by name (fallback when barcode not found)
  Future<List<FoodSuggestion>> searchProducts(String query) async {
    try {
      final url = '$_openFoodFactsBaseUrl/cgi/search.pl';
      final response = await http.get(
        Uri.parse(url).replace(
          queryParameters: {
            'search_terms': query,
            'search_simple': '1',
            'action': 'process',
            'json': '1',
            'page_size': '20',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final products = data['products'] as List? ?? [];

        return products.map((product) {
          final name =
              product['product_name'] ??
              product['product_name_en'] ??
              product['generic_name'] ??
              'Unknown Product';

          return FoodSuggestion(
            name: name,
            confidence: 0.8, // Lower confidence for search results
            category: product['categories']?.split(',').first,
            description: product['generic_name'],
          );
        }).toList();
      }

      return [];
    } catch (e) {
      print('Error searching products: $e');
      return [];
    }
  }

  /// Dispose resources
  void dispose() {
    // _barcodeScanner.close();
  }
}

/// Result of barcode scanning
class BarcodeResult {
  final String code;
  final NutritionInfo nutrition;
  final double confidence;

  BarcodeResult({
    required this.code,
    required this.nutrition,
    required this.confidence,
  });
}
