// CORE/DI — Injeção de Dependência.
// Aqui configuramos o get_it (um "armário" global de dependências) com o injectable.
// O injectable lê as anotações (@injectable, @lazySingleton, etc.) e gera o código
// que registra todas as dependências automaticamente em injection.config.dart.
//
// Na prática: você anota uma classe e ela fica disponível em qualquer lugar via getIt<Classe>().

import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/di/injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() => getIt.init();
