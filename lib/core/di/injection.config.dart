// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:ragro_mobile/features/learning/data/datasources/product_mock_datasource.dart'
    as _i368;
import 'package:ragro_mobile/features/learning/data/repositories/product_repository_impl.dart'
    as _i770;
import 'package:ragro_mobile/features/learning/domain/repositories/product_repository.dart'
    as _i414;
import 'package:ragro_mobile/features/learning/domain/usecases/get_products.dart'
    as _i20;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.lazySingleton<_i368.ProductMockDataSource>(
      () => _i368.ProductMockDataSource(),
    );
    gh.lazySingleton<_i414.ProductRepository>(
      () => _i770.ProductRepositoryImpl(gh<_i368.ProductMockDataSource>()),
    );
    gh.lazySingleton<_i20.GetProducts>(
      () => _i20.GetProducts(gh<_i414.ProductRepository>()),
    );
    return this;
  }
}
