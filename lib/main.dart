import 'dart:async';
import 'dart:developer' as developer;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:ragro_mobile/app.dart';
import 'package:ragro_mobile/core/di/injection.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Future<void> main() async {
  await runZonedGuarded(() async {
    debugPrint('>>> [RAGRO] main: start');
    WidgetsFlutterBinding.ensureInitialized();
    debugPrint('>>> [RAGRO] main: WidgetsFlutterBinding ok');

    await initializeDateFormatting('pt_BR');
    debugPrint('>>> [RAGRO] main: dateFormatting ok');

    try {
      debugPrint('>>> [RAGRO] main: Firebase.initializeApp...');
      await Firebase.initializeApp();
      debugPrint('>>> [RAGRO] main: Firebase ok');
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      debugPrint('>>> [RAGRO] main: onBackgroundMessage ok');
    } on Object catch (e, st) {
      developer.log(
        'Firebase init falhou; push desabilitado',
        name: 'RAGRO',
        level: 900,
        error: e,
        stackTrace: st,
      );
      debugPrint('>>> [RAGRO] main: Firebase falhou: $e');
    }

    debugPrint('>>> [RAGRO] main: configureDependencies...');
    await configureDependencies();
    debugPrint('>>> [RAGRO] main: configureDependencies ok');

    debugPrint('>>> [RAGRO] main: runApp...');
    runApp(const App());
  }, (error, stack) {
    debugPrint('>>> [RAGRO] UNCAUGHT ERROR: $error\n$stack');
    developer.log(
      'Uncaught error em main',
      name: 'RAGRO',
      level: 1000,
      error: error,
      stackTrace: stack,
    );
  });
}
