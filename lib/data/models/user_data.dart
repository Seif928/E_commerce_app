import 'package:e_commerce_app/domain/entities/app_user.dart';

class UserData extends AppUser {
  const UserData({
    required super.id,
    required super.password,
    required super.username,
    required super.email,
    required super.createdAt,
    super.providerId,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'id': id});
    result.addAll({'password': password});
    result.addAll({'username': username});
    result.addAll({'email': email});
    result.addAll({'createdAt': createdAt});
    result.addAll({'providerId': providerId});

    return result;
  }

  factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData(
      id: map['id'] ?? '',
      password: map['password'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      createdAt: map['createdAt'] ?? '',
      providerId: map['providerId'] ?? 'password',
    );
  }
}