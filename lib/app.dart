import 'package:flutter/material.dart';

import 'core/catalog.dart';
import 'core/screen.dart';
import 'core/session.dart';
import 'core/ui.dart';
import 'features/account.dart';
import 'features/address.dart';
import 'features/auth.dart';
import 'features/cart.dart';
import 'features/delivery.dart';
import 'features/home.dart';
import 'features/orders.dart';
import 'features/restaurant.dart';

class OrderKingApp extends StatefulWidget {
  const OrderKingApp({super.key, this.preview, this.previewDark = false});

  final Screen? preview;
  final bool previewDark;

  @override
  State<OrderKingApp> createState() => _OrderKingAppState();
}

class _OrderKingAppState extends State<OrderKingApp> {
  late final Session _session = widget.preview == null
      ? Session()
      : Session.preview(widget.preview!, widget.previewDark);

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  ThemeData _theme(bool dark) {
    final p = Palette(dark);
    final scheme =
        ColorScheme.fromSeed(
          seedColor: gold,
          brightness: dark ? Brightness.dark : Brightness.light,
        ).copyWith(
          primary: gold,
          onPrimary: Colors.black,
          surface: p.base,
          onSurface: p.ink,
        );
    return ThemeData(
      useMaterial3: true,
      splashFactory: InkRipple.splashFactory,
      fontFamily: 'Poppins',
      colorScheme: scheme,
      scaffoldBackgroundColor: p.base,
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Colors.white
              : const Color(0xffaab0b0),
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? gold : p.field,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.accent,
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: p.muted),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: p.rule),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: p.ink,
        contentTextStyle: TextStyle(color: p.base, fontFamily: 'Poppins'),
      ),
    );
  }

  Route<Object?> _route(Screen screen, [Object? data]) {
    final page = switch (screen) {
      Screen.loading ||
      Screen.onboarding1 ||
      Screen.onboarding2 ||
      Screen.onboarding3 ||
      Screen.signIn ||
      Screen.signInFilled ||
      Screen.signInError ||
      Screen.signUp ||
      Screen.signUpCode ||
      Screen.signUpPassword => AuthPage(
        screen,
        data: data,
        preview: widget.preview != null,
      ),
      Screen.home ||
      Screen.homeFull ||
      Screen.search ||
      Screen.searchResults ||
      Screen.filter ||
      Screen.pickup ||
      Screen.pickupFull ||
      Screen.pickupPin ||
      Screen.favorites => HomePage(screen),
      Screen.restaurant ||
      Screen.restaurantScrolled ||
      Screen.pickupRestaurant ||
      Screen.store ||
      Screen.storeFull ||
      Screen.dish => RestaurantPage(screen, dish: data as Dish?),
      Screen.cart ||
      Screen.cartEmpty ||
      Screen.cartItems ||
      Screen.clearCart ||
      Screen.checkout ||
      Screen.checkoutPickup => CartPage(screen),
      Screen.placing ||
      Screen.processing ||
      Screen.delivering ||
      Screen.deliveringDetails ||
      Screen.delivered ||
      Screen.chat ||
      Screen.chatMessages ||
      Screen.feedback => DeliveryPage(screen, preview: widget.preview != null),
      Screen.orders ||
      Screen.ordersEmpty ||
      Screen.receipt ||
      Screen.receiptMore => OrdersPage(screen, order: data as Order?),
      Screen.addresses ||
      Screen.addressTyping ||
      Screen.addressDetails ||
      Screen.addressPin => AddressPage(
        screen,
        address: screen == Screen.addressDetails ? data as Address? : null,
      ),
      Screen.account ||
      Screen.editProfile ||
      Screen.membership ||
      Screen.promotions ||
      Screen.promotionError ||
      Screen.payments ||
      Screen.addCard ||
      Screen.help ||
      Screen.notifications ||
      Screen.notificationsEmpty => AccountPage(screen),
    };
    return MaterialPageRoute(
      builder: (_) => page,
      settings: RouteSettings(name: screen.name, arguments: data),
    );
  }

  @override
  Widget build(BuildContext context) => SessionScope(
    session: _session,
    child: ListenableBuilder(
      listenable: _session,
      builder: (context, _) => MaterialApp(
        title: 'OrderKing',
        debugShowCheckedModeBanner: false,
        theme: _theme(false),
        darkTheme: _theme(true),
        themeMode: _session.dark ? ThemeMode.dark : ThemeMode.light,
        builder: (context, child) => ColoredBox(
          color: context.colors.base,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 540),
              child: child!,
            ),
          ),
        ),
        onGenerateInitialRoutes: (_) => [
          _route(widget.preview ?? Screen.loading),
        ],
        onGenerateRoute: (settings) {
          final screen = Screen.values
              .where((item) => item.name == settings.name)
              .firstOrNull;
          return _route(screen ?? Screen.home, settings.arguments);
        },
      ),
    ),
  );
}
