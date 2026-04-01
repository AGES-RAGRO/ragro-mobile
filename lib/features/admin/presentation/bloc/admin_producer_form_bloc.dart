import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
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
      final producer = AdminProducer(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: event.name,
        email: event.email,
        location: '${event.city}, ${event.state}',
        address: '${event.address}, ${event.city}, ${event.state}',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        active: true,
      );
      await _createProducer(producer, event.password);
      emit(const AdminProducerFormSuccess());
    } catch (e) {
      emit(AdminProducerFormFailure(e.toString()));
    }
  }
}
