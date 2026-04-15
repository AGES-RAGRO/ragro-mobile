// Screen: Admin Edit Producer (Editar Conta Produtor)
// User Story: US-30 — Admin Manage Producers
// Epic: EPIC 5 — Admin Features
// Routes: PUT /admin/producers/{id}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ragro_mobile/core/di/injection.dart';
import 'package:ragro_mobile/core/formatters/input_masks.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/features/admin/domain/entities/admin_producer.dart';
import 'package:ragro_mobile/features/admin/presentation/bloc/admin_edit_producer_bloc.dart';
import 'package:ragro_mobile/features/admin/presentation/bloc/admin_edit_producer_event.dart';
import 'package:ragro_mobile/features/admin/presentation/bloc/admin_edit_producer_state.dart';

const _pixKeyTypes = ['cpf', 'cnpj', 'email', 'phone', 'random'];
const _pixKeyTypeLabels = {
  'cpf': 'CPF',
  'cnpj': 'CNPJ',
  'email': 'E-mail',
  'phone': 'Telefone',
  'random': 'Chave aleatória',
};

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

class AdminEditProducerPage extends StatelessWidget {
  const AdminEditProducerPage({required this.producerId, super.key});

  final String producerId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<AdminEditProducerBloc>()
            ..add(AdminEditProducerLoadRequested(producerId)),
      child: const _AdminEditProducerView(),
    );
  }
}

class _AdminEditProducerView extends StatefulWidget {
  const _AdminEditProducerView();

  @override
  State<_AdminEditProducerView> createState() => _AdminEditProducerViewState();
}

class _AdminEditProducerViewState extends State<_AdminEditProducerView> {
  // ── Formulário ─────────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();

  // ── Dados Pessoais ─────────────────────────────────────────────────────
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _cpfCnpjController = TextEditingController();
  final _farmNameController = TextEditingController();
  final _descriptionController = TextEditingController();

  // ── Endereço ───────────────────────────────────────────────────────────
  final _cepController = TextEditingController();
  final _addressController = TextEditingController();
  final _numberController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _cityController = TextEditingController();
  String? _selectedState;

  // ── PIX (opcional no update — partial) ────────────────────────────────
  String? _pixKeyType;
  final _pixKeyController = TextEditingController();

  // ── Conta Bancária (opcional no update — partial) ──────────────────────
  final _bankNameController = TextEditingController();
  final _bankCodeController = TextEditingController();
  final _agencyController = TextEditingController();
  final _accountController = TextEditingController();
  final _holderController = TextEditingController();
  final _bankFiscalController = TextEditingController();

  // ── Horário ────────────────────────────────────────────────────────────
  final _scheduleStartController = TextEditingController();
  final _scheduleEndController = TextEditingController();
  final List<bool> _weekdays = List.filled(7, false);

  // ── Snapshot para detecção de alterações ──────────────────────────────
  late AdminProducer _original;
  bool _controllersInitialized = false;

  static const _weekdayLabels = [
    'Seg',
    'Ter',
    'Qua',
    'Qui',
    'Sex',
    'Sáb',
    'Dom',
  ];

  String _digitsOnly(String v) => v.replaceAll(RegExp(r'\D'), '');

