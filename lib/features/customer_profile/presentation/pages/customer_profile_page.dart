import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ragro_mobile/features/auth/presentation/bloc/auth_event.dart';
import 'package:ragro_mobile/features/customer_profile/presentation/bloc/customer_profile_bloc.dart';
import 'package:ragro_mobile/features/customer_profile/presentation/bloc/customer_profile_state.dart';
import 'package:ragro_mobile/features/customer_profile/presentation/widgets/profile_info_row.dart';
import 'package:ragro_mobile/features/customer_profile/presentation/widgets/profile_menu_item.dart';

class CustomerProfilePage extends StatelessWidget {
  const CustomerProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _CustomerProfileView();
  }
}

class _CustomerProfileView extends StatelessWidget {
  const _CustomerProfileView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<CustomerProfileBloc, CustomerProfileState>(
      listener: (context, state) {
        if (state is CustomerProfileFailure) {
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
          child: BlocBuilder<CustomerProfileBloc, CustomerProfileState>(
            builder: (context, state) {
              if (state is CustomerProfileLoading ||
                  state is CustomerProfileInitial) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.darkGreen),
                );
              }
              if (state is CustomerProfileFailure) {
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
                CustomerProfileLoaded(:final profile) => profile,
                CustomerProfileUpdating(:final profile) => profile,
                CustomerProfileUpdateSuccess(:final profile) => profile,
                CustomerProfileUpdateFailure(:final profile) => profile,
                _ => null,
              };

              if (profile == null) return const SizedBox.shrink();

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
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
                      text: profile.formattedPrimaryAddress,
                    ),
                    const SizedBox(height: 32),
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
                      onTap: () => context.push('/customer/profile/edit'),
                    ),
                    const SizedBox(height: 16),
                    ProfileMenuItem(
                      icon: Icons.help_outline,
                      label: 'Termos de uso',
                      onTap: () {},
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
