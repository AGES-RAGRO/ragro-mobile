import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ragro_mobile/core/di/injection.dart';
import 'package:ragro_mobile/core/services/cep_service.dart';
import 'package:ragro_mobile/shared/widgets/producer_form/cep_lookup.dart';
import 'package:ragro_mobile/shared/widgets/producer_form/producer_form_controllers.dart';

class MockCepService extends Mock implements CepService {}

CepAddress _address(String tag) => CepAddress(
  cep: tag,
  state: 'S$tag',
  city: 'City$tag',
  neighborhood: 'Hood$tag',
  street: 'Street$tag',
);

void main() {
  late MockCepService cep;
  late ProducerFormControllers controllers;

  setUp(() {
    cep = MockCepService();
    controllers = ProducerFormControllers();
    if (getIt.isRegistered<CepService>()) {
      getIt.unregister<CepService>();
    }
    getIt.registerSingleton<CepService>(cep);
  });

  tearDown(() {
    controllers.disposeAll();
    getIt.reset();
  });

  CepLookup buildLookup() => CepLookup(
    controllers: controllers,
    isMounted: () => true,
    applyState: (fn) => fn(),
  )..attach();

  test('applies the fetched address for a fresh, current CEP', () async {
    when(
      () => cep.fetchAddress('01001000'),
    ).thenAnswer((_) async => _address('A'));

    buildLookup();
    controllers.cep.text = '01001000';
    await Future<void>.delayed(Duration.zero);

    expect(controllers.street(), 'StreetA');
    expect(controllers.state.text, 'SA');
  });

  test('ignores a stale response superseded by a newer lookup', () async {
    // First lookup resolves slowly with "A"; second resolves fast with "B".
    final slow = Completer<CepAddress?>();
    when(() => cep.fetchAddress('11111111')).thenAnswer((_) => slow.future);
    when(
      () => cep.fetchAddress('22222222'),
    ).thenAnswer((_) async => _address('B'));

    buildLookup();

    // Type CEP #1 (slow), then immediately replace with CEP #2 (fast).
    controllers.cep.text = '11111111';
    controllers.cep.text = '22222222';

    // Let the fast lookup (#2) resolve and apply.
    await Future<void>.delayed(Duration.zero);
    expect(controllers.street(), 'StreetB');

    // Now let the stale slow lookup (#1) resolve — it must NOT overwrite #2.
    slow.complete(_address('A'));
    await Future<void>.delayed(Duration.zero);
    expect(controllers.street(), 'StreetB');
  });

  test('ignores a response whose CEP no longer matches the field', () async {
    final slow = Completer<CepAddress?>();
    when(() => cep.fetchAddress('33333333')).thenAnswer((_) => slow.future);

    buildLookup();
    controllers.cep.text = '33333333';

    // User clears the field while the request is in flight.
    controllers.cep.text = '';

    slow.complete(_address('C'));
    await Future<void>.delayed(Duration.zero);

    // The stale result must not be applied because the CEP changed.
    expect(controllers.street(), isEmpty);
  });
}

extension on ProducerFormControllers {
  String street() => address.text;
}
