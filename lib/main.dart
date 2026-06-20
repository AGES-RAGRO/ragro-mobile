import 'dart:developer' as developer;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:ragro_mobile/app.dart';
import 'package:ragro_mobile/core/di/injection.dart';

/// Background/terminated message handler. Runs in its own isolate, so it cannot
/// touch the app's DI/widget tree. The backend sends a `notification` payload,
/// which the OS displays automatically — this handler just satisfies the FCM
/// requirement and ensures Firebase is ready in the isolate.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR');

  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } on Object catch (e, st) {
    // No google-services.json / Firebase config: the app keeps working without
    // push (R1/R2/R5 unaffected); FCM stays disabled until config is added.
    developer.log(
      'Firebase init falhou; push desabilitado',
      name: 'RAGRO',
      level: 900,
      error: e,
      stackTrace: st,
    );
  }

  await configureDependencies();

  runApp(const App());
}
