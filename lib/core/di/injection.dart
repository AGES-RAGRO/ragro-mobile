// DI setup. injectable generates get_it registrations from annotations into
// injection.config.dart, exposing annotated classes via getIt<T>().

import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/di/injection.config.dart';
import 'package:ragro_mobile/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:ragro_mobile/features/home/presentation/bloc/home_bloc.dart';
import 'package:ragro_mobile/features/inventory/presentation/bloc/inventory_bloc.dart';
import 'package:ragro_mobile/features/orders/presentation/bloc/active_delivery_cubit.dart';
import 'package:ragro_mobile/features/producer_management/presentation/bloc/producer_management_bloc.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() => getIt.init();

/// Resets session-scoped `@lazySingleton` blocs/cubits so the next login never
/// shows the previous user's data (even for one frame). Excludes factories (new
/// instance per use) and NotificationsBloc (held in app.dart and cleared via
/// NotificationsReset; a get_it reset would desync the root reference).
/// Reset without close on purpose: old instances may still be mounted in the
/// shell's IndexedStack; get_it then builds fresh instances on next access.
void resetSessionScopedBlocs() {
  // isRegistered-guarded so tests without full configureDependencies don't break.
  _resetIfRegistered<HomeBloc>();
  _resetIfRegistered<CartBloc>();
  _resetIfRegistered<ProducerManagementBloc>();
  _resetIfRegistered<InventoryBloc>();
  _resetIfRegistered<ActiveDeliveryCubit>();
}

void _resetIfRegistered<T extends Object>() {
  if (getIt.isRegistered<T>()) {
    getIt.resetLazySingleton<T>();
  }
}
