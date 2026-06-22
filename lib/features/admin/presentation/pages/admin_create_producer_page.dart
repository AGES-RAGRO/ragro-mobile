// Admin create-producer screen (US-31). Backed by POST /admin/producers.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ragro_mobile/core/di/injection.dart';
import 'package:ragro_mobile/core/formatters/input_masks.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/core/validators/cnpj_validator.dart';
import 'package:ragro_mobile/core/validators/cpf_validator.dart';
import 'package:ragro_mobile/features/admin/presentation/bloc/admin_producer_form_bloc.dart';
import 'package:ragro_mobile/features/admin/presentation/bloc/admin_producer_form_event.dart';
import 'package:ragro_mobile/features/admin/presentation/bloc/admin_producer_form_state.dart';
import 'package:ragro_mobile/shared/widgets/producer_form/cep_lookup.dart';
import 'package:ragro_mobile/shared/widgets/producer_form/field_label.dart';
import 'package:ragro_mobile/shared/widgets/producer_form/producer_form_controllers.dart';
import 'package:ragro_mobile/shared/widgets/producer_form/producer_form_sections.dart';
import 'package:ragro_mobile/shared/widgets/producer_form/producer_text_field.dart';

class AdminCreateProducerPage extends StatelessWidget {
  const AdminCreateProducerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AdminProducerFormBloc>(),
      child: const _AdminCreateProducerView(),
    );
  }
}

class _AdminCreateProducerView extends StatefulWidget {
  const _AdminCreateProducerView();

  @override
  State<_AdminCreateProducerView> createState() =>
      _AdminCreateProducerViewState();
}

class _AdminCreateProducerViewState extends State<_AdminCreateProducerView> {
  final _formKey = GlobalKey<FormState>();
  final _c = ProducerFormControllers();

  // Create-only fields
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _termsAccepted = false;

  @override
  void initState() {
    super.initState();
    _c.scheduleStart.text = '08:00';
    _c.scheduleEnd.text = '18:00';
    CepLookup(
      controllers: _c,
      isMounted: () => mounted,
      applyState: setState,
    ).attach();
  }

  // The create flow masks the pix key with the type-specific formatters
  // (CPF/CNPJ) instead of the adaptive FiscalNumberInputFormatter used by
  // the edit flows, so it keeps its own cascade.
  List<TextInputFormatter> _pixKeyFormatters() {
    switch (_c.pixKeyType) {
      case 'cpf':
        return [CpfInputFormatter()];
      case 'cnpj':
        return [CnpjInputFormatter()];
      case 'phone':
        return [PhoneInputFormatter()];
      default:
        return [];
    }
  }

