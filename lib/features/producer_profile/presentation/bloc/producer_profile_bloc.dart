import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';
import 'package:ragro_mobile/features/producer_profile/domain/entities/public_producer.dart';
import 'package:ragro_mobile/features/producer_profile/domain/usecases/get_producer_profile.dart';
import 'package:ragro_mobile/features/producer_profile/domain/usecases/update_producer.dart';
import 'package:ragro_mobile/features/producer_profile/domain/usecases/upload_producer_photo.dart';
import 'package:ragro_mobile/features/producer_profile/presentation/bloc/producer_profile_event.dart';
import 'package:ragro_mobile/features/producer_profile/presentation/bloc/producer_profile_state.dart';

@injectable
class ProducerProfileBloc
    extends Bloc<ProducerProfileEvent, ProducerProfileState> {
  ProducerProfileBloc(
    this._getProducer,
    this._updateProducer,
    this._uploadAvatar,
    this._uploadCover,
  ) : super(const ProducerProfileInitial()) {
    on<ProducerProfileStarted>(_onStarted);
    on<ProducerProfileUpdateSubmitted>(_onUpdateSubmitted);
    on<ProducerAvatarPicked>(_onAvatarPicked);
    on<ProducerCoverPicked>(_onCoverPicked);
  }

  final GetProducerProfile _getProducer;
  final UpdateProducer _updateProducer;
  final UploadProducerAvatar _uploadAvatar;
  final UploadProducerCover _uploadCover;

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
    } on Object catch (_) {
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
        farmName: event.farmName,
      );
      emit(const ProducerProfileUpdateSuccess());
    } on ApiException catch (e) {
      emit(ProducerProfileFailure(e.message));
    } on Object catch (_) {
      emit(const ProducerProfileFailure('Erro ao atualizar perfil.'));
    }
  }

  Future<void> _onAvatarPicked(
    ProducerAvatarPicked event,
    Emitter<ProducerProfileState> emit,
  ) async {
    await _handleUpload(
      emit: emit,
      isAvatar: true,
      upload: () => _uploadAvatar(event.producerId, event.file),
    );
  }

  Future<void> _onCoverPicked(
    ProducerCoverPicked event,
    Emitter<ProducerProfileState> emit,
  ) async {
    await _handleUpload(
      emit: emit,
      isAvatar: false,
      upload: () => _uploadCover(event.producerId, event.file),
    );
  }

  Future<void> _handleUpload({
    required Emitter<ProducerProfileState> emit,
    required bool isAvatar,
    required Future<PublicProducer> Function() upload,
  }) async {
    final current = state;
    if (current is! ProducerProfileLoaded) return;

    emit(ProducerPhotoUploading(producer: current.producer, isAvatar: isAvatar));
    try {
      final updated = await upload();
      emit(ProducerProfileLoaded(updated));
    } on ApiException catch (e) {
      emit(ProducerProfileFailure(e.message));
      emit(ProducerProfileLoaded(current.producer));
    } on Object catch (_) {
      emit(const ProducerProfileFailure('Erro ao enviar imagem.'));
      emit(ProducerProfileLoaded(current.producer));
    }
  }
}
