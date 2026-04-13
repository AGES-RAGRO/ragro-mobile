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
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:ragro_mobile/features/producer_profile/domain/entities/public_producer.dart';
import 'package:ragro_mobile/features/producer_profile/presentation/bloc/producer_profile_bloc.dart';
import 'package:ragro_mobile/features/producer_profile/presentation/bloc/producer_profile_event.dart';
import 'package:ragro_mobile/features/producer_profile/presentation/bloc/producer_profile_state.dart';

class ProducerEditProfilePage extends StatelessWidget {
  const ProducerEditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final producerId = getIt<AuthLocalDataSource>().getUserId();
    if (producerId == null || producerId.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text('Sessão expirada. Faça login novamente.'),
        ),
      );
    }
    return BlocProvider<ProducerProfileBloc>(
      create: (_) => getIt<ProducerProfileBloc>()
        ..add(ProducerProfileStarted(producerId)),
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
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _phoneController = TextEditingController();
  final _farmNameController = TextEditingController();
  final _imagePicker = ImagePicker();

  bool _hydrated = false;
  bool _isPicking = false;

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    _farmNameController.dispose();
    super.dispose();
  }

  void _hydrateFromState(ProducerProfileLoaded state) {
    if (_hydrated) return;
    _nameController.text = state.producer.name;
    _bioController.text = state.producer.story;
    _phoneController.text = state.producer.phone;
    _farmNameController.text = state.producer.farmName;
    _hydrated = true;
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<ProducerProfileBloc>().add(
      ProducerProfileUpdateSubmitted(
        producerId: widget.producerId,
        name: _nameController.text,
        story: _bioController.text,
        phone: _phoneController.text,
        farmName: _farmNameController.text,
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
                          backgroundImage:
                              avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                          child: avatarUrl.isEmpty
                              ? Text(
                                  _nameController.text.isNotEmpty
                                      ? _nameController.text[0].toUpperCase()
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
                                color: Colors.black.withValues(alpha: 0.35),
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
                  const _FieldLabel('Nome'),
                  const SizedBox(height: 8),
                  _FormField(
                    controller: _nameController,
                    hint: 'Seu nome completo',
                    validator: (value) {
                      final trimmed = value?.trim() ?? '';
                      if (trimmed.isEmpty) return 'Informe seu nome';
                      if (trimmed.length < 3) {
                        return 'Nome deve ter ao menos 3 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  const _FieldLabel('Descrição / Bio'),
                  const SizedBox(height: 8),
                  _FormField(
                    controller: _bioController,
                    hint: 'Conte um pouco sobre você...',
                    maxLines: 3,
                    validator: (value) {
                      if (value?.trim().isEmpty ?? true) {
                        return 'Conte um pouco sobre você';
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
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      final digits = (value ?? '').replaceAll(
                        RegExp(r'\D'),
                        '',
                      );
                      if (digits.isEmpty) return 'Informe um telefone';
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
                    validator: (value) {
                      if (value?.trim().isEmpty ?? true) {
                        return 'Informe o nome da fazenda';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
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
                              'Salvar',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
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
                    errorBuilder: (_, __, ___) => const ColoredBox(
                      color: Color(0xFFE0E0E0),
                    ),
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
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        hintText: hint,
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
