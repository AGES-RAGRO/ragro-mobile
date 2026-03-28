// Screen: Admin Login
// User Story: US-09 — Admin access
// Epic: EPIC 1 — Authentication
// Routes: POST /auth/login

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ragro_mobile/core/di/injection.dart';
import 'package:ragro_mobile/features/auth/domain/entities/user_type.dart';
import 'package:ragro_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ragro_mobile/features/auth/presentation/bloc/auth_event.dart';
import 'package:ragro_mobile/features/auth/presentation/bloc/login_bloc.dart';
import 'package:ragro_mobile/features/auth/presentation/bloc/login_state.dart';
import 'package:ragro_mobile/features/auth/presentation/widgets/login_form.dart';
import 'package:ragro_mobile/features/auth/presentation/widgets/ragro_logo.dart';

class AdminLoginPage extends StatelessWidget {
  const AdminLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<LoginBloc>(),
      child: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            context.read<AuthBloc>().add(const AuthStarted());
          }
        },
        child: const Scaffold(
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Spacer(flex: 2),
                  RagroLogo(),
                  Spacer(flex: 2),
                  LoginForm(userType: UserType.admin),
                  Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
