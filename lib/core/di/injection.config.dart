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
import 'package:ragro_mobile/features/auth/data/datasources/auth_local_datasource.dart'
    as _i209;
import 'package:ragro_mobile/features/auth/data/datasources/auth_remote_datasource.dart'
    as _i201;
import 'package:ragro_mobile/features/auth/data/repositories/auth_repository_impl.dart'
    as _i579;
import 'package:ragro_mobile/features/auth/domain/repositories/auth_repository.dart'
    as _i43;
import 'package:ragro_mobile/features/auth/domain/usecases/get_current_user.dart'
    as _i846;
import 'package:ragro_mobile/features/auth/domain/usecases/login_user.dart'
    as _i1047;
import 'package:ragro_mobile/features/auth/domain/usecases/logout.dart'
    as _i418;
import 'package:ragro_mobile/features/auth/domain/usecases/register_consumer.dart'
    as _i852;
import 'package:ragro_mobile/features/auth/presentation/bloc/auth_bloc.dart'
    as _i475;
import 'package:ragro_mobile/features/auth/presentation/bloc/login_bloc.dart'
    as _i713;
import 'package:ragro_mobile/features/auth/presentation/bloc/register_bloc.dart'
    as _i192;
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
    gh.lazySingleton<_i368.ProductMockDataSource>(
      () => _i368.ProductMockDataSource(),
    );
    gh.lazySingleton<_i414.ProductRepository>(
      () => _i770.ProductRepositoryImpl(gh<_i368.ProductMockDataSource>()),
    );
    gh.lazySingleton<_i20.GetProducts>(
      () => _i20.GetProducts(gh<_i414.ProductRepository>()),
    );
    gh.lazySingleton<_i873.ApiClient>(() => _i873.ApiClient(gh<_i361.Dio>()));
    gh.factory<_i79.LearningBloc>(
      () => _i79.LearningBloc(gh<_i20.GetProducts>()),
    );
    gh.lazySingleton<_i209.AuthLocalDataSource>(
      () => _i209.AuthLocalDataSource(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i201.AuthRemoteDataSource>(
      () => _i201.AuthRemoteDataSource(gh<_i873.ApiClient>()),
    );
    gh.lazySingleton<_i43.AuthRepository>(
      () => _i579.AuthRepositoryImpl(
        gh<_i201.AuthRemoteDataSource>(),
        gh<_i209.AuthLocalDataSource>(),
        gh<_i873.ApiClient>(),
      ),
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
    gh.lazySingleton<_i852.RegisterConsumer>(
      () => _i852.RegisterConsumer(gh<_i43.AuthRepository>()),
    );
    gh.factory<_i192.RegisterBloc>(
      () => _i192.RegisterBloc(gh<_i852.RegisterConsumer>()),
    );
    gh.factory<_i475.AuthBloc>(
      () => _i475.AuthBloc(gh<_i846.GetCurrentUser>(), gh<_i418.Logout>()),
    );
    gh.factory<_i713.LoginBloc>(() => _i713.LoginBloc(gh<_i1047.LoginUser>()));
    return this;
  }
}

class _$SharedPreferencesModule extends _i55.SharedPreferencesModule {}

class _$NetworkModule extends _i1002.NetworkModule {}
