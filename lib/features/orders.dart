import 'package:flutter/material.dart';

import '../core/catalog.dart';
import '../core/screen.dart';
import '../core/session.dart';
import '../core/ui.dart';
import 'cart.dart';
import 'delivery.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage(this.screen, {super.key, this.order});
  final Screen screen;
  final Order? order;

  @override
  Widget build(BuildContext context) {
    final s = context.shop;
    switch (screen) {
      case Screen.receipt:
      case Screen.receiptMore:
        final selected = order ?? s.currentOrder ?? s.orders.firstOrNull;
        if (selected != null) {
          return _Receipt(selected, showMenu: screen == Screen.receiptMore);
        }
        return const _Orders();
      default:
        return const _Orders();
    }
  }
}

class _Orders extends StatelessWidget {
  const _Orders();

  @override
  Widget build(BuildContext context) {
    final s = context.shop;
    final grouped = <String, List<Order>>{};
    for (final order in s.orders) {
      final month = order.date.contains(',')
          ? order.date.split(' ').first
          : 'Recent';
      final year = order.date.split(' ').last;
      grouped
          .putIfAbsent(month == 'Recent' ? month : '$month $year', () => [])
          .add(order);
    }
    return Surface(
      bottom: const ShopBar(3),
      child: PageBody(
        children: [
          const Header('Your orders'),
          const SizedBox(height: 26),
          if (s.orders.isEmpty)
            const SizedBox(
              height: 460,
              child: Stack(
                children: [
                  Positioned(
                    left: 7,
                    bottom: 0,
                    child: Art('pizza', width: 55),
                  ),
                  Center(
                    child: EmptyState(
                      'receipt',
                      'No orders yet!',
                      receipt: true,
                      subtitle: 'Place an order to see order history',
                    ),
                  ),
                ],
              ),
            ),
          for (final entry in grouped.entries) ...[
            TitleText(entry.key),
            const SizedBox(height: 14),
            for (final order in entry.value) ...[
              _OrderRow(order),
              const SizedBox(height: 14),
            ],
            const SizedBox(height: 18),
          ],
        ],
      ),
    );
  }
}

class _OrderRow extends StatelessWidget {
  const _OrderRow(this.order);
  final Order order;

  @override
  Widget build(BuildContext context) {
    final s = context.shop;
    final live = order == s.currentOrder && s.progress != Progress.complete;
    final status = order.cancelled
        ? 'Cancelled'
        : live
        ? 'In progress'
        : 'Delivered';
    return InkWell(
      onTap: () {
        if (live) {
          context.open(Screen.delivering);
        } else {
          context.open(Screen.receipt, data: order);
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Row(
        children: [
          DishArt(order.items.first.dish, size: 80),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TitleText(order.store.name, size: 15),
                Muted(
                  '${order.date}  •  ${order.items.fold(0, (n, i) => n + i.quantity)} items  •  ${money(order.total)}',
                  size: 11,
                ),
                const SizedBox(height: 4),
                Pill(
                  status,
                  color: order.cancelled
                      ? const Color(0xffffc8b8)
                      : live
                      ? context.colors.field
                      : mint,
                  ink: live ? null : Colors.black,
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: context.colors.muted, size: 18),
        ],
      ),
    );
  }
}

class _Receipt extends StatelessWidget {
  const _Receipt(this.order, {required this.showMenu});
  final Order order;
  final bool showMenu;

  void _reorder(BuildContext context) {
    final s = context.shop;
    s.store = order.store;
    s.chooseMode(order.pickup);
    for (final item in order.items) {
      s.add(item.dish, item.details, item.price, item.quantity);
    }
    context.reset(Screen.cart);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.shop;
    final p = context.colors;
    final rating = s.restaurantRating == 0 ? 4 : s.restaurantRating;
    return Surface(
      bottom: const ShopBar(3),
      glow: Glow.warm,
      child: Stack(
        children: [
          PageBody(
            padding: EdgeInsets.zero,
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [honey, Color(0xffffedc8)],
                  ),
                ),
                child: Stack(
                  children: [
                    const Positioned(
                      right: 18,
                      bottom: 0,
                      child: Art('money-bag', width: 110, height: 124),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 44, 24, 35),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconTile(
                                Icons.chevron_left,
                                context.back,
                                label: 'Back',
                              ),
                              IconTile(
                                Icons.sort,
                                () => showMenu
                                    ? context.back()
                                    : context.open(
                                        Screen.receiptMore,
                                        data: order,
                                      ),
                                label: 'Receipt options',
                              ),
                            ],
                          ),
                          const SizedBox(height: 13),
                          Text(
                            order.date,
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 11,
                            ),
                          ),
                          const Text(
                            'Thanks for ordering!',
                            style: TextStyle(
                              fontSize: 28,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(
                            width: 203,
                            child: Text(
                              'Here’s the receipt from ${order.store.name}.',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Pill('Reorder', onTap: () => _reorder(context)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 21, 24, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TitleText('Order details'),
                    const SizedBox(height: 15),
                    for (final item in order.items)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: OrderLine(
                          '${item.quantity}x',
                          item.dish.name,
                          item.total,
                        ),
                      ),
                    const SizedBox(height: 19),
                    PriceRows(
                      subtotal: order.subtotal,
                      fee: order.fee,
                      total: order.total,
                      discount: order.discount,
                      reward: order.reward,
                    ),
                    Divider(color: p.rule, height: 25),
                    _ReceiptRow(
                      'Your rating',
                      trailing: InkWell(
                        onTap: () => context.open(Screen.feedback),
                        child: StarPicker(rating, null, size: 21),
                      ),
                    ),
                    if (!order.pickup)
                      const _ReceiptRow(
                        'Courier',
                        trailing: Muted('Floyd Miles'),
                      ),
                    _ReceiptRow(
                      'Payment method',
                      trailing: Muted(order.payment),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (showMenu)
            Positioned(
              top: 100,
              right: 24,
              child: Panel(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                radius: 15,
                child: SizedBox(
                  width: 170,
                  child: Column(
                    children: [
                      EntryRow(
                        Icons.download_outlined,
                        'Download PDF',
                        circle: false,
                        onTap: () => context.note(
                          'PDF download is unavailable in this demo.',
                        ),
                      ),
                      EntryRow(
                        Icons.storefront_outlined,
                        'View store',
                        circle: false,
                        onTap: () {
                          s.store = order.store;
                          s.chooseMode(order.pickup);
                          context.open(Screen.store);
                        },
                      ),
                      EntryRow(
                        Icons.help_outline,
                        'Get help',
                        circle: false,
                        onTap: () => context.open(Screen.help),
                        divider: false,
                      ),
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

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow(this.label, {required this.trailing});
  final String label;
  final Widget trailing;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        Expanded(child: Text(label)),
        trailing,
      ],
    ),
  );
}
