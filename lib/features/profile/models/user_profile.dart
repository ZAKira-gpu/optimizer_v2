import 'package:cloud_firestore/cloud_firestore.dart';

/// User profile model for Firestore database
///
/// This model represents a user's profile information stored in Firestore
class UserProfile {
  final String uid;
  final String email;
  final String fullName;
  final String bio;
  final String phone;
  final String location;
  final String occupation;
  final String level;
  final double height; // in meters
  final double weight; // in kg
  final String? profileImageUrl;
  final int points;
  final int streak;
  final int levelNumber;
  final List<String> achievements;
  final Map<String, dynamic> settings;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.bio,
    required this.phone,
    required this.location,
    required this.occupation,
    required this.level,
    required this.height,
    required this.weight,
    this.profileImageUrl,
    required this.points,
    required this.streak,
    required this.levelNumber,
    required this.achievements,
    required this.settings,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create UserProfile from Firestore document
  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return UserProfile(
      uid: doc.id,
      email: data['email'] ?? '',
      fullName: data['fullName'] ?? '',
      bio: data['bio'] ?? '',
      phone: data['phone'] ?? '',
      location: data['location'] ?? '',
      occupation: data['occupation'] ?? 'Student',
      level: data['level'] ?? 'Beginner',
      height: (data['height'] ?? 1.75).toDouble(),
      weight: (data['weight'] ?? 70.0).toDouble(),
      profileImageUrl: data['profileImageUrl'],
      points: data['points'] ?? 0,
      streak: data['streak'] ?? 0,
      levelNumber: data['levelNumber'] ?? 1,
      achievements: List<String>.from(data['achievements'] ?? []),
      settings: Map<String, dynamic>.from(data['settings'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// Convert UserProfile to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'fullName': fullName,
      'bio': bio,
      'phone': phone,
      'location': location,
      'occupation': occupation,
      'level': level,
      'height': height,
      'weight': weight,
      'profileImageUrl': profileImageUrl,
      'points': points,
      'streak': streak,
      'levelNumber': levelNumber,
      'achievements': achievements,
      'settings': settings,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Create a copy of UserProfile with updated fields
  UserProfile copyWith({
    String? uid,
    String? email,
    String? fullName,
    String? bio,
    String? phone,
    String? location,
    String? occupation,
    String? level,
    double? height,
    double? weight,
    String? profileImageUrl,
    int? points,
    int? streak,
    int? levelNumber,
    List<String>? achievements,
    Map<String, dynamic>? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      bio: bio ?? this.bio,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      occupation: occupation ?? this.occupation,
      level: level ?? this.level,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      points: points ?? this.points,
      streak: streak ?? this.streak,
      levelNumber: levelNumber ?? this.levelNumber,
      achievements: achievements ?? this.achievements,
      settings: settings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Create default UserProfile for new users
  factory UserProfile.createDefault({
    required String uid,
    required String email,
    String fullName = '',
    String bio = 'Passionate about productivity and wellness',
    String phone = '',
    String location = '',
    String occupation = 'Student',
    String level = 'Beginner',
    double height = 1.75,
    double weight = 70.0,
  }) {
    final now = DateTime.now();
    return UserProfile(
      uid: uid,
      email: email,
      fullName: fullName.isEmpty
          ? email.split('@').first.toUpperCase()
          : fullName,
      bio: bio,
      phone: phone,
      location: location,
      occupation: occupation,
      level: level,
      height: height,
      weight: weight,
      points: 0,
      streak: 0,
      levelNumber: 1,
      achievements: [],
      settings: {
        'notificationsEnabled': true,
        'darkModeEnabled': false,
        'privacyLevel': 'public',
      },
      createdAt: now,
      updatedAt: now,
    );
  }
}
