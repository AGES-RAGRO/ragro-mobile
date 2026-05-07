// Screen: Login
// User Story: US-01 — Consumer Login / US-08 — Producer Login
// Epic: EPIC 1 — Authentication
// Routes: POST /auth/login

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ragro_mobile/core/di/injection.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/core/theme/app_text_styles.dart';
import 'package:ragro_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ragro_mobile/features/auth/presentation/bloc/auth_event.dart';
import 'package:ragro_mobile/features/auth/presentation/bloc/login_bloc.dart';
import 'package:ragro_mobile/features/auth/presentation/bloc/login_event.dart';
import 'package:ragro_mobile/features/auth/presentation/bloc/login_state.dart';
import 'package:ragro_mobile/features/auth/presentation/widgets/auth_submit_button.dart';
import 'package:ragro_mobile/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:ragro_mobile/features/auth/presentation/widgets/login_form.dart';
import 'package:ragro_mobile/features/auth/presentation/widgets/ragro_logo.dart';
import 'package:ragro_mobile/shared/widgets/app_notification.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<LoginBloc>(),
      child: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            getIt<AuthBloc>().add(AuthLoggedIn(state.user));
          } else if (state is LoginFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.red,
              ),
            );
          } else if (state is LoginForgotPasswordSuccess) {
            AppNotification.showSuccess(
              context,
              'E-mail de recuperação enviado com sucesso!',
            );
          } else if (state is LoginForgotPasswordFailure) {
            AppNotification.showError(context, state.message);
          }
        },
        child: Builder(
          builder: (context) => Scaffold(
            backgroundColor: AppColors.white,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight:
                        MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        const Spacer(flex: 3),
                        const RagroLogo(),
                        const Spacer(),
                        LoginForm(
                          onRegisterTap: () => context.push('/register'),
                          onForgotPasswordTap: () =>
                              _showForgotPasswordModal(context),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showForgotPasswordModal(BuildContext context) {
    final emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final loginBloc = context.read<LoginBloc>();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BlocProvider.value(
          value: loginBloc,
          child: BlocListener<LoginBloc, LoginState>(
            listener: (context, state) {
              if (state is LoginForgotPasswordSuccess) {
                Navigator.pop(context); // Close modal on success
              }
            },
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recuperar Senha',
                            style: AppTextStyles.title2.copyWith(
                              color: AppColors.darkGreen,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Informe seu e-mail cadastrado e enviaremos um link para você definir uma nova senha.',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.black.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 24),
                      AuthTextField(
                        label: 'E-mail',
                        icon: Icons.email_outlined,
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'E-mail obrigatório';
                          }
                          final emailRegex = RegExp(
                            r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                          );
                          if (!emailRegex.hasMatch(v)) {
                            return 'E-mail inválido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      BlocBuilder<LoginBloc, LoginState>(
                        builder: (context, state) {
                          return AuthSubmitButton(
                            label: 'Enviar link',
                            isLoading: state is LoginForgotPasswordInProgress,
                            onPressed: () {
                              if (formKey.currentState?.validate() ?? false) {
                                loginBloc.add(
                                  LoginForgotPasswordRequested(
                                    emailController.text.trim(),
                                  ),
                                );
                              }
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