  @override
  void dispose() {
    _c.disposeAll();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    if (!_termsAccepted) {
      _showError('Aceite os Termos de Uso para continuar.');
      return;
    }

    final cleanFiscal = digitsOnly(_c.fiscal.text);
    final fiscalType = cleanFiscal.length == 11 ? 'CPF' : 'CNPJ';

    // PIX is always required
    if (_c.pixKeyType == null) {
      _showError('Selecione o tipo de chave Pix.');
      return;
    }
    if (_c.pixKey.text.trim().isEmpty) {
      _showError('Informe a chave Pix.');
      return;
    }
    final pixKeyType = _c.pixKeyType!;
    final rawPixKey = _c.pixKey.text.trim();
    final pixKey =
        (pixKeyType == 'cpf' || pixKeyType == 'cnpj' || pixKeyType == 'phone')
        ? digitsOnly(rawPixKey)
        : rawPixKey;

    // Bank account is always required
    if (!_c.hasCompleteBank) {
      _showError('Preencha todos os campos obrigatórios da conta bancária.');
      return;
    }
    final bankName = _c.bankName.text.trim();
    final bankCode = _c.bankCode.text.trim().isNotEmpty
        ? _c.bankCode.text.trim()
        : null;
    final agency = _c.agency.text.trim();
    final accountNumber = _c.account.text.trim();
    const accountType = 'checking';
    final accountHolder = _c.holder.text.trim();
    final rawBankFiscal = _c.bankFiscal.text.trim();
    final bankFiscalNumber = rawBankFiscal.isNotEmpty
        ? digitsOnly(rawBankFiscal)
        : null;

    // Availability
    if (!_c.weekdays.any((d) => d)) {
      _showError('Selecione pelo menos um dia de atendimento.');
      return;
    }

    context.read<AdminProducerFormBloc>().add(
      AdminProducerFormSubmitted(
        name: _c.name.text.trim(),
        email: _c.email.text.trim(),
        phone: digitsOnly(_c.phone.text),
        cep: digitsOnly(_c.cep.text),
        address: _c.address.text.trim(),
        number: _c.number.text.trim(),
        neighborhood: _c.neighborhood.text.trim().isNotEmpty
            ? _c.neighborhood.text.trim()
            : null,
        city: _c.city.text.trim(),
        state: _c.state.text.trim(),
        fiscalNumber: cleanFiscal,
        fiscalNumberType: fiscalType,
        farmName: _c.farmName.text.trim(),
        description: _c.description.text.trim(),
        password: _passwordController.text.trim(),
        scheduleWeekdays: List.from(_c.weekdays),
        scheduleStart: _c.scheduleStart.text.trim(),
        scheduleEnd: _c.scheduleEnd.text.trim(),
        pixKeyType: pixKeyType,
        pixKey: pixKey,
        bankName: bankName,
        bankCode: bankCode,
        agency: agency,
        accountNumber: accountNumber,
        accountType: accountType,
        accountHolder: accountHolder,
        bankFiscalNumber: bankFiscalNumber,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminProducerFormBloc, AdminProducerFormState>(
      listener: (context, state) {
        if (state is AdminProducerFormSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Produtor criado com sucesso!'),
              backgroundColor: AppColors.darkGreen,
            ),
          );
          context.pop(true);
        }
        if (state is AdminProducerFormFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AdminProducerFormLoading;
        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: AppBar(
            backgroundColor: AppColors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.black),
              onPressed: () => context.pop(),
            ),
            title: const Text(
              'Criar conta',
              style: TextStyle(
                fontFamily: 'Figtree',
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: AppColors.black,
              ),
            ),
          ),
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FormSectionTitle('Dados Pessoais'),
                  const SizedBox(height: 12),
                  const FieldLabel('Nome Completo'),
                  const SizedBox(height: 8),
                  ProducerTextField(
                    controller: _c.name,
                    hint: 'Nome do produtor',
                    prefixIcon: Icons.person_outline,
                    enabled: !isLoading,
                    validator: (value) {
                      if ((value ?? '').trim().isEmpty) {
                        return 'Informe o nome completo';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  const FieldLabel('CPF / CNPJ'),
                  const SizedBox(height: 8),
                  ProducerTextField(
                    controller: _c.fiscal,
                    hint: '000.000.000-00',
                    prefixIcon: Icons.badge_outlined,
                    keyboardType: TextInputType.number,
                    enabled: !isLoading,
                    inputFormatters: [FiscalNumberInputFormatter()],
                    validator: (value) {
                      final digits = digitsOnly(value ?? '');
                      if (digits.length != 11 && digits.length != 14) {
                        return 'CPF (11) ou CNPJ (14 dígitos)';
                      }
                      if (digits.length == 11 &&
                          !CpfValidator.isValid(digits)) {
                        return 'CPF inválido';
                      }
                      if (digits.length == 14 &&
                          !CnpjValidator.isValid(digits)) {
                        return 'CNPJ inválido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  const FieldLabel('Telefone'),
                  const SizedBox(height: 8),
                  ProducerTextField(
                    controller: _c.phone,
                    hint: '(XX) XXXXX-XXXX',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    enabled: !isLoading,
                    inputFormatters: [PhoneInputFormatter()],
                    validator: (value) {
                      final digits = digitsOnly(value ?? '');
                      if (digits.length != 11) {
                        return 'DDD + número com 11 dígitos';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  const FieldLabel('Email'),
                  const SizedBox(height: 8),
                  ProducerTextField(
                    controller: _c.email,
                    hint: 'email@exemplo.com',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    enabled: !isLoading,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'E-mail obrigatório';
                      }
                      final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                      if (!emailRegex.hasMatch(value)) return 'E-mail inválido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  const FieldLabel('Senha'),
                  const SizedBox(height: 8),
                  ProducerTextField(
                    controller: _passwordController,
                    hint: 'Senha de acesso',
                    prefixIcon: Icons.lock_outline,
                    obscure: true,
                    enabled: !isLoading,
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
                  const SizedBox(height: 12),
                  const FieldLabel('Confirmar Senha'),
                  const SizedBox(height: 8),
                  ProducerTextField(
                    controller: _confirmPasswordController,
                    hint: 'Repita a senha',
                    prefixIcon: Icons.lock_outline,
                    obscure: true,
                    enabled: !isLoading,
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return 'As senhas não coincidem';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  const FieldLabel('Nome da Fazenda'),
                  const SizedBox(height: 8),
                  ProducerTextField(
                    controller: _c.farmName,
                    hint: 'Ex: Fazenda Santa Luzia',
                    prefixIcon: Icons.home_outlined,
                    enabled: !isLoading,
                    validator: (value) {
                      if ((value ?? '').trim().isEmpty) {
                        return 'Informe o nome da fazenda';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  const FieldLabel('Descrição'),
                  const SizedBox(height: 8),
                  ProducerTextField(
                    controller: _c.description,
                    hint: 'Breve descrição sobre o produtor e sua fazenda...',
                    prefixIcon: Icons.description_outlined,
                    enabled: !isLoading,
                    minLines: 1,
                    maxLines: null,
                    maxLength: 1000,
                    validator: (value) {
                      if ((value ?? '').trim().isEmpty) {
                        return 'Informe uma descrição';
                      }
                      if (value!.length > 1000) return 'Máximo 1000 caracteres';
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),
                  const FormSectionTitle('Endereço'),
                  const SizedBox(height: 12),
                  AddressFields(
                    controllers: _c,
                    enabled: !isLoading,
                    cepValidator: (value) {
                      final digits = digitsOnly(value ?? '');
                      if (digits.length != 8) return 'CEP deve ter 8 dígitos';
                      return null;
                    },
                    streetValidator: (value) {
                      if ((value ?? '').trim().isEmpty) {
                        return 'Informe o endereço';
                      }
                      return null;
                    },
                    numberValidator: (value) {
                      if ((value ?? '').trim().isEmpty) {
                        return 'Informe o número';
                      }
                      return null;
                    },
                    neighborhoodValidator: (value) {
                      if ((value ?? '').trim().isEmpty) {
                        return 'Informe o bairro';
                      }
                      return null;
                    },
                    cityValidator: (value) {
                      if ((value ?? '').trim().isEmpty) {
                        return 'Informe a cidade';
                      }
                      return null;
                    },
                    stateValidator: (v) {
                      if ((v ?? '').trim().isEmpty) {
                        return 'UF';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),
                  const FormSectionTitle('Forma de Recebimento'),
                  const SizedBox(height: 8),

                  // PIX (required)
                  PixSectionCard(
                    pixKeyType: _c.pixKeyType,
                    dropdownValue: _c.pixKeyType,
                    pixKeyController: _c.pixKey,
                    keyFormatters: _pixKeyFormatters(),
                    itemTextStyle: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 15,
                    ),
                    dropdownEnabled: !isLoading,
                    fieldEnabled: !isLoading,
                    onTypeChanged: (v) => setState(() {
                      _c.pixKeyType = v;
                      _c.pixKey.clear();
                    }),
                  ),

                  const SizedBox(height: 12),

                  // Bank account (required)
                  BankSectionCard(
                    controllers: _c,
                    enabled: !isLoading,
                    agencyFormatters: [
                      LengthLimitingTextInputFormatter(4),
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),

                  const SizedBox(height: 20),
                  const FormSectionTitle('Horário de atendimento'),
                  const SizedBox(height: 12),
                  WeekdaySelector(
                    selected: _c.weekdays,
                    onToggle: (i) =>
                        setState(() => _c.weekdays[i] = !_c.weekdays[i]),
                  ),
                  const SizedBox(height: 12),
                  ScheduleHoursRow(
                    startController: _c.scheduleStart,
                    endController: _c.scheduleEnd,
                    enabled: !isLoading,
                  ),

                  const SizedBox(height: 20),

                  // Terms
                  GestureDetector(
                    onTap: () =>
                        setState(() => _termsAccepted = !_termsAccepted),
                    child: Row(
                      children: [
                        Checkbox(
                          value: _termsAccepted,
                          onChanged: (v) =>
                              setState(() => _termsAccepted = v ?? false),
                          activeColor: AppColors.darkGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const Expanded(
                          child: Text(
                            'Eu concordo com os Termos de Uso e Política de Privacidade',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 13,
                              color: AppColors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  ProducerFormSubmitButton(
                    label: 'Criar conta',
                    busy: isLoading,
                    onPressed: _submit,
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
