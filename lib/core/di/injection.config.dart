// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:ragro_mobile/core/di/network_module.dart' as _i1002;
import 'package:ragro_mobile/core/di/shared_preferences_module.dart' as _i55;
import 'package:ragro_mobile/core/network/api_client.dart' as _i873;
import 'package:ragro_mobile/core/router/app_router.dart' as _i419;
import 'package:ragro_mobile/features/admin/data/datasources/admin_remote_datasource.dart'
    as _i16;
import 'package:ragro_mobile/features/admin/data/repositories/admin_repository_impl.dart'
    as _i780;
import 'package:ragro_mobile/features/admin/domain/repositories/admin_repository.dart'
    as _i759;
import 'package:ragro_mobile/features/admin/domain/usecases/activate_admin_producer.dart'
    as _i671;
import 'package:ragro_mobile/features/admin/domain/usecases/create_admin_producer.dart'
    as _i321;
import 'package:ragro_mobile/features/admin/domain/usecases/deactivate_admin_producer.dart'
    as _i514;
import 'package:ragro_mobile/features/admin/domain/usecases/get_admin_producer_by_id.dart'
    as _i852;
import 'package:ragro_mobile/features/admin/domain/usecases/get_admin_producers.dart'
    as _i1054;
import 'package:ragro_mobile/features/admin/domain/usecases/update_admin_producer.dart'
    as _i711;
import 'package:ragro_mobile/features/admin/presentation/bloc/admin_edit_producer_bloc.dart'
    as _i914;
import 'package:ragro_mobile/features/admin/presentation/bloc/admin_producer_form_bloc.dart'
    as _i846;
import 'package:ragro_mobile/features/admin/presentation/bloc/admin_producers_bloc.dart'
    as _i1056;
import 'package:ragro_mobile/features/auth/data/datasources/auth_local_datasource.dart'
    as _i209;
import 'package:ragro_mobile/features/auth/data/datasources/auth_remote_datasource.dart'
    as _i201;
import 'package:ragro_mobile/features/auth/data/repositories/auth_repository_impl.dart'
    as _i579;
import 'package:ragro_mobile/features/auth/domain/repositories/auth_repository.dart'
    as _i43;
import 'package:ragro_mobile/features/auth/domain/usecases/forgot_password.dart'
    as _i191;
import 'package:ragro_mobile/features/auth/domain/usecases/get_current_user.dart'
    as _i846;
import 'package:ragro_mobile/features/auth/domain/usecases/login_user.dart'
    as _i1047;
import 'package:ragro_mobile/features/auth/domain/usecases/logout.dart'
    as _i418;
import 'package:ragro_mobile/features/auth/domain/usecases/register_customer.dart'
    as _i948;
import 'package:ragro_mobile/features/auth/domain/usecases/request_password_reset.dart'
    as _i485;
import 'package:ragro_mobile/features/auth/presentation/bloc/auth_bloc.dart'
    as _i475;
import 'package:ragro_mobile/features/auth/presentation/bloc/login_bloc.dart'
    as _i713;
import 'package:ragro_mobile/features/auth/presentation/bloc/register_bloc.dart'
    as _i192;
import 'package:ragro_mobile/features/cart/data/datasources/cart_local_datasource.dart'
    as _i488;
import 'package:ragro_mobile/features/cart/data/repositories/cart_repository_impl.dart'
    as _i939;
import 'package:ragro_mobile/features/cart/domain/repositories/cart_repository.dart'
    as _i830;
import 'package:ragro_mobile/features/cart/domain/usecases/add_to_cart.dart'
    as _i70;
import 'package:ragro_mobile/features/cart/domain/usecases/clear_cart.dart'
    as _i992;
import 'package:ragro_mobile/features/cart/domain/usecases/get_cart.dart'
    as _i535;
import 'package:ragro_mobile/features/cart/domain/usecases/remove_from_cart.dart'
    as _i808;
import 'package:ragro_mobile/features/cart/domain/usecases/update_cart_item_quantity.dart'
    as _i456;
import 'package:ragro_mobile/features/cart/presentation/bloc/cart_bloc.dart'
    as _i841;
