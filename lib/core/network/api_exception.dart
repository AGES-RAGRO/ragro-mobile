// lib/core/network/api_exception.dart
sealed class ApiException implements Exception {
  const ApiException(this.message);
  final String message;
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException([super.message = 'Credenciais inválidas']);
}

class NotFoundException extends ApiException {
  const NotFoundException([super.message = 'Recurso não encontrado']);
}

class ConflictException extends ApiException {
  const ConflictException([super.message = 'Recurso já existe']);
}

class RateLimitedException extends ApiException {
  const RateLimitedException([super.message = 'Muitas tentativas. Aguarde.']);
}

class TimeoutException extends ApiException {
  const TimeoutException([super.message = 'Tempo limite excedido']);
}

class NetworkException extends ApiException {
  const NetworkException([super.message = 'Sem conexão com a internet']);
}

class ServerException extends ApiException {
  const ServerException([super.message = 'Erro interno do servidor']);
}

class UnknownApiException extends ApiException {
  const UnknownApiException([super.message = 'Erro desconhecido']);
}
