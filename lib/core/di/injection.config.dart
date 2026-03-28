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
import 'package:ragro_mobile/core/network/api_client.dart' as _i873;
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

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final networkModule = _$NetworkModule();
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
    return this;
  }
}

class _$NetworkModule extends _i1002.NetworkModule {}