import 'package:ragro_mobile/features/customer_profile/data/datasources/customer_profile_remote_datasource.dart'
    as _i666;
import 'package:ragro_mobile/features/customer_profile/data/repositories/customer_profile_repository_impl.dart'
    as _i866;
import 'package:ragro_mobile/features/customer_profile/domain/repositories/customer_profile_repository.dart'
    as _i788;
import 'package:ragro_mobile/features/customer_profile/domain/usecases/get_customer_profile.dart'
    as _i626;
import 'package:ragro_mobile/features/customer_profile/domain/usecases/update_customer_profile.dart'
    as _i436;
import 'package:ragro_mobile/features/customer_profile/presentation/bloc/customer_profile_bloc.dart'
    as _i526;
import 'package:ragro_mobile/features/home/data/datasources/home_remote_datasource.dart'
    as _i904;
import 'package:ragro_mobile/features/home/data/repositories/home_repository_impl.dart'
    as _i1055;
import 'package:ragro_mobile/features/home/domain/repositories/home_repository.dart'
    as _i285;
import 'package:ragro_mobile/features/home/domain/usecases/get_home_data.dart'
    as _i159;
import 'package:ragro_mobile/features/home/domain/usecases/get_producers.dart'
    as _i298;
import 'package:ragro_mobile/features/home/presentation/bloc/home_bloc.dart'
    as _i151;
import 'package:ragro_mobile/features/inventory/data/datasources/inventory_remote_datasource.dart'
    as _i870;
import 'package:ragro_mobile/features/inventory/data/repositories/inventory_repository_impl.dart'
    as _i601;
import 'package:ragro_mobile/features/inventory/domain/repositories/inventory_repository.dart'
    as _i276;
import 'package:ragro_mobile/features/inventory/domain/usecases/create_inventory_product.dart'
    as _i291;
import 'package:ragro_mobile/features/inventory/domain/usecases/delete_inventory_product.dart'
    as _i481;
import 'package:ragro_mobile/features/inventory/domain/usecases/get_inventory_products.dart'
    as _i252;
import 'package:ragro_mobile/features/inventory/domain/usecases/update_inventory_product.dart'
    as _i626;
import 'package:ragro_mobile/features/inventory/presentation/bloc/inventory_bloc.dart'
    as _i205;
import 'package:ragro_mobile/features/inventory/presentation/bloc/product_form_bloc.dart'
    as _i760;
import 'package:ragro_mobile/features/learning/data/datasources/product_mock_datasource.dart'
    as _i368;
import 'package:ragro_mobile/features/learning/data/repositories/product_repository_impl.dart'
    as _i770;
import 'package:ragro_mobile/features/learning/domain/repositories/product_repository.dart'
    as _i414;
import 'package:ragro_mobile/features/learning/domain/usecases/get_products.dart'
    as _i20;
import 'package:ragro_mobile/features/learning/presentation/bloc/learning_bloc.dart'
    as _i79;
import 'package:ragro_mobile/features/orders/data/datasources/orders_remote_datasource.dart'
    as _i384;
import 'package:ragro_mobile/features/orders/data/repositories/orders_repository_impl.dart'
    as _i962;
import 'package:ragro_mobile/features/orders/domain/repositories/orders_repository.dart'
    as _i165;
import 'package:ragro_mobile/features/orders/domain/usecases/confirm_order.dart'
    as _i680;
import 'package:ragro_mobile/features/orders/domain/usecases/get_order_detail.dart'
    as _i884;
import 'package:ragro_mobile/features/orders/domain/usecases/get_orders.dart'
    as _i52;
import 'package:ragro_mobile/features/orders/domain/usecases/rate_producer.dart'
    as _i907;
import 'package:ragro_mobile/features/orders/presentation/bloc/checkout_bloc.dart'
    as _i463;
import 'package:ragro_mobile/features/orders/presentation/bloc/order_detail_bloc.dart'
    as _i591;
import 'package:ragro_mobile/features/orders/presentation/bloc/orders_bloc.dart'
    as _i226;
