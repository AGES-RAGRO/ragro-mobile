import 'package:flutter/foundation.dart';
import 'package:ragro_mobile/core/di/injection.dart';
import 'package:ragro_mobile/core/services/cep_service.dart';
import 'package:ragro_mobile/shared/widgets/producer_form/producer_form_controllers.dart';

/// Auto-fills the address fields from the CEP: watches the CEP controller and,
/// once 8 digits are typed, fetches the address via [CepService] and fills
/// street/neighborhood/city/state.
///
/// Call [attach] from `initState`; the listener keeps the lookup alive and
/// dies with the controller, so no detach is needed.
class CepLookup {
  CepLookup({
    required this.controllers,
    required this.isMounted,
    required this.applyState,
  });

  final ProducerFormControllers controllers;

  /// Should return the page's `mounted` flag.
  final bool Function() isMounted;

  /// Runs the fill inside the page's `setState`.
  final void Function(VoidCallback fn) applyState;

  void attach() => controllers.cep.addListener(_onCepChanged);

  void _onCepChanged() {
    final cep = digitsOnly(controllers.cep.text);
    if (cep.length == 8) {
      _lookup(cep);
    }
  }

  Future<void> _lookup(String cep) async {
    final address = await getIt<CepService>().fetchAddress(cep);
    if (address != null && isMounted()) {
      applyState(() {
        controllers.address.text = address.street;
        controllers.neighborhood.text = address.neighborhood;
        controllers.city.text = address.city;
        controllers.state.text = address.state;
      });
    }
  }
}
