// Dependency injection setup. injectable reads the annotations (@injectable,
// @lazySingleton, etc.) and generates the get_it registrations in
// injection.config.dart, making annotated classes available via getIt<T>().

import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/di/injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() => getIt.init();
