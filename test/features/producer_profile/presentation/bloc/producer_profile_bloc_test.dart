import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';
import 'package:ragro_mobile/features/producer_profile/domain/usecases/get_producer_profile.dart';
import 'package:ragro_mobile/features/producer_profile/domain/usecases/update_producer.dart';
import 'package:ragro_mobile/features/producer_profile/domain/usecases/upload_producer_photo.dart';
import 'package:ragro_mobile/features/producer_profile/presentation/bloc/producer_profile_bloc.dart';
import 'package:ragro_mobile/features/producer_profile/presentation/bloc/producer_profile_event.dart';
import 'package:ragro_mobile/features/producer_profile/presentation/bloc/producer_profile_state.dart';

class MockGetProducerProfile extends Mock implements GetProducerProfile {}

class MockUpdateProducer extends Mock implements UpdateProducer {}

class MockUploadProducerAvatar extends Mock implements UploadProducerAvatar {}

class MockUploadProducerCover extends Mock implements UploadProducerCover {}

void main() {
  late ProducerProfileBloc bloc;
  late MockGetProducerProfile mockGetProducer;
  late MockUpdateProducer mockUpdateProducer;
  late MockUploadProducerAvatar mockUploadAvatar;
  late MockUploadProducerCover mockUploadCover;

  setUp(() {
    mockGetProducer = MockGetProducerProfile();
    mockUpdateProducer = MockUpdateProducer();
    mockUploadAvatar = MockUploadProducerAvatar();
    mockUploadCover = MockUploadProducerCover();
    bloc = ProducerProfileBloc(
      mockGetProducer,
      mockUpdateProducer,
      mockUploadAvatar,
      mockUploadCover,
    );
  });

  tearDown(() => bloc.close());

  const tUpdateEvent = ProducerProfileUpdateSubmitted(
    producerId: 'me',
    name: 'João Silva',
    story: 'Produtor orgânico há 10 anos.',
    phone: '(51) 99999-0001',
    farmName: 'Fazenda Sol Nascente',
  );

  group('ProducerProfileUpdateSubmitted', () {
    blocTest<ProducerProfileBloc, ProducerProfileState>(
      'emite [Updating, UpdateSuccess] quando updateProducer tem sucesso',
      build: () {
        when(
          () => mockUpdateProducer(
            producerId: any(named: 'producerId'),
            name: any(named: 'name'),
            story: any(named: 'story'),
            phone: any(named: 'phone'),
            farmName: any(named: 'farmName'),
          ),
        ).thenAnswer((_) async {});
        return bloc;
      },
      act: (b) => b.add(tUpdateEvent),
      expect: () => [
        const ProducerProfileUpdating(),
        const ProducerProfileUpdateSuccess(),
      ],
      verify: (_) {
        verify(
          () => mockUpdateProducer(
            producerId: 'me',
            name: 'João Silva',
            story: 'Produtor orgânico há 10 anos.',
            phone: '(51) 99999-0001',
            farmName: 'Fazenda Sol Nascente',
          ),
        ).called(1);
      },
    );

    blocTest<ProducerProfileBloc, ProducerProfileState>(
      'emite [Updating, Failure] quando updateProducer lança ApiException',
      build: () {
        when(
          () => mockUpdateProducer(
            producerId: any(named: 'producerId'),
            name: any(named: 'name'),
            story: any(named: 'story'),
            phone: any(named: 'phone'),
            farmName: any(named: 'farmName'),
          ),
        ).thenThrow(const UnauthorizedException('Sessão expirada'));
        return bloc;
      },
      act: (b) => b.add(tUpdateEvent),
      expect: () => [
        const ProducerProfileUpdating(),
        const ProducerProfileFailure('Sessão expirada'),
      ],
    );
  });
}
