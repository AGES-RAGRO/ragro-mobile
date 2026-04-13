// Screen: Admin Create Producer (Criar Conta Produtor)
// User Story: US-31 — Admin Create Producer Account
// Epic: EPIC 5 — Admin Features
// Routes: POST /admin/producers

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ragro_mobile/core/di/injection.dart';
import 'package:ragro_mobile/core/formatters/input_masks.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/features/admin/presentation/bloc/admin_producer_form_bloc.dart';
import 'package:ragro_mobile/features/admin/presentation/bloc/admin_producer_form_event.dart';
import 'package:ragro_mobile/core/validators/cnpj_validator.dart';
import 'package:ragro_mobile/core/validators/cpf_validator.dart';
import 'package:ragro_mobile/features/admin/presentation/bloc/admin_producer_form_state.dart';
const List<String> _brazilianStates = [
  'AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA',
  'MT', 'MS', 'MG', 'PA', 'PB', 'PR', 'PE', 'PI', 'RJ', 'RN',
  'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO',
];

const _pixKeyTypes = ['cpf', 'cnpj', 'email', 'phone', 'random'];
const _pixKeyTypeLabels = {
  'cpf': 'CPF',
  'cnpj': 'CNPJ',
  'email': 'E-mail',
  'phone': 'Telefone',
  'random': 'Chave aleatória',
};

