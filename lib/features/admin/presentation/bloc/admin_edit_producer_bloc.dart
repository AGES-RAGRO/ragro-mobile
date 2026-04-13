import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';
import 'package:ragro_mobile/features/admin/domain/entities/admin_address.dart';
import 'package:ragro_mobile/features/admin/domain/entities/admin_availability.dart';
import 'package:ragro_mobile/features/admin/domain/entities/admin_payment_method.dart';
import 'package:ragro_mobile/features/admin/domain/usecases/get_admin_producer_by_id.dart';
import 'package:ragro_mobile/features/admin/domain/usecases/update_admin_producer.dart';
import 'package:ragro_mobile/features/admin/presentation/bloc/admin_edit_producer_event.dart';
import 'package:ragro_mobile/features/admin/presentation/bloc/admin_edit_producer_state.dart';

@injectable
class AdminEditProducerBloc
    extends Bloc<AdminEditProducerEvent, AdminEditProducerState> {
  AdminEditProducerBloc(this._getById, this._update)
      : super(const AdminEditProducerInitial()) {
    on<AdminEditProducerLoadRequested>(_onLoadRequested);
    on<AdminEditProducerSubmitted>(_onSubmitted);
  }

  final GetAdminProducerById _getById;
  final UpdateAdminProducer _update;

  Future<void> _onLoadRequested(
    AdminEditProducerLoadRequested event,
    Emitter<AdminEditProducerState> emit,
  ) async {
    emit(const AdminEditProducerLoading());
    try {
      final producer = await _getById(event.producerId);
      emit(AdminEditProducerLoaded(producer));
    } catch (e) {
      emit(AdminEditProducerFailure(e.toString()));
    }
  }

  Future<void> _onSubmitted(
    AdminEditProducerSubmitted event,
    Emitter<AdminEditProducerState> emit,
  ) async {
    final current = state;
    if (current is! AdminEditProducerLoaded) return;

    emit(const AdminEditProducerSaving());
    try {
      // ── Horário de atendimento ──────────────────────────────────────────
      final selectedDays = <AdminAvailability>[];
      for (var i = 0; i < event.scheduleWeekdays.length; i++) {
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

      // ── Payment methods (partial update — inclui apenas o que foi preenchido) ──
      // Regra: só inclui um item se o admin preencheu o bloco inteiro daquele tipo.
      final paymentMethods = <AdminPaymentMethod>[];

      final hasPix = event.pixKeyType != null &&
          event.pixKey != null &&
          event.pixKey!.isNotEmpty;
      if (hasPix) {
        paymentMethods.add(
          AdminPaymentMethod(
            type: 'pix',
            pixKeyType: event.pixKeyType,
            pixKey: event.pixKey,
          ),
        );
      }

      final hasBank = event.bankName != null && event.bankName!.isNotEmpty;
      if (hasBank) {
        paymentMethods.add(
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
        );
      }

      final updated = current.producer.copyWith(
        name: event.name,
        phone: event.phone,
        producerAddress: AdminAddress(
          street: event.address,
          number: event.number,
          city: event.city,
          state: event.state,
          zipCode: event.cep.replaceAll(RegExp(r'\D'), ''),
        ),
        paymentMethods: paymentMethods.isNotEmpty ? paymentMethods : null,
        availability: selectedDays.isNotEmpty ? selectedDays : null,
        updatedAt: DateTime.now(),
      );

      await _update(updated);
      emit(const AdminEditProducerSuccess());
    } on ApiException catch (e) {
      emit(AdminEditProducerFailure(e.message));
    } catch (e) {
      emit(AdminEditProducerFailure(e.toString()));
    }
  }
}
