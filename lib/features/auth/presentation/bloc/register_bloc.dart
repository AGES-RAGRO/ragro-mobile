import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';
import 'package:ragro_mobile/features/auth/domain/usecases/register_customer.dart';
import 'package:ragro_mobile/features/auth/presentation/bloc/register_event.dart';
import 'package:ragro_mobile/features/auth/presentation/bloc/register_state.dart';

@injectable
class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc(this._register) : super(const RegisterInitial()) {
    on<RegisterSubmitted>(_onSubmitted);
  }

  final RegisterCustomer _register;

  Future<void> _onSubmitted(
    RegisterSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    emit(const RegisterLoading());
    try {
      final user = await _register(
        name: event.name,
        phone: event.phone,
        email: event.email,
        fiscalNumber: event.fiscalNumber,
        password: event.password,
        zipCode: event.zipCode,
        street: event.street,
        number: event.number,
        city: event.city,
        state: event.state,
        complement: event.complement,
        neighborhood: event.neighborhood,
      );
      emit(RegisterSuccess(user));
    } on ConflictException catch (e) {
      emit(RegisterFailure(_mapConflictMessage(e.message)));
    } on ApiException catch (e) {
      emit(RegisterFailure(e.message));
    }
  }

  // Traduz mensagens do backend (EN) para o usuário final (PT-BR).
  String _mapConflictMessage(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('e-mail') || lower.contains('email')) {
      return 'Este e-mail já está cadastrado.';
    }
    if (lower.contains('fiscal')) {
      return 'Este CPF já está cadastrado.';
    }
    return 'Cadastro já existente.';
  }
}
