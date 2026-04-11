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
    fiscalNumber: '12345678901',
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
      when(
        () => mockRegister(
          name: any(named: 'name'),
          phone: any(named: 'phone'),
          email: any(named: 'email'),
          fiscalNumber: any(named: 'fiscalNumber'),
          password: any(named: 'password'),
          zipCode: any(named: 'zipCode'),
          street: any(named: 'street'),
          number: any(named: 'number'),
          city: any(named: 'city'),
          state: any(named: 'state'),
          complement: any(named: 'complement'),
          neighborhood: any(named: 'neighborhood'),
        ),
      ).thenAnswer((_) async => tUser);
      return bloc;
    },
    act: (b) => b.add(tEvent),
    expect: () => [const RegisterLoading(), const RegisterSuccess(tUser)],
  );

  blocTest<RegisterBloc, RegisterState>(
    'emits [Loading, Failure] on ConflictException (email already exists)',
    build: () {
      when(
        () => mockRegister(
          name: any(named: 'name'),
          phone: any(named: 'phone'),
          email: any(named: 'email'),
          fiscalNumber: any(named: 'fiscalNumber'),
          password: any(named: 'password'),
          zipCode: any(named: 'zipCode'),
          street: any(named: 'street'),
          number: any(named: 'number'),
          city: any(named: 'city'),
          state: any(named: 'state'),
          complement: any(named: 'complement'),
          neighborhood: any(named: 'neighborhood'),
        ),
      ).thenThrow(const ConflictException('Este e-mail já está em uso.'));
      return bloc;
    },
    act: (b) => b.add(tEvent),
    expect: () => [
      const RegisterLoading(),
      const RegisterFailure('Este e-mail já está em uso.'),
    ],
  );

  blocTest<RegisterBloc, RegisterState>(
    'emits [Loading, Failure] on ConflictException (CPF already registered)',
    build: () {
      when(
        () => mockRegister(
          name: any(named: 'name'),
          phone: any(named: 'phone'),
          email: any(named: 'email'),
          fiscalNumber: any(named: 'fiscalNumber'),
          password: any(named: 'password'),
          zipCode: any(named: 'zipCode'),
          street: any(named: 'street'),
          number: any(named: 'number'),
          city: any(named: 'city'),
          state: any(named: 'state'),
          complement: any(named: 'complement'),
          neighborhood: any(named: 'neighborhood'),
        ),
      ).thenThrow(const ConflictException('Este CPF já está cadastrado.'));
      return bloc;
    },
    act: (b) => b.add(tEvent),
    expect: () => [
      const RegisterLoading(),
      const RegisterFailure('Este CPF já está cadastrado.'),
    ],
  );

  blocTest<RegisterBloc, RegisterState>(
    'emits [Loading, Failure] on ConflictException (generic 409)',
    build: () {
      when(
        () => mockRegister(
          name: any(named: 'name'),
          phone: any(named: 'phone'),
          email: any(named: 'email'),
          fiscalNumber: any(named: 'fiscalNumber'),
          password: any(named: 'password'),
          zipCode: any(named: 'zipCode'),
          street: any(named: 'street'),
          number: any(named: 'number'),
          city: any(named: 'city'),
          state: any(named: 'state'),
          complement: any(named: 'complement'),
          neighborhood: any(named: 'neighborhood'),
        ),
      ).thenThrow(const ConflictException('E-mail ou CPF já cadastrado.'));
      return bloc;
    },
    act: (b) => b.add(tEvent),
    expect: () => [
      const RegisterLoading(),
      const RegisterFailure('E-mail ou CPF já cadastrado.'),
    ],
  );

  blocTest<RegisterBloc, RegisterState>(
    'emits [Loading, Failure] on UnknownApiException (400)',
    build: () {
      when(
        () => mockRegister(
          name: any(named: 'name'),
          phone: any(named: 'phone'),
          email: any(named: 'email'),
          fiscalNumber: any(named: 'fiscalNumber'),
          password: any(named: 'password'),
          zipCode: any(named: 'zipCode'),
          street: any(named: 'street'),
          number: any(named: 'number'),
          city: any(named: 'city'),
          state: any(named: 'state'),
          complement: any(named: 'complement'),
          neighborhood: any(named: 'neighborhood'),
        ),
      ).thenThrow(const UnknownApiException('Campo inválido'));
      return bloc;
    },
    act: (b) => b.add(tEvent),
    expect: () => [
      const RegisterLoading(),
      const RegisterFailure('Campo inválido'),
    ],
  );

  blocTest<RegisterBloc, RegisterState>(
    'emits [Loading, Failure] on ServerException (500)',
    build: () {
      when(
        () => mockRegister(
          name: any(named: 'name'),
          phone: any(named: 'phone'),
          email: any(named: 'email'),
          fiscalNumber: any(named: 'fiscalNumber'),
          password: any(named: 'password'),
          zipCode: any(named: 'zipCode'),
          street: any(named: 'street'),
          number: any(named: 'number'),
          city: any(named: 'city'),
          state: any(named: 'state'),
          complement: any(named: 'complement'),
          neighborhood: any(named: 'neighborhood'),
        ),
      ).thenThrow(const ServerException());
      return bloc;
    },
    act: (b) => b.add(tEvent),
    expect: () => [
      const RegisterLoading(),
      const RegisterFailure('Erro interno do servidor'),
    ],
  );

  blocTest<RegisterBloc, RegisterState>(
    'emits [Loading, Failure] on NetworkException',
    build: () {
      when(
        () => mockRegister(
          name: any(named: 'name'),
          phone: any(named: 'phone'),
          email: any(named: 'email'),
          fiscalNumber: any(named: 'fiscalNumber'),
          password: any(named: 'password'),
          zipCode: any(named: 'zipCode'),
          street: any(named: 'street'),
          number: any(named: 'number'),
          city: any(named: 'city'),
          state: any(named: 'state'),
          complement: any(named: 'complement'),
          neighborhood: any(named: 'neighborhood'),
        ),
      ).thenThrow(const NetworkException());
      return bloc;
    },
    act: (b) => b.add(tEvent),
    expect: () => [
      const RegisterLoading(),
      const RegisterFailure('Sem conexão com a internet'),
    ],
  );
}
