# RAGRO Architecture — Guide: Adding a New Feature

This guide uses **"Producer Reviews"** as a practical example. Follow each step in the indicated order.

---

## Checklist

```
[ ] 1. Create the folder structure in lib/features/new_feature/
[ ] 2. Start with domain/ (pure entities, no dependencies)
[ ] 3. Implement data/ (models, datasource, repository impl)
[ ] 4. Create the BLoC in presentation/ (event, state, bloc)
[ ] 5. Create the Page and Widgets
[ ] 6. Register the route in AppRouter
[ ] 7. Run build_runner
[ ] 8. Write tests
```

---

## Step 1 — Folder Structure

```bash
mkdir -p lib/features/producer_reviews/{data/{datasources,models,repositories},domain/{entities,repositories,usecases},presentation/{bloc,pages,widgets}}
```

```
lib/features/producer_reviews/
├── data/
│   ├── datasources/
│   │   └── producer_reviews_remote_datasource.dart
│   ├── models/
│   │   └── producer_review_model.dart
│   └── repositories/
│       └── producer_reviews_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── producer_review.dart
│   ├── repositories/
│   │   └── producer_reviews_repository.dart
│   └── usecases/
│       ├── get_producer_reviews.dart
│       └── submit_producer_review.dart
└── presentation/
    ├── bloc/
    │   ├── producer_reviews_bloc.dart
    │   ├── producer_reviews_event.dart
    │   └── producer_reviews_state.dart
    ├── pages/
    │   └── producer_reviews_page.dart
    └── widgets/
        ├── review_card.dart
        └── review_form.dart
```

---

## Step 2 — Domain Layer

### Entity

```dart
// lib/features/producer_reviews/domain/entities/producer_review.dart
import 'package:equatable/equatable.dart';

class ProducerReview extends Equatable {
  const ProducerReview({
    required this.id,
    required this.producerId,
    required this.consumerId,
    required this.consumerName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  final String id;
  final String producerId;
  final String consumerId;
  final String consumerName;
  final int rating;           // 1–5
  final String comment;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, producerId, consumerId, rating, comment, createdAt];
}
```

### Repository Contract

```dart
// lib/features/producer_reviews/domain/repositories/producer_reviews_repository.dart
import 'package:ragro_mobile/features/producer_reviews/domain/entities/producer_review.dart';

abstract class ProducerReviewsRepository {
  Future<List<ProducerReview>> getProducerReviews(String producerId);
  Future<ProducerReview> submitReview({
    required String producerId,
    required int rating,
    required String comment,
  });
}
```

### UseCases

```dart
// lib/features/producer_reviews/domain/usecases/get_producer_reviews.dart
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/producer_reviews/domain/entities/producer_review.dart';
import 'package:ragro_mobile/features/producer_reviews/domain/repositories/producer_reviews_repository.dart';

@lazySingleton
class GetProducerReviews {
  const GetProducerReviews(this._repository);
  final ProducerReviewsRepository _repository;

  Future<List<ProducerReview>> call(String producerId) =>
      _repository.getProducerReviews(producerId);
}
```

```dart
// lib/features/producer_reviews/domain/usecases/submit_producer_review.dart
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/producer_reviews/domain/entities/producer_review.dart';
import 'package:ragro_mobile/features/producer_reviews/domain/repositories/producer_reviews_repository.dart';

@lazySingleton
class SubmitProducerReview {
  const SubmitProducerReview(this._repository);
  final ProducerReviewsRepository _repository;

  Future<ProducerReview> call({
    required String producerId,
    required int rating,
    required String comment,
  }) =>
      _repository.submitReview(
        producerId: producerId,
        rating: rating,
        comment: comment,
      );
}
```

---

## Step 3 — Data Layer

### Model

```dart
// lib/features/producer_reviews/data/models/producer_review_model.dart
import 'package:ragro_mobile/features/producer_reviews/domain/entities/producer_review.dart';

class ProducerReviewModel extends ProducerReview {
  const ProducerReviewModel({
    required super.id,
    required super.producerId,
    required super.consumerId,
    required super.consumerName,
    required super.rating,
    required super.comment,
    required super.createdAt,
  });

  factory ProducerReviewModel.fromJson(Map<String, dynamic> json) {
    return ProducerReviewModel(
      id: json['id'] as String,
      producerId: json['producer_id'] as String,
      consumerId: json['consumer_id'] as String,
      consumerName: json['consumer_name'] as String,
      rating: json['rating'] as int,
      comment: json['comment'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'producer_id': producerId,
    'rating': rating,
    'comment': comment,
  };
}
```

### RemoteDataSource

