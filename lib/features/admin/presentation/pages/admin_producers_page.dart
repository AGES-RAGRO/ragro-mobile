// Screen: Admin Producers (Painel Admin - Produtores)
// User Story: US-30 — Admin Manage Producers
// Epic: EPIC 5 — Admin Features
// Routes: GET /admin/producers

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ragro_mobile/core/di/injection.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/features/admin/domain/entities/admin_producer_summary.dart';
import 'package:ragro_mobile/features/admin/presentation/bloc/admin_producers_bloc.dart';
import 'package:ragro_mobile/features/admin/presentation/bloc/admin_producers_event.dart';
import 'package:ragro_mobile/features/admin/presentation/bloc/admin_producers_state.dart';

class AdminProducersPage extends StatelessWidget {
  const AdminProducersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<AdminProducersBloc>()..add(const AdminProducersStarted()),
      child: const _AdminProducersView(),
    );
  }
}

class _AdminProducersView extends StatelessWidget {
  const _AdminProducersView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Text(
                'Produtores',
                style: TextStyle(
                  fontFamily: 'Figtree',
                  fontWeight: FontWeight.w700,
                  fontSize: 34,
                  color: AppColors.darkGreen,
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<AdminProducersBloc, AdminProducersState>(
                builder: (context, state) {
                  if (state is AdminProducersLoading ||
                      state is AdminProducersInitial) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.darkGreen),
                    );
                  }
                  if (state is AdminProducersFailure) {
                    return Center(child: Text(state.message));
                  }
                  if (state is! AdminProducersLoaded) {
                    return const SizedBox.shrink();
                  }
                  if (state.producers.isEmpty) {
                    return const Center(
                      child: Text(
                        'Nenhum produtor cadastrado',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 16,
                          color: AppColors.placeholder,
                        ),
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                    itemCount: state.producers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final producer = state.producers[index];
                      return _ProducerCard(
                        producer: producer,
                        onDelete: () => _confirmDeactivate(
                          context,
                          producer.id,
                          producer.name,
                        ),
                        onEdit: () =>
                            context.push('/admin/producers/${producer.id}/edit')
                                .then((_) {
                              if (context.mounted) {
                                context
                                    .read<AdminProducersBloc>()
                                    .add(const AdminProducersRefreshed());
                              }
                            }),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              onPressed: () => context.push('/admin/producers/new'),
              icon: const Icon(Icons.add, size: 18),
              label: const Text(
                '+ Novo produtor',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkGreen,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  void _confirmDeactivate(
      BuildContext context, String producerId, String producerName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Desativar "$producerName"?'),
        action: SnackBarAction(
          label: 'Confirmar',
          textColor: AppColors.white,
          onPressed: () {
            context
                .read<AdminProducersBloc>()
                .add(AdminProducerDeactivated(producerId));
          },
        ),
        backgroundColor: AppColors.red,
      ),
    );
  }
}

class _ProducerCard extends StatelessWidget {
  const _ProducerCard({
    required this.producer,
    required this.onDelete,
    required this.onEdit,
  });


  final AdminProducerSummary producer;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    String fmtDate(DateTime d) =>
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name + action buttons row
          Row(
            children: [
              Expanded(
                child: Text(
                  producer.name,
                  style: const TextStyle(
                    fontFamily: 'Figtree',
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppColors.black,
                  ),
                ),
              ),
              // Edit
              GestureDetector(
                onTap: onEdit,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.lightGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.edit_outlined,
                      size: 16, color: AppColors.lightGreen),
                ),
              ),
              const SizedBox(width: 8),
              // Delete
              GestureDetector(
                onTap: onDelete,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.delete_outline,
                      size: 16, color: AppColors.red),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Email
          Row(
            children: [
              const Icon(Icons.email_outlined,
                  size: 14, color: AppColors.placeholder),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  producer.email,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13,
                    color: AppColors.placeholder,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          // Address
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 14, color: AppColors.placeholder),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  producer.address,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13,
                    color: AppColors.placeholder,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),
          const Divider(color: Color(0xFFE2E8F0), height: 1),
          const SizedBox(height: 8),

          // Dates
          Row(
            children: [
              _DateBadge(
                label: 'CADASTRO',
                date: fmtDate(producer.createdAt),
              ),
              const SizedBox(width: 12),
              _DateBadge(
                label: 'MODIFICADO',
                date: fmtDate(producer.updatedAt),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: producer.active
                      ? AppColors.lightGreen.withOpacity(0.1)
                      : AppColors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  producer.active ? 'ATIVO' : 'INATIVO',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                    color: producer.active
                        ? AppColors.lightGreen
                        : AppColors.red,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DateBadge extends StatelessWidget {
  const _DateBadge({required this.label, required this.date});
  final String label;
  final String date;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w700,
            fontSize: 10,
            color: AppColors.placeholder,
            letterSpacing: 0.5,
          ),
        ),
        Text(
          date,
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 12,
            color: AppColors.black,
          ),
        ),
      ],
    );
  }
}
