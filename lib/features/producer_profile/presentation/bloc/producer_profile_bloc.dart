import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';
import 'package:ragro_mobile/features/producer_profile/domain/usecases/get_producer_profile.dart';
import 'package:ragro_mobile/features/producer_profile/domain/usecases/update_producer.dart';
import 'package:ragro_mobile/features/producer_profile/presentation/bloc/producer_profile_event.dart';
import 'package:ragro_mobile/features/producer_profile/presentation/bloc/producer_profile_state.dart';

@injectable
class ProducerProfileBloc
    extends Bloc<ProducerProfileEvent, ProducerProfileState> {
  ProducerProfileBloc(this._getProducer, this._updateProducer)
    : super(const ProducerProfileInitial()) {
    on<ProducerProfileStarted>(_onStarted);
    on<ProducerProfileUpdateSubmitted>(_onUpdateSubmitted);
  }

  final GetProducerProfile _getProducer;
  final UpdateProducer _updateProducer;

  Future<void> _onStarted(
    ProducerProfileStarted event,
    Emitter<ProducerProfileState> emit,
  ) async {
    emit(const ProducerProfileLoading());
    try {
      final producer = await _getProducer(event.producerId);
      emit(ProducerProfileLoaded(producer));
    } on ApiException catch (e) {
      emit(ProducerProfileFailure(e.message));
    } catch (_) {
      emit(
        const ProducerProfileFailure('Erro ao carregar perfil do produtor.'),
      );
    }
  }

  Future<void> _onUpdateSubmitted(
    ProducerProfileUpdateSubmitted event,
    Emitter<ProducerProfileState> emit,
  ) async {
    emit(const ProducerProfileUpdating());
    try {
      await _updateProducer(
        producerId: event.producerId,
        name: event.name,
        story: event.story,
        phone: event.phone,
        location: event.location,
      );
      emit(const ProducerProfileUpdateSuccess());
    } on ApiException catch (e) {
      emit(ProducerProfileFailure(e.message));
    }
  }
}
