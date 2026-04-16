import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';
import 'package:ragro_mobile/features/auth/domain/entities/user.dart';
import 'package:ragro_mobile/features/auth/domain/entities/user_type.dart';
import 'package:ragro_mobile/features/auth/domain/usecases/register_customer.dart';
import 'package:ragro_mobile/features/auth/presentation/bloc/register_bloc.dart';
import 'package:ragro_mobile/features/auth/presentation/bloc/register_event.dart';
import 'package:ragro_mobile/features/auth/presentation/bloc/register_state.dart';

class MockRegisterCustomer extends Mock implements RegisterCustomer {}

void main() {
  late RegisterBloc bloc;
  late MockRegisterCustomer mockRegister;

  setUp(() {
    mockRegister = MockRegisterCustomer();
    bloc = RegisterBloc(mockRegister);
  });

  tearDown(() => bloc.close());

  const tUser = User(
    id: '2',
    name: 'Ana',
    email: 'ana@t.com',
    type: UserType.customer,
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
      ).thenThrow(const ConflictException('E-mail already registered'));
      return bloc;
    },
    act: (b) => b.add(tEvent),
    expect: () => [
      const RegisterLoading(),
      const RegisterFailure('Este e-mail já está cadastrado.'),
    ],
  );

  blocTest<RegisterBloc, RegisterState>(
    'emits [Loading, Failure] on ConflictException (fiscal number)',
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
      ).thenThrow(const ConflictException('Fiscal number already registered'));
      return bloc;
    },
    act: (b) => b.add(tEvent),
    expect: () => [
      const RegisterLoading(),
      const RegisterFailure('Este CPF já está cadastrado.'),
    ],
  );
}
