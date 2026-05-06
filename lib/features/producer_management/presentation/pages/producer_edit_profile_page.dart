// Screen: Producer Edit Profile (Editar Perfil do Produtor)
// User Story: US-25 — Edit Producer Profile
// Epic: EPIC 4 — Producer Features
// Routes: GET /producers/:id, PUT /producers/:id

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ragro_mobile/core/di/injection.dart';
import 'package:ragro_mobile/core/formatters/input_masks.dart';
import 'package:ragro_mobile/core/services/cep_service.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:ragro_mobile/features/producer_profile/domain/entities/public_producer.dart';
import 'package:ragro_mobile/features/producer_profile/presentation/bloc/producer_profile_bloc.dart';
import 'package:ragro_mobile/features/producer_profile/presentation/bloc/producer_profile_event.dart';
import 'package:ragro_mobile/features/producer_profile/presentation/bloc/producer_profile_state.dart';

const _pixKeyTypes = ['cpf', 'cnpj', 'email', 'phone', 'random'];
const _pixKeyTypeLabels = {
  'cpf': 'CPF',
  'cnpj': 'CNPJ',
  'email': 'E-mail',
  'phone': 'Telefone',
  'random': 'Chave aleatória',
};

class ProducerEditProfilePage extends StatelessWidget {
  const ProducerEditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final producerId = getIt<AuthLocalDataSource>().getUserId();
    if (producerId == null || producerId.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Sessão expirada. Faça login novamente.')),
      );
    }
    return BlocProvider<ProducerProfileBloc>(
      create: (_) =>
          getIt<ProducerProfileBloc>()
            ..add(ProducerProfileStarted(producerId, isOwnerView: true)),
      child: _ProducerEditProfileView(producerId: producerId),
    );
  }
}

class _ProducerEditProfileView extends StatefulWidget {
  const _ProducerEditProfileView({required this.producerId});

  final String producerId;

  @override
  State<_ProducerEditProfileView> createState() =>
      _ProducerEditProfileViewState();
}

class _ProducerEditProfileViewState extends State<_ProducerEditProfileView> {
  final _formKey = GlobalKey<FormState>();

  // ── Dados Pessoais ─────────────────────────────────────────────────────
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _phoneController = TextEditingController();
  final _farmNameController = TextEditingController();

  // ── Endereço ───────────────────────────────────────────────────────────
  final _cepController = TextEditingController();
  final _addressController = TextEditingController();
  final _numberController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();

  // ── Forma de Recebimento ──────────────────────────────────────────────
  String? _pixKeyType;
  final _pixKeyController = TextEditingController();

  final _bankNameController = TextEditingController();
  final _bankCodeController = TextEditingController();
  final _agencyController = TextEditingController();
  final _accountController = TextEditingController();
  final _holderController = TextEditingController();
  final _bankFiscalController = TextEditingController();

  // ── Horário ────────────────────────────────────────────────────────────
  // Assuming simple availability where we pick typical open/close times
  final _scheduleStartController = TextEditingController();
  final _scheduleEndController = TextEditingController();
  final List<bool> _weekdays = List.filled(7, false);

  final _imagePicker = ImagePicker();

  bool _hydrated = false;
  bool _isPicking = false;

  @override
  void initState() {
    super.initState();
    _cepController.addListener(_onCepChanged);
  }

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

  String _applyMask(String val, TextInputFormatter formatter) {
    if (val.isEmpty) return val;
    return formatter
        .formatEditUpdate(TextEditingValue.empty, TextEditingValue(text: val))
        .text;
  }

  void _onCepChanged() {
    final cep = _digitsOnly(_cepController.text);
    if (cep.length == 8) {
      _lookupCep(cep);
    }
  }

  Future<void> _lookupCep(String cep) async {
    final address = await getIt<CepService>().fetchAddress(cep);
    if (address != null && mounted) {
      setState(() {
        _addressController.text = address.street;
        _neighborhoodController.text = address.neighborhood;
        _cityController.text = address.city;
        _stateController.text = address.state;
      });
    }
  }

