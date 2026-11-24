import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:order_king/app.dart';
import 'package:order_king/core/screen.dart';
import 'package:order_king/core/session.dart';

void phoneViewport(
  WidgetTester tester, {
  double width = 375,
  double height = 812,
}) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, height);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  testWidgets('onboarding leads to a validated local sign-in', (tester) async {
    phoneViewport(tester);
    await tester.pumpWidget(const OrderKingApp());
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    final inputs = find.byType(TextField);
    await tester.enterText(inputs.at(0), '123');
    await tester.enterText(inputs.at(1), 'abc');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();
    expect(find.text('Invalid phone number'), findsOneWidget);
    expect(find.text('Wrong password!'), findsOneWidget);
    await tester.enterText(inputs.at(0), '9052360000');
    await tester.enterText(inputs.at(1), 'ABC2303!');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();
    expect(find.text('Categories'), findsOneWidget);
  });

  testWidgets('menu, cart, pickup checkout and tracking stay in sync', (
    tester,
  ) async {
    phoneViewport(tester);
    await tester.pumpWidget(const OrderKingApp(preview: Screen.restaurant));
    await tester.pumpAndSettle();
    await tester.tap(find.text('French fries'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Increase quantity'));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Add to cart   \$7.98'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Cart'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('One Bowl Club'));
    await tester.pumpAndSettle();
    expect(find.text('French fries'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Check out   \$7.98'));
    await tester.pumpAndSettle();
    expect(find.text('Place order   \$10.97'), findsOneWidget);
    await tester.tap(find.text('Pick-up'));
    await tester.pumpAndSettle();
    expect(find.text('Pickup info'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Place order   \$7.98'));
    await tester.pumpAndSettle();
    expect(find.text('Placing order'), findsOneWidget);
    await tester.pump(const Duration(seconds: 7));
    expect(find.text('Processing order...'), findsOneWidget);
    await tester.pump(const Duration(seconds: 14));
    expect(find.text('Order complete!'), findsOneWidget);
  });

  testWidgets('theme switching and map selection retain active routes', (
    tester,
  ) async {
    phoneViewport(tester);
    await tester.pumpWidget(const OrderKingApp(preview: Screen.account));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    final context = tester.element(find.text('Mei Jun'));
    expect(Theme.of(context).brightness, Brightness.dark);
    await tester.tap(find.text('Addresses'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('123 Forum Dr'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Adjust pin'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Center map'));
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();
    expect(find.text('Address details'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Save address'));
    await tester.pumpAndSettle();
    final session = SessionScope.of(
      tester.element(find.text('Saved addresses')),
    );
    expect(session.address.street, '123 Forum Dr');
  });

  testWidgets('narrow screen keeps the shopping and account layouts usable', (
    tester,
  ) async {
    phoneViewport(tester, width: 320, height: 640);
    for (final screen in [
      Screen.home,
      Screen.account,
      Screen.checkout,
      Screen.filter,
      Screen.feedback,
    ]) {
      await tester.pumpWidget(
        OrderKingApp(key: ValueKey(screen), preview: screen),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: screen.name);
    }
  });
}
