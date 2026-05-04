import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

class CepAddress {
  CepAddress({
    required this.cep,
    required this.state,
    required this.city,
    required this.neighborhood,
    required this.street,
  });

  factory CepAddress.fromJson(Map<String, dynamic> json) {
    return CepAddress(
      cep: (json['cep'] as String?) ?? '',
      state: (json['state'] as String?) ?? '',
      city: (json['city'] as String?) ?? '',
      neighborhood: (json['neighborhood'] as String?) ?? '',
      street: (json['street'] as String?) ?? '',
    );
  }

  final String cep;
  final String state;
  final String city;
  final String neighborhood;
  final String street;

  @override
  String toString() {
    return 'CepAddress(cep: $cep, state: $state, city: $city, neighborhood: $neighborhood, street: $street)';
  }
}

@lazySingleton
class CepService {
  final Dio _dio = Dio();

  Future<CepAddress?> fetchAddress(String cep) async {
    final cleanCep = cep.replaceAll(RegExp(r'\D'), '');
    if (cleanCep.length != 8) return null;

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        'https://brasilapi.com.br/api/cep/v1/$cleanCep',
        options: Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );

      final data = response.data;
      if (response.statusCode == 200 && data != null) {
        return CepAddress.fromJson(data);
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}
