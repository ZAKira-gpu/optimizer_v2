import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/user_profile.dart';

/// Service for managing user profile data in Firestore
class ProfileService {
  static const String _collection = 'userProfiles';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _imagePicker = ImagePicker();

  /// Get user profile by UID
  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection(_collection).doc(uid).get();
      if (doc.exists) {
        return UserProfile.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  /// Create or update user profile
  Future<bool> saveUserProfile(UserProfile profile) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(profile.uid)
          .set(profile.toFirestore());
      return true;
    } catch (e) {
      print('Error saving user profile: $e');
      return false;
    }
  }

  /// Update specific profile fields
  Future<bool> updateProfileFields(
    String uid,
    Map<String, dynamic> fields,
  ) async {
    try {
      fields['updatedAt'] = Timestamp.fromDate(DateTime.now());
      await _firestore.collection(_collection).doc(uid).update(fields);
      return true;
    } catch (e) {
      print('Error updating profile fields: $e');
      return false;
    }
  }

  /// Upload profile image to Firebase Storage
  Future<String?> uploadProfileImage(String uid, File imageFile) async {
    try {
      print('Starting upload to Firebase Storage for uid: $uid');
      final ref = _storage.ref().child('profile_images/$uid.jpg');
      print('Storage reference created: ${ref.fullPath}');

      print('Reading image file as bytes...');
      final imageBytes = await imageFile.readAsBytes().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print('File read timeout after 30 seconds');
          throw Exception('File read timeout');
        },
      );
      print('Image bytes read: ${imageBytes.length} bytes');

      print('Starting data upload...');
      final uploadTask = ref.putData(
        imageBytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      // Add timeout to prevent hanging
      final uploadResult = await uploadTask.timeout(
        const Duration(minutes: 2),
        onTimeout: () {
          print('Upload timeout after 2 minutes');
          throw Exception('Upload timeout');
        },
      );

      print('Upload task completed');

      print('Getting download URL...');
      final downloadUrl = await uploadResult.ref.getDownloadURL().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print('Download URL timeout after 30 seconds');
          throw Exception('Download URL timeout');
        },
      );

      print('Download URL obtained: $downloadUrl');

      return downloadUrl;
    } catch (e) {
      print('Error uploading profile image: $e');
      return null;
    }
  }

  /// Check and request permissions for image picking
  Future<bool> _checkPermissions(ImageSource source) async {
    if (source == ImageSource.camera) {
      final cameraStatus = await Permission.camera.request();
      if (cameraStatus != PermissionStatus.granted) {
        print('Camera permission denied');
        return false;
      }
    } else {
      final storageStatus = await Permission.photos.request();
      if (storageStatus != PermissionStatus.granted) {
        print('Photos permission denied');
        return false;
      }
    }
    return true;
  }

  /// Pick image from camera or gallery
  Future<File?> pickImage(ImageSource source) async {
    try {
      print('Starting image pick with source: $source');

      // Check permissions first
      final hasPermission = await _checkPermissions(source);
      if (!hasPermission) {
        print('Permission denied for image source: $source');
        return null;
      }

      final XFile? image = await _imagePicker
          .pickImage(
            source: source,
            maxWidth: 800,
            maxHeight: 800,
            imageQuality: 80,
          )
          .timeout(
            const Duration(minutes: 1),
            onTimeout: () {
              print('Image pick timeout after 1 minute');
              throw Exception('Image pick timeout');
            },
          );

      print('Image pick result: ${image?.path}');

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  /// Update profile image
  Future<bool> updateProfileImage(String uid, File imageFile) async {
    try {
      print('updateProfileImage called for uid: $uid');

      // Upload image to storage
      final imageUrl = await uploadProfileImage(uid, imageFile);
      print('Upload result: $imageUrl');

      if (imageUrl != null) {
        print('Updating profile fields with image URL...');
        // Update profile with new image URL
        final result = await updateProfileFields(uid, {
          'profileImageUrl': imageUrl,
        });
        print('Profile fields update result: $result');
        return result;
      }
      print('No image URL received, returning false');
      return false;
    } catch (e) {
      print('Error updating profile image: $e');
      return false;
    }
  }

  /// Add points to user profile
  Future<bool> addPoints(String uid, int points) async {
    try {
      final profile = await getUserProfile(uid);
      if (profile != null) {
        final newPoints = profile.points + points;
        final newLevel = _calculateLevel(newPoints);
        return await updateProfileFields(uid, {
          'points': newPoints,
          'levelNumber': newLevel,
        });
      }
      return false;
    } catch (e) {
      print('Error adding points: $e');
      return false;
    }
  }

  /// Update user streak
  Future<bool> updateStreak(String uid, int streak) async {
    try {
      return await updateProfileFields(uid, {'streak': streak});
    } catch (e) {
      print('Error updating streak: $e');
      return false;
    }
  }

  /// Add achievement to user profile
  Future<bool> addAchievement(String uid, String achievement) async {
    try {
      final profile = await getUserProfile(uid);
      if (profile != null) {
        final achievements = List<String>.from(profile.achievements);
        if (!achievements.contains(achievement)) {
          achievements.add(achievement);
          return await updateProfileFields(uid, {'achievements': achievements});
        }
      }
      return false;
    } catch (e) {
      print('Error adding achievement: $e');
      return false;
    }
  }

  /// Update user settings
  Future<bool> updateSettings(String uid, Map<String, dynamic> settings) async {
    try {
      return await updateProfileFields(uid, {'settings': settings});
    } catch (e) {
      print('Error updating settings: $e');
      return false;
    }
  }

  /// Get leaderboard (top users by points)
  Future<List<UserProfile>> getLeaderboard({int limit = 10}) async {
    try {
      final query = await _firestore
          .collection(_collection)
          .orderBy('points', descending: true)
          .limit(limit)
          .get();

      return query.docs.map((doc) => UserProfile.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting leaderboard: $e');
      return [];
    }
  }

  /// Calculate level based on points
  int _calculateLevel(int points) {
    if (points < 100) return 1;
    if (points < 300) return 2;
    if (points < 600) return 3;
    if (points < 1000) return 4;
    if (points < 1500) return 5;
    if (points < 2100) return 6;
    if (points < 2800) return 7;
    if (points < 3600) return 8;
    if (points < 4500) return 9;
    if (points < 5500) return 10;
    if (points < 6600) return 11;
    if (points < 7800) return 12;
    if (points < 9100) return 13;
    if (points < 10500) return 14;
    if (points < 12000) return 15;
    if (points < 13600) return 16;
    if (points < 15300) return 17;
    if (points < 17100) return 18;
    if (points < 19000) return 19;
    return 20; // Max level
  }

  /// Get level name based on level number
  String getLevelName(int levelNumber) {
    if (levelNumber <= 5) return 'Beginner';
    if (levelNumber <= 10) return 'Intermediate';
    if (levelNumber <= 15) return 'Advanced';
    return 'Expert';
  }

  /// Update user points based on step achievements
  Future<bool> updatePointsFromSteps(
    String uid,
    int steps,
    String level,
  ) async {
    try {
      final profile = await getUserProfile(uid);
      if (profile == null) return false;

      // Calculate points based on step goals
      int pointsEarned = _calculatePointsFromSteps(steps, level);

      // Only update if user earned points
      if (pointsEarned > 0) {
        final newPoints = profile.points + pointsEarned;
        final newLevelNumber = _calculateLevelFromPoints(newPoints);

        await updateProfileFields(uid, {
          'points': newPoints,
          'levelNumber': newLevelNumber,
        });

        // Add achievement if significant milestone reached
        if (pointsEarned >= 100) {
          await addAchievement(
            uid,
            'Step Master: Earned ${pointsEarned} points in one day!',
          );
        }
      }

      return true;
    } catch (e) {
      print('Error updating points from steps: $e');
      return false;
    }
  }

  /// Calculate points based on steps and user level
  int _calculatePointsFromSteps(int steps, String level) {
    // Points calculation based on step goals
    // 10,000 steps = 100 points (base goal)
    // 15,000 steps = 150 points (advanced goal)
    // 20,000 steps = 200 points (expert goal)

    int goal = _getStepGoal(level);

    if (steps >= goal * 2) {
      return 200; // Double goal achievement
    } else if (steps >= (goal * 1.5).round()) {
      return 150; // 1.5x goal achievement
    } else if (steps >= goal) {
      return 100; // Goal achievement
    } else if (steps >= (goal * 0.5).round()) {
      return 50; // Half goal achievement
    } else {
      return (steps / 100).round(); // 1 point per 100 steps
    }
  }

  /// Get step goal based on user level
  int _getStepGoal(String level) {
    switch (level.toLowerCase()) {
      case 'beginner':
        return 5000;
      case 'intermediate':
        return 10000;
      case 'advanced':
        return 15000;
      case 'expert':
        return 20000;
      default:
        return 10000;
    }
  }

  /// Calculate level number based on total points
  int _calculateLevelFromPoints(int totalPoints) {
    if (totalPoints >= 10000) return 10; // Expert
    if (totalPoints >= 7500) return 9;
    if (totalPoints >= 5000) return 8;
    if (totalPoints >= 3500) return 7;
    if (totalPoints >= 2500) return 6;
    if (totalPoints >= 1500) return 5;
    if (totalPoints >= 1000) return 4;
    if (totalPoints >= 500) return 3;
    if (totalPoints >= 200) return 2;
    return 1; // Beginner
  }

  /// Delete user profile
  Future<bool> deleteUserProfile(String uid) async {
    try {
      // Delete profile image from storage
      try {
        await _storage.ref().child('profile_images/$uid.jpg').delete();
      } catch (e) {
        print('Error deleting profile image: $e');
      }

      // Delete profile document
      await _firestore.collection(_collection).doc(uid).delete();
      return true;
    } catch (e) {
      print('Error deleting user profile: $e');
      return false;
    }
  }
}
