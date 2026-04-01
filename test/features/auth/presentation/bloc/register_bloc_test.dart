import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';
import 'package:ragro_mobile/features/auth/domain/entities/user.dart';
import 'package:ragro_mobile/features/auth/domain/entities/user_type.dart';
import 'package:ragro_mobile/features/auth/domain/usecases/register_consumer.dart';
import 'package:ragro_mobile/features/auth/presentation/bloc/register_bloc.dart';
import 'package:ragro_mobile/features/auth/presentation/bloc/register_event.dart';
import 'package:ragro_mobile/features/auth/presentation/bloc/register_state.dart';

class MockRegisterConsumer extends Mock implements RegisterConsumer {}

void main() {
  late RegisterBloc bloc;
  late MockRegisterConsumer mockRegister;

  setUp(() {
    mockRegister = MockRegisterConsumer();
    bloc = RegisterBloc(mockRegister);
  });

  tearDown(() => bloc.close());

  const tUser = User(
    id: '2',
    name: 'Ana',
    email: 'ana@t.com',
    type: UserType.consumer,
    active: true,
  );

  const tEvent = RegisterSubmitted(
    name: 'Ana',
    phone: '11900000000',
    email: 'ana@t.com',
    password: 'password123',
    zipCode: '01310100',
    street: 'Av. Paulista',
    number: '1000',
    city: 'São Paulo',
    state: 'SP',
  );

  blocTest<RegisterBloc, RegisterState>(
    'emits [Loading, Success] on successful registration',
    build: () {
      when(() => mockRegister(
            name: any(named: 'name'),
            phone: any(named: 'phone'),
            email: any(named: 'email'),
            password: any(named: 'password'),
            zipCode: any(named: 'zipCode'),
            street: any(named: 'street'),
            number: any(named: 'number'),
            city: any(named: 'city'),
            state: any(named: 'state'),
            complement: any(named: 'complement'),
          )).thenAnswer((_) async => tUser);
      return bloc;
    },
    act: (b) => b.add(tEvent),
    expect: () => [const RegisterLoading(), const RegisterSuccess(tUser)],
  );

  blocTest<RegisterBloc, RegisterState>(
    'emits [Loading, Failure] on ConflictException (email already exists)',
    build: () {
      when(() => mockRegister(
            name: any(named: 'name'),
            phone: any(named: 'phone'),
            email: any(named: 'email'),
            password: any(named: 'password'),
            zipCode: any(named: 'zipCode'),
            street: any(named: 'street'),
            number: any(named: 'number'),
            city: any(named: 'city'),
            state: any(named: 'state'),
            complement: any(named: 'complement'),
          )).thenThrow(const ConflictException());
      return bloc;
    },
    act: (b) => b.add(tEvent),
    expect: () => [
      const RegisterLoading(),
      const RegisterFailure('Recurso já existe'),
    ],
  );
}