  List<TextInputFormatter> _pixKeyFormatters() {
    switch (_pixKeyType) {
      case 'cpf':
      case 'cnpj':
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
    _bioController.dispose();
    _phoneController.dispose();
    _farmNameController.dispose();
    _cepController.dispose();
    _addressController.dispose();
    _numberController.dispose();
    _neighborhoodController.dispose();
    _cityController.dispose();
    _stateController.dispose();
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

  void _hydrateFromState(ProducerProfileLoaded state) {
    if (_hydrated) return;
    final producer = state.producer;

    _nameController.text = producer.name;
    _bioController.text = producer.description;
    _phoneController.text = _applyMask(producer.phone, PhoneInputFormatter());
    _farmNameController.text = producer.farmName;

    if (producer.producerAddress != null) {
      final addr = producer.producerAddress!;
      _cepController.text = _applyMask(addr.zipCode, CepInputFormatter());
      _addressController.text = addr.street;
      _numberController.text = addr.number;
      _neighborhoodController.text = addr.neighborhood ?? '';
      _cityController.text = addr.city;
      _stateController.text = addr.state;
    }

    // Payment Methods
    if (producer.paymentMethods != null) {
      final pix = producer.paymentMethods!
          .where((pm) => pm.type == 'pix')
          .firstOrNull;
      if (pix != null) {
        _pixKeyType = pix.pixKeyType;
        if (_pixKeyType == 'cpf' || _pixKeyType == 'cnpj') {
          _pixKeyController.text = _applyMask(
            pix.pixKey ?? '',
            FiscalNumberInputFormatter(),
          );
        } else if (_pixKeyType == 'phone') {
          _pixKeyController.text = _applyMask(
            pix.pixKey ?? '',
            PhoneInputFormatter(),
          );
        } else {
          _pixKeyController.text = pix.pixKey ?? '';
        }
      }

      final bank = producer.paymentMethods!
          .where((pm) => pm.type == 'bank_account')
          .firstOrNull;
      if (bank != null) {
        _bankNameController.text = bank.bankName ?? '';
        _bankCodeController.text = bank.bankCode ?? '';
        _agencyController.text = bank.agency ?? '';
        _accountController.text = _applyMask(
          bank.accountNumber ?? '',
          BankAccountInputFormatter(),
        );
        _holderController.text = bank.holderName ?? '';
        _bankFiscalController.text = _applyMask(
          bank.fiscalNumber ?? '',
          FiscalNumberInputFormatter(),
        );
      }
    }

    // Schedule
    if (producer.availability.isNotEmpty) {
      _scheduleStartController.text = producer.availability.first.opensAt;
      _scheduleEndController.text = producer.availability.first.closesAt;
      for (var i = 0; i < 7; i++) {
        _weekdays[i] = false;
      }
      for (final slot in producer.availability) {
        final uiIndex = slot.weekday == 0 ? 6 : slot.weekday - 1;
        if (uiIndex >= 0 && uiIndex < 7) {
          _weekdays[uiIndex] = true;
        }
      }
    } else {
      _scheduleStartController.text = '08:00';
      _scheduleEndController.text = '18:00';
    }

    _hydrated = true;
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    Map<String, dynamic>? addressPayload;
    if (_addressController.text.trim().isNotEmpty) {
      addressPayload = {
        'street': _addressController.text.trim(),
        'number': _numberController.text.trim(),
        'city': _cityController.text.trim(),
        'state': _stateController.text.trim(),
        'zipCode': _digitsOnly(_cepController.text),
        if (_neighborhoodController.text.trim().isNotEmpty)
          'neighborhood': _neighborhoodController.text.trim(),
      };
    }

    final paymentMethods = <Map<String, dynamic>>[];
    final hasPix =
        _pixKeyType != null && _pixKeyController.text.trim().isNotEmpty;
    if (hasPix) {
      final raw = _pixKeyController.text.trim();
      final pKey = (_pixKeyType == 'cpf' || _pixKeyType == 'phone')
          ? _digitsOnly(raw)
          : raw;
      paymentMethods.add({
        'type': 'pix',
        'pixKeyType': _pixKeyType,
        'pixKey': pKey,
      });
    }

    final hasBank =
        _bankNameController.text.trim().isNotEmpty &&
        _agencyController.text.trim().isNotEmpty &&
        _accountController.text.trim().isNotEmpty &&
        _holderController.text.trim().isNotEmpty;

    if (_bankNameController.text.trim().isNotEmpty && !hasBank) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha agência, conta e titular.'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    if (hasBank) {
      paymentMethods.add({
        'type': 'bank_account',
        'bankName': _bankNameController.text.trim(),
        if (_bankCodeController.text.isNotEmpty)
          'bankCode': _bankCodeController.text.trim(),
        'agency': _agencyController.text.trim(),
        'accountNumber': _accountController.text.trim(),
        'accountType': 'checking',
        'holderName': _holderController.text.trim(),
        if (_bankFiscalController.text.isNotEmpty)
          'fiscalNumber': _digitsOnly(_bankFiscalController.text),
      });
    }

    final availability = <Map<String, dynamic>>[];
    final sStart = _scheduleStartController.text.trim();
    final sEnd = _scheduleEndController.text.trim();
    for (var i = 0; i < 7; i++) {
      if (_weekdays[i]) {
        // UI weekday: 0=Mon..6=Sun. API weekday: 0=Sun, 1=Mon..
        final apiWeekday = (i == 6) ? 0 : i + 1;
        availability.add({
          'weekday': apiWeekday,
          'opensAt': sStart,
          'closesAt': sEnd,
        });
      }
    }

    context.read<ProducerProfileBloc>().add(
      ProducerProfileUpdateSubmitted(
        producerId: widget.producerId,
        name: _nameController.text,
        description: _bioController.text,
        phone: _digitsOnly(_phoneController.text),
        farmName: _farmNameController.text,
        address: addressPayload,
        paymentMethods: paymentMethods.isNotEmpty ? paymentMethods : null,
        availability: availability.isNotEmpty ? availability : null,
      ),
    );
  }

  Future<XFile?> _pickImage() async {
    if (_isPicking) return null;
    _isPicking = true;
    try {
      return await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
    } on PlatformException {
      return null;
    } finally {
      _isPicking = false;
    }
  }

  Future<void> _pickAvatar() async {
    final picked = await _pickImage();
    if (picked == null || !mounted) return;
    context.read<ProducerProfileBloc>().add(
      ProducerAvatarPicked(widget.producerId, picked),
    );
  }

  Future<void> _pickCover() async {
    final picked = await _pickImage();
    if (picked == null || !mounted) return;
    context.read<ProducerProfileBloc>().add(
      ProducerCoverPicked(widget.producerId, picked),
    );
  }

  PublicProducer? _producerFrom(ProducerProfileState state) {
    if (state is ProducerProfileLoaded) return state.producer;
    if (state is ProducerPhotoUploading) return state.producer;
    return null;
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
    switch (type) {
      case 'cpf':
        return '000.000.000-00';
      case 'cnpj':
        return '00.000.000/0000-00';
      case 'email':
        return 'email@exemplo.com';
      case 'phone':
        return '(XX) XXXXX-XXXX';
      default:
        return 'Chave Aleatória';
    }
  }

  TextInputType _pixKeyboardType(String type) {
    if (type == 'cpf' || type == 'cnpj' || type == 'phone') {
      return TextInputType.number;
    }
    if (type == 'email') {
      return TextInputType.emailAddress;
    }
    return TextInputType.text;
  }

  @override
  Widget build(BuildContext context) {
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
          'Editar Perfil',
          style: TextStyle(
            fontFamily: 'Figtree',
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: AppColors.black,
          ),
        ),
      ),
      body: BlocConsumer<ProducerProfileBloc, ProducerProfileState>(
        listenWhen: (previous, current) =>
            current is ProducerProfileLoaded ||
            current is ProducerProfileUpdateSuccess ||
            current is ProducerProfileFailure,
        listener: (context, state) {
          if (state is ProducerProfileLoaded) {
            _hydrateFromState(state);
          } else if (state is ProducerProfileUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Perfil atualizado com sucesso!'),
                backgroundColor: AppColors.darkGreen,
              ),
            );
            context.pop();
          } else if (state is ProducerProfileFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ProducerProfileLoading ||
              state is ProducerProfileInitial) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.darkGreen),
            );
          }
          if (state is ProducerProfileFailure && !_hydrated) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    color: AppColors.black,
                  ),
                ),
              ),
            );
          }

          final isSaving = state is ProducerProfileUpdating;
          final isUploadingAvatar =
              state is ProducerPhotoUploading && state.isAvatar;
          final isUploadingCover =
              state is ProducerPhotoUploading && !state.isAvatar;
          final producer = _producerFrom(state);
          final avatarUrl = producer?.avatarUrl ?? '';
          final coverUrl = producer?.coverUrl ?? '';

          return SingleChildScrollView(
            padding: EdgeInsets.zero,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CoverPhotoSection(
                    coverUrl: coverUrl,
                    isUploading: isUploadingCover,
                    onPick: _pickCover,
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 52,
                                backgroundColor: AppColors.darkGreen.withValues(
                                  alpha: 0.1,
                                ),
                                backgroundImage: avatarUrl.isNotEmpty
                                    ? NetworkImage(avatarUrl)
                                    : null,
                                child: avatarUrl.isEmpty
                                    ? Text(
                                        _nameController.text.isNotEmpty
                                            ? _nameController.text[0]
                                                  .toUpperCase()
                                            : '?',
                                        style: const TextStyle(
                                          fontFamily: 'Figtree',
                                          fontWeight: FontWeight.w700,
                                          fontSize: 36,
                                          color: AppColors.darkGreen,
                                        ),
                                      )
                                    : null,
                              ),
                              if (isUploadingAvatar)
                                Positioned.fill(
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(
                                        alpha: 0.35,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        color: AppColors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    ),
                                  ),
                                ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: isUploadingAvatar ? null : _pickAvatar,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(
                                      color: AppColors.darkGreen,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      size: 16,
                                      color: AppColors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        _sectionTitle('Dados Pessoais'),
                        const SizedBox(height: 12),
                        const _FieldLabel('Nome Completo'),
                        const SizedBox(height: 8),
                        _FormField(
                          controller: _nameController,
                          hint: 'Seu nome completo',
                          prefixIcon: Icons.person_outline,
                          validator: (value) {
                            final trimmed = value?.trim() ?? '';
                            if (trimmed.isEmpty) {
                              return 'Informe seu nome';
                            }
                            if (trimmed.length < 3) {
                              return 'Nome deve ter ao menos 3 caracteres';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        const _FieldLabel('Telefone'),
                        const SizedBox(height: 8),
                        _FormField(
                          controller: _phoneController,
                          hint: '(XX) XXXXX-XXXX',
                          prefixIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [PhoneInputFormatter()],
                          validator: (value) {
                            final digits = (value ?? '').replaceAll(
                              RegExp(r'\D'),
                              '',
                            );
                            if (digits.isEmpty) {
                              return 'Informe um telefone';
                            }
                            if (digits.length < 10) {
                              return 'Telefone deve ter ao menos 10 dígitos';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        const _FieldLabel('Nome da Fazenda'),
                        const SizedBox(height: 8),
                        _FormField(
                          controller: _farmNameController,
                          hint: 'Nome da sua propriedade rural',
                          prefixIcon: Icons.home_outlined,
                          validator: (value) {
                            if (value?.trim().isEmpty ?? true) {
                              return 'Informe o nome da fazenda';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        const _FieldLabel('Descrição'),
                        const SizedBox(height: 8),
                        _FormField(
                          controller: _bioController,
                          hint: 'Conte um pouco sobre você...',
                          prefixIcon: Icons.description_outlined,
                          minLines: 1,
                          maxLines: null,
                          validator: (value) {
                            if (value?.trim().isEmpty ?? true) {
                              return 'Conte um pouco sobre você';
                            }
                            return null;
                          },
                        ),

                        // ── Endereço ───────────────────────────────────────────────
                        const SizedBox(height: 24),
                        _sectionTitle('Endereço'),
                        const SizedBox(height: 12),
                        const _FieldLabel('CEP'),
                        const SizedBox(height: 8),
                        _FormField(
                          controller: _cepController,
                          hint: '00000-000',
                          prefixIcon: Icons.location_on_outlined,
                          keyboardType: TextInputType.number,
                          inputFormatters: [CepInputFormatter()],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return null;
                            }
                            final digits = _digitsOnly(value);
                            if (digits.length != 8) {
                              return 'CEP deve ter 8 dígitos';
                            }
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
                              child: _FormField(
                                controller: _addressController,
                                hint: 'Rua / Avenida',
                                prefixIcon: Icons.location_on_outlined,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _FormField(
                                controller: _numberController,
                                hint: 'Nº',
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const _FieldLabel('Bairro'),
                        const SizedBox(height: 8),
                        _FormField(
                          controller: _neighborhoodController,
                          hint: 'Bairro',
                          prefixIcon: Icons.map_outlined,
                          validator: (value) {
                            if ((value ?? '').trim().isEmpty) {
                              return 'Informe o bairro';
                            }
                            return null;
                          },
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
                                  _FormField(
                                    controller: _cityController,
                                    hint: 'Cidade',
                                    prefixIcon: Icons.location_city_outlined,
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
                                  _FormField(
                                    controller: _stateController,
                                    hint: 'UF',
                                    prefixIcon: Icons.map_outlined,
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(2),
                                      _UppercaseFormatter(),
                                    ],
                                    validator: (v) {
                                      if ((v ?? '').trim().isEmpty) {
                                        return 'UF';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // ── Forma de Recebimento ──────────────────────────────
                        const SizedBox(height: 24),
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

                        Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(
                              color: AppColors.inputBorder,
                            ),
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
                                const _FieldLabel('Tipo da chave (opcional)'),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  initialValue:
                                      _pixKeyTypes.contains(_pixKeyType)
                                      ? _pixKeyType
                                      : null,
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
                                  _FormField(
                                    key: ValueKey(_pixKeyType),
                                    controller: _pixKeyController,
                                    hint: _pixKeyHint(_pixKeyType!),
                                    keyboardType: _pixKeyboardType(
                                      _pixKeyType!,
                                    ),
                                    inputFormatters: _pixKeyFormatters(),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(
                              color: AppColors.inputBorder,
                            ),
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
                                _FormField(
                                  controller: _bankNameController,
                                  hint: 'Nome do banco',
                                  prefixIcon: Icons.account_balance_outlined,
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const _FieldLabel('Código'),
                                          const SizedBox(height: 8),
                                          _FormField(
                                            controller: _bankCodeController,
                                            hint: '001',
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [
                                              LengthLimitingTextInputFormatter(
                                                3,
                                              ),
                                              FilteringTextInputFormatter
                                                  .digitsOnly,
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const _FieldLabel('Agência'),
                                          const SizedBox(height: 8),
                                          _FormField(
                                            controller: _agencyController,
                                            hint: '0000',
                                            keyboardType: TextInputType.number,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                const _FieldLabel('Conta'),
                                const SizedBox(height: 8),
                                _FormField(
                                  controller: _accountController,
                                  hint: '000000-0',
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    BankAccountInputFormatter(),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                const _FieldLabel('Titular'),
                                const SizedBox(height: 8),
                                _FormField(
                                  controller: _holderController,
                                  hint: 'Nome completo do titular',
                                  prefixIcon: Icons.account_circle_outlined,
                                ),
                                const SizedBox(height: 12),
                                const _FieldLabel('CPF / CNPJ do Titular'),
                                const SizedBox(height: 8),
                                _FormField(
                                  controller: _bankFiscalController,
                                  hint: '000.000.000-00',
                                  prefixIcon: Icons.badge_outlined,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FiscalNumberInputFormatter(),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        // ── Horário de Atendimento ─────────────────────────────
                        const SizedBox(height: 24),
                        _sectionTitle('Horário de atendimento'),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const _FieldLabel('Abre às'),
                                  const SizedBox(height: 8),
                                  _FormField(
                                    controller: _scheduleStartController,
                                    hint: '08:00',
                                    prefixIcon: Icons.schedule_outlined,
                                    keyboardType: TextInputType.datetime,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const _FieldLabel('Fecha às'),
                                  const SizedBox(height: 8),
                                  _FormField(
                                    controller: _scheduleEndController,
                                    hint: '18:00',
                                    prefixIcon: Icons.schedule_outlined,
                                    keyboardType: TextInputType.datetime,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
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

                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isSaving ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.darkGreen,
                              foregroundColor: AppColors.white,
                              disabledBackgroundColor: AppColors.darkGreen
                                  .withValues(alpha: 0.5),
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
                                    'Salvar',
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CoverPhotoSection extends StatelessWidget {
  const _CoverPhotoSection({
    required this.coverUrl,
    required this.isUploading,
    required this.onPick,
  });
  final String coverUrl;
  final bool isUploading;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: coverUrl.isNotEmpty
                ? Image.network(
                    coverUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const ColoredBox(color: Color(0xFFE0E0E0)),
                  )
                : const ColoredBox(color: Color(0xFFE0E0E0)),
          ),
          if (isUploading)
            const Positioned.fill(
              child: ColoredBox(
                color: Color(0x59000000),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.white),
                ),
              ),
            ),
          Positioned(
            bottom: 12,
            right: 12,
            child: GestureDetector(
              onTap: isUploading ? null : onPick,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: AppColors.darkGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 18,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ],
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

class _FormField extends StatelessWidget {
  const _FormField({
    required this.controller,
    required this.hint,
    this.prefixIcon,
    this.maxLines = 1,
    this.minLines,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.validator,
    super.key,
  });

  final TextEditingController controller;
  final String hint;
  final IconData? prefixIcon;
  final int? maxLines;
  final int? minLines;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      minLines: minLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
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

class _UppercaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) => newValue.copyWith(text: newValue.text.toUpperCase());
}
