import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    super.phone,
    super.dateOfBirth,
    super.gender,
    super.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        phone: json['phone'] ?? '',
        dateOfBirth: json['dateOfBirth'] ?? '',
        gender: json['gender'] ?? '',
        avatarUrl: json['avatarUrl'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'dateOfBirth': dateOfBirth,
        'gender': gender,
        'avatarUrl': avatarUrl,
      };
}
