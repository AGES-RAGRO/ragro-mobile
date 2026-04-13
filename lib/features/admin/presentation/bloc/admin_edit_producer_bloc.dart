import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/features/admin/domain/entities/admin_address.dart';
import 'package:ragro_mobile/features/admin/domain/entities/admin_bank_account.dart';
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
      final updated = current.producer.copyWith(
        name: event.name,
        phone: event.phone,
        producerAddress: AdminAddress(
          street: event.address,
          number: '',
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
                fiscalNumber: current.producer.fiscalNumber,
              )
            : null,
        updatedAt: DateTime.now(),
      );
      await _update(updated);
      emit(const AdminEditProducerSuccess());
    } catch (e) {
      emit(AdminEditProducerFailure(e.toString()));
    }
  }
}
