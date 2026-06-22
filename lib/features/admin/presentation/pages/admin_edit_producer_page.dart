// Admin edit-producer screen (US-30). Backed by PUT /admin/producers/{id}.

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
import 'package:ragro_mobile/shared/widgets/producer_form/cep_lookup.dart';
import 'package:ragro_mobile/shared/widgets/producer_form/field_label.dart';
import 'package:ragro_mobile/shared/widgets/producer_form/pix_mask.dart';
import 'package:ragro_mobile/shared/widgets/producer_form/producer_form_controllers.dart';
import 'package:ragro_mobile/shared/widgets/producer_form/producer_form_sections.dart';
import 'package:ragro_mobile/shared/widgets/producer_form/producer_text_field.dart';

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
  final _formKey = GlobalKey<FormState>();
  final _c = ProducerFormControllers();

  // Snapshot used to detect changes
  late AdminProducer _original;
  bool _controllersInitialized = false;

  @override
  void initState() {
    super.initState();
    CepLookup(
      controllers: _c,
      isMounted: () => mounted,
      applyState: setState,
    ).attach();
  }

  @override
  void dispose() {
    _c.disposeAll();
    super.dispose();
  }

  void _fillControllers(AdminProducer producer) {
    _original = producer;
    _c.hydrateFromAdminProducer(producer);
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
    return _c.name.text != _original.name ||
        _c.phone.text != _original.phone ||
        _c.email.text != _original.email ||
        _c.cep.text != (_original.producerAddress?.zipCode ?? '') ||
        _c.address.text != (_original.producerAddress?.street ?? '') ||
        _c.number.text != (_original.producerAddress?.number ?? '') ||
        _c.neighborhood.text !=
            (_original.producerAddress?.neighborhood ?? '') ||
        _c.city.text != (_original.producerAddress?.city ?? '') ||
        _c.state.text != (_original.producerAddress?.state ?? '') ||
        _c.pixKeyType != pix?.pixKeyType ||
        _c.pixKey.text != (pix?.pixKey ?? '') ||
        _c.bankName.text != (bank?.bankName ?? '') ||
        _c.agency.text != (bank?.agency ?? '') ||
        _c.account.text != (bank?.accountNumber ?? '') ||
        _c.holder.text != (bank?.holderName ?? '') ||
        _c.farmName.text != _original.farmName ||
        _c.description.text != _original.description;
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

    // Include PIX only if the admin filled in both type and key
    final hasPix = _c.pixKeyType != null && _c.pixKey.text.trim().isNotEmpty;
    String? pixKey;
    if (hasPix) {
      final raw = _c.pixKey.text.trim();
      pixKey =
          (_c.pixKeyType == 'cpf' ||
              _c.pixKeyType == 'phone' ||
              _c.pixKeyType == 'cnpj')
          ? digitsOnly(raw)
          : raw;
    }

    // Include the bank account only if bank, agency, account and holder are filled
    final hasBank = _c.hasCompleteBank;

    if (_c.bankName.text.trim().isNotEmpty && !hasBank) {
      _showError(
        'Preencha agência, conta e titular para salvar os dados bancários.',
      );
      return;
    }

    context.read<AdminEditProducerBloc>().add(
      AdminEditProducerSubmitted(
        name: _c.name.text.trim(),
        email: _c.email.text.trim(),
        phone: digitsOnly(_c.phone.text),
        cep: digitsOnly(_c.cep.text),
        address: _c.address.text.trim(),
        number: _c.number.text.trim(),
        neighborhood: _c.neighborhood.text.trim(),
        city: _c.city.text.trim(),
        state: _c.state.text.trim(),
        cpfCnpj: _c.fiscal.text.trim(),
        farmName: _c.farmName.text.trim(),
        description: _c.description.text.trim(),
        scheduleWeekdays: List.from(_c.weekdays),
        scheduleStart: _c.scheduleStart.text.trim(),
        scheduleEnd: _c.scheduleEnd.text.trim(),
        // PIX (optional)
        pixKeyType: hasPix ? _c.pixKeyType : null,
        pixKey: hasPix ? pixKey : null,
        // Bank account (optional)
        bankName: hasBank ? _c.bankName.text.trim() : null,
        bankCode: _c.bankCode.text.trim().isNotEmpty
            ? _c.bankCode.text.trim()
            : null,
        agency: hasBank ? _c.agency.text.trim() : null,
        accountNumber: hasBank ? _c.account.text.trim() : null,
        accountType: hasBank ? 'checking' : null,
        accountHolder: hasBank ? _c.holder.text.trim() : null,
        bankFiscalNumber: _c.bankFiscal.text.trim().isNotEmpty
            ? digitsOnly(_c.bankFiscal.text)
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
            const FormSectionTitle('Dados Pessoais'),
            const SizedBox(height: 12),
            const FieldLabel('Nome Completo'),
            const SizedBox(height: 8),
            ProducerTextField(
              controller: _c.name,
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
            const FieldLabel('Telefone'),
            const SizedBox(height: 8),
            ProducerTextField(
              controller: _c.phone,
              hint: '(XX) XXXXX-XXXX',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              enabled: !isSaving,
              inputFormatters: [PhoneInputFormatter()],
              validator: (value) {
                if (value == null || value.isEmpty) return null; // partial
                final digits = digitsOnly(value);
                if (digits.length != 11) return 'DDD + número com 11 dígitos';
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
              enabled: !isSaving,
              validator: (value) {
                if (value == null || value.isEmpty) return null; // partial
                final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                if (!emailRegex.hasMatch(value)) return 'E-mail inválido';
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
              enabled: !isSaving,
            ),
            const SizedBox(height: 12),
            const FieldLabel('Nome da Fazenda'),
            const SizedBox(height: 8),
            ProducerTextField(
              controller: _c.farmName,
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
            const FieldLabel('Descrição'),
            const SizedBox(height: 8),
            ProducerTextField(
              controller: _c.description,
              hint: 'Breve descrição sobre o produtor...',
              prefixIcon: Icons.description_outlined,
              enabled: !isSaving,
              minLines: 1,
              maxLines: null,
              maxLength: 1000,
            ),

            const SizedBox(height: 20),
            const FormSectionTitle('Endereço'),
            const SizedBox(height: 12),
            AddressFields(
              controllers: _c,
              enabled: !isSaving,
              cepValidator: (value) {
                if (value == null || value.isEmpty) return null; // partial
                final digits = digitsOnly(value);
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
                  return 'Informe o nº';
                }
                return null;
              },
              neighborhoodValidator: (value) {
                if ((value ?? '').trim().isEmpty) {
                  return 'Informe o bairro';
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

            // Payment method (partial — optional)
            const SizedBox(height: 20),
            const FormSectionTitle('Forma de Recebimento'),
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
            PixSectionCard(
              pixKeyType: _c.pixKeyType,
              dropdownValue: _c.pixKeyType,
              pixKeyController: _c.pixKey,
              keyFormatters: pixMaskListFor(_c.pixKeyType),
              dropdownHint: 'Selecione (opcional)',
              itemTextStyle: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 15,
              ),
              dropdownEnabled: !isSaving,
              fieldEnabled: !isSaving,
              onTypeChanged: (v) => setState(() {
                _c.pixKeyType = v;
                _c.pixKey.clear();
              }),
            ),

            const SizedBox(height: 12),

            // Bank account
            BankSectionCard(
              controllers: _c,
              enabled: !isSaving,
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
              onToggle: (i) => setState(() => _c.weekdays[i] = !_c.weekdays[i]),
              enabled: !isSaving,
            ),
            const SizedBox(height: 12),
            ScheduleHoursRow(
              startController: _c.scheduleStart,
              endController: _c.scheduleEnd,
              enabled: !isSaving,
            ),

            const SizedBox(height: 24),

            ProducerFormSubmitButton(
              label: 'Salvar alterações',
              busy: isSaving,
              onPressed: _submit,
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
