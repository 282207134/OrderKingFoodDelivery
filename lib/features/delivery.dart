import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/catalog.dart';
import '../core/screen.dart';
import '../core/session.dart';
import '../core/ui.dart';
import 'cart.dart';

class DeliveryPage extends StatelessWidget {
  const DeliveryPage(this.screen, {super.key, required this.preview});
  final Screen screen;
  final bool preview;

  @override
  Widget build(BuildContext context) => switch (screen) {
    Screen.chat || Screen.chatMessages => _Chat(screen == Screen.chatMessages),
    Screen.feedback => _Feedback(preview: preview),
    _ => _Tracking(details: screen == Screen.deliveringDetails),
  };
}

class _Tracking extends StatelessWidget {
  const _Tracking({required this.details});
  final bool details;

  @override
  Widget build(BuildContext context) {
    final s = context.shop;
    final step = s.progress;
    final pickup = s.currentOrder?.pickup ?? false;
    final activeMap = step == Progress.preparing || step == Progress.enRoute;
    final (heading, summary) = switch (step) {
      Progress.placing => ('Placing order', ''),
      Progress.preparing => (
        'Processing order...',
        '${s.currentOrder?.store.name ?? s.store.name} is currently preparing your order',
      ),
      Progress.enRoute when pickup => (
        'Ready for pickup',
        'Pick up your order at ${s.currentOrder?.store.name ?? s.store.name}.',
      ),
      Progress.enRoute => (
        'En route to you...',
        'Your courier is heading to you with your order',
      ),
      Progress.complete => (
        'Order complete!',
        pickup
            ? 'Enjoy your meal!'
            : 'Your order is delivered. Enjoy your meal!',
      ),
    };
    return Surface(
      glow: Glow.warm,
      child: LayoutBuilder(
        builder: (context, box) => Stack(
          children: [
            if (activeMap)
              Positioned.fill(
                child: Art(
                  'map-order${context.colors.dark ? '-dark' : ''}',
                  fit: BoxFit.cover,
                ),
              ),
            if (activeMap && !details)
              Positioned(
                top: 144,
                left: 0,
                right: 0,
                child: SizedBox(
                  height: 225,
                  child: Stack(
                    children: [
                      if (step == Progress.enRoute)
                        Positioned.fill(
                          child: CustomPaint(painter: _RouteLine()),
                        ),
                      Align(
                        alignment: const Alignment(.08, -.6),
                        child: _MapMark(Icons.home_rounded, active: false),
                      ),
                      Align(
                        alignment: const Alignment(-.37, .5),
                        child: _MapMark(
                          step == Progress.enRoute
                              ? Icons.person_pin_outlined
                              : Icons.storefront,
                          active: step == Progress.enRoute,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (details && activeMap)
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
                  child: const ColoredBox(color: Color(0x45000000)),
                ),
              ),
            PageBody(
              padding: EdgeInsets.fromLTRB(
                24,
                details
                    ? 95
                    : activeMap
                    ? (box.maxHeight * (step == Progress.enRoute ? .44 : .53))
                          .clamp(230, 465)
                    : (box.maxHeight * .18).clamp(72, 145),
                24,
                38,
              ),
              children: [
                if (step == Progress.placing || step == Progress.complete)
                  Center(
                    child: Art(
                      step == Progress.placing ? 'hero-snack' : 'party-face',
                      width: 189,
                      height: 173,
                    ),
                  ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(29),
                  child: Panel(
                    radius: 29,
                    padding: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (activeMap)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              width: 232,
                              height: 30,
                              decoration: const BoxDecoration(
                                color: gold,
                                borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(24),
                                ),
                              ),
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(left: 14),
                              child: Text(
                                pickup
                                    ? 'Pickup order'
                                    : 'Arrives between 5PM–5:30PM',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(21),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(child: TitleText(heading, size: 24)),
                                  if (step == Progress.placing)
                                    const SizedBox(
                                      width: 21,
                                      height: 21,
                                      child: CircularProgressIndicator(
                                        value: .73,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                ],
                              ),
                              if (step != Progress.placing) ...[
                                const SizedBox(height: 20),
                                _ProgressLine(step),
                                const SizedBox(height: 14),
                                Muted(summary, size: 14),
                              ],
                              if (!pickup &&
                                  step.index >= Progress.enRoute.index) ...[
                                const SizedBox(height: 13),
                                const _Courier(),
                              ],
                              const SizedBox(height: 10),
                              Divider(color: context.colors.rule),
                              if (step != Progress.placing)
                                EntryRow(
                                  details
                                      ? Icons.remove_circle_outline
                                      : Icons.add_circle_outline,
                                  'View order details',
                                  circle: false,
                                  divider: details,
                                  onTap: () => details
                                      ? context.back()
                                      : context.open(Screen.deliveringDetails),
                                ),
                              if (step == Progress.placing || details) ...[
                                const SizedBox(height: 8),
                                Text(
                                  pickup ? 'Pick up at' : 'Deliver to',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Muted(
                                  pickup
                                      ? s.currentOrder?.store.name ??
                                            s.store.name
                                      : '${s.address.street}, ${s.address.city}',
                                ),
                                if (details && !pickup) ...[
                                  const SizedBox(height: 9),
                                  Center(
                                    child: Pill(
                                      'Edit address',
                                      onTap: () =>
                                          context.open(Screen.addresses),
                                      color: context.colors.field,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 7),
                                Divider(color: context.colors.rule),
                                const SizedBox(height: 7),
                                TitleText(
                                  s.currentOrder?.store.name ?? s.store.name,
                                  size: 15,
                                ),
                                const SizedBox(height: 7),
                                for (final item
                                    in s.currentOrder?.items ??
                                        const <CartItem>[])
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                    child: OrderLine(
                                      '${item.quantity}x',
                                      item.dish.name,
                                      item.total,
                                    ),
                                  ),
                                const SizedBox(height: 12),
                                if (step == Progress.placing)
                                  Primary('Cancel order', () {
                                    s.cancelOrder();
                                    context.reset(Screen.orders);
                                  }, danger: true)
                                else
                                  Center(
                                    child: Pill(
                                      'View receipt',
                                      color: context.colors.field,
                                      onTap: () => context.open(
                                        Screen.receipt,
                                        data: s.currentOrder,
                                      ),
                                    ),
                                  ),
                              ],
                              if (!details && step == Progress.complete)
                                Primary(
                                  'Rate order',
                                  () => context.open(Screen.feedback),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (step != Progress.placing && !details)
              Positioned(
                top: 44,
                left: 24,
                child: IconTile(Icons.close, context.back, label: 'Close'),
              ),
          ],
        ),
      ),
    );
  }
}

class _MapMark extends StatelessWidget {
  const _MapMark(this.icon, {required this.active});
  final IconData icon;
  final bool active;

  @override
  Widget build(BuildContext context) => CircleAvatar(
    radius: 17,
    backgroundColor: active ? gold : const Color(0xff222225),
    child: Icon(icon, size: 20, color: active ? Colors.black : Colors.white),
  );
}

class _RouteLine extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final path = Path()
      ..moveTo(w * .32, h * .75)
      ..cubicTo(w * .25, h * .63, w * .16, h * .61, w * .19, h * .50)
      ..cubicTo(w * .28, h * .28, w * .47, h * .52, w * .54, h * .20);
    canvas.drawPath(
      path,
      Paint()
        ..color = gold
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(covariant _RouteLine oldDelegate) => false;
}

class _ProgressLine extends StatelessWidget {
  const _ProgressLine(this.step);
  final Progress step;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      for (final (index, icon) in [
        Icons.storefront_outlined,
        Icons.person_outline,
        Icons.home_rounded,
      ].indexed) ...[
        if (index > 0)
          Expanded(
            child: Container(
              height: 5,
              color: step.index > index ? gold : context.colors.field,
            ),
          ),
        CircleAvatar(
          radius: 18,
          backgroundColor: step.index > index ? gold : context.colors.field,
          child: Icon(
            icon,
            size: 19,
            color: step.index > index ? Colors.black : context.colors.ink,
          ),
        ),
      ],
    ],
  );
}

class _Courier extends StatelessWidget {
  const _Courier();

  @override
  Widget build(BuildContext context) => Row(
    children: [
      const ClipOval(
        child: Art('avatar-courier', width: 41, height: 41, fit: BoxFit.cover),
      ),
      const SizedBox(width: 7),
      const Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Muted('Your courier', size: 11),
            TitleText('Marvin McKinney', size: 13),
          ],
        ),
      ),
      IconTile(
        Icons.chat_bubble_outline,
        () => context.open(
          context.shop.chat.isEmpty ? Screen.chat : Screen.chatMessages,
        ),
        label: 'Chat with courier',
        size: 35,
        round: true,
      ),
      const SizedBox(width: 6),
      IconTile(
        Icons.phone_outlined,
        () => context.note('Courier number: 647-000-0000'),
        label: 'Call courier',
        size: 35,
        round: true,
      ),
    ],
  );
}

class _Chat extends StatefulWidget {
  const _Chat(this.filled);
  final bool filled;

  @override
  State<_Chat> createState() => _ChatState();
}

class _ChatState extends State<_Chat> {
  late final _draft = TextEditingController(
    text: widget.filled ? 'Please knock the door' : '',
  );

  @override
  void dispose() {
    _draft.dispose();
    super.dispose();
  }

  void _send() {
    final value = _draft.text.trim();
    if (value.isEmpty) return;
    context.shop.chat.add(value);
    context.shop.refresh();
    _draft.clear();
  }

  @override
  Widget build(BuildContext context) {
    final messages = context.shop.chat;
    return Surface(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 44, 24, 14),
            child: Row(
              children: [
                IconTile(Icons.chevron_left, context.back, label: 'Back'),
                const Expanded(
                  child: Column(
                    children: [
                      Muted('Your courier', size: 12),
                      TitleText('Marvin McKinney', size: 16),
                    ],
                  ),
                ),
                IconTile(
                  Icons.phone_outlined,
                  () => context.note('Courier number: 647-000-0000'),
                  label: 'Call courier',
                ),
              ],
            ),
          ),
          Expanded(
            child: messages.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Art('chat-bubble', width: 175, height: 161),
                        SizedBox(height: 20),
                        SizedBox(
                          width: 245,
                          child: TitleText(
                            'Chat with your courier about your order here',
                            size: 16,
                            align: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      for (final (i, value) in messages.indexed) ...[
                        Align(
                          alignment: Alignment.centerRight,
                          child: Panel(
                            color: gold,
                            radius: 18,
                            padding: const EdgeInsets.fromLTRB(15, 8, 15, 8),
                            child: Text(
                              value,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        if (i == 0)
                          const Padding(
                            padding: EdgeInsets.only(top: 12),
                            child: Row(
                              children: [
                                ClipOval(
                                  child: Art(
                                    'avatar-courier',
                                    width: 38,
                                    height: 38,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Flexible(
                                  child: Panel(
                                    padding: EdgeInsets.fromLTRB(12, 7, 12, 7),
                                    child: Text(
                                      'Hello, what can I help you with?',
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 10),
                      ],
                    ],
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 6, 15, 22),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => context.note(
                    'Image sharing is unavailable in this demo.',
                  ),
                  tooltip: 'Attach image',
                  icon: const Icon(Icons.image_outlined, size: 20),
                ),
                Expanded(
                  child: SearchBarBox(
                    controller: _draft,
                    hint: 'Your message',
                    onSubmitted: (_) => _send(),
                    leading: const SizedBox(
                      width: 35,
                      child: Icon(Icons.chat_bubble_outline, size: 16),
                    ),
                    trailing: IconButton(
                      onPressed: _send,
                      tooltip: 'Send',
                      icon: Icon(
                        Icons.send_outlined,
                        color: context.colors.accent,
                        size: 19,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Feedback extends StatefulWidget {
  const _Feedback({required this.preview});
  final bool preview;

  @override
  State<_Feedback> createState() => _FeedbackState();
}

class _FeedbackState extends State<_Feedback> {
  late int _courier = widget.preview ? 4 : 0;
  late int _restaurant = widget.preview ? 3 : 0;

  @override
  Widget build(BuildContext context) => Surface(
    bottom: Footer(
      Primary(
        'Submit review',
        _restaurant == 0
            ? null
            : () {
                final s = context.shop;
                s.restaurantRating = _restaurant;
                s.refresh();
                context.back();
                if (context.mounted) context.note('Thanks for your review.');
              },
      ),
    ),
    child: PageBody(
      children: [
        Header(
          'Rate order',
          close: true,
          trailing: TextButton(
            onPressed: () => context.open(Screen.help),
            child: const Text('Help'),
          ),
        ),
        const SizedBox(height: 12),
        const Center(child: Art('star-struck', width: 150, height: 146)),
        Panel(
          child: Column(
            children: [
              const TitleText('Rate your courier'),
              const Muted(
                'How was the experience with your courier Marvin McKinney?',
                align: TextAlign.center,
              ),
              StarPicker(_courier, (value) => setState(() => _courier = value)),
              Divider(color: context.colors.rule, height: 34),
              const TitleText('Review restaurant'),
              const Muted(
                'How was your experience with One Bowl Club?',
                align: TextAlign.center,
              ),
              StarPicker(
                _restaurant,
                (value) => setState(() => _restaurant = value),
              ),
              const SizedBox(height: 11),
              TextField(
                minLines: 2,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Write a review',
                  filled: true,
                  fillColor: context.colors.field,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class StarPicker extends StatelessWidget {
  const StarPicker(this.value, this.onChange, {super.key, this.size = 25});
  final int value;
  final ValueChanged<int>? onChange;
  final double size;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (var i = 1; i <= 5; i++)
        if (onChange == null)
          Icon(
            Icons.star_rounded,
            size: size,
            color: value >= i ? gold : context.colors.rule,
          )
        else
          SizedBox(
            width: 44,
            height: 44,
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: () => onChange!(i),
              tooltip: '$i stars',
              icon: Icon(
                Icons.star_rounded,
                size: size,
                color: value >= i ? gold : context.colors.rule,
              ),
            ),
          ),
    ],
  );
}
