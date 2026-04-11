// Screen: Producer Edit Profile (Editar Perfil do Produtor)
// User Story: US-25 — Edit Producer Profile
// Epic: EPIC 4 — Producer Features
// Routes: PUT /producers/me

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';

class ProducerEditProfilePage extends StatefulWidget {
  const ProducerEditProfilePage({super.key});

  @override
  State<ProducerEditProfilePage> createState() =>
      _ProducerEditProfilePageState();
}

class _ProducerEditProfilePageState extends State<ProducerEditProfilePage> {
  final _nameController = TextEditingController(text: 'João Silva');
  final _bioController = TextEditingController(
    text: 'Produtor orgânico certificado com mais de 10 anos de experiência.',
  );
  final _phoneController = TextEditingController(text: '(51) 99999-0001');
  final _locationController = TextEditingController(text: 'Porto Alegre, RS');
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    // TODO: replace with real API call — PUT /producers/me
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Perfil atualizado com sucesso!'),
        backgroundColor: AppColors.darkGreen,
      ),
    );
    context.pop();
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar with camera edit
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 52,
                    backgroundColor: AppColors.darkGreen.withOpacity(0.1),
                    child: const Text(
                      'J',
                      style: TextStyle(
                        fontFamily: 'Figtree',
                        fontWeight: FontWeight.w700,
                        fontSize: 36,
                        color: AppColors.darkGreen,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Seleção de foto em breve...'),
                          ),
                        );
                      },
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

            _FieldLabel('Nome'),
            const SizedBox(height: 8),
            _TextField(controller: _nameController, hint: 'Seu nome completo'),

            const SizedBox(height: 16),

            _FieldLabel('Descrição / Bio'),
            const SizedBox(height: 8),
            _TextField(
              controller: _bioController,
              hint: 'Conte um pouco sobre você...',
              maxLines: 3,
            ),

            const SizedBox(height: 16),

            _FieldLabel('Telefone'),
            const SizedBox(height: 8),
            _TextField(
              controller: _phoneController,
              hint: '(XX) XXXXX-XXXX',
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 16),

            _FieldLabel('Localização'),
            const SizedBox(height: 8),
            _TextField(controller: _locationController, hint: 'Cidade, Estado'),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkGreen,
                  foregroundColor: AppColors.white,
                  disabledBackgroundColor: AppColors.darkGreen.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _saving
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
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
  });

  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
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
