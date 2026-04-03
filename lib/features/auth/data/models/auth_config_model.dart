class AuthConfigModel {
  const AuthConfigModel({
    required this.tokenUrl,
    required this.clientId,
    required this.realm,
  });

  factory AuthConfigModel.fromJson(Map<String, dynamic> json) {
    return AuthConfigModel(
      tokenUrl: json['tokenUrl'] as String,
      clientId: json['clientId'] as String,
      realm: json['realm'] as String,
    );
  }

  final String tokenUrl;
  final String clientId;
  final String realm;
}
