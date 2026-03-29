// Screen: Configurações Perfil do Produtor
// User Story: US-07 — Update Producer Data
// Epic: EPIC 1 — Authentication
// Routes: (settings page, no dedicated API route)

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ragro_mobile/core/di/injection.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ragro_mobile/features/auth/presentation/bloc/auth_event.dart';

class ProducerSettingsPage extends StatelessWidget {
  const ProducerSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F6),
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: const Icon(Icons.arrow_back, color: AppColors.black),
        ),
        title: const Text(
          'Perfil do Produtor',
          style: TextStyle(
            fontFamily: 'Figtree',
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: AppColors.black,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0x1A2E5729), height: 1),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Alterar senha
              ListTile(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Alteração de senha em breve'),
                    ),
                  );
                },
                leading: const Icon(
                  Icons.edit_outlined,
                  color: AppColors.black,
                  size: 20,
                ),
                title: const Text(
                  'Alterar senha',
                  style: TextStyle(
                    fontFamily: 'Figtree',
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: AppColors.black,
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: AppColors.placeholder,
                  size: 20,
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              // Sair
              ListTile(
                onTap: () {
                  getIt<AuthBloc>().add(const AuthLogoutRequested());
                },
                leading: const Icon(
                  Icons.close,
                  color: AppColors.red,
                  size: 20,
                ),
                title: const Text(
                  'Sair',
                  style: TextStyle(
                    fontFamily: 'Figtree',
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: AppColors.red,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
