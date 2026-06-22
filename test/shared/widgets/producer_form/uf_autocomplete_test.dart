import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ragro_mobile/shared/widgets/producer_form/uf_autocomplete.dart';

void main() {
  Widget harness({
    required ValueChanged<String> onSelected,
    String? initialValue,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: UfAutocomplete(
          initialValue: initialValue,
          onSelected: onSelected,
        ),
      ),
    );
  }

  testWidgets('propagates a valid UF on change', (tester) async {
    final selected = <String>[];
    await tester.pumpWidget(harness(onSelected: selected.add));

    await tester.enterText(find.byType(TextField), 'sp');
    await tester.pump();

    expect(selected, contains('SP'));
  });

  testWidgets('propagates empty string when the field is cleared', (
    tester,
  ) async {
    final selected = <String>[];
    await tester.pumpWidget(
      harness(initialValue: 'SP', onSelected: selected.add),
    );

    await tester.enterText(find.byType(TextField), '');
    await tester.pump();

    expect(selected.last, '');
  });

  testWidgets('propagates empty string for an invalid/partial UF', (
    tester,
  ) async {
    final selected = <String>[];
    await tester.pumpWidget(harness(onSelected: selected.add));

    // 'X' is not a complete valid UF code.
    await tester.enterText(find.byType(TextField), 'X');
    await tester.pump();

    expect(selected.last, '');
  });
}
