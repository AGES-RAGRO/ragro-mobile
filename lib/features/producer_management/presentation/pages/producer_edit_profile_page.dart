// Producer Edit Profile screen (US-25). Routes: GET /producers/:id, PUT /producers/:id.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ragro_mobile/core/di/injection.dart';
import 'package:ragro_mobile/core/formatters/input_masks.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:ragro_mobile/features/producer_profile/domain/entities/public_producer.dart';
import 'package:ragro_mobile/features/producer_profile/presentation/bloc/producer_profile_bloc.dart';
import 'package:ragro_mobile/features/producer_profile/presentation/bloc/producer_profile_event.dart';
import 'package:ragro_mobile/features/producer_profile/presentation/bloc/producer_profile_state.dart';
import 'package:ragro_mobile/shared/widgets/producer_form/cep_lookup.dart';
import 'package:ragro_mobile/shared/widgets/producer_form/field_label.dart';
import 'package:ragro_mobile/shared/widgets/producer_form/pix_mask.dart';
import 'package:ragro_mobile/shared/widgets/producer_form/producer_form_controllers.dart';
import 'package:ragro_mobile/shared/widgets/producer_form/producer_form_sections.dart';
import 'package:ragro_mobile/shared/widgets/producer_form/producer_text_field.dart';
import 'package:ragro_mobile/shared/widgets/producer_form/weekday_mapper.dart';

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
  final _c = ProducerFormControllers();

  final _imagePicker = ImagePicker();

  bool _hydrated = false;
  bool _isPicking = false;

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

  void _hydrateFromState(ProducerProfileLoaded state) {
    if (_hydrated) return;
    _c.hydrateFromPublicProducer(state.producer);
    _hydrated = true;
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    Map<String, dynamic>? addressPayload;
    if (_c.address.text.trim().isNotEmpty) {
      addressPayload = {
        'street': _c.address.text.trim(),
        'number': _c.number.text.trim(),
        'city': _c.city.text.trim(),
        'state': _c.state.text.trim(),
        'zipCode': digitsOnly(_c.cep.text),
        if (_c.neighborhood.text.trim().isNotEmpty)
          'neighborhood': _c.neighborhood.text.trim(),
      };
    }

    final paymentMethods = <Map<String, dynamic>>[];
    final hasPix = _c.pixKeyType != null && _c.pixKey.text.trim().isNotEmpty;
    if (hasPix) {
      final raw = _c.pixKey.text.trim();
      final pKey = (_c.pixKeyType == 'cpf' || _c.pixKeyType == 'phone')
          ? digitsOnly(raw)
          : raw;
      paymentMethods.add({
        'type': 'pix',
        'pixKeyType': _c.pixKeyType,
        'pixKey': pKey,
      });
    }

    final hasBank = _c.hasCompleteBank;

    if (_c.bankName.text.trim().isNotEmpty && !hasBank) {
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
        'bankName': _c.bankName.text.trim(),
        if (_c.bankCode.text.isNotEmpty) 'bankCode': _c.bankCode.text.trim(),
        'agency': _c.agency.text.trim(),
        'accountNumber': _c.account.text.trim(),
        'accountType': 'checking',
        'holderName': _c.holder.text.trim(),
        if (_c.bankFiscal.text.isNotEmpty)
          'fiscalNumber': digitsOnly(_c.bankFiscal.text),
      });
    }

    final availability = <Map<String, dynamic>>[];
    final sStart = _c.scheduleStart.text.trim();
    final sEnd = _c.scheduleEnd.text.trim();
    for (var i = 0; i < 7; i++) {
      if (_c.weekdays[i]) {
        availability.add({
          'weekday': WeekdayMapper.toApi(i),
          'opensAt': sStart,
          'closesAt': sEnd,
        });
      }
    }

    context.read<ProducerProfileBloc>().add(
      ProducerProfileUpdateSubmitted(
        producerId: widget.producerId,
        name: _c.name.text,
        description: _c.description.text,
        phone: digitsOnly(_c.phone.text),
        farmName: _c.farmName.text,
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
                                        _c.name.text.isNotEmpty
                                            ? _c.name.text[0].toUpperCase()
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
                        const FormSectionTitle('Dados Pessoais'),
                        const SizedBox(height: 12),
                        const FieldLabel('Nome Completo'),
                        const SizedBox(height: 8),
                        ProducerTextField(
                          controller: _c.name,
                          hint: 'Seu nome completo',
                          prefixIcon: Icons.person_outline,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
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
                        const FieldLabel('Telefone'),
                        const SizedBox(height: 8),
                        ProducerTextField(
                          controller: _c.phone,
                          hint: '(XX) XXXXX-XXXX',
                          prefixIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
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
                        const FieldLabel('Nome da Fazenda'),
                        const SizedBox(height: 8),
                        ProducerTextField(
                          controller: _c.farmName,
                          hint: 'Nome da sua propriedade rural',
                          prefixIcon: Icons.home_outlined,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            if (value?.trim().isEmpty ?? true) {
                              return 'Informe o nome da fazenda';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        const FieldLabel('Descrição'),
                        const SizedBox(height: 8),
                        ProducerTextField(
                          controller: _c.description,
                          hint: 'Conte um pouco sobre você...',
                          prefixIcon: Icons.description_outlined,
                          minLines: 1,
                          maxLines: null,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            if (value?.trim().isEmpty ?? true) {
                              return 'Conte um pouco sobre você';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 24),
                        const FormSectionTitle('Endereço'),
                        const SizedBox(height: 12),
                        AddressFields(
                          controllers: _c,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          cepValidator: (value) {
                            if (value == null || value.isEmpty) {
                              return null;
                            }
                            final digits = digitsOnly(value);
                            if (digits.length != 8) {
                              return 'CEP deve ter 8 dígitos';
                            }
                            return null;
                          },
                          neighborhoodValidator: (value) {
                            if ((value ?? '').trim().isEmpty) {
                              return 'Informe o bairro';
                            }
                            return null;
                          },
                          statePrefixIcon: Icons.map_outlined,
                          stateValidator: (v) {
                            if ((v ?? '').trim().isEmpty) {
                              return 'UF';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 24),
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

                        PixSectionCard(
                          pixKeyType: _c.pixKeyType,
                          dropdownValue: kPixKeyTypes.contains(_c.pixKeyType)
                              ? _c.pixKeyType
                              : null,
                          pixKeyController: _c.pixKey,
                          keyFormatters: pixMaskListFor(_c.pixKeyType),
                          typeLabel: 'Tipo da chave (opcional)',
                          randomKeyHint: 'Chave Aleatória',
                          dropdownEnabled: !isSaving,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          onTypeChanged: (v) => setState(() {
                            _c.pixKeyType = v;
                            _c.pixKey.clear();
                          }),
                        ),

                        const SizedBox(height: 12),

                        BankSectionCard(
                          controllers: _c,
                          codeLabel: 'Código',
                          fiscalLabel: 'CPF / CNPJ do Titular',
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                        ),

                        const SizedBox(height: 24),
                        const FormSectionTitle('Horário de atendimento'),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const FieldLabel('Abre às'),
                                  const SizedBox(height: 8),
                                  ProducerTextField(
                                    controller: _c.scheduleStart,
                                    hint: '08:00',
                                    prefixIcon: Icons.schedule_outlined,
                                    keyboardType: TextInputType.datetime,
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const FieldLabel('Fecha às'),
                                  const SizedBox(height: 8),
                                  ProducerTextField(
                                    controller: _c.scheduleEnd,
                                    hint: '18:00',
                                    prefixIcon: Icons.schedule_outlined,
                                    keyboardType: TextInputType.datetime,
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        WeekdaySelector(
                          selected: _c.weekdays,
                          onToggle: (i) =>
                              setState(() => _c.weekdays[i] = !_c.weekdays[i]),
                          runSpacing: 8,
                        ),

                        const SizedBox(height: 32),
                        ProducerFormSubmitButton(
                          label: 'Salvar',
                          busy: isSaving,
                          onPressed: _submit,
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
