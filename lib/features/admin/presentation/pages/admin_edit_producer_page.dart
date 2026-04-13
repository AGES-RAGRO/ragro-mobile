// Screen: Admin Edit Producer (Editar Conta Produtor)
// User Story: US-30 — Admin Manage Producers
// Epic: EPIC 5 — Admin Features
// Routes: PUT /admin/producers/{id}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ragro_mobile/core/di/injection.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/features/admin/domain/entities/admin_producer.dart';
import 'package:ragro_mobile/features/admin/presentation/bloc/admin_edit_producer_bloc.dart';
import 'package:ragro_mobile/features/admin/presentation/bloc/admin_edit_producer_event.dart';
import 'package:ragro_mobile/features/admin/presentation/bloc/admin_edit_producer_state.dart';

class AdminEditProducerPage extends StatelessWidget {
  const AdminEditProducerPage({super.key, required this.producerId});

  final String producerId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AdminEditProducerBloc>()
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
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _cepController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _bankController = TextEditingController();
  final _agencyController = TextEditingController();
  final _accountController = TextEditingController();
  final _holderController = TextEditingController();
  final _cpfCnpjController = TextEditingController();
  final _scheduleStartController = TextEditingController();
  final _scheduleEndController = TextEditingController();

  final List<bool> _weekdays = List.filled(7, false);

  // Snapshot dos valores originais para detectar alterações
  late AdminProducer _original;
  bool _controllersInitialized = false;

