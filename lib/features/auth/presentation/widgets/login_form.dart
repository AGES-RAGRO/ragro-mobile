import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/core/theme/app_text_styles.dart';
import 'package:ragro_mobile/features/auth/presentation/bloc/login_bloc.dart';
import 'package:ragro_mobile/features/auth/presentation/bloc/login_event.dart';
import 'package:ragro_mobile/features/auth/presentation/bloc/login_state.dart';
import 'package:ragro_mobile/features/auth/presentation/widgets/auth_submit_button.dart';
import 'package:ragro_mobile/features/auth/presentation/widgets/auth_text_field.dart';

/// Login form widget — composes email/password fields, submit button,
/// and optional links for password recovery and account registration.
///
/// Requires [LoginBloc] to be available above this widget in the tree.
class LoginForm extends StatefulWidget {
  const LoginForm({
    super.key,
    this.onRegisterTap,
    this.onForgotPasswordTap,
    this.onLoginFailure,
  });

  final VoidCallback? onRegisterTap;
  final VoidCallback? onForgotPasswordTap;
  final ValueChanged<String>? onLoginFailure;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late final TapGestureRecognizer? _registerTapRecognizer =
      widget.onRegisterTap != null
          ? (TapGestureRecognizer()..onTap = widget.onRegisterTap)
          : null;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _registerTapRecognizer?.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<LoginBloc>().add(
            LoginSubmitted(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          AuthTextField(
            label: 'E-mail',
            icon: Icons.email_outlined,
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.isEmpty) return 'E-mail obrigatório';
              final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
              if (!emailRegex.hasMatch(v)) return 'E-mail inválido';
              return null;
            },
          ),
          const SizedBox(height: 16),
          AuthTextField(
            label: 'Senha',
            icon: Icons.lock_outline,
            controller: _passwordController,
            isPassword: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Informe sua senha';
              }
              return null;
            },
          ),
          if (widget.onForgotPasswordTap != null) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: widget.onForgotPasswordTap,
                child: Text(
                  'Esqueceu sua senha?',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.darkGreen,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          BlocBuilder<LoginBloc, LoginState>(
            builder: (context, state) {
              return AuthSubmitButton(
                label: 'Entrar',
                isLoading: state is LoginLoading,
                onPressed: _submit,
              );
            },
          ),
          if (widget.onRegisterTap != null) ...[
            const SizedBox(height: 20),
            Center(
              child: RichText(
                text: TextSpan(
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.black,
                  ),
                  children: [
                    const TextSpan(text: 'Não tem conta? '),
                    TextSpan(
                      text: 'Criar uma conta',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.darkGreen,
                        fontWeight: FontWeight.w700,
                      ),
                      recognizer: _registerTapRecognizer,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
