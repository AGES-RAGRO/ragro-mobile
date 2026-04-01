import 'package:ragro_mobile/features/auth/data/models/user_model.dart';

class LoginResponseModel {
  const LoginResponseModel({required this.token, required this.user});

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      token: json['token'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  final String token;
  final UserModel user;
}
