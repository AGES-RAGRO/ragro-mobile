import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ragro_mobile/core/di/injection.dart';
import 'package:ragro_mobile/core/router/app_router.dart';
import 'package:ragro_mobile/core/theme/app_theme.dart';
import 'package:ragro_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ragro_mobile/features/auth/presentation/bloc/auth_event.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthBloc>()..add(const AuthStarted()),
      child: Builder(
        builder: (context) => MaterialApp.router(
          title: 'RAGRO',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          routerConfig: getIt<AppRouter>().router,
        ),
      ),
    );
  }
}
