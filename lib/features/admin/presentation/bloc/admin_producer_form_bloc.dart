import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';
import 'package:ragro_mobile/features/admin/domain/entities/admin_address.dart';
import 'package:ragro_mobile/features/admin/domain/entities/admin_availability.dart';
import 'package:ragro_mobile/features/admin/domain/entities/admin_bank_account.dart';
import 'package:ragro_mobile/features/admin/domain/entities/admin_producer.dart';
import 'package:ragro_mobile/features/admin/domain/usecases/create_admin_producer.dart';
import 'package:ragro_mobile/features/admin/presentation/bloc/admin_producer_form_event.dart';
import 'package:ragro_mobile/features/admin/presentation/bloc/admin_producer_form_state.dart';

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
      // Mapeamento UI → backend weekday:
      //   UI index 0..5 = Seg..Sáb  → backend 1..6
      //   UI index 6    = Dom       → backend 0
      final selectedDays = <AdminAvailability>[];
      for (int i = 0; i < event.scheduleWeekdays.length; i++) {
        if (event.scheduleWeekdays[i]) {
          selectedDays.add(
            AdminAvailability(
              weekday: i == 6 ? 0 : i + 1,
              opensAt: event.scheduleStart,
              closesAt: event.scheduleEnd,
            ),
          );
        }
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
        producerAddress: AdminAddress(
          street: event.address,
          number: event.number,
          city: event.city,
          state: event.state,
          zipCode: event.cep.replaceAll(RegExp(r'\D'), ''),
        ),
        bankAccount: event.bank.isNotEmpty
            ? AdminBankAccount(
                bankName: event.bank,
                agency: event.agency,
                accountNumber: event.account,
                holderName: event.accountHolder,
                fiscalNumber: event.fiscalNumber,
              )
            : null,
        availability: selectedDays.isNotEmpty ? selectedDays : null,
      );
      await _createProducer(producer, event.password);
      emit(const AdminProducerFormSuccess());
    } on ApiException catch (e) {
      emit(AdminProducerFormFailure(e.message));
    }
  }
}
