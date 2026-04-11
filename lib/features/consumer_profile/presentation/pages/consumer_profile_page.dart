// Screen: Consumer Profile
// User Story: US-03 — Retrieve Consumer Profile
// Epic: EPIC 1 — Authentication and User Management
// Routes: GET /consumers/:id

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ragro_mobile/features/auth/presentation/bloc/auth_event.dart';
import 'package:ragro_mobile/features/consumer_profile/presentation/bloc/consumer_profile_bloc.dart';
import 'package:ragro_mobile/features/consumer_profile/presentation/bloc/consumer_profile_state.dart';
import 'package:ragro_mobile/features/consumer_profile/presentation/widgets/profile_info_row.dart';
import 'package:ragro_mobile/features/consumer_profile/presentation/widgets/profile_menu_item.dart';

class ConsumerProfilePage extends StatelessWidget {
  const ConsumerProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ConsumerProfileView();
  }
}

class _ConsumerProfileView extends StatelessWidget {
  const _ConsumerProfileView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConsumerProfileBloc, ConsumerProfileState>(
      listener: (context, state) {
        if (state is ConsumerProfileFailure) {
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
          child: BlocBuilder<ConsumerProfileBloc, ConsumerProfileState>(
            builder: (context, state) {
              if (state is ConsumerProfileLoading ||
                  state is ConsumerProfileInitial) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.darkGreen),
                );
              }
              if (state is ConsumerProfileFailure) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppColors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(state.message),
                    ],
                  ),
                );
              }

              final profile = switch (state) {
                ConsumerProfileLoaded(:final profile) => profile,
                ConsumerProfileUpdating(:final profile) => profile,
                ConsumerProfileUpdateSuccess(:final profile) => profile,
                _ => null,
              };

              if (profile == null) return const SizedBox.shrink();

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    // Header
                    const Text(
                      'Perfil',
                      style: TextStyle(
                        fontFamily: 'Figtree',
                        fontWeight: FontWeight.w700,
                        fontSize: 34,
                        color: AppColors.darkGreen,
                      ),
                    ),
                    const SizedBox(height: 40),
                    // User name
                    Text(
                      profile.name,
                      style: const TextStyle(
                        fontFamily: 'Figtree',
                        fontWeight: FontWeight.w800,
                        fontSize: 24,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // User info rows
                    ProfileInfoRow(
                      icon: Icons.email_outlined,
                      text: profile.email,
                    ),
                    const SizedBox(height: 7),
                    ProfileInfoRow(
                      icon: Icons.phone_outlined,
                      text: profile.phone,
                    ),
                    const SizedBox(height: 7),
                    ProfileInfoRow(
                      icon: Icons.location_on_outlined,
                      text: profile.address,
                    ),
                    const SizedBox(height: 32),
                    // Management section
                    const Padding(
                      padding: EdgeInsets.only(left: 8, bottom: 16),
                      child: Text(
                        'GERENCIAMENTO',
                        style: TextStyle(
                          fontFamily: 'Figtree',
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppColors.darkGreen,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    ProfileMenuItem(
                      icon: Icons.edit_outlined,
                      label: 'Editar perfil',
                      onTap: () => context.push('/consumer/profile/edit'),
                    ),
                    const SizedBox(height: 16),
                    ProfileMenuItem(
                      icon: Icons.help_outline,
                      label: 'Termos de uso',
                      onTap: () {
                        // TODO: open terms of use
                      },
                    ),
                    const SizedBox(height: 16),
                    ProfileMenuItem(
                      icon: Icons.logout,
                      label: 'Sair',
                      onTap: () => _onLogout(context),
                      iconBackgroundColor: const Color(0x1AEF4444),
                      iconColor: const Color(0xFFDC2626),
                      labelColor: const Color(0xFFDC2626),
                      backgroundColor: const Color(0xFFFEF2F2),
                      borderColor: const Color(0xFFFEE2E2),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _onLogout(BuildContext context) {
    context.read<AuthBloc>().add(const AuthLogoutRequested());
  }
}
