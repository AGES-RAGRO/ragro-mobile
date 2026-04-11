import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:ragro_mobile/core/network/api_exception.dart';
import 'package:ragro_mobile/features/customer_profile/domain/usecases/get_customer_profile.dart';
import 'package:ragro_mobile/features/customer_profile/domain/usecases/update_customer_profile.dart';
import 'package:ragro_mobile/features/customer_profile/presentation/bloc/customer_profile_event.dart';
import 'package:ragro_mobile/features/customer_profile/presentation/bloc/customer_profile_state.dart';

@injectable
class CustomerProfileBloc
    extends Bloc<CustomerProfileEvent, CustomerProfileState> {
  CustomerProfileBloc(this._getProfile, this._updateProfile)
    : super(const CustomerProfileInitial()) {
    on<CustomerProfileStarted>(_onStarted);
    on<CustomerProfileUpdateSubmitted>(_onUpdateSubmitted);
  }

  final GetCustomerProfile _getProfile;
  final UpdateCustomerProfile _updateProfile;

  Future<void> _onStarted(
    CustomerProfileStarted event,
    Emitter<CustomerProfileState> emit,
  ) async {
    emit(const CustomerProfileLoading());
    try {
      final profile = await _getProfile();
      emit(CustomerProfileLoaded(profile));
    } on ApiException catch (e) {
      emit(CustomerProfileFailure(e.message));
    } on Exception catch (_) {
      emit(const CustomerProfileFailure('Erro ao carregar perfil.'));
    }
  }

  Future<void> _onUpdateSubmitted(
    CustomerProfileUpdateSubmitted event,
    Emitter<CustomerProfileState> emit,
  ) async {
    final currentProfile = switch (state) {
      CustomerProfileLoaded(:final profile) => profile,
      CustomerProfileUpdating(:final profile) => profile,
      CustomerProfileUpdateSuccess(:final profile) => profile,
      _ => null,
    };

    if (currentProfile != null) {
      emit(CustomerProfileUpdating(currentProfile));
    }

    try {
      final updated = await _updateProfile(
        name: event.name,
        phone: event.phone,
        street: event.street,
        number: event.number,
        city: event.city,
        state: event.state,
        zipCode: event.zipCode,
        complement: event.complement,
        neighborhood: event.neighborhood,
      );
      emit(CustomerProfileUpdateSuccess(updated));
    } on ApiException catch (e) {
      if (currentProfile != null) {
        emit(CustomerProfileUpdateFailure(currentProfile, e.message));
        return;
      }
      emit(CustomerProfileFailure(e.message));
    } on Exception catch (_) {
      if (currentProfile != null) {
        emit(
          CustomerProfileUpdateFailure(
            currentProfile,
            'Erro ao atualizar perfil.',
          ),
        );
        return;
      }
      emit(const CustomerProfileFailure('Erro ao atualizar perfil.'));
    }
  }
}
