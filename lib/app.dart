// APP.DART — O ponto de entrada visual do app.
// Configura o MaterialApp com tema e tela inicial.
// Por enquanto, aponta direto para a LearningPage (sem router).
// Quando o projeto evoluir, aqui entrará o GoRouter com todas as rotas.

import 'package:flutter/material.dart';
import 'package:ragro_mobile/features/learning/presentation/pages/learning_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RAGRO Mobile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.green, useMaterial3: true),
      home: const LearningPage(),
    );
  }
}
