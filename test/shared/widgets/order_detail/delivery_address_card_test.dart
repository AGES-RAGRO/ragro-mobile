import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ragro_mobile/shared/widgets/order_detail/delivery_address_card.dart';

void main() {
  Widget harness(List<String> lines) {
    return MaterialApp(
      home: Scaffold(body: DeliveryAddressCard(lines: lines)),
    );
  }

  testWidgets('renders non-empty lines', (tester) async {
    await tester.pumpWidget(
      harness(const ['Rua das Flores, 123', 'Centro - São Paulo/SP']),
    );

    expect(find.text('Rua das Flores, 123'), findsOneWidget);
    expect(find.text('Centro - São Paulo/SP'), findsOneWidget);
  });

  testWidgets('filters out empty and whitespace-only lines', (tester) async {
    await tester.pumpWidget(
      harness(const ['Rua A, 10', '', '   ', '\t', 'Bairro B']),
    );

    // Only the two real lines render; whitespace-only lines are dropped.
    expect(find.text('Rua A, 10'), findsOneWidget);
    expect(find.text('Bairro B'), findsOneWidget);
    expect(find.text('   '), findsNothing);
    expect(find.text('\t'), findsNothing);
  });
}
