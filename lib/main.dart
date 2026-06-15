import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:ragro_mobile/app.dart';
import 'package:ragro_mobile/core/di/injection.dart';
import 'package:ragro_mobile/core/services/notification_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
  await initializeDateFormatting('pt_BR');
  await configureDependencies();
  await getIt<NotificationService>().requestPermission();

  runApp(const App());
}