const _accountTypes = ['checking', 'savings'];
const _accountTypeLabels = {'checking': 'Corrente', 'savings': 'Poupança'};

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
  // ── Dados Pessoais ─────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _fiscalController = TextEditingController();
  final _farmNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // ── Endereço ───────────────────────────────────────────────────────────
  final _cepController = TextEditingController();
  final _addressController = TextEditingController();
  final _numberController = TextEditingController();
  final _cityController = TextEditingController();
  String? _selectedState;

  // ── Horário ────────────────────────────────────────────────────────────
  final _scheduleStartController = TextEditingController(text: '08:00');
  final _scheduleEndController = TextEditingController(text: '18:00');
  final List<bool> _weekdays = List.filled(7, false);

  // ── Pix (sempre obrigatório) ──────────────────────────────────────────
  String? _pixKeyType;
  final _pixKeyController = TextEditingController();

  // ── Conta Bancária (sempre obrigatório) ───────────────────────────────
  final _bankNameController = TextEditingController();
  final _bankCodeController = TextEditingController();
  final _agencyController = TextEditingController();
  final _accountController = TextEditingController();
  String? _accountType;
  final _holderController = TextEditingController();
  final _bankFiscalController = TextEditingController();

  bool _termsAccepted = false;

  static const _weekdayLabels = [
    'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom',
  ];

  String _digitsOnly(String v) => v.replaceAll(RegExp(r'\D'), '');

  // Retorna o formatter adequado para a chave pix conforme o tipo selecionado
  List<TextInputFormatter> _pixKeyFormatters() {
    switch (_pixKeyType) {
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
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _fiscalController.dispose();
    _farmNameController.dispose();
    _passwordController.dispose();
    _cepController.dispose();
    _addressController.dispose();
    _numberController.dispose();
    _cityController.dispose();
    _scheduleStartController.dispose();
    _scheduleEndController.dispose();
    _pixKeyController.dispose();
    _bankNameController.dispose();
    _bankCodeController.dispose();
    _agencyController.dispose();
    _accountController.dispose();
    _holderController.dispose();
    _bankFiscalController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    if (!_termsAccepted) {
      _showError('Aceite os Termos de Uso para continuar.');
      return;
    }

    final cleanFiscal = _digitsOnly(_fiscalController.text);
    final String fiscalType = cleanFiscal.length == 11 ? 'CPF' : 'CNPJ';

    // PIX sempre obrigatório
    if (_pixKeyType == null) {
      _showError('Selecione o tipo de chave Pix.');
      return;
    }
    if (_pixKeyController.text.trim().isEmpty) {
      _showError('Informe a chave Pix.');
      return;
    }
    final pixKeyType = _pixKeyType!;
    final rawPixKey = _pixKeyController.text.trim();
    final pixKey = (pixKeyType == 'cpf' ||
            pixKeyType == 'cnpj' ||
            pixKeyType == 'phone')
        ? _digitsOnly(rawPixKey)
        : rawPixKey;

    // Conta Bancária sempre obrigatória
    if (_bankNameController.text.trim().isEmpty ||
        _agencyController.text.trim().isEmpty ||
        _accountController.text.trim().isEmpty ||
        _accountType == null ||
        _holderController.text.trim().isEmpty) {
      _showError('Preencha todos os campos obrigatórios da conta bancária.');
      return;
    }
    final bankName = _bankNameController.text.trim();
    final bankCode = _bankCodeController.text.trim().isNotEmpty
        ? _bankCodeController.text.trim()
        : null;
    final agency = _agencyController.text.trim();
    final accountNumber = _accountController.text.trim();
    final accountType = _accountType!;
    final accountHolder = _holderController.text.trim();
    final rawBankFiscal = _bankFiscalController.text.trim();
    final bankFiscalNumber =
        rawBankFiscal.isNotEmpty ? _digitsOnly(rawBankFiscal) : null;

    // Disponibilidade
    if (!_weekdays.any((d) => d)) {
      _showError('Selecione pelo menos um dia de atendimento.');
      return;
    }

    context.read<AdminProducerFormBloc>().add(
          AdminProducerFormSubmitted(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            phone: _digitsOnly(_phoneController.text),
            cep: _digitsOnly(_cepController.text),
            address: _addressController.text.trim(),
            number: _numberController.text.trim(),
            city: _cityController.text.trim(),
            state: _selectedState ?? '',
            fiscalNumber: cleanFiscal,
            fiscalNumberType: fiscalType,
            farmName: _farmNameController.text.trim(),
            password: _passwordController.text.trim(),
            scheduleWeekdays: List.from(_weekdays),
            scheduleStart: _scheduleStartController.text.trim(),
            scheduleEnd: _scheduleEndController.text.trim(),
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
                // ── Dados Pessoais ─────────────────────────────────────
                _sectionTitle('Dados Pessoais'),
                const SizedBox(height: 12),
                _FieldLabel('Nome Completo'),
                const SizedBox(height: 8),
                _TextField(
                  controller: _nameController,
                  hint: 'Nome do produtor',
                  prefixIcon: Icons.person_outline,
                  enabled: !isLoading,
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) return 'Informe o nome completo';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _FieldLabel('CPF / CNPJ'),
                const SizedBox(height: 8),
                _TextField(
                  controller: _fiscalController,
                  hint: '000.000.000-00',
                  prefixIcon: Icons.badge_outlined,
                  keyboardType: TextInputType.number,
                  enabled: !isLoading,
                  inputFormatters: [FiscalNumberInputFormatter()],
                  validator: (value) {
                    final digits = _digitsOnly(value ?? '');
                    if (digits.length != 11 && digits.length != 14) {
                      return 'CPF (11) ou CNPJ (14 dígitos)';
                    }
                    if (digits.length == 11 && !CpfValidator.isValid(digits)) {
                      return 'CPF inválido';
                    }
                    if (digits.length == 14 && !CnpjValidator.isValid(digits)) {
                      return 'CNPJ inválido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _FieldLabel('Telefone'),
                const SizedBox(height: 8),
                _TextField(
                  controller: _phoneController,
                  hint: '(XX) XXXXX-XXXX',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  enabled: !isLoading,
                  inputFormatters: [PhoneInputFormatter()],
                  validator: (value) {
                    final digits = _digitsOnly(value ?? '');
                    if (digits.length != 11) return 'DDD + número com 11 dígitos';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _FieldLabel('Email'),
                const SizedBox(height: 8),
                _TextField(
                  controller: _emailController,
                  hint: 'email@exemplo.com',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !isLoading,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'E-mail obrigatório';
                    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                    if (!emailRegex.hasMatch(value)) return 'E-mail inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _FieldLabel('Senha'),
                const SizedBox(height: 8),
                _TextField(
                  controller: _passwordController,
                  hint: 'Senha de acesso',
                  prefixIcon: Icons.lock_outline,
                  obscure: true,
                  enabled: !isLoading,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Informe uma senha';
                    if (value.length < 8 || value.length > 50) return 'Entre 8 e 50 caracteres';
                    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).+$').hasMatch(value)) {
                      return 'Inclua maiúscula, minúscula e um número';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _FieldLabel('Confirmar Senha'),
                const SizedBox(height: 8),
                _TextField(
                  controller: _confirmPasswordController,
                  hint: 'Repita a senha',
                  prefixIcon: Icons.lock_outline,
                  obscure: true,
                  enabled: !isLoading,
                  validator: (value) {
                    if (value != _passwordController.text) return 'As senhas não coincidem';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _FieldLabel('Nome da Fazenda'),
                const SizedBox(height: 8),
                _TextField(
                  controller: _farmNameController,
                  hint: 'Ex: Fazenda Santa Luzia',
                  prefixIcon: Icons.home_outlined,
                  enabled: !isLoading,
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) return 'Informe o nome da fazenda';
                    return null;
                  },
                ),

                // ── Endereço ───────────────────────────────────────────
                const SizedBox(height: 20),
                _sectionTitle('Endereço'),
                const SizedBox(height: 12),
                _FieldLabel('CEP'),
                const SizedBox(height: 8),
                _TextField(
                  controller: _cepController,
                  hint: '00000-000',
                  prefixIcon: Icons.location_on_outlined,
                  keyboardType: TextInputType.number,
                  enabled: !isLoading,
                  inputFormatters: [CepInputFormatter()],
                  validator: (value) {
                    final digits = _digitsOnly(value ?? '');
                    if (digits.length != 8) return 'CEP deve ter 8 dígitos';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _FieldLabel('Endereço'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: _TextField(
                        controller: _addressController,
                        hint: 'Rua / Avenida',
                        prefixIcon: Icons.location_on_outlined,
                        enabled: !isLoading,
                        validator: (value) {
                          if ((value ?? '').trim().isEmpty) return 'Informe o endereço';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _TextField(
                        controller: _numberController,
                        hint: 'Nº',
                        keyboardType: TextInputType.number,
                        enabled: !isLoading,
                        validator: (value) {
                          if ((value ?? '').trim().isEmpty) return 'Informe o número';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FieldLabel('Cidade'),
                          const SizedBox(height: 8),
                          _TextField(
                            controller: _cityController,
                            hint: 'Cidade',
                            prefixIcon: Icons.location_city_outlined,
                            enabled: !isLoading,
                            validator: (value) {
                              if ((value ?? '').trim().isEmpty) return 'Informe a cidade';
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FieldLabel('Estado'),
                          const SizedBox(height: 8),
                          _UfAutocomplete(
                            initialValue: _selectedState,
                            onSelected: (uf) =>
                                setState(() => _selectedState = uf),
                            enabled: !isLoading,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // ── Forma de Recebimento ───────────────────────────────
                const SizedBox(height: 20),
                _sectionTitle('Forma de Recebimento'),
                const SizedBox(height: 8),

                // PIX (obrigatório)
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.inputBorder),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Chave PIX',
                          style: TextStyle(
                            fontFamily: 'Figtree',
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: AppColors.darkGreen,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _FieldLabel('Tipo da chave'),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _pixKeyType,
                          decoration: _dropdownDecoration(),
                          hint: const Text(
                            'Selecione',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 15,
                              color: AppColors.placeholder,
                            ),
                          ),
                          items: _pixKeyTypes
                              .map(
                                (t) => DropdownMenuItem(
                                  value: t,
                                  child: Text(
                                    _pixKeyTypeLabels[t] ?? t,
                                    style: const TextStyle(
                                      fontFamily: 'Manrope',
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: isLoading
                              ? null
                              : (v) => setState(() {
                                    _pixKeyType = v;
                                    _pixKeyController.clear();
                                  }),
                        ),
                        if (_pixKeyType != null) ...[
                          const SizedBox(height: 12),
                          _FieldLabel('Chave Pix'),
                          const SizedBox(height: 8),
                          _TextField(
                            key: ValueKey(_pixKeyType),
                            controller: _pixKeyController,
                            hint: _pixKeyHint(_pixKeyType!),
                            keyboardType: _pixKeyboardType(_pixKeyType!),
                            enabled: !isLoading,
                            inputFormatters: _pixKeyFormatters(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Conta Bancária (obrigatória)
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.inputBorder),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Conta Bancária',
                          style: TextStyle(
                            fontFamily: 'Figtree',
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: AppColors.darkGreen,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _FieldLabel('Banco'),
                        const SizedBox(height: 8),
                        _TextField(
                          controller: _bankNameController,
                          hint: 'Nome do banco',
                          prefixIcon: Icons.account_balance_outlined,
                          enabled: !isLoading,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _FieldLabel('Código (3 dígitos)'),
                                  const SizedBox(height: 8),
                                  _TextField(
                                    controller: _bankCodeController,
                                    hint: '001',
                                    keyboardType: TextInputType.number,
                                    enabled: !isLoading,
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(3),
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _FieldLabel('Agência'),
                                  const SizedBox(height: 8),
                                  _TextField(
                                    controller: _agencyController,
                                    hint: '0000',
                                    keyboardType: TextInputType.number,
                                    enabled: !isLoading,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _FieldLabel('Conta'),
                        const SizedBox(height: 8),
                        _TextField(
                          controller: _accountController,
                          hint: '000000-0',
                          enabled: !isLoading,
                        ),
                        const SizedBox(height: 12),
                        _FieldLabel('Tipo de Conta'),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _accountType,
                          decoration: _dropdownDecoration(),
                          hint: const Text(
                            'Selecione',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 15,
                              color: AppColors.placeholder,
                            ),
                          ),
                          items: _accountTypes
                              .map(
                                (t) => DropdownMenuItem(
                                  value: t,
                                  child: Text(
                                    _accountTypeLabels[t] ?? t,
                                    style: const TextStyle(
                                      fontFamily: 'Manrope',
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: isLoading
                              ? null
                              : (v) => setState(() => _accountType = v),
                        ),
                        const SizedBox(height: 12),
                        _FieldLabel('Titular'),
                        const SizedBox(height: 8),
                        _TextField(
                          controller: _holderController,
                          hint: 'Nome completo do titular',
                          prefixIcon: Icons.account_circle_outlined,
                          enabled: !isLoading,
                        ),
                        const SizedBox(height: 12),
                        _FieldLabel('CPF / CNPJ do Titular (opcional)'),
                        const SizedBox(height: 8),
                        _TextField(
                          controller: _bankFiscalController,
                          hint: '000.000.000-00',
                          prefixIcon: Icons.badge_outlined,
                          keyboardType: TextInputType.number,
                          enabled: !isLoading,
                          inputFormatters: [FiscalNumberInputFormatter()],
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Horário de Atendimento ─────────────────────────────
                const SizedBox(height: 20),
                _sectionTitle('Horário de atendimento'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: List.generate(7, (i) {
                    final isSelected = _weekdays[i];
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _weekdays[i] = !_weekdays[i]),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.darkGreen
                              : AppColors.inputBackground,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _weekdayLabels[i],
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: isSelected
                                ? AppColors.white
                                : AppColors.placeholder,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FieldLabel('Início'),
                          const SizedBox(height: 8),
                          _TextField(
                            controller: _scheduleStartController,
                            hint: '08:00',
                            prefixIcon: Icons.schedule_outlined,
                            keyboardType: TextInputType.datetime,
                            enabled: !isLoading,
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding:
                          EdgeInsets.only(top: 28, left: 12, right: 12),
                      child: Icon(
                        Icons.arrow_forward,
                        color: AppColors.placeholder,
                        size: 18,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FieldLabel('Fim'),
                          const SizedBox(height: 8),
                          _TextField(
                            controller: _scheduleEndController,
                            hint: '18:00',
                            prefixIcon: Icons.schedule_outlined,
                            keyboardType: TextInputType.datetime,
                            enabled: !isLoading,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Termos
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

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkGreen,
                      foregroundColor: AppColors.white,
                      disabledBackgroundColor:
                          AppColors.darkGreen.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.white,
                            ),
                          )
                        : const Text(
                            'Criar conta',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                  ),
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

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.inputBackground,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.inputBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.inputBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkGreen, width: 1.5),
      ),
    );
  }

  String _pixKeyHint(String type) {
    return switch (type) {
      'cpf' => '000.000.000-00',
      'cnpj' => '00.000.000/0000-00',
      'email' => 'email@exemplo.com',
      'phone' => '(XX) XXXXX-XXXX',
      _ => 'Chave aleatória',
    };
  }

  TextInputType _pixKeyboardType(String type) {
    return switch (type) {
      'cpf' || 'cnpj' || 'phone' => TextInputType.number,
      'email' => TextInputType.emailAddress,
      _ => TextInputType.text,
    };
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Figtree',
        fontWeight: FontWeight.w700,
        fontSize: 17,
        color: AppColors.darkGreen,
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Manrope',
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: AppColors.black,
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    super.key,
    required this.controller,
    required this.hint,
    this.prefixIcon,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.enabled = true,
    this.obscure = false,
    this.inputFormatters,
    this.validator,
  });

  final TextEditingController controller;
  final String hint;
  final IconData? prefixIcon;
  final int maxLines;
  final TextInputType keyboardType;
  final bool enabled;
  final bool obscure;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      enabled: enabled,
      obscureText: obscure,
      inputFormatters: inputFormatters,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          fontFamily: 'Figtree',
          fontSize: 17,
          color: AppColors.placeholder,
        ),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, size: 20, color: AppColors.placeholder)
            : null,
        filled: true,
        fillColor: AppColors.inputBackground,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide:
              const BorderSide(color: AppColors.darkGreen, width: 1.5),
        ),
      ),
      style: const TextStyle(
        fontFamily: 'Figtree',
        fontSize: 17,
        color: AppColors.black,
      ),
    );
  }
}

class _UfAutocomplete extends StatelessWidget {
  const _UfAutocomplete({
    required this.initialValue,
    required this.onSelected,
    this.enabled = true,
  });

  final String? initialValue;
  final ValueChanged<String> onSelected;
  final bool enabled;

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
        return TextField(
          controller: controller,
          focusNode: focusNode,
          enabled: enabled,
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
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 15,
            color: AppColors.black,
          ),
          decoration: InputDecoration(
            hintText: 'UF',
            hintStyle: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 15,
              color: AppColors.placeholder,
            ),
            filled: true,
            fillColor: AppColors.inputBackground,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.inputBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.darkGreen, width: 1.5),
            ),
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 110,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final uf = options.elementAt(index);
                  return ListTile(
                    dense: true,
                    title: Text(
                      uf,
                      style: const TextStyle(fontFamily: 'Manrope'),
                    ),
                    onTap: () => onSelected(uf),
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
  ) =>
      newValue.copyWith(text: newValue.text.toUpperCase());
}
