// 🍽️ PRESENTATION/PAGES — A tela que o usuário vê.
// LearningPage é o ponto de entrada da feature. Ela:
// 1. Cria o BLoC via getIt (injeção de dependência)
// 2. Dispara o evento LearningProductsRequested ao carregar
// 3. Reage aos estados do BLoC para mostrar loading, lista ou erro
//
// BlocProvider: fornece o BLoC para toda a árvore de widgets abaixo dele.
// BlocBuilder: reconstroi o widget sempre que o estado do BLoC muda.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ragro_mobile/core/di/injection.dart';
import 'package:ragro_mobile/features/learning/presentation/bloc/learning_bloc.dart';
import 'package:ragro_mobile/features/learning/presentation/bloc/learning_event.dart';
import 'package:ragro_mobile/features/learning/presentation/bloc/learning_state.dart';
import 'package:ragro_mobile/features/learning/presentation/widgets/product_card.dart';

class LearningPage extends StatelessWidget {
  const LearningPage({super.key});

  @override
  Widget build(BuildContext context) {
    // BlocProvider cria o BLoC e já dispara o primeiro evento
    // O operador ".." (cascade) chama add() e retorna o próprio BLoC
    return BlocProvider(
      create: (_) =>
          getIt<LearningBloc>()..add(const LearningProductsRequested()),
      child: const _LearningView(),
    );
  }
}

class _LearningView extends StatelessWidget {
  const _LearningView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aprendendo Flutter'),
        actions: [
          // Botão de refresh para recarregar os dados (e demonstrar o erro a cada 3 chamadas)
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<LearningBloc>().add(
              const LearningProductsRequested(),
            ),
          ),
        ],
      ),
      // BlocBuilder reconstroi o body baseado no estado atual do BLoC
      body: BlocBuilder<LearningBloc, LearningState>(
        builder: (context, state) {
          return switch (state) {
            LearningInitial() => const SizedBox.shrink(),
            LearningLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            LearningSuccess(:final products) => ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) =>
                  ProductCard(product: products[index]),
            ),
            LearningFailure(:final message) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<LearningBloc>().add(
                        const LearningProductsRequested(),
                      ),
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            ),
          };
        },
      ),
    );
  }
}