```dart
// lib/features/producer_reviews/data/datasources/producer_reviews_remote_datasource.dart
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/network/api_client.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';
import 'package:ragro_mobile/features/producer_reviews/data/models/producer_review_model.dart';

@lazySingleton
class ProducerReviewsRemoteDataSource {
  const ProducerReviewsRemoteDataSource(this._apiClient);
  final ApiClient _apiClient;

  Future<List<ProducerReviewModel>> getProducerReviews(String producerId) async {
    try {
      final response = await _apiClient.dio.get<List<dynamic>>(
        '/producers/$producerId/reviews',
      );
      return (response.data ?? [])
          .cast<Map<String, dynamic>>()
          .map(ProducerReviewModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }

  Future<ProducerReviewModel> submitReview({
    required String producerId,
    required int rating,
    required String comment,
  }) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/producers/$producerId/reviews',
        data: {'rating': rating, 'comment': comment},
      );
      return ProducerReviewModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw e.error as ApiException? ?? const UnknownApiException();
    }
  }
}
```

### RepositoryImpl

```dart
// lib/features/producer_reviews/data/repositories/producer_reviews_repository_impl.dart
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/producer_reviews/data/datasources/producer_reviews_remote_datasource.dart';
import 'package:ragro_mobile/features/producer_reviews/domain/entities/producer_review.dart';
import 'package:ragro_mobile/features/producer_reviews/domain/repositories/producer_reviews_repository.dart';

@LazySingleton(as: ProducerReviewsRepository)
class ProducerReviewsRepositoryImpl implements ProducerReviewsRepository {
  const ProducerReviewsRepositoryImpl(this._remoteDataSource);
  final ProducerReviewsRemoteDataSource _remoteDataSource;

  @override
  Future<List<ProducerReview>> getProducerReviews(String producerId) =>
      _remoteDataSource.getProducerReviews(producerId);

  @override
  Future<ProducerReview> submitReview({
    required String producerId,
    required int rating,
    required String comment,
  }) =>
      _remoteDataSource.submitReview(
        producerId: producerId,
        rating: rating,
        comment: comment,
      );
}
```

---

## Step 4 — BLoC

### Event

```dart
// lib/features/producer_reviews/presentation/bloc/producer_reviews_event.dart
import 'package:equatable/equatable.dart';

sealed class ProducerReviewsEvent extends Equatable {
  const ProducerReviewsEvent();
  @override
  List<Object?> get props => [];
}

class ProducerReviewsStarted extends ProducerReviewsEvent {
  const ProducerReviewsStarted(this.producerId);
  final String producerId;
  @override
  List<Object?> get props => [producerId];
}

class ProducerReviewSubmitted extends ProducerReviewsEvent {
  const ProducerReviewSubmitted({
    required this.producerId,
    required this.rating,
    required this.comment,
  });
  final String producerId;
  final int rating;
  final String comment;
  @override
  List<Object?> get props => [producerId, rating, comment];
}
```

### State

```dart
// lib/features/producer_reviews/presentation/bloc/producer_reviews_state.dart
import 'package:equatable/equatable.dart';
import 'package:ragro_mobile/features/producer_reviews/domain/entities/producer_review.dart';

sealed class ProducerReviewsState extends Equatable {
  const ProducerReviewsState();
  @override
  List<Object?> get props => [];
}

class ProducerReviewsInitial extends ProducerReviewsState {
  const ProducerReviewsInitial();
}

class ProducerReviewsLoading extends ProducerReviewsState {
  const ProducerReviewsLoading();
}

class ProducerReviewsLoaded extends ProducerReviewsState {
  const ProducerReviewsLoaded(this.reviews);
  final List<ProducerReview> reviews;
  @override
  List<Object?> get props => [reviews];
}

class ProducerReviewsEmpty extends ProducerReviewsState {
  const ProducerReviewsEmpty();
}

class ProducerReviewsError extends ProducerReviewsState {
  const ProducerReviewsError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

class ProducerReviewSubmitSuccess extends ProducerReviewsState {
  const ProducerReviewSubmitSuccess();
}
```

### BLoC

```dart
// lib/features/producer_reviews/presentation/bloc/producer_reviews_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';
import 'package:ragro_mobile/features/producer_reviews/domain/usecases/get_producer_reviews.dart';
import 'package:ragro_mobile/features/producer_reviews/domain/usecases/submit_producer_review.dart';
import 'producer_reviews_event.dart';
import 'producer_reviews_state.dart';

@injectable
class ProducerReviewsBloc extends Bloc<ProducerReviewsEvent, ProducerReviewsState> {
  ProducerReviewsBloc(this._getReviews, this._submitReview)
      : super(const ProducerReviewsInitial()) {
    on<ProducerReviewsStarted>(_onStarted);
    on<ProducerReviewSubmitted>(_onSubmitted);
  }

  final GetProducerReviews _getReviews;
  final SubmitProducerReview _submitReview;

  Future<void> _onStarted(
    ProducerReviewsStarted event,
    Emitter<ProducerReviewsState> emit,
  ) async {
    emit(const ProducerReviewsLoading());
    try {
      final reviews = await _getReviews(event.producerId);
      if (reviews.isEmpty) {
        emit(const ProducerReviewsEmpty());
      } else {
        emit(ProducerReviewsLoaded(reviews));
      }
    } on ApiException catch (e) {
      emit(ProducerReviewsError(e.message));
    }
  }

  Future<void> _onSubmitted(
    ProducerReviewSubmitted event,
    Emitter<ProducerReviewsState> emit,
  ) async {
    emit(const ProducerReviewsLoading());
    try {
      await _submitReview(
        producerId: event.producerId,
        rating: event.rating,
        comment: event.comment,
      );
      emit(const ProducerReviewSubmitSuccess());
    } on ApiException catch (e) {
      emit(ProducerReviewsError(e.message));
    }
  }
}
```