  List<TextInputFormatter> _pixKeyFormatters() {
    switch (_pixKeyType) {
      case 'cpf':
        return [FiscalNumberInputFormatter()];
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
    _cpfCnpjController.dispose();
    _farmNameController.dispose();
    _descriptionController.dispose();
    _cepController.dispose();
    _addressController.dispose();
    _numberController.dispose();
    _neighborhoodController.dispose();
    _cityController.dispose();
    _pixKeyController.dispose();
    _bankNameController.dispose();
    _bankCodeController.dispose();
    _agencyController.dispose();
    _accountController.dispose();
    _holderController.dispose();
    _bankFiscalController.dispose();
    _scheduleStartController.dispose();
    _scheduleEndController.dispose();
    super.dispose();
  }

  void _fillControllers(AdminProducer producer) {
    _original = producer;

    _nameController.text = producer.name;
    _phoneController.text = producer.phone;
    _emailController.text = producer.email;
    _cpfCnpjController.text = producer.fiscalNumber;
    _farmNameController.text = producer.farmName;
    _descriptionController.text = producer.description;
    _cepController.text = producer.producerAddress?.zipCode ?? '';
    _addressController.text = producer.producerAddress?.street ?? '';
    _numberController.text = producer.producerAddress?.number ?? '';
    _neighborhoodController.text = producer.producerAddress?.neighborhood ?? '';
    _cityController.text = producer.producerAddress?.city ?? '';
    _selectedState = producer.producerAddress?.state;

    // Pre-fill PIX
    final pix = producer.paymentMethods
        ?.where((pm) => pm.type == 'pix')
        .firstOrNull;
    if (pix != null) {
      _pixKeyType = pix.pixKeyType;
      _pixKeyController.text = pix.pixKey ?? '';
    }

    // Pre-fill Conta Bancária
    final bank = producer.paymentMethods
        ?.where((pm) => pm.type == 'bank_account')
        .firstOrNull;
    if (bank != null) {
      _bankNameController.text = bank.bankName ?? '';
      _bankCodeController.text = bank.bankCode ?? '';
      _agencyController.text = bank.agency ?? '';
      _accountController.text = bank.accountNumber ?? '';
      _holderController.text = bank.holderName ?? '';
      _bankFiscalController.text = bank.fiscalNumber ?? '';
    }

    // Pre-fill horário
    _scheduleStartController.text =
        producer.availability?.firstOrNull?.opensAt ?? '';
    _scheduleEndController.text =
        producer.availability?.firstOrNull?.closesAt ?? '';
    for (var i = 0; i < 7; i++) {
      _weekdays[i] = false;
    }
    if (producer.availability != null) {
      for (final slot in producer.availability!) {
        final uiIndex = slot.weekday == 0 ? 6 : slot.weekday - 1;
        if (uiIndex >= 0 && uiIndex < 7) _weekdays[uiIndex] = true;
      }
    }

    _controllersInitialized = true;
  }

  bool _hasChanges() {
    if (!_controllersInitialized) return false;
    final bank = _original.paymentMethods
        ?.where((pm) => pm.type == 'bank_account')
        .firstOrNull;
    final pix = _original.paymentMethods
        ?.where((pm) => pm.type == 'pix')
        .firstOrNull;
    return _nameController.text != _original.name ||
        _phoneController.text != _original.phone ||
        _emailController.text != _original.email ||
        _cepController.text != (_original.producerAddress?.zipCode ?? '') ||
        _addressController.text != (_original.producerAddress?.street ?? '') ||
        _numberController.text != (_original.producerAddress?.number ?? '') ||
        _neighborhoodController.text !=
            (_original.producerAddress?.neighborhood ?? '') ||
        _cityController.text != (_original.producerAddress?.city ?? '') ||
        _selectedState != _original.producerAddress?.state ||
        _pixKeyType != pix?.pixKeyType ||
        _pixKeyController.text != (pix?.pixKey ?? '') ||
        _bankNameController.text != (bank?.bankName ?? '') ||
        _agencyController.text != (bank?.agency ?? '') ||
        _accountController.text != (bank?.accountNumber ?? '') ||
        _holderController.text != (bank?.holderName ?? '') ||
        _farmNameController.text != _original.farmName ||
        _descriptionController.text != _original.description;
  }

  Future<bool> _confirmDiscard() async {
    if (!_hasChanges()) return true;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Descartar alterações?',
          style: TextStyle(
            fontFamily: 'Figtree',
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: AppColors.black,
          ),
        ),
        content: const Text(
          'As alterações feitas não foram salvas e serão perdidas.',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 14,
            color: AppColors.placeholder,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Continuar editando',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w600,
                color: AppColors.darkGreen,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Descartar',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w600,
                color: AppColors.red,
              ),
            ),
          ),
        ],
      ),
    );

    return confirmed ?? false;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    // PIX: inclui apenas se o admin preencheu tipo e chave
    final hasPix =
        _pixKeyType != null && _pixKeyController.text.trim().isNotEmpty;
    String? pixKey;
    if (hasPix) {
      final raw = _pixKeyController.text.trim();
      pixKey = (_pixKeyType == 'cpf' || _pixKeyType == 'phone')
          ? _digitsOnly(raw)
          : raw;
    }

    // Conta Bancária: inclui apenas se o admin preencheu banco, agência, conta e titular
    final hasBank =
        _bankNameController.text.trim().isNotEmpty &&
        _agencyController.text.trim().isNotEmpty &&
        _accountController.text.trim().isNotEmpty &&
        _holderController.text.trim().isNotEmpty;

    if (_bankNameController.text.trim().isNotEmpty && !hasBank) {
      _showError(
        'Preencha agência, conta e titular para salvar os dados bancários.',
      );
      return;
    }

    context.read<AdminEditProducerBloc>().add(
      AdminEditProducerSubmitted(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _digitsOnly(_phoneController.text),
        cep: _digitsOnly(_cepController.text),
        address: _addressController.text.trim(),
        number: _numberController.text.trim(),
        neighborhood: _neighborhoodController.text.trim().isNotEmpty
            ? _neighborhoodController.text.trim()
            : null,
        city: _cityController.text.trim(),
        state: _selectedState ?? '',
        cpfCnpj: _cpfCnpjController.text.trim(),
        farmName: _farmNameController.text.trim(),
        description: _descriptionController.text.trim(),
        scheduleWeekdays: List.from(_weekdays),
        scheduleStart: _scheduleStartController.text.trim(),
        scheduleEnd: _scheduleEndController.text.trim(),
        // PIX (opcional)
        pixKeyType: hasPix ? _pixKeyType : null,
        pixKey: hasPix ? pixKey : null,
        // Conta Bancária (opcional)
        bankName: hasBank ? _bankNameController.text.trim() : null,
        bankCode: _bankCodeController.text.trim().isNotEmpty
            ? _bankCodeController.text.trim()
            : null,
        agency: hasBank ? _agencyController.text.trim() : null,
        accountNumber: hasBank ? _accountController.text.trim() : null,
        accountType: hasBank ? 'checking' : null,
        accountHolder: hasBank ? _holderController.text.trim() : null,
        bankFiscalNumber: _bankFiscalController.text.trim().isNotEmpty
            ? _digitsOnly(_bankFiscalController.text)
            : null,
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
    return BlocConsumer<AdminEditProducerBloc, AdminEditProducerState>(
      listener: (context, state) {
        if (state is AdminEditProducerLoaded && !_controllersInitialized) {
          setState(() => _fillControllers(state.producer));
        }
        if (state is AdminEditProducerSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Produtor atualizado com sucesso!'),
              backgroundColor: AppColors.darkGreen,
            ),
          );
          context.pop();
        }
        if (state is AdminEditProducerFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AdminEditProducerLoading;
        final isSaving = state is AdminEditProducerSaving;
        final isReady =
            state is AdminEditProducerLoaded ||
            state is AdminEditProducerSaving ||
            state is AdminEditProducerFailure;

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            final shouldPop = await _confirmDiscard();
            if (shouldPop && context.mounted) context.pop();
          },
          child: Scaffold(
            backgroundColor: AppColors.white,
            appBar: AppBar(
              backgroundColor: AppColors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.black),
                onPressed: () async {
                  final shouldPop = await _confirmDiscard();
                  if (shouldPop && context.mounted) context.pop();
                },
              ),
              title: const Text(
                'Editar produtor',
                style: TextStyle(
                  fontFamily: 'Figtree',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: AppColors.black,
                ),
              ),
            ),
            body: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.darkGreen,
                    ),
                  )
                : isReady
                ? _buildForm(isSaving)
                : const SizedBox.shrink(),
          ),
        );
      },
    );
  }

  Widget _buildForm(bool isSaving) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Dados Pessoais ─────────────────────────────────────────
            _sectionTitle('Dados Pessoais'),
            const SizedBox(height: 12),
            const _FieldLabel('Nome Completo'),
            const SizedBox(height: 8),
            _TextField(
              controller: _nameController,
              hint: 'Nome do produtor',
              prefixIcon: Icons.person_outline,
              enabled: !isSaving,
              validator: (value) {
                if ((value ?? '').trim().isEmpty) {
                  return 'Informe o nome completo';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            const _FieldLabel('Telefone'),
            const SizedBox(height: 8),
            _TextField(
              controller: _phoneController,
              hint: '(XX) XXXXX-XXXX',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              enabled: !isSaving,
              inputFormatters: [PhoneInputFormatter()],
              validator: (value) {
                if (value == null || value.isEmpty) return null; // partial
                final digits = _digitsOnly(value);
                if (digits.length != 11) return 'DDD + número com 11 dígitos';
                return null;
              },
            ),
            const SizedBox(height: 12),
            const _FieldLabel('Email'),
            const SizedBox(height: 8),
            _TextField(
              controller: _emailController,
              hint: 'email@exemplo.com',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              enabled: !isSaving,
              validator: (value) {
                if (value == null || value.isEmpty) return null; // partial
                final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                if (!emailRegex.hasMatch(value)) return 'E-mail inválido';
                return null;
              },
            ),
            const SizedBox(height: 12),
            const _FieldLabel('CPF / CNPJ'),
            const SizedBox(height: 8),
            _TextField(
              controller: _cpfCnpjController,
              hint: '000.000.000-00',
              prefixIcon: Icons.badge_outlined,
              keyboardType: TextInputType.number,
              enabled: !isSaving,
            ),
            const SizedBox(height: 12),
            const _FieldLabel('Nome da Fazenda'),
            const SizedBox(height: 8),
            _TextField(
              controller: _farmNameController,
              hint: 'Ex: Fazenda Santa Luzia',
              prefixIcon: Icons.home_outlined,
              enabled: !isSaving,
              validator: (value) {
                if ((value ?? '').trim().isEmpty) {
                  return 'Informe o nome da fazenda';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            const _FieldLabel('Descrição'),
            const SizedBox(height: 8),
            _TextField(
              controller: _descriptionController,
              hint: 'Breve descrição sobre o produtor...',
              prefixIcon: Icons.description_outlined,
              enabled: !isSaving,
              minLines: 1,
              maxLines: null,
              maxLength: 1000,
            ),

            // ── Endereço ───────────────────────────────────────────────
            const SizedBox(height: 20),
            _sectionTitle('Endereço'),
            const SizedBox(height: 12),
            const _FieldLabel('CEP'),
            const SizedBox(height: 8),
            _TextField(
              controller: _cepController,
              hint: '00000-000',
              prefixIcon: Icons.location_on_outlined,
              keyboardType: TextInputType.number,
              enabled: !isSaving,
              inputFormatters: [CepInputFormatter()],
              validator: (value) {
                if (value == null || value.isEmpty) return null; // partial
                final digits = _digitsOnly(value);
                if (digits.length != 8) return 'CEP deve ter 8 dígitos';
                return null;
              },
            ),
            const SizedBox(height: 12),
            const _FieldLabel('Endereço'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _TextField(
                    controller: _addressController,
                    hint: 'Rua / Avenida',
                    prefixIcon: Icons.location_on_outlined,
                    enabled: !isSaving,
                    validator: (value) {
                      if ((value ?? '').trim().isEmpty) {
                        return 'Informe o endereço';
                      }
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
                    enabled: !isSaving,
                    validator: (value) {
                      if ((value ?? '').trim().isEmpty) {
                        return 'Informe o nº';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const _FieldLabel('Bairro (opcional)'),
            const SizedBox(height: 8),
            _TextField(
              controller: _neighborhoodController,
              hint: 'Bairro',
              prefixIcon: Icons.map_outlined,
              enabled: !isSaving,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _FieldLabel('Cidade'),
                      const SizedBox(height: 8),
                      _TextField(
                        controller: _cityController,
                        hint: 'Cidade',
                        prefixIcon: Icons.location_city_outlined,
                        enabled: !isSaving,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _FieldLabel('Estado'),
                      const SizedBox(height: 8),
                      _UfAutocomplete(
                        initialValue: _selectedState,
                        onSelected: (uf) => setState(() => _selectedState = uf),
                        enabled: !isSaving,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // ── Forma de Recebimento (parcial — opcional) ──────────────
            const SizedBox(height: 20),
            _sectionTitle('Forma de Recebimento'),
            const SizedBox(height: 4),
            const Text(
              'Preencha apenas os campos que deseja atualizar.',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 13,
                color: AppColors.placeholder,
              ),
            ),
            const SizedBox(height: 12),

            // PIX
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
                    const _FieldLabel('Tipo da chave'),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _pixKeyType,
                      decoration: _dropdownDecoration(),
                      hint: const Text(
                        'Selecione (opcional)',
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
                      onChanged: isSaving
                          ? null
                          : (v) => setState(() {
                              _pixKeyType = v;
                              _pixKeyController.clear();
                            }),
                    ),
                    if (_pixKeyType != null) ...[
                      const SizedBox(height: 12),
                      const _FieldLabel('Chave Pix'),
                      const SizedBox(height: 8),
                      _TextField(
                        key: ValueKey(_pixKeyType),
                        controller: _pixKeyController,
                        hint: _pixKeyHint(_pixKeyType!),
                        keyboardType: _pixKeyboardType(_pixKeyType!),
                        enabled: !isSaving,
                        inputFormatters: _pixKeyFormatters(),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Conta Bancária
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
                    const _FieldLabel('Banco'),
                    const SizedBox(height: 8),
                    _TextField(
                      controller: _bankNameController,
                      hint: 'Nome do banco',
                      prefixIcon: Icons.account_balance_outlined,
                      enabled: !isSaving,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _FieldLabel('Código (3 dígitos)'),
                              const SizedBox(height: 8),
                              _TextField(
                                controller: _bankCodeController,
                                hint: '001',
                                keyboardType: TextInputType.number,
                                enabled: !isSaving,
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
                              const _FieldLabel('Agência'),
                              const SizedBox(height: 8),
                              _TextField(
                                controller: _agencyController,
                                hint: '0000',
                                keyboardType: TextInputType.number,
                                enabled: !isSaving,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const _FieldLabel('Conta'),
                    const SizedBox(height: 8),
                    _TextField(
                      controller: _accountController,
                      hint: '000000-0',
                      enabled: !isSaving,
                    ),
                    const SizedBox(height: 12),
                    const _FieldLabel('Titular'),
                    const SizedBox(height: 8),
                    _TextField(
                      controller: _holderController,
                      hint: 'Nome completo do titular',
                      prefixIcon: Icons.account_circle_outlined,
                      enabled: !isSaving,
                    ),
                    const SizedBox(height: 12),
                    const _FieldLabel('CPF / CNPJ do Titular (opcional)'),
                    const SizedBox(height: 8),
                    _TextField(
                      controller: _bankFiscalController,
                      hint: '000.000.000-00',
                      prefixIcon: Icons.badge_outlined,
                      keyboardType: TextInputType.number,
                      enabled: !isSaving,
                      inputFormatters: [FiscalNumberInputFormatter()],
                    ),
                  ],
                ),
              ),
            ),

            // ── Horário de Atendimento ─────────────────────────────────
            const SizedBox(height: 20),
            _sectionTitle('Horário de atendimento'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: List.generate(7, (i) {
                final isSelected = _weekdays[i];
                return GestureDetector(
                  onTap: isSaving
                      ? null
                      : () => setState(() => _weekdays[i] = !_weekdays[i]),
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
                      const _FieldLabel('Início'),
                      const SizedBox(height: 8),
                      _TextField(
                        controller: _scheduleStartController,
                        hint: '08:00',
                        prefixIcon: Icons.schedule_outlined,
                        keyboardType: TextInputType.datetime,
                        enabled: !isSaving,
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 28, left: 12, right: 12),
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
                      const _FieldLabel('Fim'),
                      const SizedBox(height: 8),
                      _TextField(
                        controller: _scheduleEndController,
                        hint: '18:00',
                        prefixIcon: Icons.schedule_outlined,
                        keyboardType: TextInputType.datetime,
                        enabled: !isSaving,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSaving ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkGreen,
                  foregroundColor: AppColors.white,
                  disabledBackgroundColor: AppColors.darkGreen.withValues(
                    alpha: 0.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : const Text(
                        'Salvar alterações',
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
    );
  }

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.inputBackground,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
    required this.controller,
    required this.hint,
    super.key,
    this.prefixIcon,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.keyboardType = TextInputType.text,
    this.enabled = true,
    this.inputFormatters,
    this.validator,
  });

  final TextEditingController controller;
  final String hint;
  final IconData? prefixIcon;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final TextInputType keyboardType;
  final bool enabled;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      enabled: enabled,
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
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
          borderSide: const BorderSide(color: AppColors.darkGreen, width: 1.5),
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
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
              borderSide: const BorderSide(
                color: AppColors.darkGreen,
                width: 1.5,
              ),
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
  ) => newValue.copyWith(text: newValue.text.toUpperCase());
}
