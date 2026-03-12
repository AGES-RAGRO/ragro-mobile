// 🚀 MAIN.DART — O ponto de partida do app.
// 1. Garante que o Flutter está inicializado (WidgetsFlutterBinding)
// 2. Configura a injeção de dependência (todas as classes anotadas ficam disponíveis)
// 3. Roda o app

import 'package:flutter/material.dart';
import 'package:ragro_mobile/app.dart';
import 'package:ragro_mobile/core/di/injection.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  runApp(const App());
}
