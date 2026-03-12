import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ragro_mobile/features/learning/domain/entities/product.dart';
import 'package:ragro_mobile/features/learning/domain/usecases/get_products.dart';
import 'package:ragro_mobile/features/learning/presentation/bloc/learning_bloc.dart';
import 'package:ragro_mobile/features/learning/presentation/bloc/learning_event.dart';
import 'package:ragro_mobile/features/learning/presentation/bloc/learning_state.dart';

class MockGetProducts extends Mock implements GetProducts {}

void main() {
  late LearningBloc bloc;
  late MockGetProducts mockGetProducts;

  setUp(() {
    mockGetProducts = MockGetProducts();
    bloc = LearningBloc(mockGetProducts);
  });

  tearDown(() => bloc.close());

  final testProducts = [
    const Product(
      id: '1',
      name: 'Soja',
      description: 'Soja em grão',
      price: 150,
    ),
  ];

  test('initial state is LearningInitial', () {
    expect(bloc.state, const LearningInitial());
  });

  blocTest<LearningBloc, LearningState>(
    'emits [Loading, Success] when products are fetched successfully',
    build: () {
      when(() => mockGetProducts()).thenAnswer((_) async => testProducts);
      return bloc;
    },
    act: (bloc) => bloc.add(const LearningProductsRequested()),
    expect: () => [const LearningLoading(), LearningSuccess(testProducts)],
  );

  blocTest<LearningBloc, LearningState>(
    'emits [Loading, Failure] when fetching products fails',
    build: () {
      when(() => mockGetProducts()).thenThrow(Exception('Erro simulado'));
      return bloc;
    },
    act: (bloc) => bloc.add(const LearningProductsRequested()),
    expect: () => [const LearningLoading(), isA<LearningFailure>()],
  );
}
