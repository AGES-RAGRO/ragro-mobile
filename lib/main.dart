import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:ragro_mobile/app.dart';
import 'package:ragro_mobile/core/di/injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR');
  await configureDependencies();

  runApp(const App());
}
