import 'dart:async';

import 'package:flutter/material.dart';

import 'catalog.dart';
import 'screen.dart';

enum Progress { placing, preparing, enRoute, complete }

typedef Address = ({String street, String city, String note});
typedef Profile = ({String first, String last, String phone, String email});

class CartItem {
  CartItem(
    this.dish,
    this.store,
    this.pickup,
    this.details,
    this.price,
    this.quantity,
  );

  final Dish dish;
  final Restaurant store;
  final bool pickup;
  final String details;
  final int price;
  int quantity;

  int get total => quantity * price;
}

class Order {
  const Order(
    this.store,
    this.items,
    this.pickup,
    this.total,
    this.date, {
    this.cancelled = false,
    this.fee = 0,
    this.discount = 0,
    this.reward = 0,
    this.payment = '•••• 1234',
  });

  final Restaurant store;
  final List<CartItem> items;
  final bool pickup;
  final int total;
  final String date;
  final bool cancelled;
  final int fee;
  final int discount;
  final int reward;
  final String payment;

  int get subtotal => items.fold(0, (sum, item) => sum + item.total);
}

class Session extends ChangeNotifier {
  Session({this.dark = false});

  factory Session.preview(Screen screen, bool dark) {
    final session = Session(dark: dark);
    session.query = 'Asian food';
    if (screen == Screen.filter) {
      session.sort = 'Top rated';
      session.prices.addAll([1, 2]);
      session.dealsOnly = true;
      session.maxFee = 4;
    }
    if ({
      Screen.cart,
      Screen.cartItems,
      Screen.clearCart,
      Screen.checkout,
      Screen.checkoutPickup,
      Screen.placing,
      Screen.processing,
      Screen.delivering,
      Screen.deliveringDetails,
      Screen.delivered,
    }.contains(screen)) {
      final pickup = screen == Screen.checkoutPickup;
      session.pickup = pickup;
      session.cart.addAll([
        CartItem(hotdog, bowlClub, pickup, 'Medium, mustard', 799, 1),
        CartItem(donut, bowlClub, pickup, 'Strawberry', 299, 2),
      ]);
      if ({Screen.cart, Screen.cartItems, Screen.clearCart}.contains(screen)) {
        session.cart.addAll([
          CartItem(pizza, dumplings, true, 'Thin crust', 1199, 2),
          CartItem(burger, bowlClub, true, 'Regular', 799, 2),
        ]);
      }
      if ({
        Screen.placing,
        Screen.processing,
        Screen.delivering,
        Screen.deliveringDetails,
        Screen.delivered,
      }.contains(screen)) {
        session.placeOrder(runClock: false);
        session.progress = switch (screen) {
          Screen.placing => Progress.placing,
          Screen.processing => Progress.preparing,
          Screen.delivered => Progress.complete,
          _ => Progress.enRoute,
        };
      }
    }
    if ({Screen.orders, Screen.receipt, Screen.receiptMore}.contains(screen)) {
      session.orders.addAll([
        Order(
          bowlClub,
          [
            CartItem(pizza, bowlClub, false, '', 1199, 1),
            CartItem(donut, bowlClub, false, '', 399, 1),
          ],
          false,
          1598,
          'March 14, 2023',
        ),
        Order(
          donuts,
          [CartItem(donut, donuts, false, '', 399, 3)],
          false,
          1197,
          'March 11, 2023',
          cancelled: true,
        ),
        Order(
          bowlClub,
          [CartItem(burger, bowlClub, true, '', 799, 3)],
          true,
          2397,
          'December 24, 2022',
        ),
        Order(
          donuts,
          [CartItem(cupcake, donuts, false, '', 399, 3)],
          false,
          1197,
          'December 11, 2022',
        ),
      ]);
      if (screen == Screen.orders) {
        session.currentOrder = session.orders.first;
        session.progress = Progress.preparing;
      }
    }
    if (screen == Screen.notificationsEmpty) session.hasNotifications = false;
    if (screen == Screen.chatMessages) session.chat.add('Hi there');
    return session;
  }

