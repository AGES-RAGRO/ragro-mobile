// Screen: Admin Producers (Painel Admin - Produtores)
// User Story: US-30 — Admin Manage Producers
// Epic: EPIC 5 — Admin Features
// Routes: GET /admin/producers

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ragro_mobile/core/di/injection.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/features/admin/domain/entities/admin_producer.dart';
import 'package:ragro_mobile/features/admin/presentation/bloc/admin_producers_bloc.dart';
import 'package:ragro_mobile/features/admin/presentation/bloc/admin_producers_event.dart';
import 'package:ragro_mobile/features/admin/presentation/bloc/admin_producers_state.dart';
import 'package:ragro_mobile/shared/widgets/confirm_dialog.dart';

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
              child: BlocConsumer<AdminProducersBloc, AdminProducersState>(
                listenWhen: (previous, current) =>
                    current is AdminProducerMutationFailure,
                listener: (context, state) {
                  if (state is AdminProducerMutationFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppColors.red,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is AdminProducersLoading ||
                      state is AdminProducersInitial) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.darkGreen,
                      ),
                    );
                  }
                  if (state is AdminProducersFailure) {
                    return Center(child: Text(state.message));
                  }

                  final List<AdminProducer> producers;
                  final bool isMutating;
                  if (state is AdminProducersLoaded) {
                    producers = state.producers;
                    isMutating = false;
                  } else if (state is AdminProducersMutating) {
                    producers = state.previousProducers;
                    isMutating = true;
                  } else if (state is AdminProducerMutationFailure) {
                    producers = state.previousProducers;
                    isMutating = false;
                  } else {
                    return const SizedBox.shrink();
                  }

                  if (producers.isEmpty) {
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

                  return Stack(
                    children: [
                      ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                        itemCount: producers.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final producer = producers[index];
                          return _ProducerCard(
                            producer: producer,
                            enabled: !isMutating,
                            onToggleActive: () => _confirmMutation(
                              context: context,
                              producer: producer,
                            ),
                            onEdit: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Editar ${producer.name} — em breve',
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      if (isMutating)
                        Positioned.fill(
                          child: ColoredBox(
                            color: Colors.black.withValues(alpha: 0.08),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.darkGreen,
                              ),
                            ),
                          ),
                        ),
                    ],
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
              onPressed: () async {
                final created = await context.push<bool>(
                  '/admin/producers/new',
                );
                if ((created ?? false) && context.mounted) {
                  context.read<AdminProducersBloc>().add(
                    const AdminProducersStarted(),
                  );
                }
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text(
                'Novo produtor',
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
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Future<void> _confirmMutation({
    required BuildContext context,
    required AdminProducer producer,
  }) async {
    final isDeactivating = producer.active;
    final verb = isDeactivating ? 'desativar' : 'ativar';
    final confirmLabel = isDeactivating ? 'Desativar' : 'Ativar';
    final highlightColor = isDeactivating ? AppColors.red : AppColors.darkGreen;

    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Tem certeza que deseja\n$verb ',
      highlight: producer.name,
      highlightColor: highlightColor,
      trailingTitle: '?',
      confirmLabel: confirmLabel,
      confirmColor: highlightColor,
    );

    if (confirmed != true || !context.mounted) return;

    final bloc = context.read<AdminProducersBloc>();
    if (isDeactivating) {
      bloc.add(AdminProducerDeactivated(producer.id));
    } else {
      bloc.add(AdminProducerActivated(producer.id));
    }
  }
}

class _ProducerCard extends StatelessWidget {
  const _ProducerCard({
    required this.producer,
    required this.onToggleActive,
    required this.onEdit,
    required this.enabled,
  });

  final AdminProducer producer;
  final VoidCallback onToggleActive;
  final VoidCallback onEdit;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    String fmtDate(DateTime d) =>
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

    final toggleColor = producer.active ? AppColors.red : AppColors.darkGreen;
    final toggleIcon = producer.active ? Icons.delete_outline : Icons.restore;
    final toggleTooltip = producer.active
        ? 'Desativar produtor'
        : 'Ativar produtor';

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
              Tooltip(
                message: 'Editar produtor',
                child: Semantics(
                  button: true,
                  label: 'Editar ${producer.name}',
                  child: InkWell(
                    onTap: enabled ? onEdit : null,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.lightGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.edit_outlined,
                        size: 16,
                        color: AppColors.lightGreen,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Tooltip(
                message: toggleTooltip,
                child: Semantics(
                  button: true,
                  label: '$toggleTooltip ${producer.name}',
                  child: InkWell(
                    onTap: enabled ? onToggleActive : null,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: toggleColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(toggleIcon, size: 16, color: toggleColor),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.email_outlined,
                size: 14,
                color: AppColors.placeholder,
              ),
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 14,
                color: AppColors.placeholder,
              ),
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
          Row(
            children: [
              _DateBadge(label: 'CADASTRO', date: fmtDate(producer.createdAt)),
              const SizedBox(width: 12),
              _DateBadge(
                label: 'MODIFICADO',
                date: fmtDate(producer.updatedAt),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: producer.active
                      ? AppColors.lightGreen.withValues(alpha: 0.1)
                      : AppColors.red.withValues(alpha: 0.1),
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
