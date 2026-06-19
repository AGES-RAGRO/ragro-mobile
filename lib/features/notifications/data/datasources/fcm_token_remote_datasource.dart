import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/network/api_client.dart';
import 'package:ragro_mobile/core/network/api_endpoints.dart';

/// Registers/refreshes this device's FCM token on the backend
/// (`POST /notifications/token`, any authenticated user).
@lazySingleton
class FcmTokenRemoteDataSource {
  const FcmTokenRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<void> registerToken(String token) async {
    await _apiClient.dio.post<void>(
      ApiEndpoints.notificationToken,
      data: <String, dynamic>{'token': token},
    );
  }
}
