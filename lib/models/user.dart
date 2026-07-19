import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 4)
class User extends HiveObject {
  @HiveField(0)
  final String email;

  @HiveField(1)
  final String phone;

  @HiveField(2)
  final DateTime registrationDate;

  @HiveField(3)
  final String name;

  @HiveField(4)
  final String pin; // Added PIN field

  @HiveField(5)
  final String? password;

  @HiveField(6)
  final bool isEmailVerified;

  User({
    this.email = '',
    required this.phone,
    required this.registrationDate,
    required this.name,
    this.pin = '',
    this.password,
    this.isEmailVerified = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'phone': phone,
      'registrationDate': registrationDate.toIso8601String(),
      'name': name,
      'pin': pin,
      'isEmailVerified': isEmailVerified,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      registrationDate: DateTime.parse(map['registrationDate'] ?? DateTime.now().toIso8601String()),
      name: map['name'] ?? '',
      pin: map['pin'] ?? '',
      isEmailVerified: map['isEmailVerified'] ?? false,
    );
  }

  /// Returns a new User with an updated PIN (all other fields unchanged).
  User copyWithPin(String newPin) => User(
        email: email,
        phone: phone,
        registrationDate: registrationDate,
        name: name,
        pin: newPin,
        password: password,
        isEmailVerified: isEmailVerified,
      );

  /// Returns a new User with updated fields (all other fields unchanged).
  User copyWith({
    String? email,
    String? phone,
    DateTime? registrationDate,
    String? name,
    String? pin,
    String? password,
    bool? isEmailVerified,
  }) {
    return User(
      email: email ?? this.email,
      phone: phone ?? this.phone,
      registrationDate: registrationDate ?? this.registrationDate,
      name: name ?? this.name,
      pin: pin ?? this.pin,
      password: password ?? this.password,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }
}
