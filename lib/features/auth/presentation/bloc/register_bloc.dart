import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';
import 'package:ragro_mobile/features/auth/domain/usecases/register_consumer.dart';
import 'package:ragro_mobile/features/auth/presentation/bloc/register_event.dart';
import 'package:ragro_mobile/features/auth/presentation/bloc/register_state.dart';

@injectable
class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc(this._register) : super(const RegisterInitial()) {
    on<RegisterSubmitted>(_onSubmitted);
  }

  final RegisterConsumer _register;

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
        password: event.password,
        zipCode: event.zipCode,
        street: event.street,
        number: event.number,
        city: event.city,
        state: event.state,
        complement: event.complement,
      );
      emit(RegisterSuccess(user));
    } on ApiException catch (e) {
      emit(RegisterFailure(e.message));
    }
  }
}
