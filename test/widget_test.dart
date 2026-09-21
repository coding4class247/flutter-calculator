import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:workspace/main.dart';

void main() {
  Future<void> tapButtons(WidgetTester tester, String values) async {
    for (final value in values.split('')) {
      await tester.tap(find.widgetWithText(FilledButton, value));
    }
    await tester.pump();
  }

  testWidgets('shows the full expression and honors operator precedence', (tester) async {
    await tester.pumpWidget(const MyApp());

    await tapButtons(tester, '2+3*4=');

    expect(find.text('2 + 3 * 4 = 14'), findsOneWidget);
  });

  testWidgets('clear resets the accumulator display', (tester) async {
    await tester.pumpWidget(const MyApp());

    await tapButtons(tester, '123+45');
    await tester.tap(find.text('C'));
    await tester.pump();

    expect(find.text('0'), findsAtLeastNWidgets(1));
    expect(find.text('123 + 45'), findsNothing);
  });

  testWidgets('reports division by zero without crashing', (tester) async {
    await tester.pumpWidget(const MyApp());

    await tapButtons(tester, '8/0=');

    expect(find.text('Cannot calculate this expression'), findsOneWidget);
  });
}