  bool dark;
  bool pickup = false;
  String? memberPlan;
  bool get member => memberPlan != null;
  bool hasNotifications = true;
  bool gift = false;
  String query = '';
  String sort = 'Picked for you (default)';
  final prices = <int>{};
  bool dealsOnly = false;
  bool memberOnly = false;
  int maxFee = 6;
  String payment = '•••• 1234';
  final savedCards = <String>['•••• 1234'];
  String promo = '';
  int reward = 0;
  int restaurantRating = 0;
  Profile profile = (
    first: 'Mei Jun',
    last: 'Lam',
    phone: '9052360000',
    email: 'meijun@gmail.com',
  );
  Address address = (
    street: '123 Forum Dr',
    city: 'Mississauga, ON, L4Z 1Y2',
    note: 'Leave at door',
  );
  Offset mapPin = const Offset(.52, .52);
  final addresses = <Address>[
    (street: '246 Forum Dr', city: 'Mississauga, ON, L4Z 1Y2', note: ''),
    (street: '2464 Royal Ln', city: 'Mesa, New Jersey 45463', note: ''),
  ];
  final favorites = <Restaurant>{};
  final history = <String>['Chicken', 'Coffee'];
  final chat = <String>[];
  final cart = <CartItem>[];
  final orders = <Order>[];
  Restaurant store = bowlClub;
  Order? currentOrder;
  Progress progress = Progress.complete;
  Timer? _progressTimer;

  List<CartItem> get storeCart => cart
      .where((item) => item.store == store && item.pickup == pickup)
      .toList();
  int get count => cart.fold(0, (total, item) => total + item.quantity);
  int get subtotal => storeCart.fold(0, (total, item) => total + item.total);
  int get fee => pickup || member ? 0 : 299;
  int get discount => switch (promo) {
    'KING5' when subtotal >= 3000 => 500,
    'DEAL30' when store == bowlClub || store == pho => (subtotal * .30).round(),
    _ => 0,
  };
  int get total =>
      (subtotal + fee - discount - reward).clamp(0, subtotal + fee);

  void refresh() => notifyListeners();

  void search(String value) {
    query = value.trim();
    if (query.isNotEmpty) {
      history.remove(query);
      history.insert(0, query);
    }
    refresh();
  }

  void toggleFavorite(Restaurant restaurant) {
    if (!favorites.remove(restaurant)) favorites.add(restaurant);
    refresh();
  }

  void add(Dish dish, String details, int price, int quantity) {
    final same = cart
        .where(
          (item) =>
              item.dish == dish &&
              item.store == store &&
              item.pickup == pickup &&
              item.details == details &&
              item.price == price,
        )
        .firstOrNull;
    if (same == null) {
      cart.add(CartItem(dish, store, pickup, details, price, quantity));
    } else {
      same.quantity += quantity;
    }
    refresh();
  }

  void adjust(CartItem item, int delta) {
    item.quantity += delta;
    if (item.quantity <= 0) cart.remove(item);
    refresh();
  }

  void chooseMode(bool value, {bool moveCart = false}) {
    if (moveCart && pickup != value) {
      final previous = storeCart;
      for (final item in previous) {
        final existing = cart
            .where(
              (other) =>
                  other.store == item.store &&
                  other.pickup == value &&
                  other.dish == item.dish &&
                  other.details == item.details &&
                  other.price == item.price,
            )
            .firstOrNull;
        if (existing == null) {
          cart.add(
            CartItem(
              item.dish,
              item.store,
              value,
              item.details,
              item.price,
              item.quantity,
            ),
          );
        } else {
          existing.quantity += item.quantity;
        }
      }
      cart.removeWhere(previous.contains);
    }
    pickup = value;
    refresh();
  }

  void placeOrder({bool runClock = true}) {
    final items = storeCart;
    if (items.isEmpty) return;
    final now = DateTime.now();
    final date =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final order = Order(
      store,
      items,
      pickup,
      total,
      date,
      fee: fee,
      discount: discount,
      reward: reward,
      payment: payment,
    );
    currentOrder = order;
    orders.insert(0, order);
    cart.removeWhere(items.contains);
    chat.clear();
    promo = '';
    reward = 0;
    gift = false;
    hasNotifications = true;
    progress = Progress.placing;
    refresh();
    _progressTimer?.cancel();
    if (runClock) {
      _progressTimer = Timer.periodic(const Duration(seconds: 7), (timer) {
        progress = Progress.values[progress.index + 1];
        if (progress == Progress.complete) timer.cancel();
        hasNotifications = true;
        refresh();
      });
    }
  }

  void cancelOrder() {
    final order = currentOrder;
    if (order != null) {
      orders[orders.indexOf(order)] = Order(
        order.store,
        order.items,
        order.pickup,
        order.total,
        order.date,
        cancelled: true,
        fee: order.fee,
        discount: order.discount,
        reward: order.reward,
        payment: order.payment,
      );
    }
    _progressTimer?.cancel();
    currentOrder = null;
    progress = Progress.complete;
    refresh();
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    super.dispose();
  }
}

class SessionScope extends InheritedNotifier<Session> {
  const SessionScope({
    super.key,
    required Session session,
    required super.child,
  }) : super(notifier: session);

  static Session of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SessionScope>()!.notifier!;
}