---

## Step 5 — Presentation (Page + Widgets)

```dart
// lib/features/producer_reviews/presentation/pages/producer_reviews_page.dart
// Screen: Producer Reviews
// User Story: US-XX — View reviews for a producer
// Epic: EPIC 3 — Producer Profile
// Routes: GET /producers/:id/reviews

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ragro_mobile/core/di/injection.dart';
import '../bloc/producer_reviews_bloc.dart';
import '../bloc/producer_reviews_event.dart';
import '../bloc/producer_reviews_state.dart';
import '../widgets/review_card.dart';

class ProducerReviewsPage extends StatelessWidget {
  const ProducerReviewsPage({super.key, required this.producerId});
  final String producerId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProducerReviewsBloc>()
        ..add(ProducerReviewsStarted(producerId)),
      child: Scaffold(
        appBar: AppBar(title: const Text('Reviews')),
        body: BlocBuilder<ProducerReviewsBloc, ProducerReviewsState>(
          builder: (context, state) {
            return switch (state) {
              ProducerReviewsLoading() => const Center(
                  child: CircularProgressIndicator(),
                ),
              ProducerReviewsEmpty() => const Center(
                  child: Text('No reviews yet.'),
                ),
              ProducerReviewsLoaded(:final reviews) => ListView.builder(
                  itemCount: reviews.length,
                  itemBuilder: (_, i) => ReviewCard(review: reviews[i]),
                ),
              ProducerReviewsError(:final message) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(message),
                      ElevatedButton(
                        onPressed: () => context
                            .read<ProducerReviewsBloc>()
                            .add(ProducerReviewsStarted(producerId)),
                        child: const Text('Try again'),
                      ),
                    ],
                  ),
                ),
              _ => const SizedBox.shrink(),
            };
          },
        ),
      ),
    );
  }
}
```

---

## Step 6 — Register the Route in AppRouter

In `lib/core/router/app_router.dart`, add inside the corresponding branch:

```dart
GoRoute(
  path: 'reviews',
  builder: (context, state) => ProducerReviewsPage(
    producerId: state.pathParameters['producerId']!,
  ),
),
```

The resulting route would be: `/consumer/home/producer/:producerId/reviews`

---

## Step 7 — Run build_runner

```bash
dart run build_runner build --delete-conflicting-outputs
```

Verify that `lib/core/di/injection.config.dart` was updated with the new registrations for `ProducerReviewsRemoteDataSource`, `ProducerReviewsRepositoryImpl`, `GetProducerReviews`, `SubmitProducerReview`, and `ProducerReviewsBloc`.

---

## Step 8 — Write Tests

### BLoC Test

```dart
// test/features/producer_reviews/presentation/bloc/producer_reviews_bloc_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetProducerReviews extends Mock implements GetProducerReviews {}
class MockSubmitProducerReview extends Mock implements SubmitProducerReview {}

void main() {
  late MockGetProducerReviews mockGet;
  late MockSubmitProducerReview mockSubmit;

  setUp(() {
    mockGet = MockGetProducerReviews();
    mockSubmit = MockSubmitProducerReview();
  });

  blocTest<ProducerReviewsBloc, ProducerReviewsState>(
    'emits [Loading, Loaded] when reviews are found',
    build: () {
      when(() => mockGet('producer-123'))
          .thenAnswer((_) async => [fakeReview]);
      return ProducerReviewsBloc(mockGet, mockSubmit);
    },
    act: (bloc) => bloc.add(const ProducerReviewsStarted('producer-123')),
    expect: () => [
      const ProducerReviewsLoading(),
      ProducerReviewsLoaded([fakeReview]),
    ],
  );

  blocTest<ProducerReviewsBloc, ProducerReviewsState>(
    'emits [Loading, Empty] when no reviews found',
    build: () {
      when(() => mockGet('producer-123'))
          .thenAnswer((_) async => []);
      return ProducerReviewsBloc(mockGet, mockSubmit);
    },
    act: (bloc) => bloc.add(const ProducerReviewsStarted('producer-123')),
    expect: () => [
      const ProducerReviewsLoading(),
      const ProducerReviewsEmpty(),
    ],
  );
}
```

### UseCase Test

```dart
// test/features/producer_reviews/domain/usecases/get_producer_reviews_test.dart
void main() {
  late MockProducerReviewsRepository mockRepo;
  late GetProducerReviews useCase;

  setUp(() {
    mockRepo = MockProducerReviewsRepository();
    useCase = GetProducerReviews(mockRepo);
  });

  test('returns list of reviews from repository', () async {
    when(() => mockRepo.getProducerReviews('p1'))
        .thenAnswer((_) async => [fakeReview]);

    final result = await useCase('p1');

    expect(result, [fakeReview]);
    verify(() => mockRepo.getProducerReviews('p1')).called(1);
  });
}
```
