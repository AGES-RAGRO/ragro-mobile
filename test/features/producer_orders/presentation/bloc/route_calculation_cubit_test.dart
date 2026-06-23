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
import 'package:ragro_mobile/features/producer_orders/domain/usecases/refuse_producer_order.dart';
import 'package:ragro_mobile/features/producer_orders/presentation/bloc/route_calculation_cubit.dart';
import 'package:ragro_mobile/features/producer_orders/presentation/bloc/route_calculation_state.dart';

class MockRouteRepository extends Mock implements RouteRepository {}

class MockCo2Repository extends Mock implements Co2Repository {}

class MockRouteTrackingPublisher extends Mock
    implements RouteTrackingPublisher {}

class MockRefuseProducerOrder extends Mock implements RefuseProducerOrder {}

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
  late MockRefuseProducerOrder refuseProducerOrder;
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
    refuseProducerOrder = MockRefuseProducerOrder();
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
      refuseProducerOrder,
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
        refuseProducerOrder,
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

  group('cancelOrder', () {
    test(
      'refuses the order (by order id + reason) and refreshes the route',
      () async {
        final cubit = await buildLoadedCubit();
        when(
          () => refuseProducerOrder(
            any(),
            reason: any(named: 'reason'),
            details: any(named: 'details'),
          ),
        ).thenAnswer((_) async {});
        // After the refuse, the backend synced the stop to terminal; the refresh
        // re-fetches the active route with the cancelled stop removed.
        when(() => routeRepository.getActiveRoute()).thenAnswer(
          (_) async => _route(),
        );

        final ok = await cubit.cancelOrder(
          'stop-1',
          reason: 'Estoque insuficiente',
        );

        expect(ok, isTrue);
        // The refuse acts on the ORDER id (order-stop-1 per the _stop helper),
        // not the route stop id.
        verify(
          () => refuseProducerOrder(
            'order-stop-1',
            reason: 'Estoque insuficiente',
          ),
        ).called(1);
        // Route was refreshed: getActiveRoute is called again after the refuse
        // (once on load, once on refresh).
        verify(() => routeRepository.getActiveRoute()).called(greaterThan(1));
        // The cancelled stop no longer shows as a pending delivery.
        expect(cubit.state.deliveries, isEmpty);
        await cubit.close();
      },
    );

    test(
      'empties the route gracefully when the last stop is cancelled '
      '(active route now 404 -> null)',
      () async {
        final cubit = await buildLoadedCubit();
        when(
          () => refuseProducerOrder(
            any(),
            reason: any(named: 'reason'),
            details: any(named: 'details'),
          ),
        ).thenAnswer((_) async {});
        // Last stop cancelled: backend completes the route, /routes/active 404s.
        when(() => routeRepository.getActiveRoute())
            .thenAnswer((_) async => null);

        final ok = await cubit.cancelOrder(
          'stop-1',
          reason: 'Cliente solicitou cancelamento',
        );

        expect(ok, isTrue);
        expect(cubit.state.deliveries, isEmpty);
        expect(cubit.state.orderedStops, isEmpty);
        expect(cubit.state.status, isNot(RouteCalculationStatus.error));
        await cubit.close();
      },
    );

    test('emits error state and returns false when the refuse fails', () async {
      final cubit = await buildLoadedCubit();
      when(
        () => refuseProducerOrder(
          any(),
          reason: any(named: 'reason'),
          details: any(named: 'details'),
        ),
      ).thenThrow(const UnknownApiException('Não foi possível cancelar'));

      final ok = await cubit.cancelOrder(
        'stop-1',
        reason: 'Outro',
        details: 'motivo',
      );

      expect(ok, isFalse);
      expect(cubit.state.status, RouteCalculationStatus.error);
      expect(cubit.state.errorMessage, 'Não foi possível cancelar');
      await cubit.close();
    });

    test('returns false without refusing when no routeId', () async {
      when(() => routeRepository.getActiveRoute()).thenAnswer((_) async => null);
      final cubit = RouteCalculationCubit(
        co2Repository,
        routeRepository,
        trackingPublisher,
        refuseProducerOrder,
      );
      await Future<void>.delayed(Duration.zero);
      await cubit.stream.firstWhere(
        (s) => s.status == RouteCalculationStatus.error,
      ).timeout(const Duration(seconds: 2), onTimeout: () => cubit.state);

      final ok = await cubit.cancelOrder('stop-1', reason: 'Outro');

      expect(ok, isFalse);
      verifyNever(
        () => refuseProducerOrder(
          any(),
          reason: any(named: 'reason'),
          details: any(named: 'details'),
        ),
      );
      await cubit.close();
    });
  });

  group('refreshRoute', () {
    test('calls addStops and applies the returned route', () async {
      final cubit = await buildLoadedCubit();
      when(() => routeRepository.addStops(any())).thenAnswer(
        (_) async => _route(stops: [_stop(id: 'stop-1'), _stop(id: 'stop-2')]),
      );

      await cubit.refreshRoute();

      verify(() => routeRepository.addStops('route-1')).called(1);
      expect(cubit.state.deliveries.length, 2);
      expect(cubit.state.status, isNot(RouteCalculationStatus.loading));
      await cubit.close();
    });

    test('clears state when the route completed (addStops -> null)', () async {
      final cubit = await buildLoadedCubit();
      when(() => routeRepository.addStops(any())).thenAnswer((_) async => null);

      await cubit.refreshRoute();

      expect(cubit.state.deliveries, isEmpty);
      expect(cubit.state.orderedStops, isEmpty);
      await cubit.close();
    });

    test('falls back to loadRoute (no addStops) when there is no route yet', () async {
      when(() => routeRepository.getActiveRoute()).thenAnswer((_) async => null);
      final cubit = RouteCalculationCubit(
        co2Repository,
        routeRepository,
        trackingPublisher,
        refuseProducerOrder,
      );
      await Future<void>.delayed(Duration.zero);

      await cubit.refreshRoute();

      verifyNever(() => routeRepository.addStops(any()));
      await cubit.close();
    });

    test('emits the backend message on ApiException', () async {
      final cubit = await buildLoadedCubit();
      when(
        () => routeRepository.addStops(any()),
      ).thenThrow(const UnknownApiException('Falha ao otimizar a rota'));

      await cubit.refreshRoute();

      expect(cubit.state.status, RouteCalculationStatus.error);
      expect(cubit.state.errorMessage, 'Falha ao otimizar a rota');
      await cubit.close();
    });
  });

  group('loadRoute', () {
    test('surfaces the backend ApiException message (not a generic one)', () async {
      when(() => routeRepository.getActiveRoute()).thenThrow(
        const UnknownApiException(
          'Não foi possível localizar o endereço de entrega do pedido',
        ),
      );
      final cubit = RouteCalculationCubit(
        co2Repository,
        routeRepository,
        trackingPublisher,
        refuseProducerOrder,
      );
      await cubit.stream
          .firstWhere((s) => s.status == RouteCalculationStatus.error)
          .timeout(const Duration(seconds: 2), onTimeout: () => cubit.state);

      expect(
        cubit.state.errorMessage,
        'Não foi possível localizar o endereço de entrega do pedido',
      );
      await cubit.close();
    });
  });
}