import 'package:ragro_mobile/features/orders/presentation/bloc/rate_producer_bloc.dart'
    as _i432;
import 'package:ragro_mobile/features/producer_management/data/datasources/producer_management_remote_datasource.dart'
    as _i727;
import 'package:ragro_mobile/features/producer_management/data/repositories/producer_management_repository_impl.dart'
    as _i715;
import 'package:ragro_mobile/features/producer_management/domain/repositories/producer_management_repository.dart'
    as _i570;
import 'package:ragro_mobile/features/producer_management/domain/usecases/get_producer_dashboard.dart'
    as _i805;
import 'package:ragro_mobile/features/producer_management/presentation/bloc/producer_management_bloc.dart'
    as _i767;
import 'package:ragro_mobile/features/producer_orders/data/datasources/producer_orders_remote_datasource.dart'
    as _i608;
import 'package:ragro_mobile/features/producer_orders/data/repositories/producer_orders_repository_impl.dart'
    as _i182;
import 'package:ragro_mobile/features/producer_orders/domain/repositories/producer_orders_repository.dart'
    as _i649;
import 'package:ragro_mobile/features/producer_orders/domain/usecases/confirm_producer_order.dart'
    as _i141;
import 'package:ragro_mobile/features/producer_orders/domain/usecases/get_producer_order_detail.dart'
    as _i181;
import 'package:ragro_mobile/features/producer_orders/domain/usecases/get_producer_orders.dart'
    as _i935;
import 'package:ragro_mobile/features/producer_orders/domain/usecases/refuse_producer_order.dart'
    as _i885;
import 'package:ragro_mobile/features/producer_orders/domain/usecases/update_producer_order_status.dart'
    as _i1038;
import 'package:ragro_mobile/features/producer_orders/presentation/bloc/producer_order_detail_bloc.dart'
    as _i921;
import 'package:ragro_mobile/features/producer_orders/presentation/bloc/producer_orders_bloc.dart'
    as _i1;
import 'package:ragro_mobile/features/producer_profile/data/datasources/producer_profile_remote_datasource.dart'
    as _i889;
import 'package:ragro_mobile/features/producer_profile/data/repositories/producer_profile_repository_impl.dart'
    as _i86;
import 'package:ragro_mobile/features/producer_profile/domain/repositories/producer_profile_repository.dart'
    as _i420;
import 'package:ragro_mobile/features/producer_profile/domain/usecases/get_producer_profile.dart'
    as _i1031;
import 'package:ragro_mobile/features/producer_profile/domain/usecases/update_producer.dart'
    as _i240;
import 'package:ragro_mobile/features/producer_profile/domain/usecases/upload_producer_photo.dart'
    as _i657;
import 'package:ragro_mobile/features/producer_profile/presentation/bloc/producer_profile_bloc.dart'
    as _i756;
import 'package:ragro_mobile/features/product_detail/data/datasources/product_detail_remote_datasource.dart'
    as _i127;
import 'package:ragro_mobile/features/product_detail/data/repositories/product_detail_repository_impl.dart'
    as _i43;
import 'package:ragro_mobile/features/product_detail/domain/repositories/product_detail_repository.dart'
    as _i818;
import 'package:ragro_mobile/features/product_detail/domain/usecases/get_product_detail.dart'
    as _i680;
import 'package:ragro_mobile/features/product_detail/presentation/bloc/product_detail_bloc.dart'
    as _i740;
import 'package:ragro_mobile/features/search/data/datasources/search_remote_datasource.dart'
    as _i987;
import 'package:ragro_mobile/features/search/data/repositories/search_repository_impl.dart'
    as _i563;
import 'package:ragro_mobile/features/search/domain/repositories/search_repository.dart'
    as _i38;
import 'package:ragro_mobile/features/search/domain/usecases/search_producers_and_products.dart'
    as _i894;
