import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';
import 'package:ragro_mobile/features/admin/domain/entities/admin_address.dart';
import 'package:ragro_mobile/features/admin/domain/entities/admin_availability.dart';
import 'package:ragro_mobile/features/admin/domain/entities/admin_payment_method.dart';
import 'package:ragro_mobile/features/admin/domain/entities/admin_producer.dart';
import 'package:ragro_mobile/features/admin/domain/usecases/create_admin_producer.dart';
import 'package:ragro_mobile/features/admin/presentation/bloc/admin_producer_form_event.dart';
import 'package:ragro_mobile/features/admin/presentation/bloc/admin_producer_form_state.dart';
import 'package:ragro_mobile/shared/widgets/producer_form/weekday_mapper.dart';

@injectable
class AdminProducerFormBloc
    extends Bloc<AdminProducerFormEvent, AdminProducerFormState> {
  AdminProducerFormBloc(this._createProducer)
    : super(const AdminProducerFormInitial()) {
    on<AdminProducerFormSubmitted>(_onSubmitted);
  }

  final CreateAdminProducer _createProducer;

  Future<void> _onSubmitted(
    AdminProducerFormSubmitted event,
    Emitter<AdminProducerFormState> emit,
  ) async {
    emit(const AdminProducerFormLoading());
    try {
      // Map UI weekday to backend weekday:
      //   UI index 0..5 = Mon..Sat -> backend 1..6
      //   UI index 6    = Sun      -> backend 0
      final selectedDays = <AdminAvailability>[];
      for (var i = 0; i < event.scheduleWeekdays.length; i++) {
        if (event.scheduleWeekdays[i]) {
          selectedDays.add(
            AdminAvailability(
              weekday: WeekdayMapper.toApi(i),
              opensAt: event.scheduleStart,
              closesAt: event.scheduleEnd,
            ),
          );
        }
      }

      // Backend requires both payment methods (pix + bank_account); the page
      // validates this before dispatching the event.
      final paymentMethods = <AdminPaymentMethod>[
        AdminPaymentMethod(
          type: 'pix',
          pixKeyType: event.pixKeyType,
          pixKey: event.pixKey,
        ),
        AdminPaymentMethod(
          type: 'bank_account',
          bankCode: event.bankCode,
          bankName: event.bankName,
          agency: event.agency,
          accountNumber: event.accountNumber,
          accountType: event.accountType,
          holderName: event.accountHolder,
          fiscalNumber: event.bankFiscalNumber,
        ),
      ];

      double? lat;
      double? lng;
      try {
        final fullAddress =
            '${event.address}, ${event.number}, ${event.city}, ${event.state}';
        final locations = await locationFromAddress(fullAddress);
        if (locations.isNotEmpty) {
          lat = locations.first.latitude;
          lng = locations.first.longitude;
        }
      } on Object catch (_) {
        // Ignore geocoding errors so they don't block creation (o plugin de
        // geocoding pode lançar tipos fora de Exception, ex.: em ambiente de teste).
      }

      final producer = AdminProducer(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: event.name,
        email: event.email,
        phone: event.phone,
        address: '${event.address}, ${event.city}, ${event.state}',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        active: true,
        fiscalNumber: event.fiscalNumber,
        fiscalNumberType: event.fiscalNumberType,
        farmName: event.farmName,
        description: event.description,
        producerAddress: AdminAddress(
          street: event.address,
          number: event.number,
          city: event.city,
          state: event.state,
          zipCode: event.cep.replaceAll(RegExp(r'\D'), ''),
          neighborhood: (event.neighborhood?.isNotEmpty ?? false)
              ? event.neighborhood
              : null,
          latitude: lat,
          longitude: lng,
        ),
        paymentMethods: paymentMethods,
        availability: selectedDays.isNotEmpty ? selectedDays : null,
      );
      await _createProducer(producer, event.password);
      emit(const AdminProducerFormSuccess());
    } on ApiException catch (e) {
      emit(AdminProducerFormFailure(e.message));
    }
  }
}
