import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_profile.dart';
import '../services/profile_service.dart';

/// Provider for managing user profile state
class ProfileProvider extends ChangeNotifier {
  final ProfileService _profileService = ProfileService();

  UserProfile? _userProfile;
  bool _isLoading = false;
  String? _error;

  // Getters
  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasProfile => _userProfile != null;

  /// Load user profile from Firestore
  Future<void> loadUserProfile(String uid) async {
    _setLoading(true);
    _clearError();

    try {
      _userProfile = await _profileService.getUserProfile(uid);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load profile: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Create new user profile
  Future<bool> createUserProfile({
    required String uid,
    required String email,
    String fullName = '',
    String bio = 'Passionate about productivity and wellness',
    String phone = '',
    String location = '',
    String occupation = 'Student',
    String level = 'Beginner',
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final profile = UserProfile.createDefault(
        uid: uid,
        email: email,
        fullName: fullName,
        bio: bio,
        phone: phone,
        location: location,
        occupation: occupation,
        level: level,
      );

      final success = await _profileService.saveUserProfile(profile);
      if (success) {
        _userProfile = profile;
        notifyListeners();
      }
      return success;
    } catch (e) {
      _setError('Failed to create profile: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update user profile
  Future<bool> updateUserProfile(UserProfile updatedProfile) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _profileService.saveUserProfile(updatedProfile);
      if (success) {
        _userProfile = updatedProfile;
        notifyListeners();
      }
      return success;
    } catch (e) {
      _setError('Failed to update profile: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update specific profile fields
  Future<bool> updateProfileFields(Map<String, dynamic> fields) async {
    if (_userProfile == null) return false;

    _setLoading(true);
    _clearError();

    try {
      final success = await _profileService.updateProfileFields(
        _userProfile!.uid,
        fields,
      );
      if (success) {
        // Reload profile to get updated data
        await loadUserProfile(_userProfile!.uid);
      }
      return success;
    } catch (e) {
      _setError('Failed to update profile fields: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update profile image
  Future<bool> updateProfileImage(String imagePath) async {
    if (_userProfile == null) {
      _setError('No user profile found');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      print('ProfileProvider: Starting image update for path: $imagePath');
      final imageFile = File(imagePath);

      if (!await imageFile.exists()) {
        _setError('Image file does not exist');
        return false;
      }

      print('ProfileProvider: Image file exists, calling service...');
      final success = await _profileService
          .updateProfileImage(_userProfile!.uid, imageFile)
          .timeout(
            const Duration(minutes: 3),
            onTimeout: () {
              print('ProfileProvider: Image update timeout after 3 minutes');
              throw Exception('Image update timeout');
            },
          );

      print('ProfileProvider: Service call completed with result: $success');

      if (success) {
        print('ProfileProvider: Reloading profile...');
        // Reload profile to get updated image URL
        await loadUserProfile(_userProfile!.uid);
        print('ProfileProvider: Profile reloaded');
      }
      return success;
    } catch (e) {
      print('ProfileProvider: Error updating profile image: $e');
      _setError('Failed to update profile image: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Add points to user profile
  Future<bool> addPoints(int points) async {
    if (_userProfile == null) return false;

    try {
      final success = await _profileService.addPoints(
        _userProfile!.uid,
        points,
      );
      if (success) {
        // Reload profile to get updated points
        await loadUserProfile(_userProfile!.uid);
      }
      return success;
    } catch (e) {
      _setError('Failed to add points: $e');
      return false;
    }
  }

  /// Update user streak
  Future<bool> updateStreak(int streak) async {
    if (_userProfile == null) return false;

    try {
      final success = await _profileService.updateStreak(
        _userProfile!.uid,
        streak,
      );
      if (success) {
        // Reload profile to get updated streak
        await loadUserProfile(_userProfile!.uid);
      }
      return success;
    } catch (e) {
      _setError('Failed to update streak: $e');
      return false;
    }
  }

  /// Add achievement
  Future<bool> addAchievement(String achievement) async {
    if (_userProfile == null) return false;

    try {
      final success = await _profileService.addAchievement(
        _userProfile!.uid,
        achievement,
      );
      if (success) {
        // Reload profile to get updated achievements
        await loadUserProfile(_userProfile!.uid);
      }
      return success;
    } catch (e) {
      _setError('Failed to add achievement: $e');
      return false;
    }
  }

  /// Update settings
  Future<bool> updateSettings(Map<String, dynamic> settings) async {
    if (_userProfile == null) return false;

    try {
      final success = await _profileService.updateSettings(
        _userProfile!.uid,
        settings,
      );
      if (success) {
        // Reload profile to get updated settings
        await loadUserProfile(_userProfile!.uid);
      }
      return success;
    } catch (e) {
      _setError('Failed to update settings: $e');
      return false;
    }
  }

  /// Get leaderboard
  Future<List<UserProfile>> getLeaderboard({int limit = 10}) async {
    try {
      return await _profileService.getLeaderboard(limit: limit);
    } catch (e) {
      _setError('Failed to get leaderboard: $e');
      return [];
    }
  }

  /// Pick image from camera or gallery
  Future<File?> pickImage(ImageSource source) async {
    try {
      return await _profileService.pickImage(source);
    } catch (e) {
      _setError('Failed to pick image: $e');
      return null;
    }
  }

  /// Update points based on step achievements
  Future<bool> updatePointsFromSteps(
    String uid,
    int steps,
    String level,
  ) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _profileService.updatePointsFromSteps(
        uid,
        steps,
        level,
      );

      if (success) {
        // Reload profile to get updated points
        await loadUserProfile(uid);
      }

      return success;
    } catch (e) {
      _setError('Failed to update points: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Clear profile data (for logout)
  void clearProfile() {
    _userProfile = null;
    _clearError();
    notifyListeners();
  }

  /// Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
