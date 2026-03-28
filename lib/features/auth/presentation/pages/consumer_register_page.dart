// Screen: Consumer Registration
// User Story: US-01 — Consumer Registration
// Epic: EPIC 1 — Authentication
// Routes: POST /auth/register

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ragro_mobile/core/di/injection.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/core/theme/app_text_styles.dart';
import 'package:ragro_mobile/features/auth/presentation/bloc/register_bloc.dart';
import 'package:ragro_mobile/features/auth/presentation/bloc/register_event.dart';
import 'package:ragro_mobile/features/auth/presentation/bloc/register_state.dart';
import 'package:ragro_mobile/features/auth/presentation/widgets/auth_submit_button.dart';
import 'package:ragro_mobile/features/auth/presentation/widgets/auth_text_field.dart';

class ConsumerRegisterPage extends StatelessWidget {
  const ConsumerRegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<RegisterBloc>(),
      child: const _ConsumerRegisterView(),
    );
  }
}

class _ConsumerRegisterView extends StatefulWidget {
  const _ConsumerRegisterView();

  @override
  State<_ConsumerRegisterView> createState() => _ConsumerRegisterViewState();
}

class _ConsumerRegisterViewState extends State<_ConsumerRegisterView> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();

  bool _termsAccepted = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _zipCodeController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Você precisa aceitar os Termos de Uso.'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    context.read<RegisterBloc>().add(
          RegisterSubmitted(
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            zipCode: _zipCodeController.text.trim(),
            street: _streetController.text.trim(),
            number: _numberController.text.trim(),
            city: _cityController.text.trim(),
            state: _stateController.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegisterBloc, RegisterState>(
      listener: (context, state) {
        if (state is RegisterSuccess) {
          context.go('/login/consumer');
        } else if (state is RegisterFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Criar conta'),
          leading: const BackButton(),
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              children: [
                AuthTextField(
                  label: 'Nome Completo',
                  icon: Icons.person_outline,
                  controller: _nameController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe seu nome completo';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  label: 'Telefone',
                  icon: Icons.phone_outlined,
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe seu telefone';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  label: 'E-mail',
                  icon: Icons.email_outlined,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe seu e-mail';
                    }
                    if (!value.contains('@')) {
                      return 'E-mail inválido';
                    }
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
                      return 'Informe uma senha';
                    }
                    if (value.length < 8) {
                      return 'A senha deve ter pelo menos 8 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  label: 'Confirmar senha',
                  icon: Icons.lock_outline,
                  controller: _confirmPasswordController,
                  isPassword: true,
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'As senhas não coincidem';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  label: 'CEP',
                  icon: Icons.location_on_outlined,
                  controller: _zipCodeController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    final digits =
                        value?.replaceAll(RegExp(r'\D'), '') ?? '';
                    if (digits.length != 8) {
                      return 'CEP deve ter 8 dígitos';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  label: 'Endereço',
                  icon: Icons.home_outlined,
                  controller: _streetController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe seu endereço';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  label: 'Número',
                  icon: Icons.numbers_outlined,
                  controller: _numberController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe o número';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AuthTextField(
                        label: 'Cidade',
                        icon: Icons.location_city_outlined,
                        controller: _cityController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Informe a cidade';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 100,
                      child: AuthTextField(
                        label: 'Estado',
                        icon: Icons.map_outlined,
                        controller: _stateController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'UF';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _TermsCheckbox(
                  value: _termsAccepted,
                  onChanged: (value) {
                    setState(() {
                      _termsAccepted = value ?? false;
                    });
                  },
                ),
                const SizedBox(height: 24),
                BlocBuilder<RegisterBloc, RegisterState>(
                  builder: (context, state) {
                    return AuthSubmitButton(
                      label: 'Criar conta',
                      isLoading: state is RegisterLoading,
                      onPressed: _submit,
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TermsCheckbox extends StatelessWidget {
  const _TermsCheckbox({
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.darkGreen,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.caption.copyWith(color: AppColors.black),
                children: [
                  const TextSpan(text: 'Eu concordo com os '),
                  TextSpan(
                    text: 'Termos de Uso e Política de Privacidade',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.darkGreen,
                      fontWeight: FontWeight.w700,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        // TODO(ragro): open terms of service page
                      },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
