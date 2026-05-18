import 'package:hive/hive.dart';

part 'user_profile_model.g.dart';

/// Hive model for storing user profile locally
@HiveType(typeId: 0)
class UserProfileModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double height; // in cm

  @HiveField(3)
  final double weight; // in kg

  @HiveField(4)
  final int age;

  @HiveField(5)
  final String gender; // 'male' | 'female' | 'other'

  @HiveField(6)
  final String? avatarPath;

  @HiveField(7)
  final int totalLifetimeSteps;

  @HiveField(8)
  final DateTime createdAt;

  UserProfileModel({
    required this.id,
    required this.name,
    required this.height,
    required this.weight,
    required this.age,
    required this.gender,
    this.avatarPath,
    this.totalLifetimeSteps = 0,
    required this.createdAt,
  });

  /// Body Mass Index calculation
  double get bmi => weight / ((height / 100) * (height / 100));

  /// BMI classification label
  String get bmiCategory {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25.0) return 'Normal';
    if (bmi < 30.0) return 'Overweight';
    return 'Obese';
  }

  UserProfileModel copyWith({
    String? name,
    double? height,
    double? weight,
    int? age,
    String? gender,
    String? avatarPath,
    int? totalLifetimeSteps,
  }) {
    return UserProfileModel(
      id: id,
      name: name ?? this.name,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      avatarPath: avatarPath ?? this.avatarPath,
      totalLifetimeSteps: totalLifetimeSteps ?? this.totalLifetimeSteps,
      createdAt: createdAt,
    );
  }

  /// Default profile for first-time users
  static UserProfileModel get defaultProfile => UserProfileModel(
        id: 'default_user',
        name: 'Fitness Pro',
        height: 170.0,
        weight: 70.0,
        age: 28,
        gender: 'male',
        totalLifetimeSteps: 0,
        createdAt: DateTime.now(),
      );
}
