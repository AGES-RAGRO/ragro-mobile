import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ragro_mobile/features/admin/domain/entities/admin_producer.dart';
import 'package:ragro_mobile/features/admin/domain/usecases/get_admin_producer_by_id.dart';
import 'package:ragro_mobile/features/admin/domain/usecases/update_admin_producer.dart';
import 'package:ragro_mobile/features/admin/presentation/bloc/admin_edit_producer_bloc.dart';
import 'package:ragro_mobile/features/admin/presentation/bloc/admin_edit_producer_event.dart';
import 'package:ragro_mobile/features/admin/presentation/bloc/admin_edit_producer_state.dart';

class MockGetAdminProducerById extends Mock implements GetAdminProducerById {}

class MockUpdateAdminProducer extends Mock implements UpdateAdminProducer {}

class _AdminProducerFake extends Fake implements AdminProducer {}

final _tProducer = AdminProducer(
  id: 'p1',
  name: 'João Silva',
  email: 'joao@test.com',
  phone: '51999999999',
  address: 'Rua das Flores, 42, São Paulo, SP',
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
  active: true,
  fiscalNumber: '52998224725',
  fiscalNumberType: 'CPF',
  farmName: 'Fazenda Bela',
  description: 'Descrição da fazenda',
);

AdminEditProducerSubmitted _event({String? neighborhood}) =>
    AdminEditProducerSubmitted(
      name: 'João Silva',
      email: 'joao@test.com',
      phone: '51999999999',
      cep: '01234567',
      address: 'Rua das Flores',
      number: '42',
      city: 'São Paulo',
      state: 'SP',
      cpfCnpj: '52998224725',
      farmName: 'Fazenda Bela',
      description: 'Descrição da fazenda',
      scheduleWeekdays: const [true, false, false, false, false, false, false],
      scheduleStart: '08:00',
      scheduleEnd: '18:00',
      neighborhood: neighborhood,
    );

void main() {
  setUpAll(() {
    registerFallbackValue(_AdminProducerFake());
  });

  late MockGetAdminProducerById mockGetById;
  late MockUpdateAdminProducer mockUpdate;

  setUp(() {
    mockGetById = MockGetAdminProducerById();
    mockUpdate = MockUpdateAdminProducer();
  });

  group('AdminEditProducerBloc — campo neighborhood', () {
    blocTest<AdminEditProducerBloc, AdminEditProducerState>(
      'envia neighborhood preenchido para o AdminAddress',
      build: () {
        when(() => mockUpdate(any())).thenAnswer((_) async {});
        return AdminEditProducerBloc(mockGetById, mockUpdate);
      },
      seed: () => AdminEditProducerLoaded(_tProducer),
      act: (b) => b.add(_event(neighborhood: 'Centro')),
      expect: () => [
        const AdminEditProducerSaving(),
        const AdminEditProducerSuccess(),
      ],
      verify: (_) {
        final captured = verify(() => mockUpdate(captureAny())).captured;
        final producer = captured.first as AdminProducer;
        expect(producer.producerAddress?.neighborhood, 'Centro');
      },
    );

    blocTest<AdminEditProducerBloc, AdminEditProducerState>(
      'envia neighborhood como null quando não preenchido',
      build: () {
        when(() => mockUpdate(any())).thenAnswer((_) async {});
        return AdminEditProducerBloc(mockGetById, mockUpdate);
      },
      seed: () => AdminEditProducerLoaded(_tProducer),
      act: (b) => b.add(_event()),
      expect: () => [
        const AdminEditProducerSaving(),
        const AdminEditProducerSuccess(),
      ],
      verify: (_) {
        final captured = verify(() => mockUpdate(captureAny())).captured;
        final producer = captured.first as AdminProducer;
        expect(producer.producerAddress?.neighborhood, isNull);
      },
    );

    blocTest<AdminEditProducerBloc, AdminEditProducerState>(
      'envia neighborhood como null quando string vazia',
      build: () {
        when(() => mockUpdate(any())).thenAnswer((_) async {});
        return AdminEditProducerBloc(mockGetById, mockUpdate);
      },
      seed: () => AdminEditProducerLoaded(_tProducer),
      act: (b) => b.add(_event(neighborhood: '')),
      expect: () => [
        const AdminEditProducerSaving(),
        const AdminEditProducerSuccess(),
      ],
      verify: (_) {
        final captured = verify(() => mockUpdate(captureAny())).captured;
        final producer = captured.first as AdminProducer;
        expect(producer.producerAddress?.neighborhood, isNull);
      },
    );
  });
}
