import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String dateOfBirth;
  final String gender;
  final String avatarUrl;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '',
    this.dateOfBirth = '',
    this.gender = '',
    this.avatarUrl = '',
  });

  @override
  List<Object?> get props => [id, name, email, phone, dateOfBirth, gender, avatarUrl];
}
