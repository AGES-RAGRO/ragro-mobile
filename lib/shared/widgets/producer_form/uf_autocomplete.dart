import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/shared/widgets/producer_form/uppercase_formatter.dart';

/// Brazilian state (UF) codes offered by [UfAutocomplete].
const List<String> brazilianStates = [
  'AC',
  'AL',
  'AP',
  'AM',
  'BA',
  'CE',
  'DF',
  'ES',
  'GO',
  'MA',
  'MT',
  'MS',
  'MG',
  'PA',
  'PB',
  'PR',
  'PE',
  'PI',
  'RJ',
  'RN',
  'RS',
  'RO',
  'RR',
  'SC',
  'SP',
  'SE',
  'TO',
];

/// Autocomplete input for the UF/state field of the producer forms.
class UfAutocomplete extends StatelessWidget {
  const UfAutocomplete({
    required this.initialValue,
    required this.onSelected,
    super.key,
    this.enabled = true,
  });

  final String? initialValue;
  final ValueChanged<String> onSelected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      initialValue: TextEditingValue(text: initialValue ?? ''),
      optionsBuilder: (value) {
        final query = value.text.toUpperCase();
        if (query.isEmpty) return brazilianStates;
        return brazilianStates.where((uf) => uf.startsWith(query));
      },
      onSelected: onSelected,
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          enabled: enabled,
          textCapitalization: TextCapitalization.characters,
          inputFormatters: [
            LengthLimitingTextInputFormatter(2),
            UppercaseFormatter(),
          ],
          onChanged: (v) {
            final normalized = v.toUpperCase();
            if (brazilianStates.contains(normalized)) {
              onSelected(normalized);
            } else {
              onSelected('');
            }
          },
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 15,
            color: AppColors.black,
          ),
          decoration: InputDecoration(
            hintText: 'UF',
            hintStyle: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 15,
              color: AppColors.placeholder,
            ),
            filled: true,
            fillColor: AppColors.inputBackground,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.inputBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.darkGreen,
                width: 1.5,
              ),
            ),
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 110,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final uf = options.elementAt(index);
                  return ListTile(
                    dense: true,
                    title: Text(
                      uf,
                      style: const TextStyle(fontFamily: 'Manrope'),
                    ),
                    onTap: () => onSelected(uf),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
