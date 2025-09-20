import 'package:flutter/material.dart';

/// Navigation provider to manage bottom navigation state
///
/// This provider handles the current selected index in the bottom navigation bar
/// and provides methods to change the selected tab.
class NavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;

  /// Get the current selected index
  int get currentIndex => _currentIndex;

  /// Set the current selected index
  void setCurrentIndex(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  /// Navigate to home tab
  void goToHome() => setCurrentIndex(0);

  /// Navigate to efficiency tab
  void goToEfficiency() => setCurrentIndex(1);

  /// Navigate to fitness tab
  void goToFitness() => setCurrentIndex(2);

  /// Navigate to ranking tab
  void goToRanking() => setCurrentIndex(3);
}
