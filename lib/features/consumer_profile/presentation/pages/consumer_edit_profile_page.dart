// Screen: Consumer Edit Profile
// User Story: US-04 — Update Consumer Profile
// Epic: EPIC 1 — Authentication and User Management
// Routes: PUT /consumers/:id

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/features/consumer_profile/presentation/bloc/consumer_profile_bloc.dart';
import 'package:ragro_mobile/features/consumer_profile/presentation/bloc/consumer_profile_event.dart';
import 'package:ragro_mobile/features/consumer_profile/presentation/bloc/consumer_profile_state.dart';

class ConsumerEditProfilePage extends StatefulWidget {
  const ConsumerEditProfilePage({super.key});

  @override
  State<ConsumerEditProfilePage> createState() => _ConsumerEditProfilePageState();
}

class _ConsumerEditProfilePageState extends State<ConsumerEditProfilePage> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _cpfController;
  late final TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    final state = context.read<ConsumerProfileBloc>().state;
    final profile = state is ConsumerProfileLoaded ? state.profile : null;
    _nameController = TextEditingController(text: profile?.name ?? '');
    _emailController = TextEditingController(text: profile?.email ?? '');
    _phoneController = TextEditingController(text: profile?.phone ?? '');
    _cpfController = TextEditingController(text: profile?.fiscalNumber ?? '');
    _addressController = TextEditingController(text: profile?.address ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cpfController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConsumerProfileBloc, ConsumerProfileState>(
      listener: (context, state) {
        if (state is ConsumerProfileUpdateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Perfil atualizado com sucesso!'),
              backgroundColor: AppColors.lightGreen,
            ),
          );
          context.pop();
        } else if (state is ConsumerProfileFailure) {
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
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: const Icon(Icons.arrow_back, size: 24),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Editar Perfil',
                          style: const TextStyle(
                            fontFamily: 'Figtree',
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 32),
                  ],
                ),
              ),
              // Form
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(26, 0, 26, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),
                      _buildField(
                        label: 'Nome Completo',
                        controller: _nameController,
                        icon: Icons.person_outline,
                        hint: 'João Da Silva',
                      ),
                      const SizedBox(height: 35),
                      _buildField(
                        label: 'Email',
                        controller: _emailController,
                        icon: Icons.email_outlined,
                        hint: 'exemplo@email.com',
                        readOnly: true,
                      ),
                      const SizedBox(height: 35),
                      _buildField(
                        label: 'Telefone',
                        controller: _phoneController,
                        icon: Icons.phone_outlined,
                        hint: '+55 (11) 90000-0000',
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 35),
                      _buildField(
                        label: 'CPF',
                        controller: _cpfController,
                        icon: Icons.badge_outlined,
                        hint: '000.000.000-00',
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 35),
                      _buildField(
                        label: 'Endereço',
                        controller: _addressController,
                        icon: Icons.location_on_outlined,
                        hint: 'Rua São Pedro, 123',
                      ),
                      const SizedBox(height: 35),
                      // Save button
                      BlocBuilder<ConsumerProfileBloc, ConsumerProfileState>(
                        builder: (context, state) {
                          final isLoading = state is ConsumerProfileUpdating;
                          return Column(
                            children: [
                              GestureDetector(
                                onTap: isLoading ? null : _onSave,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                                  decoration: BoxDecoration(
                                    color: AppColors.darkGreen,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x40000000),
                                        blurRadius: 4,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (isLoading)
                                        const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            color: AppColors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      else ...[
                                        const Icon(Icons.save_outlined, color: AppColors.white, size: 18),
                                        const SizedBox(width: 8),
                                      ],
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Salvar Alterações',
                                        style: TextStyle(
                                          fontFamily: 'Figtree',
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                          color: AppColors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () => context.pop(),
                                child: const Text(
                                  'Cancelar',
                                  style: TextStyle(
                                    fontFamily: 'Figtree',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: AppColors.darkGreen,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    TextInputType? keyboardType,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Figtree',
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Color(0xFF1E293B),
            ),
          ),
        ),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.inputBackground,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0x332E5729)),
          ),
          child: TextField(
            controller: controller,
            readOnly: readOnly,
            keyboardType: keyboardType,
            style: const TextStyle(
              fontFamily: 'Figtree',
              fontWeight: FontWeight.w400,
              fontSize: 16,
              color: AppColors.black,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: AppColors.placeholder),
              prefixIcon: Icon(icon, color: AppColors.placeholder, size: 20),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  void _onSave() {
    context.read<ConsumerProfileBloc>().add(
      ConsumerProfileUpdateSubmitted(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        fiscalNumber: _cpfController.text.trim().isEmpty
            ? null
            : _cpfController.text.trim(),
      ),
    );
  }
}
