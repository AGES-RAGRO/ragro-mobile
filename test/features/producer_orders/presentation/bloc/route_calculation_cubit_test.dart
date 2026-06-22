import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ragro_mobile/core/di/injection.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';
import 'package:ragro_mobile/features/producer_management/presentation/bloc/producer_management_bloc.dart';
import 'package:ragro_mobile/features/producer_management/presentation/bloc/producer_management_event.dart';
import 'package:ragro_mobile/features/producer_management/presentation/bloc/producer_management_state.dart';
import 'package:ragro_mobile/features/producer_orders/data/repositories/co2_repository.dart';
import 'package:ragro_mobile/features/producer_orders/data/repositories/route_repository.dart';
import 'package:ragro_mobile/features/producer_orders/data/services/route_tracking_publisher.dart';
import 'package:ragro_mobile/features/producer_orders/presentation/bloc/route_calculation_cubit.dart';
import 'package:ragro_mobile/features/producer_orders/presentation/bloc/route_calculation_state.dart';

class MockRouteRepository extends Mock implements RouteRepository {}

class MockCo2Repository extends Mock implements Co2Repository {}

class MockRouteTrackingPublisher extends Mock
    implements RouteTrackingPublisher {}

class MockProducerManagementBloc
    extends MockBloc<ProducerManagementEvent, ProducerManagementState>
    implements ProducerManagementBloc {}

DeliveryRoute _route({
  String id = 'route-1',
  String status = 'ACTIVE',
  List<DeliveryRouteStop> stops = const [],
}) {
  return DeliveryRoute(
    id: id,
    status: status,
    originLatitude: -16.6,
    originLongitude: -49.2,
    totalDistanceKm: 10,
    totalDurationSeconds: 600,
    stops: stops,
  );
}

DeliveryRouteStop _stop({
  required String id,
  String status = 'PENDING',
}) {
  return DeliveryRouteStop(
    id: id,
    orderId: 'order-$id',
    sequence: 1,
    status: status,
    latitude: -16.61,
    longitude: -49.21,
    addressText: 'Rua $id',
    customerName: 'Cliente $id',
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Geolocator hits a platform channel in the cubit's ctor (_initRoute). Stub it
  // to "deniedForever" so the GPS branch is skipped (no getCurrentPosition) and
  // the cubit proceeds straight to loadRoute() — deterministic in pure-dart tests.
  const geolocatorChannel = MethodChannel('flutter.baseflow.com/geolocator');

  late MockRouteRepository routeRepository;
  late MockCo2Repository co2Repository;
  late MockRouteTrackingPublisher trackingPublisher;
  late MockProducerManagementBloc dashboardBloc;

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(geolocatorChannel, (call) async {
      if (call.method == 'checkPermission' ||
          call.method == 'requestPermission') {
        return 1; // LocationPermission.deniedForever
      }
      return null;
    });

    routeRepository = MockRouteRepository();
    co2Repository = MockCo2Repository();
    trackingPublisher = MockRouteTrackingPublisher();
    dashboardBloc = MockProducerManagementBloc();

    // Dashboard refresh after a successful delivery resolves through getIt.
    if (getIt.isRegistered<ProducerManagementBloc>()) {
      getIt.unregister<ProducerManagementBloc>();
    }
    getIt.registerSingleton<ProducerManagementBloc>(dashboardBloc);
    // Stay in the Initial state so _refreshProducerDashboard is a no-op and we
    // assert behavior on confirmDelivery alone.
    when(() => dashboardBloc.state).thenReturn(ProducerManagementInitial());

    when(() => co2Repository.getOptions()).thenAnswer((_) async => {});
    when(() => trackingPublisher.start(any())).thenAnswer((_) async {});
    when(trackingPublisher.stop).thenAnswer((_) async {});
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(geolocatorChannel, null);
    return getIt.reset();
  });

  // Builds a cubit whose route is already loaded (routeId set) with a single
  // pending stop, so confirmDelivery has a valid target.
  Future<RouteCalculationCubit> buildLoadedCubit() async {
    when(() => routeRepository.getActiveRoute()).thenAnswer(
      (_) async => _route(stops: [_stop(id: 'stop-1')]),
    );
    final cubit = RouteCalculationCubit(
      co2Repository,
      routeRepository,
      trackingPublisher,
    );
    // Let _initRoute() settle (Geolocator throws MissingPluginException in
    // pure-dart tests and is swallowed; loadRoute then applies the active route).
    await Future<void>.delayed(Duration.zero);
    await cubit.stream.firstWhere((s) => s.routeId != null).timeout(
      const Duration(seconds: 2),
      onTimeout: () => cubit.state,
    );
    return cubit;
  }

  group('confirmDelivery', () {
    test('passes the code through to updateStop(status: DELIVERED)', () async {
      final cubit = await buildLoadedCubit();
      when(
        () => routeRepository.updateStop(
          routeId: any(named: 'routeId'),
          stopId: any(named: 'stopId'),
          status: any(named: 'status'),
          code: any(named: 'code'),
        ),
      ).thenAnswer(
        (_) async => _route(
          stops: [_stop(id: 'stop-1', status: 'DELIVERED')],
        ),
      );

      final ok = await cubit.confirmDelivery('stop-1', '1234');

      expect(ok, isTrue);
      verify(
        () => routeRepository.updateStop(
          routeId: 'route-1',
          stopId: 'stop-1',
          status: 'DELIVERED',
          code: '1234',
        ),
      ).called(1);
      await cubit.close();
    });

    test(
      'emits error state and returns false when the backend rejects the code',
      () async {
        final cubit = await buildLoadedCubit();
        when(
          () => routeRepository.updateStop(
            routeId: any(named: 'routeId'),
            stopId: any(named: 'stopId'),
            status: any(named: 'status'),
            code: any(named: 'code'),
          ),
        ).thenThrow(const UnknownApiException('Código de confirmação inválido'));

        final ok = await cubit.confirmDelivery('stop-1', '0000');

        expect(ok, isFalse);
        expect(cubit.state.status, RouteCalculationStatus.error);
        expect(cubit.state.errorMessage, 'Código de confirmação inválido');
        await cubit.close();
      },
    );

    test('returns false without calling the repo when no routeId', () async {
      when(() => routeRepository.getActiveRoute()).thenAnswer((_) async => null);
      final cubit = RouteCalculationCubit(
        co2Repository,
        routeRepository,
        trackingPublisher,
      );
      await Future<void>.delayed(Duration.zero);
      // No GPS in tests -> loadRoute can't create a route -> routeId stays null.
      await cubit.stream.firstWhere(
        (s) => s.status == RouteCalculationStatus.error,
      ).timeout(const Duration(seconds: 2), onTimeout: () => cubit.state);

      final ok = await cubit.confirmDelivery('stop-1', '1234');

      expect(ok, isFalse);
      verifyNever(
        () => routeRepository.updateStop(
          routeId: any(named: 'routeId'),
          stopId: any(named: 'stopId'),
          status: any(named: 'status'),
          code: any(named: 'code'),
        ),
      );
      await cubit.close();
    });
  });
}
