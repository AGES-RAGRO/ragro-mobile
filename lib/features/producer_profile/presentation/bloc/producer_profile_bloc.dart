import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';
import 'package:ragro_mobile/features/producer_profile/domain/usecases/get_producer_profile.dart';
import 'package:ragro_mobile/features/producer_profile/presentation/bloc/producer_profile_event.dart';
import 'package:ragro_mobile/features/producer_profile/presentation/bloc/producer_profile_state.dart';

@injectable
class ProducerProfileBloc
    extends Bloc<ProducerProfileEvent, ProducerProfileState> {
  ProducerProfileBloc(this._getProducer) : super(const ProducerProfileInitial()) {
    on<ProducerProfileStarted>(_onStarted);
  }

  final GetProducerProfile _getProducer;

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
      emit(const ProducerProfileFailure('Erro ao carregar perfil do produtor.'));
    }
  }
}
