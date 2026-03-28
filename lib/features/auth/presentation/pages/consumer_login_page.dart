// Screen: Consumer Login
// User Story: US-02 — Consumer Login
// Epic: EPIC 1 — Authentication
// Routes: POST /auth/login

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ragro_mobile/core/di/injection.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/features/auth/domain/entities/user_type.dart';
import 'package:ragro_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ragro_mobile/features/auth/presentation/bloc/auth_event.dart';
import 'package:ragro_mobile/features/auth/presentation/bloc/login_bloc.dart';
import 'package:ragro_mobile/features/auth/presentation/bloc/login_state.dart';
import 'package:ragro_mobile/features/auth/presentation/widgets/login_form.dart';
import 'package:ragro_mobile/features/auth/presentation/widgets/ragro_logo.dart';

class ConsumerLoginPage extends StatelessWidget {
  const ConsumerLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<LoginBloc>(),
      child: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            context.read<AuthBloc>().add(const AuthStarted());
          } else if (state is LoginFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.red,
              ),
            );
          }
        },
        child: Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  const RagroLogo(),
                  const Spacer(flex: 2),
                  LoginForm(
                    userType: UserType.consumer,
                    onRegisterTap: () => context.push('/register'),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