  static const _weekdayLabels = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _cepController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _bankController.dispose();
    _agencyController.dispose();
    _accountController.dispose();
    _holderController.dispose();
    _cpfCnpjController.dispose();
    _scheduleStartController.dispose();
    _scheduleEndController.dispose();
    super.dispose();
  }

  void _fillControllers(AdminProducer producer) {
    _original = producer;
    _nameController.text = producer.name;
    _phoneController.text = producer.phone;
    _emailController.text = producer.email;
    _cepController.text = producer.producerAddress?.zipCode ?? '';
    _addressController.text = producer.producerAddress?.street ?? '';
    _cityController.text = producer.producerAddress?.city ?? '';
    _stateController.text = producer.producerAddress?.state ?? '';
    _bankController.text = producer.bankAccount?.bankName ?? '';
    _agencyController.text = producer.bankAccount?.agency ?? '';
    _accountController.text = producer.bankAccount?.accountNumber ?? '';
    _holderController.text = producer.bankAccount?.holderName ?? '';
    _cpfCnpjController.text = producer.fiscalNumber;
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
    return _nameController.text != _original.name ||
        _phoneController.text != _original.phone ||
        _emailController.text != _original.email ||
        _cepController.text != (_original.producerAddress?.zipCode ?? '') ||
        _addressController.text != (_original.producerAddress?.street ?? '') ||
        _cityController.text != (_original.producerAddress?.city ?? '') ||
        _stateController.text != (_original.producerAddress?.state ?? '') ||
        _bankController.text != (_original.bankAccount?.bankName ?? '') ||
        _agencyController.text != (_original.bankAccount?.agency ?? '') ||
        _accountController.text != (_original.bankAccount?.accountNumber ?? '') ||
        _holderController.text != (_original.bankAccount?.holderName ?? '') ||
        _cpfCnpjController.text != _original.fiscalNumber;
  }

  bool _listEquals(List<bool> a, List<bool> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
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

  Future<void> _confirmAndSubmit() async {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha os campos obrigatórios.'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Salvar alterações?',
          style: TextStyle(
            fontFamily: 'Figtree',
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: AppColors.black,
          ),
        ),
        content: const Text(
          'As informações do produtor serão atualizadas.',
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
              'Cancelar',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w600,
                color: AppColors.placeholder,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Confirmar',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w600,
                color: AppColors.darkGreen,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    if (!mounted) return;
    context.read<AdminEditProducerBloc>().add(
          AdminEditProducerSubmitted(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            phone: _phoneController.text.trim(),
            cep: _cepController.text.trim(),
            address: _addressController.text.trim(),
            city: _cityController.text.trim(),
            state: _stateController.text.trim(),
            bank: _bankController.text.trim(),
            agency: _agencyController.text.trim(),
            account: _accountController.text.trim(),
            accountHolder: _holderController.text.trim(),
            cpfCnpj: _cpfCnpjController.text.trim(),
            scheduleWeekdays: List.from(_weekdays),
            scheduleStart: _scheduleStartController.text.trim(),
            scheduleEnd: _scheduleEndController.text.trim(),
          ),
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
        final isReady = state is AdminEditProducerLoaded ||
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
                    child: CircularProgressIndicator(color: AppColors.darkGreen),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Dados Pessoais'),
          const SizedBox(height: 12),
          _FieldLabel('Nome Completo'),
          const SizedBox(height: 8),
          _FormTextField(
              controller: _nameController,
              hint: 'Nome do produtor',
              enabled: !isSaving),
          const SizedBox(height: 12),
          _FieldLabel('Telefone'),
          const SizedBox(height: 8),
          _FormTextField(
              controller: _phoneController,
              hint: '(XX) XXXXX-XXXX',
              keyboardType: TextInputType.phone,
              enabled: !isSaving),
          const SizedBox(height: 12),
          _FieldLabel('Email'),
          const SizedBox(height: 8),
          _FormTextField(
              controller: _emailController,
              hint: 'email@exemplo.com',
              keyboardType: TextInputType.emailAddress,
              enabled: !isSaving),
          const SizedBox(height: 12),
          _FieldLabel('CPF / CNPJ'),
          const SizedBox(height: 8),
          _FormTextField(
              controller: _cpfCnpjController,
              hint: '000.000.000-00',
              keyboardType: TextInputType.number,
              enabled: !isSaving),

          const SizedBox(height: 20),
          _sectionTitle('Endereço'),
          const SizedBox(height: 12),
          _FieldLabel('CEP'),
          const SizedBox(height: 8),
          _FormTextField(
              controller: _cepController,
              hint: '00000-000',
              keyboardType: TextInputType.number,
              enabled: !isSaving),
          const SizedBox(height: 12),
          _FieldLabel('Endereço'),
          const SizedBox(height: 8),
          _FormTextField(
              controller: _addressController,
              hint: 'Rua, número, bairro',
              enabled: !isSaving),
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
                    _FormTextField(
                        controller: _cityController,
                        hint: 'Cidade',
                        enabled: !isSaving),
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
                    _FormTextField(
                        controller: _stateController,
                        hint: 'UF',
                        enabled: !isSaving),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          _sectionTitle('Dados Bancários'),
          const SizedBox(height: 12),
          _FieldLabel('Banco'),
          const SizedBox(height: 8),
          _FormTextField(
              controller: _bankController,
              hint: 'Nome do banco',
              enabled: !isSaving),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel('Agência'),
                    const SizedBox(height: 8),
                    _FormTextField(
                        controller: _agencyController,
                        hint: '0000',
                        keyboardType: TextInputType.number,
                        enabled: !isSaving),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel('Conta'),
                    const SizedBox(height: 8),
                    _FormTextField(
                        controller: _accountController,
                        hint: '000000-0',
                        keyboardType: TextInputType.number,
                        enabled: !isSaving),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _FieldLabel('Nome do Titular'),
          const SizedBox(height: 8),
          _FormTextField(
              controller: _holderController,
              hint: 'Nome completo do titular',
              enabled: !isSaving),

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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                    _FormTextField(
                        controller: _scheduleStartController,
                        hint: '08:00',
                        keyboardType: TextInputType.datetime,
                        enabled: !isSaving),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 28, left: 12, right: 12),
                child: Icon(Icons.arrow_forward,
                    color: AppColors.placeholder, size: 18),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel('Fim'),
                    const SizedBox(height: 8),
                    _FormTextField(
                        controller: _scheduleEndController,
                        hint: '18:00',
                        keyboardType: TextInputType.datetime,
                        enabled: !isSaving),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isSaving ? null : _confirmAndSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkGreen,
                foregroundColor: AppColors.white,
                disabledBackgroundColor: AppColors.darkGreen.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
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
    );
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

class _FormTextField extends StatelessWidget {
  const _FormTextField({
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: enabled,
      decoration: InputDecoration(
        hintText: hint,
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
          borderSide: const BorderSide(color: AppColors.darkGreen, width: 1.5),
        ),
      ),
      style: const TextStyle(
        fontFamily: 'Manrope',
        fontSize: 15,
        color: AppColors.black,
      ),
    );
  }
}
