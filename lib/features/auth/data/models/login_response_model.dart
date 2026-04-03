import 'package:ragro_mobile/features/auth/data/models/user_model.dart';

class LoginResponseModel {
  const LoginResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenUrl,
    required this.clientId,
    required this.user,
  });

  final String accessToken;
  final String refreshToken;
  final String tokenUrl;
  final String clientId;
  final UserModel user;
}
