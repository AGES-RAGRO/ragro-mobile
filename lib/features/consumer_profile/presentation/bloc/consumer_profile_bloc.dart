import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';
import 'package:ragro_mobile/features/consumer_profile/domain/usecases/get_consumer_profile.dart';
import 'package:ragro_mobile/features/consumer_profile/domain/usecases/update_consumer_profile.dart';
import 'package:ragro_mobile/features/consumer_profile/presentation/bloc/consumer_profile_event.dart';
import 'package:ragro_mobile/features/consumer_profile/presentation/bloc/consumer_profile_state.dart';

@injectable
class ConsumerProfileBloc
    extends Bloc<ConsumerProfileEvent, ConsumerProfileState> {
  ConsumerProfileBloc(this._getProfile, this._updateProfile)
      : super(const ConsumerProfileInitial()) {
    on<ConsumerProfileStarted>(_onStarted);
    on<ConsumerProfileUpdateSubmitted>(_onUpdateSubmitted);
  }

  final GetCustomerProfile _getProfile;
  final UpdateCustomerProfile _updateProfile;

  Future<void> _onStarted(
    ConsumerProfileStarted event,
    Emitter<ConsumerProfileState> emit,
  ) async {
    emit(const ConsumerProfileLoading());
    try {
      final profile = await _getProfile(event.userId);
      emit(ConsumerProfileLoaded(profile));
    } on ApiException catch (e) {
      emit(ConsumerProfileFailure(e.message));
    } catch (_) {
      emit(const ConsumerProfileFailure('Erro ao carregar perfil.'));
    }
  }

  Future<void> _onUpdateSubmitted(
    ConsumerProfileUpdateSubmitted event,
    Emitter<ConsumerProfileState> emit,
  ) async {
    final currentState = state;
    final currentProfile = currentState is ConsumerProfileLoaded
        ? currentState.profile
        : null;
    if (currentProfile != null) {
      emit(ConsumerProfileUpdating(currentProfile));
    }
    try {
      final updated = await _updateProfile(
        userId: event.userId,
        name: event.name,
        phone: event.phone,
        address: event.address,
        fiscalNumber: event.fiscalNumber,
      );
      emit(ConsumerProfileUpdateSuccess(updated));
    } on ApiException catch (e) {
      emit(ConsumerProfileFailure(e.message));
    } catch (_) {
      emit(const ConsumerProfileFailure('Erro ao atualizar perfil.'));
    }
  }
}
