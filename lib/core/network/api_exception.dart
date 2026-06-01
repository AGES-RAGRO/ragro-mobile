sealed class ApiException implements Exception {
  const ApiException(this.message);
  final String message;
  @override
  String toString() => message;
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException([super.message = 'Credenciais inválidas']);
}

/// Thrown when the backend returns 401 with a body indicating the producer
/// account is deactivated (e.g. `{"error": "Produtor inativo"}`). Separate from
/// [UnauthorizedException] so the UI can show a specific message.
class DeactivatedAccountException extends ApiException {
  const DeactivatedAccountException([
    super.message =
        'Sua conta está desativada. Entre em contato com o administrador.',
  ]);
}

class ForbiddenException extends ApiException {
  const ForbiddenException([super.message = 'Sem permissão para esta ação']);
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

class ApiTimeoutException extends ApiException {
  const ApiTimeoutException([super.message = 'Tempo limite excedido']);
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

class InvalidCredentialsApiException extends ApiException {
  const InvalidCredentialsApiException([
    super.message = 'E-mail ou senha inválidos',
  ]);
}
