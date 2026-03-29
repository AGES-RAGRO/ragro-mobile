import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';
import 'package:ragro_mobile/features/auth/domain/usecases/login_user.dart';
import 'package:ragro_mobile/features/auth/presentation/bloc/login_event.dart';
import 'package:ragro_mobile/features/auth/presentation/bloc/login_state.dart';

@injectable
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc(this._loginUser) : super(const LoginInitial()) {
    on<LoginSubmitted>(_onSubmitted);
  }

  final LoginUser _loginUser;

  Future<void> _onSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(const LoginLoading());
    try {
      final result = await _loginUser(
        email: event.email,
        password: event.password,
      );
      emit(LoginSuccess(result.user));
    } on ApiException catch (e) {
      emit(LoginFailure(e.message));
    }
  }
}
