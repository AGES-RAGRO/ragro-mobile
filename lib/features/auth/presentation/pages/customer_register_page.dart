// Screen: Customer Registration
// User Story: US-01 — Customer Registration
// Epic: EPIC 1 — Authentication
// Routes: POST /auth/register/customer

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ragro_mobile/core/di/injection.dart';
import 'package:ragro_mobile/core/formatters/input_masks.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/core/theme/app_text_styles.dart';
import 'package:ragro_mobile/core/validators/cpf_validator.dart';
import 'package:ragro_mobile/features/auth/presentation/bloc/register_bloc.dart';
import 'package:ragro_mobile/features/auth/presentation/bloc/register_event.dart';
import 'package:ragro_mobile/features/auth/presentation/bloc/register_state.dart';
import 'package:ragro_mobile/features/auth/presentation/widgets/auth_submit_button.dart';
import 'package:ragro_mobile/features/auth/presentation/widgets/auth_text_field.dart';

const List<String> _brazilianStates = [
  'AC',
  'AL',
  'AP',
  'AM',
  'BA',
  'CE',
  'DF',
  'ES',
  'GO',
  'MA',
  'MT',
  'MS',
  'MG',
  'PA',
  'PB',
  'PR',
  'PE',
  'PI',
  'RJ',
  'RN',
  'RS',
  'RO',
  'RR',
  'SC',
  'SP',
  'SE',
  'TO',
];

class CustomerRegisterPage extends StatelessWidget {
  const CustomerRegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<RegisterBloc>(),
      child: const _CustomerRegisterView(),
    );
  }
}

class _CustomerRegisterView extends StatefulWidget {
  const _CustomerRegisterView();

  @override
  State<_CustomerRegisterView> createState() => _CustomerRegisterViewState();
}

class _CustomerRegisterViewState extends State<_CustomerRegisterView> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _cpfController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _complementController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _cityController = TextEditingController();
  String? _selectedState;

  bool _termsAccepted = false;

  String _digitsOnly(String input) => input.replaceAll(RegExp(r'\D'), '');

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _cpfController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _zipCodeController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _complementController.dispose();
    _neighborhoodController.dispose();
    _cityController.dispose();
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
        phone: _digitsOnly(_phoneController.text),
        email: _emailController.text.trim(),
        fiscalNumber: _digitsOnly(_cpfController.text),
        password: _passwordController.text,
        zipCode: _digitsOnly(_zipCodeController.text),
        street: _streetController.text.trim(),
        number: _numberController.text.trim(),
        city: _cityController.text.trim(),
        state: _selectedState!,
        complement: _complementController.text.trim().isEmpty
            ? null
            : _complementController.text.trim(),
        neighborhood: _neighborhoodController.text.trim().isEmpty
            ? null
            : _neighborhoodController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegisterBloc, RegisterState>(
      listener: (context, state) {
        if (state is RegisterSuccess) {
          context.go('/login');
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
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
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
                  inputFormatters: [PhoneInputFormatter()],
                  validator: (value) {
                    final digits = _digitsOnly(value ?? '');
                    if (digits.length != 11) {
                      return 'DDD + número com 11 dígitos';
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
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'E-mail obrigatório';
                    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                    if (!emailRegex.hasMatch(v)) return 'E-mail inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  label: 'CPF',
                  icon: Icons.badge_outlined,
                  controller: _cpfController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [CpfInputFormatter()],
                  validator: (value) {
                    final digits = _digitsOnly(value ?? '');
                    if (digits.length != 11) {
                      return 'CPF deve ter 11 dígitos';
                    }
                    if (!CpfValidator.isValid(digits)) {
                      return 'CPF inválido';
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
                    if (value.length < 8 || value.length > 50) {
                      return 'Entre 8 e 50 caracteres';
                    }
                    if (!RegExp(
                      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).+$',
                    ).hasMatch(value)) {
                      return 'Inclua maiúscula, minúscula e um número';
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
                  inputFormatters: [CepInputFormatter()],
                  validator: (value) {
                    final digits = _digitsOnly(value ?? '');
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
                AuthTextField(
                  label: 'Complemento (opcional)',
                  icon: Icons.apartment_outlined,
                  controller: _complementController,
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  label: 'Bairro (opcional)',
                  icon: Icons.signpost_outlined,
                  controller: _neighborhoodController,
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
                      width: 110,
                      child: _UfAutocomplete(
                        initialValue: _selectedState,
                        onSelected: (uf) => setState(() => _selectedState = uf),
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

class _TermsCheckbox extends StatefulWidget {
  const _TermsCheckbox({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool?> onChanged;

  @override
  State<_TermsCheckbox> createState() => _TermsCheckboxState();
}

class _TermsCheckboxState extends State<_TermsCheckbox> {
  late final TapGestureRecognizer _termsTapRecognizer = TapGestureRecognizer()
    ..onTap = () {
      // TODO(ragro): open terms of service page
    };

  @override
  void dispose() {
    _termsTapRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: widget.value,
          onChanged: widget.onChanged,
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
                    recognizer: _termsTapRecognizer,
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

class _UfAutocomplete extends StatelessWidget {
  const _UfAutocomplete({required this.initialValue, required this.onSelected});

  final String? initialValue;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      initialValue: TextEditingValue(text: initialValue ?? ''),
      optionsBuilder: (value) {
        final query = value.text.toUpperCase();
        if (query.isEmpty) return _brazilianStates;
        return _brazilianStates.where((uf) => uf.startsWith(query));
      },
      onSelected: onSelected,
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          textCapitalization: TextCapitalization.characters,
          inputFormatters: [
            LengthLimitingTextInputFormatter(2),
            _UppercaseFormatter(),
          ],
          onChanged: (v) {
            if (_brazilianStates.contains(v.toUpperCase())) {
              onSelected(v.toUpperCase());
            }
          },
          style: AppTextStyles.body.copyWith(color: AppColors.black),
          decoration: InputDecoration(
            labelText: 'UF',
            labelStyle: AppTextStyles.textfieldLabel,
            prefixIcon: const Icon(
              Icons.map_outlined,
              color: AppColors.darkGreen,
              size: 20,
            ),
            filled: true,
            fillColor: AppColors.inputBackground,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 18,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.darkGreen,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.red, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.red, width: 1.5),
            ),
          ),
          validator: (value) {
            final v = value?.trim().toUpperCase() ?? '';
            if (!_brazilianStates.contains(v)) return 'UF inválida';
            return null;
          },
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 220, maxWidth: 120),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  return InkWell(
                    onTap: () => onSelected(option),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Text(
                        option,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.black,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _UppercaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
