import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:order_king/app.dart';
import 'package:order_king/core/screen.dart';

const _capturePort = int.fromEnvironment('ORDERKING_CAPTURE_PORT');
const _fullPageHeights = {
  Screen.homeFull: 1770.0,
  Screen.search: 1120.0,
  Screen.searchResults: 1040.0,
  Screen.filter: 1040.0,
  Screen.restaurant: 1625.0,
  Screen.pickupRestaurant: 1625.0,
  Screen.storeFull: 1240.0,
  Screen.dish: 1590.0,
  Screen.checkout: 1360.0,
  Screen.checkoutPickup: 1255.0,
  Screen.addressDetails: 910.0,
  Screen.membership: 910.0,
};

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('render every Pixso screen in both themes on Android', (
    tester,
  ) async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    tester.view.devicePixelRatio = 2;
    tester.view.padding = const FakeViewPadding();
    tester.view.viewPadding = const FakeViewPadding();
    tester.view.viewInsets = const FakeViewPadding();
    addTearDown(tester.view.reset);
    final client = HttpClient();
    addTearDown(() => client.close(force: true));
    final assets = (await AssetManifest.loadFromAssetBundle(rootBundle))
        .listAssets();
    var preloaded = false;

    for (final dark in [false, true]) {
      final theme = dark ? 'dark' : 'light';
      for (final screen in Screen.values) {
        final boundary = GlobalKey();
        final height = _fullPageHeights[screen] ?? 812;
        tester.view.physicalSize = Size(750, height * 2);
        await tester.pumpWidget(
          RepaintBoundary(
            key: boundary,
            child: OrderKingApp(
              key: ValueKey((screen, dark)),
              preview: screen,
              previewDark: dark,
            ),
          ),
        );
        await tester.pumpAndSettle();
        if (!preloaded) {
          final context = tester.element(find.byType(Scaffold).first);
          await Future.wait(
            assets
                .where((file) => file.startsWith('assets/images/'))
                .map((file) => precacheImage(AssetImage(file), context)),
          );
          preloaded = true;
        }
        await tester.pump(const Duration(milliseconds: 100));
        expect(tester.takeException(), isNull, reason: '$theme/${screen.name}');
        if (screen == Screen.checkoutPickup) {
          expect(find.text('Pickup info'), findsOneWidget);
        }
        if (_capturePort == 0) continue;
        final box =
            boundary.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        final image = await box.toImage(pixelRatio: 1.6);
        try {
          final data = (await image.toByteData(
            format: ui.ImageByteFormat.png,
          ))!;
          final request = await client.postUrl(
            Uri.http('127.0.0.1:$_capturePort', '/$theme/${screen.name}'),
          );
          final bytes = data.buffer.asUint8List();
          request.contentLength = bytes.length;
          request.add(bytes);
          final response = await request.close();
          await response.drain<void>();
          expect(
            response.statusCode,
            HttpStatus.noContent,
            reason: '$theme/${screen.name}',
          );
        } finally {
          image.dispose();
        }
      }
    }
  }, timeout: const Timeout(Duration(minutes: 9)));
}