import 'package:ragro_mobile/features/search/presentation/bloc/search_bloc.dart'
    as _i856;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final sharedPreferencesModule = _$SharedPreferencesModule();
    final networkModule = _$NetworkModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => sharedPreferencesModule.prefs,
      preResolve: true,
    );
    gh.lazySingleton<_i361.Dio>(() => networkModule.dio);
    gh.lazySingleton<_i488.CartLocalDatasource>(
      () => _i488.CartLocalDatasource(),
    );
    gh.lazySingleton<_i870.InventoryRemoteDataSource>(
      () => _i870.InventoryRemoteDataSource(),
    );
    gh.lazySingleton<_i368.ProductMockDataSource>(
      () => _i368.ProductMockDataSource(),
    );
    gh.lazySingleton<_i384.OrdersRemoteDatasource>(
      () => _i384.OrdersRemoteDatasource(),
    );
    gh.lazySingleton<_i727.ProducerManagementRemoteDataSource>(
      () => _i727.ProducerManagementRemoteDataSource(),
    );
    gh.lazySingleton<_i608.ProducerOrdersRemoteDataSource>(
      () => _i608.ProducerOrdersRemoteDataSource(),
    );
    gh.lazySingleton<_i127.ProductDetailRemoteDataSource>(
      () => const _i127.ProductDetailRemoteDataSource(),
    );
    gh.lazySingleton<_i165.OrdersRepository>(
      () => _i962.OrdersRepositoryImpl(gh<_i384.OrdersRemoteDatasource>()),
    );
    gh.lazySingleton<_i830.CartRepository>(
      () => _i939.CartRepositoryImpl(gh<_i488.CartLocalDatasource>()),
    );
    gh.lazySingleton<_i276.InventoryRepository>(
      () =>
          _i601.InventoryRepositoryImpl(gh<_i870.InventoryRemoteDataSource>()),
    );
    gh.lazySingleton<_i649.ProducerOrdersRepository>(
      () => _i182.ProducerOrdersRepositoryImpl(
        gh<_i608.ProducerOrdersRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i414.ProductRepository>(
      () => _i770.ProductRepositoryImpl(gh<_i368.ProductMockDataSource>()),
    );
    gh.lazySingleton<_i20.GetProducts>(
      () => _i20.GetProducts(gh<_i414.ProductRepository>()),
    );
    gh.lazySingleton<_i818.ProductDetailRepository>(
      () => _i43.ProductDetailRepositoryImpl(
        gh<_i127.ProductDetailRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i570.ProducerManagementRepository>(
      () => _i715.ProducerManagementRepositoryImpl(
        gh<_i727.ProducerManagementRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i680.ConfirmOrder>(
      () => _i680.ConfirmOrder(gh<_i165.OrdersRepository>()),
    );
    gh.lazySingleton<_i884.GetOrderDetail>(
      () => _i884.GetOrderDetail(gh<_i165.OrdersRepository>()),
    );
    gh.lazySingleton<_i52.GetOrders>(
      () => _i52.GetOrders(gh<_i165.OrdersRepository>()),
    );
    gh.lazySingleton<_i907.RateProducer>(
      () => _i907.RateProducer(gh<_i165.OrdersRepository>()),
    );
    gh.lazySingleton<_i873.ApiClient>(() => _i873.ApiClient(gh<_i361.Dio>()));
    gh.factory<_i79.LearningBloc>(
      () => _i79.LearningBloc(gh<_i20.GetProducts>()),
    );
    gh.factory<_i591.OrderDetailBloc>(
      () => _i591.OrderDetailBloc(gh<_i884.GetOrderDetail>()),
    );
    gh.lazySingleton<_i805.GetProducerDashboard>(
      () =>
          _i805.GetProducerDashboard(gh<_i570.ProducerManagementRepository>()),
    );
    gh.lazySingleton<_i209.AuthLocalDataSource>(
      () => _i209.AuthLocalDataSource(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i680.GetProductDetail>(
      () => _i680.GetProductDetail(gh<_i818.ProductDetailRepository>()),
    );
    gh.factory<_i463.CheckoutBloc>(
      () => _i463.CheckoutBloc(gh<_i680.ConfirmOrder>()),
    );
    gh.lazySingleton<_i141.ConfirmProducerOrder>(
      () => _i141.ConfirmProducerOrder(gh<_i649.ProducerOrdersRepository>()),
    );
    gh.lazySingleton<_i181.GetProducerOrderDetail>(
      () => _i181.GetProducerOrderDetail(gh<_i649.ProducerOrdersRepository>()),
    );
    gh.lazySingleton<_i935.GetProducerOrders>(
      () => _i935.GetProducerOrders(gh<_i649.ProducerOrdersRepository>()),
    );
    gh.lazySingleton<_i885.RefuseProducerOrder>(
      () => _i885.RefuseProducerOrder(gh<_i649.ProducerOrdersRepository>()),
    );
    gh.lazySingleton<_i1038.UpdateProducerOrderStatus>(
      () => _i1038.UpdateProducerOrderStatus(
        gh<_i649.ProducerOrdersRepository>(),
      ),
    );
    gh.factory<_i226.OrdersBloc>(() => _i226.OrdersBloc(gh<_i52.GetOrders>()));
    gh.factory<_i740.ProductDetailBloc>(
      () => _i740.ProductDetailBloc(gh<_i680.GetProductDetail>()),
    );
    gh.factory<_i1.ProducerOrdersBloc>(
      () => _i1.ProducerOrdersBloc(gh<_i935.GetProducerOrders>()),
    );
    gh.lazySingleton<_i894.SearchProducersAndProducts>(
      () => _i894.SearchProducersAndProducts(gh<_i38.SearchRepository>()),
    );
    gh.lazySingleton<_i70.AddToCart>(
      () => _i70.AddToCart(gh<_i830.CartRepository>()),
    );
    gh.lazySingleton<_i992.ClearCart>(
      () => _i992.ClearCart(gh<_i830.CartRepository>()),
    );
    gh.lazySingleton<_i535.GetCart>(
      () => _i535.GetCart(gh<_i830.CartRepository>()),
    );
    gh.lazySingleton<_i808.RemoveFromCart>(
      () => _i808.RemoveFromCart(gh<_i830.CartRepository>()),
    );
    gh.lazySingleton<_i456.UpdateCartItemQuantity>(
      () => _i456.UpdateCartItemQuantity(gh<_i830.CartRepository>()),
    );
    gh.factory<_i432.RateProducerBloc>(
      () => _i432.RateProducerBloc(gh<_i907.RateProducer>()),
    );
    gh.lazySingleton<_i291.CreateInventoryProduct>(
      () => _i291.CreateInventoryProduct(gh<_i276.InventoryRepository>()),
    );
    gh.lazySingleton<_i481.DeleteInventoryProduct>(
      () => _i481.DeleteInventoryProduct(gh<_i276.InventoryRepository>()),
    );
    gh.lazySingleton<_i252.GetInventoryProducts>(
      () => _i252.GetInventoryProducts(gh<_i276.InventoryRepository>()),
    );
    gh.lazySingleton<_i626.UpdateInventoryProduct>(
      () => _i626.UpdateInventoryProduct(gh<_i276.InventoryRepository>()),
    );
    gh.factory<_i760.ProductFormBloc>(
      () => _i760.ProductFormBloc(
        gh<_i252.GetInventoryProducts>(),
        gh<_i291.CreateInventoryProduct>(),
        gh<_i626.UpdateInventoryProduct>(),
      ),
    );
    gh.lazySingleton<_i16.AdminRemoteDataSource>(
      () => _i16.AdminRemoteDataSource(gh<_i873.ApiClient>()),
    );
    gh.lazySingleton<_i201.AuthRemoteDataSource>(
      () => _i201.AuthRemoteDataSource(gh<_i873.ApiClient>()),
    );
    gh.lazySingleton<_i666.CustomerProfileRemoteDataSource>(
      () => _i666.CustomerProfileRemoteDataSource(gh<_i873.ApiClient>()),
    );
    gh.lazySingleton<_i904.HomeRemoteDataSource>(
      () => _i904.HomeRemoteDataSource(gh<_i873.ApiClient>()),
    );
    gh.lazySingleton<_i889.ProducerProfileRemoteDataSource>(
      () => _i889.ProducerProfileRemoteDataSource(gh<_i873.ApiClient>()),
    );
    gh.lazySingleton<_i987.SearchRemoteDataSource>(
      () => _i987.SearchRemoteDataSource(gh<_i873.ApiClient>()),
    );
    gh.factory<_i767.ProducerManagementBloc>(
      () => _i767.ProducerManagementBloc(gh<_i805.GetProducerDashboard>()),
    );
    gh.factory<_i921.ProducerOrderDetailBloc>(
      () => _i921.ProducerOrderDetailBloc(
        gh<_i181.GetProducerOrderDetail>(),
        gh<_i141.ConfirmProducerOrder>(),
        gh<_i885.RefuseProducerOrder>(),
        gh<_i1038.UpdateProducerOrderStatus>(),
      ),
    );
    gh.lazySingleton<_i43.AuthRepository>(
      () => _i579.AuthRepositoryImpl(
        gh<_i201.AuthRemoteDataSource>(),
        gh<_i209.AuthLocalDataSource>(),
        gh<_i873.ApiClient>(),
      ),
    );
    gh.lazySingleton<_i38.SearchRepository>(
      () => _i563.SearchRepositoryImpl(gh<_i987.SearchRemoteDataSource>()),
    );
    gh.lazySingleton<_i846.GetCurrentUser>(
      () => _i846.GetCurrentUser(gh<_i43.AuthRepository>()),
    );
    gh.lazySingleton<_i1047.LoginUser>(
      () => _i1047.LoginUser(gh<_i43.AuthRepository>()),
    );
    gh.lazySingleton<_i418.Logout>(
      () => _i418.Logout(gh<_i43.AuthRepository>()),
    );
    gh.lazySingleton<_i948.RegisterCustomer>(
      () => _i948.RegisterCustomer(gh<_i43.AuthRepository>()),
    );
    gh.lazySingleton<_i485.RequestPasswordReset>(
      () => _i485.RequestPasswordReset(gh<_i43.AuthRepository>()),
    );
    gh.factory<_i205.InventoryBloc>(
      () => _i205.InventoryBloc(
        gh<_i252.GetInventoryProducts>(),
        gh<_i481.DeleteInventoryProduct>(),
      ),
    );
    gh.lazySingleton<_i759.AdminRepository>(
      () => _i780.AdminRepositoryImpl(gh<_i16.AdminRemoteDataSource>()),
    );
    gh.lazySingleton<_i841.CartBloc>(
      () => _i841.CartBloc(
        gh<_i535.GetCart>(),
        gh<_i70.AddToCart>(),
        gh<_i456.UpdateCartItemQuantity>(),
        gh<_i808.RemoveFromCart>(),
        gh<_i992.ClearCart>(),
      ),
    );
    gh.factory<_i192.RegisterBloc>(
      () => _i192.RegisterBloc(gh<_i948.RegisterCustomer>()),
    );
    gh.lazySingleton<_i671.ActivateAdminProducer>(
      () => _i671.ActivateAdminProducer(gh<_i759.AdminRepository>()),
    );
    gh.lazySingleton<_i321.CreateAdminProducer>(
      () => _i321.CreateAdminProducer(gh<_i759.AdminRepository>()),
    );
    gh.lazySingleton<_i514.DeactivateAdminProducer>(
      () => _i514.DeactivateAdminProducer(gh<_i759.AdminRepository>()),
    );
    gh.lazySingleton<_i852.GetAdminProducerById>(
      () => _i852.GetAdminProducerById(gh<_i759.AdminRepository>()),
    );
    gh.lazySingleton<_i1054.GetAdminProducers>(
      () => _i1054.GetAdminProducers(gh<_i759.AdminRepository>()),
    );
    gh.lazySingleton<_i711.UpdateAdminProducer>(
      () => _i711.UpdateAdminProducer(gh<_i759.AdminRepository>()),
    );
    gh.lazySingleton<_i420.ProducerProfileRepository>(
      () => _i86.ProducerProfileRepositoryImpl(
        gh<_i889.ProducerProfileRemoteDataSource>(),
      ),
    );
    gh.factory<_i713.LoginBloc>(
      () => _i713.LoginBloc(gh<_i1047.LoginUser>(), gh<_i191.ForgotPassword>()),
    );
    gh.lazySingleton<_i285.HomeRepository>(
      () => _i1055.HomeRepositoryImpl(gh<_i904.HomeRemoteDataSource>()),
    );
    gh.lazySingleton<_i475.AuthBloc>(
      () => _i475.AuthBloc(
        gh<_i846.GetCurrentUser>(),
        gh<_i418.Logout>(),
        gh<_i485.RequestPasswordReset>(),
      ),
    );
    gh.lazySingleton<_i788.CustomerProfileRepository>(
      () => _i866.CustomerProfileRepositoryImpl(
        gh<_i666.CustomerProfileRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i159.GetHomeData>(
      () => _i159.GetHomeData(gh<_i285.HomeRepository>()),
    );
    gh.lazySingleton<_i298.GetProducers>(
      () => _i298.GetProducers(gh<_i285.HomeRepository>()),
    );
    gh.lazySingleton<_i626.GetCustomerProfile>(
      () => _i626.GetCustomerProfile(gh<_i788.CustomerProfileRepository>()),
    );
    gh.lazySingleton<_i436.UpdateCustomerProfile>(
      () => _i436.UpdateCustomerProfile(gh<_i788.CustomerProfileRepository>()),
    );
    gh.factory<_i713.LoginBloc>(() => _i713.LoginBloc(gh<_i1047.LoginUser>()));
    gh.factory<_i151.HomeBloc>(
      () => _i151.HomeBloc(gh<_i159.GetHomeData>(), gh<_i298.GetProducers>()),
    );
    gh.factory<_i856.SearchBloc>(
      () => _i856.SearchBloc(gh<_i894.SearchProducersAndProducts>()),
    );
    gh.factory<_i914.AdminEditProducerBloc>(
      () => _i914.AdminEditProducerBloc(
        gh<_i852.GetAdminProducerById>(),
        gh<_i711.UpdateAdminProducer>(),
      ),
    );
    gh.factory<_i1056.AdminProducersBloc>(
      () => _i1056.AdminProducersBloc(
        gh<_i1054.GetAdminProducers>(),
        gh<_i514.DeactivateAdminProducer>(),
        gh<_i671.ActivateAdminProducer>(),
      ),
    );
    gh.lazySingleton<_i1031.GetProducerProfile>(
      () => _i1031.GetProducerProfile(gh<_i420.ProducerProfileRepository>()),
    );
    gh.lazySingleton<_i240.UpdateProducer>(
      () => _i240.UpdateProducer(gh<_i420.ProducerProfileRepository>()),
    );
    gh.lazySingleton<_i657.UploadProducerAvatar>(
      () => _i657.UploadProducerAvatar(gh<_i420.ProducerProfileRepository>()),
    );
    gh.lazySingleton<_i657.UploadProducerCover>(
      () => _i657.UploadProducerCover(gh<_i420.ProducerProfileRepository>()),
    );
    gh.lazySingleton<_i419.AppRouter>(
      () => _i419.AppRouter(gh<_i475.AuthBloc>()),
    );
    gh.factory<_i846.AdminProducerFormBloc>(
      () => _i846.AdminProducerFormBloc(gh<_i321.CreateAdminProducer>()),
    );
    gh.factory<_i526.CustomerProfileBloc>(
      () => _i526.CustomerProfileBloc(
        gh<_i626.GetCustomerProfile>(),
        gh<_i436.UpdateCustomerProfile>(),
      ),
    );
    gh.factory<_i756.ProducerProfileBloc>(
      () => _i756.ProducerProfileBloc(
        gh<_i1031.GetProducerProfile>(),
        gh<_i240.UpdateProducer>(),
        gh<_i657.UploadProducerAvatar>(),
        gh<_i657.UploadProducerCover>(),
      ),
    );
    return this;
  }
}

class _$SharedPreferencesModule extends _i55.SharedPreferencesModule {}

class _$NetworkModule extends _i1002.NetworkModule {}
