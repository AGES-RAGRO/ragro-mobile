import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ragro_mobile/core/di/injection.dart';
import 'package:ragro_mobile/features/producer_management/presentation/bloc/producer_management_bloc.dart';
import 'package:ragro_mobile/features/producer_management/presentation/bloc/producer_management_event.dart';
import 'package:ragro_mobile/features/producer_management/presentation/bloc/producer_management_state.dart';
import 'package:ragro_mobile/features/producer_orders/data/repositories/co2_repository.dart';
import 'package:ragro_mobile/features/producer_orders/data/repositories/route_repository.dart';
import 'package:ragro_mobile/features/producer_orders/data/services/route_tracking_publisher.dart';
import 'package:ragro_mobile/features/producer_orders/presentation/bloc/route_calculation_cubit.dart';
import 'package:ragro_mobile/shared/widgets/confirm_delivery_code_dialog.dart';

class MockRouteRepository extends Mock implements RouteRepository {}

class MockCo2Repository extends Mock implements Co2Repository {}

class MockRouteTrackingPublisher extends Mock
    implements RouteTrackingPublisher {}

class MockProducerManagementBloc
    extends MockBloc<ProducerManagementEvent, ProducerManagementState>
    implements ProducerManagementBloc {}

DeliveryRoute _route({String status = 'ACTIVE', List<DeliveryRouteStop> stops = const []}) {
  return DeliveryRoute(
    id: 'route-1',
    status: status,
    originLatitude: -16.6,
    originLongitude: -49.2,
    totalDistanceKm: 10,
    totalDurationSeconds: 600,
    stops: stops,
  );
}

DeliveryRouteStop _stop({required String id, String status = 'PENDING'}) {
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
        return 1; // deniedForever
      }
      return null;
    });

    routeRepository = MockRouteRepository();
    co2Repository = MockCo2Repository();
    trackingPublisher = MockRouteTrackingPublisher();
    dashboardBloc = MockProducerManagementBloc();

    if (getIt.isRegistered<ProducerManagementBloc>()) {
      getIt.unregister<ProducerManagementBloc>();
    }
    getIt.registerSingleton<ProducerManagementBloc>(dashboardBloc);
    when(() => dashboardBloc.state).thenReturn(ProducerManagementInitial());

    when(() => co2Repository.getOptions()).thenAnswer((_) async => {});
    when(() => trackingPublisher.start(any())).thenAnswer((_) async {});
    when(trackingPublisher.stop).thenAnswer((_) async {});
    when(() => routeRepository.getActiveRoute())
        .thenAnswer((_) async => _route(stops: [_stop(id: 'stop-1')]));
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(geolocatorChannel, null);
    return getIt.reset();
  });

  // Mirrors the per-stop wiring in route_calculation_page.dart: the
  // "Confirmar Entrega" action opens the SHARED ConfirmDeliveryCodeDialog whose
  // onConfirm(code) calls cubit.confirmDelivery(id, code).
  Widget harness(RouteCalculationCubit cubit) {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<RouteCalculationCubit>.value(
          value: cubit,
          child: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () => showDialog<bool>(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => ConfirmDeliveryCodeDialog(
                    onConfirm: (code) =>
                        cubit.confirmDelivery('stop-1', code),
                  ),
                ),
                child: const Text('Confirmar Entrega'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets(
    'per-stop confirm opens the code dialog and does NOT hit the repository '
    'until a 4-digit code is entered and confirmed',
    (tester) async {
      final cubit = RouteCalculationCubit(
        co2Repository,
        routeRepository,
        trackingPublisher,
      );
      await tester.pump(); // settle _initRoute/loadRoute
      await tester.pump();

      when(
        () => routeRepository.updateStop(
          routeId: any(named: 'routeId'),
          stopId: any(named: 'stopId'),
          status: any(named: 'status'),
          code: any(named: 'code'),
        ),
      ).thenAnswer(
        (_) async => _route(stops: [_stop(id: 'stop-1', status: 'DELIVERED')]),
      );

      await tester.pumpWidget(harness(cubit));
      await tester.pumpAndSettle();

      // Tap the per-stop action -> opens the shared dialog.
      await tester.tap(find.text('Confirmar Entrega'));
      await tester.pumpAndSettle();

      expect(find.byType(ConfirmDeliveryCodeDialog), findsOneWidget);
      // The repository was NOT called just by opening the dialog.
      verifyNever(
        () => routeRepository.updateStop(
          routeId: any(named: 'routeId'),
          stopId: any(named: 'stopId'),
          status: any(named: 'status'),
          code: any(named: 'code'),
        ),
      );

      // The dialog's "Confirmar" button is disabled until 4 digits are entered:
      // tapping it now must not call the repository.
      await tester.tap(find.widgetWithText(ElevatedButton, 'Confirmar'));
      await tester.pump();
      verifyNever(
        () => routeRepository.updateStop(
          routeId: any(named: 'routeId'),
          stopId: any(named: 'stopId'),
          status: any(named: 'status'),
          code: any(named: 'code'),
        ),
      );

      // Enter the 4-digit code and confirm.
      final fields = find.byType(TextField);
      expect(fields, findsNWidgets(4));
      for (var i = 0; i < 4; i++) {
        await tester.enterText(fields.at(i), '${i + 1}');
        await tester.pump();
      }
      await tester.tap(find.widgetWithText(ElevatedButton, 'Confirmar'));
      await tester.pumpAndSettle();

      // NOW the repository is called once, with the entered code.
      verify(
        () => routeRepository.updateStop(
          routeId: 'route-1',
          stopId: 'stop-1',
          status: 'DELIVERED',
          code: '1234',
        ),
      ).called(1);

      await cubit.close();
    },
  );
}
