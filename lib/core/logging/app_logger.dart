import 'dart:developer' as developer;

import 'package:injectable/injectable.dart';

/// Minimal structured logger built on `dart:developer` (no stray `print`s).
/// Levels follow the conventional severities used by `dart:developer.log`.
@lazySingleton
class AppLogger {
  const AppLogger();

  static const _name = 'RAGRO';

  void debug(String message) => _log(message, level: 500);

  void info(String message) => _log(message, level: 800);

  void warn(String message) => _log(message, level: 900);

  void error(String message, {Object? error, StackTrace? stackTrace}) =>
      _log(message, level: 1000, error: error, stackTrace: stackTrace);

  void _log(
    String message, {
    required int level,
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      message,
      name: _name,
      level: level,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
