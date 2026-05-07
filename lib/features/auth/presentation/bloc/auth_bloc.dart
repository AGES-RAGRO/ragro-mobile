import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';
import 'package:ragro_mobile/features/auth/domain/usecases/get_current_user.dart';
import 'package:ragro_mobile/features/auth/domain/usecases/logout.dart';
import 'package:ragro_mobile/features/auth/domain/usecases/request_password_reset.dart';
import 'package:ragro_mobile/features/auth/presentation/bloc/auth_event.dart';
import 'package:ragro_mobile/features/auth/presentation/bloc/auth_state.dart';

@lazySingleton
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._getCurrentUser, this._logout, this._requestPasswordReset)
    : super(const AuthInitial()) {
    on<AuthStarted>(_onStarted);
    on<AuthLoggedIn>((event, emit) => emit(AuthAuthenticated(event.user)));
    on<AuthLogoutRequested>(_onLogout);
    on<AuthPasswordResetRequested>(_onPasswordResetRequested);
  }

  final GetCurrentUser _getCurrentUser;
  final Logout _logout;
  final RequestPasswordReset _requestPasswordReset;

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final user = await _getCurrentUser();
    if (user != null) {
      emit(AuthAuthenticated(user));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onLogout(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _logout();
    } on Exception catch (_) {
      // Logout failure (e.g. local storage error) — still clear local session
      // and unauthenticate the user in-memory.
    }
    emit(const AuthUnauthenticated());
  }

  Future<void> _onPasswordResetRequested(
    AuthPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AuthAuthenticated) return;

    final user = currentState.user;
    emit(AuthPasswordResetInProgress(user));

    try {
      await _requestPasswordReset();
      emit(AuthPasswordResetSuccess(user));
    } on ApiException catch (e) {
      emit(AuthPasswordResetFailure(user, e.message));
    } on Exception catch (e) {
      emit(AuthPasswordResetFailure(user, e.toString()));
    }
  }
}
