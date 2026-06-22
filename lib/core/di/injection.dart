// Dependency injection setup. injectable reads the annotations (@injectable,
// @lazySingleton, etc.) and generates the get_it registrations in
// injection.config.dart, making annotated classes available via getIt<T>().

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

/// Reseta os singletons que guardam dados da sessão do usuário, para que um
/// próximo login não exiba (nem por um frame) dados do usuário anterior.
///
/// Cobre os blocs/cubits `@lazySingleton` providos por shell/página (re-lidos do
/// get_it no próximo login). NÃO inclui:
/// - factories (Orders/CustomerProfile/Recommendations): instância nova a cada uso;
/// - NotificationsBloc: é segurado na raiz (app.dart) por toda a vida do app e
///   já é limpo via evento `NotificationsReset` no logout — um reset no get_it
///   deixaria a referência da raiz dessincronizada.
///
/// Reset SEM fechar de propósito: as instâncias antigas ainda podem estar
/// montadas no IndexedStack do shell no momento do logout; o get_it passa a
/// criar instâncias novas (estado inicial) no próximo acesso.
void resetSessionScopedBlocs() {
  // Guardado por isRegistered para não quebrar em testes que não rodam o
  // configureDependencies completo.
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
