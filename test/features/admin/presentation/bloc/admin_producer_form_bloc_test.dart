import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ragro_mobile/features/admin/domain/entities/admin_producer.dart';
import 'package:ragro_mobile/features/admin/domain/usecases/create_admin_producer.dart';
import 'package:ragro_mobile/features/admin/presentation/bloc/admin_producer_form_bloc.dart';
import 'package:ragro_mobile/features/admin/presentation/bloc/admin_producer_form_event.dart';
import 'package:ragro_mobile/features/admin/presentation/bloc/admin_producer_form_state.dart';

class MockCreateAdminProducer extends Mock implements CreateAdminProducer {}

class _AdminProducerFake extends Fake implements AdminProducer {}

AdminProducerFormSubmitted _event({String? neighborhood}) =>
    AdminProducerFormSubmitted(
      name: 'João Silva',
      email: 'joao@test.com',
      phone: '51999999999',
      cep: '01234567',
      address: 'Rua das Flores',
      number: '42',
      city: 'São Paulo',
      state: 'SP',
      fiscalNumber: '52998224725',
      fiscalNumberType: 'CPF',
      farmName: 'Fazenda Bela',
      description: 'Descrição da fazenda',
      password: 'Test@123',
      scheduleWeekdays: const [true, false, false, false, false, false, false],
      scheduleStart: '08:00',
      scheduleEnd: '18:00',
      pixKeyType: 'email',
      pixKey: 'joao@test.com',
      bankName: 'Banco do Brasil',
      agency: '1234',
      accountNumber: '56789-0',
      accountType: 'checking',
      accountHolder: 'João Silva',
      neighborhood: neighborhood,
    );

void main() {
  setUpAll(() {
    registerFallbackValue(_AdminProducerFake());
  });

  late AdminProducerFormBloc bloc;
  late MockCreateAdminProducer mockCreate;

  setUp(() {
    mockCreate = MockCreateAdminProducer();
    bloc = AdminProducerFormBloc(mockCreate);
  });

  tearDown(() => bloc.close());

  group('AdminProducerFormBloc — campo neighborhood', () {
    blocTest<AdminProducerFormBloc, AdminProducerFormState>(
      'envia neighborhood preenchido para o AdminAddress',
      build: () {
        when(() => mockCreate(any(), any())).thenAnswer((_) async {});
        return AdminProducerFormBloc(mockCreate);
      },
      act: (b) => b.add(_event(neighborhood: 'Centro')),
      expect: () => [
        const AdminProducerFormLoading(),
        const AdminProducerFormSuccess(),
      ],
      verify: (_) {
        final captured = verify(() => mockCreate(captureAny(), any())).captured;
        final producer = captured.first as AdminProducer;
        expect(producer.producerAddress?.neighborhood, 'Centro');
      },
    );

    blocTest<AdminProducerFormBloc, AdminProducerFormState>(
      'envia neighborhood como null quando não preenchido',
      build: () {
        when(() => mockCreate(any(), any())).thenAnswer((_) async {});
        return AdminProducerFormBloc(mockCreate);
      },
      act: (b) => b.add(_event()),
      expect: () => [
        const AdminProducerFormLoading(),
        const AdminProducerFormSuccess(),
      ],
      verify: (_) {
        final captured = verify(() => mockCreate(captureAny(), any())).captured;
        final producer = captured.first as AdminProducer;
        expect(producer.producerAddress?.neighborhood, isNull);
      },
    );

    blocTest<AdminProducerFormBloc, AdminProducerFormState>(
      'envia neighborhood como null quando string vazia',
      build: () {
        when(() => mockCreate(any(), any())).thenAnswer((_) async {});
        return AdminProducerFormBloc(mockCreate);
      },
      act: (b) => b.add(_event(neighborhood: '')),
      expect: () => [
        const AdminProducerFormLoading(),
        const AdminProducerFormSuccess(),
      ],
      verify: (_) {
        final captured = verify(() => mockCreate(captureAny(), any())).captured;
        final producer = captured.first as AdminProducer;
        expect(producer.producerAddress?.neighborhood, isNull);
      },
    );
  });
}
