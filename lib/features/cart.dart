import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/catalog.dart';
import '../core/screen.dart';
import '../core/session.dart';
import '../core/ui.dart';

class CartPage extends StatelessWidget {
  const CartPage(this.screen, {super.key});
  final Screen screen;

  @override
  Widget build(BuildContext context) => switch (screen) {
    Screen.checkout || Screen.checkoutPickup => const _Checkout(),
    _ => _CartOverview(screen),
  };
}

class _CartOverview extends StatelessWidget {
  const _CartOverview(this.screen);
  final Screen screen;

  @override
  Widget build(BuildContext context) {
    final session = context.shop;
    final empty = session.cart.isEmpty;
    final showItems = screen == Screen.cartItems;
    final showClear = screen == Screen.clearCart;
    final groups = <(Restaurant, bool), List<CartItem>>{};
    for (final item in session.cart) {
      groups.putIfAbsent((item.store, item.pickup), () => []).add(item);
    }
    return Surface(
      bottom: showItems || showClear ? null : const ShopBar(2),
      child: Stack(
        children: [
          PageBody(
            children: [
              Header(
                'Your cart',
                trailing: empty
                    ? null
                    : TextButton(
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        onPressed: () => context.open(Screen.clearCart),
                        child: const Text(
                          'Clear all',
                          style: TextStyle(fontSize: 11),
                        ),
                      ),
              ),
              const SizedBox(height: 21),
              if (empty)
                const SizedBox(
                  height: 475,
                  child: Stack(
                    children: [
                      Positioned(
                        left: -20,
                        top: 0,
                        child: Art('hotdog', width: 78),
                      ),
                      Positioned(
                        left: -3,
                        bottom: 24,
                        child: Art('pizza', width: 50),
                      ),
                      Center(
                        child: EmptyState(
                          'shopping-cart',
                          'No items in\nyour cart',
                          subtitle:
                              'Add items from a restaurant to start a cart',
                        ),
                      ),
                    ],
                  ),
                ),
              for (final (index, entry) in groups.entries.indexed) ...[
                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    session.store = entry.key.$1;
                    session.chooseMode(entry.key.$2);
                    context.open(Screen.cartItems);
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: [honey, lavender, blush][index % 3],
                          borderRadius: BorderRadius.circular(17),
                        ),
                        child: Art(
                          [
                            'hero-delivery',
                            'hero-noodles',
                            'hero-snack',
                          ][index % 3],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TitleText(entry.key.$1.name, size: 15),
                            Muted(
                              '${entry.key.$2 ? 'Pickup' : 'Delivery'}  •  ${entry.value.fold(0, (count, item) => count + item.quantity)} items',
                            ),
                            const SizedBox(height: 3),
                            Pill(
                              money(
                                entry.value.fold(
                                  0,
                                  (total, item) => total + item.total,
                                ),
                              ),
                              color: context.colors.field,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: context.colors.muted,
                        size: 19,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ],
          ),
          if (showItems || showClear)
            Positioned.fill(
              child: GestureDetector(
                onTap: context.back,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                  child: ColoredBox(color: Colors.black.withValues(alpha: .22)),
                ),
              ),
            ),
          if (showItems)
            Align(alignment: Alignment.bottomCenter, child: _CartItems()),
          if (showClear)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Panel(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const TitleText('Clear all'),
                      const SizedBox(height: 8),
                      const Muted(
                        'Are you sure to delete all saved items in your cart?',
                        align: TextAlign.center,
                      ),
                      const SizedBox(height: 17),
                      Primary('Clear cart', () {
                        session.cart.clear();
                        session.refresh();
                        context.reset(Screen.cartEmpty);
                      }),
                      const SizedBox(height: 12),
                      Primary('Cancel', context.back, secondary: true),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CartItems extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = context.shop;
    return LayoutBuilder(
      builder: (context, box) => SizedBox(
        height: (box.maxHeight * .70).clamp(240, 630),
        child: Panel(
          color: context.colors.base,
          padding: EdgeInsets.zero,
          radius: 30,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 14),
                child: Header(s.store.name, close: true),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    for (final item in s.storeCart)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DishArt(item.dish, size: 79),
                            const SizedBox(width: 9),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TitleText(item.dish.name, size: 15),
                                  Muted(item.details),
                                  Text(
                                    money(item.total),
                                    style: TextStyle(
                                      color: context.colors.accent,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Qty(
                              item.quantity,
                              (delta) => s.adjust(item, delta),
                              vertical: true,
                            ),
                          ],
                        ),
                      ),
                    if (s.storeCart.isEmpty)
                      const Muted('Your order is empty.'),
                  ],
                ),
              ),
              Footer(
                Row(
                  children: [
                    Expanded(
                      child: Primary(
                        'Add items',
                        () => context.open(
                          s.pickup
                              ? Screen.pickupRestaurant
                              : Screen.restaurant,
                        ),
                        secondary: true,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: Primary(
                        'Check out   ${money(s.subtotal)}',
                        s.storeCart.isEmpty
                            ? null
                            : () => context.open(
                                s.pickup
                                    ? Screen.checkoutPickup
                                    : Screen.checkout,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Checkout extends StatelessWidget {
  const _Checkout();

  @override
  Widget build(BuildContext context) {
    final s = context.shop;
    final pickup = s.pickup;
    return Surface(
      bottom: Footer(
        Primary(
          'Place order   ${money(s.total)}',
          s.storeCart.isEmpty
              ? null
              : () {
                  s.placeOrder();
                  context.reset(Screen.placing);
                },
        ),
      ),
      child: PageBody(
        children: [
          const Header('Checkout'),
          const SizedBox(height: 30),
          ModeSwitch(pickup, (value) {
            if (value == pickup) return;
            s.chooseMode(value, moveCart: true);
            context.swap(value ? Screen.checkoutPickup : Screen.checkout);
          }),
          const SizedBox(height: 24),
          MapArt(
            pickup ? 'map-checkout' : 'map-address',
            onTap: () => context.open(pickup ? Screen.store : Screen.addresses),
          ),
          const SizedBox(height: 20),
          TitleText(pickup ? 'Pickup info' : 'Delivery info', size: 18),
          EntryRow(
            pickup ? Icons.storefront_outlined : Icons.location_on_outlined,
            pickup ? s.store.name : s.address.street,
            subtitle: s.address.city,
            onTap: () => context.open(pickup ? Screen.store : Screen.addresses),
          ),
          EntryRow(
            pickup ? Icons.map_outlined : Icons.door_front_door_outlined,
            pickup
                ? 'Distance'
                : s.address.note.startsWith('Meet outside')
                ? 'Meet outside'
                : 'Leave at door',
            subtitle: pickup
                ? '5.2 kilometers'
                : s.address.note.isEmpty
                ? 'Add delivery note'
                : s.address.note,
            onTap: () async {
              if (pickup) {
                context.open(Screen.store);
              } else {
                final note = await editText(
                  context,
                  'Delivery note',
                  s.address.note,
                );
                if (note != null) {
                  s.address = (
                    street: s.address.street,
                    city: s.address.city,
                    note: note,
                  );
                  s.refresh();
                }
              }
            },
          ),
          EntryRow(
            Icons.phone_outlined,
            s.profile.phone,
            divider: false,
            onTap: () async {
              final value = await editText(
                context,
                'Contact phone',
                s.profile.phone,
                keyboard: TextInputType.phone,
              );
              if (value != null &&
                  value.replaceAll(RegExp(r'\D'), '').length == 10) {
                final profile = s.profile;
                s.profile = (
                  first: profile.first,
                  last: profile.last,
                  phone: value,
                  email: profile.email,
                );
                s.refresh();
              } else if (value != null && context.mounted) {
                context.note('Enter a 10-digit phone number.');
              }
            },
          ),
          const SizedBox(height: 8),
          SectionTitle(
            'Your order',
            action: 'Add items',
            onTap: () => context.open(
              pickup ? Screen.pickupRestaurant : Screen.restaurant,
            ),
          ),
          for (final item in s.storeCart)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: OrderLine(
                '${item.quantity}x',
                item.dish.name,
                item.total,
                details: item.details,
              ),
            ),
          const SizedBox(height: 25),
          PriceRows(
            subtotal: s.subtotal,
            fee: s.fee,
            total: s.total,
            discount: s.discount,
            reward: s.reward,
          ),
          const SizedBox(height: 20),
          Divider(color: context.colors.rule),
          if (!pickup)
            EntryRow(
              Icons.card_giftcard_outlined,
              'Send as a gift',
              divider: false,
              circle: false,
              trailing: Switch(
                value: s.gift,
                onChanged: (value) {
                  s.gift = value;
                  s.refresh();
                },
              ),
            ),
          EntryRow(
            Icons.confirmation_number_outlined,
            s.promo.isEmpty ? 'Add promo code' : 'Promo code · ${s.promo}',
            circle: false,
            divider: false,
            onTap: () => context.open(Screen.promotions),
          ),
          EntryRow(
            Icons.toll_outlined,
            s.reward == 0
                ? 'Use KingCoins'
                : 'Using ${money(s.reward)} in KingCoins',
            circle: false,
            divider: false,
            onTap: () {
              s.reward = s.reward == 0 ? 100 : 0;
              s.refresh();
            },
          ),
          EntryRow(
            Icons.credit_card_outlined,
            'Payment method',
            subtitle: s.payment,
            circle: false,
            onTap: () => context.open(Screen.payments),
          ),
        ],
      ),
    );
  }
}

class OrderLine extends StatelessWidget {
  const OrderLine(
    this.quantity,
    this.name,
    this.total, {
    super.key,
    this.details,
  });
  final String quantity;
  final String name;
  final int total;
  final String? details;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 31,
        child: Text(quantity, style: const TextStyle(fontSize: 13)),
      ),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TitleText(name, size: 14),
            if (details?.isNotEmpty ?? false) Muted(details!, size: 11),
          ],
        ),
      ),
      const SizedBox(width: 8),
      Text(money(total), style: const TextStyle(fontSize: 14)),
    ],
  );
}

class PriceRows extends StatelessWidget {
  const PriceRows({
    super.key,
    required this.subtotal,
    required this.fee,
    required this.total,
    this.discount = 0,
    this.reward = 0,
  });
  final int subtotal;
  final int fee;
  final int total;
  final int discount;
  final int reward;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (final (label, amount) in [
        ('Subtotal', money(subtotal)),
        ('Delivery fee', money(fee)),
        if (discount > 0) ('Promotion', '-${money(discount)}'),
        if (reward > 0) ('KingCoins', '-${money(reward)}'),
        ('Total', money(total)),
      ])
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Expanded(
                child: Text(label, style: const TextStyle(fontSize: 15)),
              ),
              Text(
                amount,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: label == 'Total' ? FontWeight.w600 : null,
                ),
              ),
            ],
          ),
        ),
    ],
  );
}
