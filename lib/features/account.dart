import 'package:flutter/material.dart';

import '../core/catalog.dart';
import '../core/screen.dart';
import '../core/ui.dart';
import 'auth.dart';

class AccountPage extends StatelessWidget {
  const AccountPage(this.screen, {super.key});
  final Screen screen;

  @override
  Widget build(BuildContext context) => switch (screen) {
    Screen.editProfile => const _EditProfile(),
    Screen.membership => const _Membership(),
    Screen.promotions ||
    Screen.promotionError => _Promotions(screen == Screen.promotionError),
    Screen.payments => const _Payment(),
    Screen.addCard => const _AddCard(),
    Screen.help => const _Help(),
    Screen.notifications || Screen.notificationsEmpty => const _Notifications(),
    _ => const _Account(),
  };
}

class _Account extends StatelessWidget {
  const _Account();

  @override
  Widget build(BuildContext context) {
    final s = context.shop;
    return Surface(
      glow: Glow.account,
      bottom: const ShopBar(4),
      child: PageBody(
        children: [
          Row(
            children: [
              const ClipOval(
                child: Art(
                  'avatar-profile',
                  width: 52,
                  height: 52,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () => context.open(Screen.editProfile),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TitleText(s.profile.first, size: 24),
                      Text(
                        'Edit profile',
                        style: TextStyle(
                          color: context.colors.accent,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Stack(
                children: [
                  IconButton(
                    onPressed: () => context.open(
                      s.hasNotifications
                          ? Screen.notifications
                          : Screen.notificationsEmpty,
                    ),
                    tooltip: 'Notifications',
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      size: 27,
                    ),
                  ),
                  if (s.hasNotifications)
                    const Positioned(
                      right: 12,
                      top: 10,
                      child: IgnorePointer(
                        child: CircleAvatar(
                          radius: 4,
                          backgroundColor: Colors.deepOrangeAccent,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 26),
          Container(
            height: 139,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xffffd86d), Color(0xffffe7a7)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Stack(
              children: [
                const Positioned(
                  bottom: -36,
                  right: 12,
                  child: Art('hero-burger', width: 132, height: 164),
                ),
                Positioned(
                  left: 24,
                  top: 19,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.member ? 'KingMember' : 'Become a member',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        s.memberPlan ?? 'Try free for one month',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Pill(
                        s.member ? 'View plan' : 'Join now',
                        color: const Color(0xff252424),
                        ink: Colors.white,
                        onTap: () => context.open(Screen.membership),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          for (final (icon, title, color, screen) in const [
            (
              Icons.favorite_border,
              'Favorites',
              Colors.pinkAccent,
              Screen.favorites,
            ),
            (
              Icons.confirmation_number_outlined,
              'Promotions',
              Color(0xffbc8400),
              Screen.promotions,
            ),
            (
              Icons.toll_outlined,
              'Payment',
              Color(0xff9a83ed),
              Screen.payments,
            ),
            (
              Icons.location_on_outlined,
              'Addresses',
              Color(0xff3eb889),
              Screen.addresses,
            ),
            (
              Icons.support_outlined,
              'Help center',
              Color(0xff699ed6),
              Screen.help,
            ),
          ])
            EntryRow(
              icon,
              title,
              iconColor: color,
              circle: false,
              divider: false,
              verticalPadding: 8,
              onTap: () => context.open(screen),
            ),
          EntryRow(
            Icons.auto_fix_high_outlined,
            'Darkmode',
            iconColor: const Color(0xff9a83ed),
            circle: false,
            divider: false,
            verticalPadding: 8,
            trailing: Switch(
              value: s.dark,
              onChanged: (value) {
                s.dark = value;
                s.refresh();
              },
            ),
          ),
          EntryRow(
            Icons.lock_outline,
            'Log out',
            iconColor: Colors.deepOrangeAccent,
            circle: false,
            divider: false,
            verticalPadding: 8,
            onTap: () async {
              final leave = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Log out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Log out'),
                    ),
                  ],
                ),
              );
              if (leave == true && context.mounted) {
                context.reset(Screen.signIn);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _EditProfile extends StatefulWidget {
  const _EditProfile();
  @override
  State<_EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<_EditProfile> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _first, _last, _phone, _email;
  bool _ready = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ready) return;
    final p = context.shop.profile;
    _first = TextEditingController(text: p.first);
    _last = TextEditingController(text: p.last);
    _phone = TextEditingController(text: p.phone);
    _email = TextEditingController(text: p.email);
    _ready = true;
  }

  @override
  void dispose() {
    for (final controller in [_first, _last, _phone, _email]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _save() {
    if (_form.currentState?.validate() != true) return;
    final s = context.shop;
    s.profile = (
      first: _first.text.trim(),
      last: _last.text.trim(),
      phone: _phone.text.trim(),
      email: _email.text.trim(),
    );
    s.refresh();
    context.back();
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    TextInputType? keyboard,
    String? Function(String?)? validate,
  }) => TextFormField(
    controller: controller,
    keyboardType: keyboard,
    validator:
        validate ?? (text) => (text ?? '').trim().isEmpty ? 'Required' : null,
    decoration: InputDecoration(
      labelText: label,
      floatingLabelBehavior: FloatingLabelBehavior.always,
    ),
  );

  @override
  Widget build(BuildContext context) => Surface(
    glow: Glow.account,
    bottom: Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 44),
      child: Primary('Save', _save),
    ),
    child: Form(
      key: _form,
      child: PageBody(
        children: [
          const Header('Edit profile'),
          const SizedBox(height: 18),
          Center(
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                const ClipOval(
                  child: Art(
                    'avatar-profile',
                    width: 111,
                    height: 111,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  bottom: -9,
                  child: IconTile(
                    Icons.camera_alt_outlined,
                    () => context.note('The demo uses a sample profile photo.'),
                    label: 'Profile photo',
                    size: 32,
                    round: true,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 35),
          Row(
            children: [
              Expanded(child: _field('First name', _first)),
              const SizedBox(width: 14),
              Expanded(child: _field('Last name', _last)),
            ],
          ),
          const SizedBox(height: 20),
          _field(
            'Phone number',
            _phone,
            keyboard: TextInputType.phone,
            validate: (value) =>
                (value ?? '').replaceAll(RegExp(r'\D'), '').length != 10
                ? 'Enter a 10-digit phone number'
                : null,
          ),
          const SizedBox(height: 20),
          _field(
            'Email address',
            _email,
            keyboard: TextInputType.emailAddress,
            validate: (value) =>
                !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                    .hasMatch(value?.trim() ?? '')
                ? 'Enter a valid email'
                : null,
          ),
        ],
      ),
    ),
  );
}

class _Membership extends StatefulWidget {
  const _Membership();
  @override
  State<_Membership> createState() => _MembershipState();
}

class _MembershipState extends State<_Membership> {
  int? _plan;

  @override
  Widget build(BuildContext context) {
    final s = context.shop;
    final plan = _plan ?? (s.memberPlan == 'Annual plan' ? 1 : 0);
    return Surface(
      glow: Glow.warm,
      bottom: Footer(
        Primary(
          s.member ? 'Membership active' : 'Join us',
          s.member
              ? null
              : () {
                  s.memberPlan = plan == 0 ? 'Monthly plan' : 'Annual plan';
                  s.refresh();
                  context.back();
                  if (context.mounted) {
                    context.note('KingMember is active in this demo.');
                  }
                },
        ),
      ),
      child: PageBody(
        padding: EdgeInsets.zero,
        children: [
          Container(
            decoration: const BoxDecoration(
              color: honey,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.elliptical(200, 50),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                const Positioned(
                  right: -23,
                  top: 6,
                  child: Art('hero-carrot', width: 157, height: 168),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 44, 24, 37),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconTile(Icons.close, context.back, label: 'Close'),
                      const SizedBox(height: 13),
                      const Text(
                        '◆ KingMember',
                        style: TextStyle(color: Colors.black87, fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Join us and save up to\n\$50 per month',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 3, 24, 20),
            child: Column(
              children: [
                for (final (icon, label, tint) in const [
                  (
                    Icons.shopping_bag_outlined,
                    'Free delivery within 8km',
                    Colors.pinkAccent,
                  ),
                  (
                    Icons.person_outline,
                    'High rated courier',
                    Colors.blueAccent,
                  ),
                  (
                    Icons.workspace_premium_outlined,
                    'Member-only restaurant deals',
                    Colors.green,
                  ),
                ])
                  EntryRow(icon, label, iconColor: tint, divider: false),
                SectionTitle(
                  'Choose your plan',
                  action: 'More info',
                  onTap: () => context.open(Screen.help),
                ),
                const SizedBox(height: 8),
                RadioGroup<int>(
                  groupValue: plan,
                  onChanged: (value) {
                    if (!s.member) setState(() => _plan = value);
                  },
                  child: Column(
                    children: [
                      for (final (index, label, price, term) in const [
                        (0, 'Monthly plan', '\$9.99', '/Month'),
                        (1, 'Annual plan', '\$96', '/Year (\$8/month)'),
                      ])
                        Padding(
                          padding: const EdgeInsets.only(bottom: 13),
                          child: Panel(
                            padding: const EdgeInsets.all(9),
                            child: RadioListTile<int>(
                              value: index,
                              activeColor: gold,
                              controlAffinity: ListTileControlAffinity.trailing,
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (index == 1)
                                    const Pill(
                                      'Best value',
                                      color: mint,
                                      ink: Colors.black,
                                    ),
                                  TitleText(label, size: 15),
                                ],
                              ),
                              subtitle: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: price,
                                      style: TextStyle(
                                        color: context.colors.accent,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' $term',
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
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

class _Promotions extends StatefulWidget {
  const _Promotions(this.initialError);
  final bool initialError;

  @override
  State<_Promotions> createState() => _PromotionsState();
}

class _PromotionsState extends State<_Promotions> {
  late final _code = TextEditingController(
    text: widget.initialError ? 'ABC' : '',
  );
  late bool _error = widget.initialError;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  void _claim(String code) {
    final value = code.trim().toUpperCase();
    if (!['KING5', 'DEAL30'].contains(value)) {
      setState(() => _error = true);
      return;
    }
    final s = context.shop;
    s.promo = value;
    s.refresh();
    FocusScope.of(context).unfocus();
    setState(() {
      _error = false;
      _code.clear();
    });
    context.note('Promo code $value applied.');
  }

  @override
  Widget build(BuildContext context) {
    final s = context.shop;
    return Surface(
      bottom: _error
          ? Footer(Primary('Claim', () => _claim(_code.text)))
          : null,
      child: PageBody(
        children: [
          if (!_error) ...[
            const Header('Promo code'),
            const SizedBox(height: 25),
          ],
          SearchBarBox(
            controller: _code,
            hint: 'Enter promo code',
            error: _error,
            leading: _error
                ? IconButton(
                    onPressed: context.back,
                    tooltip: 'Back',
                    icon: const Icon(Icons.chevron_left),
                  )
                : const Icon(Icons.confirmation_number_outlined, size: 20),
            onChanged: (_) => setState(() {}),
            onSubmitted: _claim,
            trailing: IconButton(
              onPressed: () => _claim(_code.text),
              tooltip: 'Apply promo code',
              icon: Icon(
                Icons.arrow_forward,
                color: context.colors.accent,
                size: 20,
              ),
            ),
          ),
          if (_error) ...[
            const SizedBox(height: 8),
            const Text(
              'Invalid code! Please try another one',
              style: TextStyle(color: Colors.deepOrangeAccent, fontSize: 12),
            ),
          ] else ...[
            const SizedBox(height: 24),
            const TitleText('Available codes'),
            const SizedBox(height: 12),
            for (final (label, details, code) in const [
              ('\$5 OFF', 'Apply when spend over \$30', 'KING5'),
              ('30% OFF', 'At selected restaurants*', 'DEAL30'),
            ])
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Panel(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              label,
                              style: TextStyle(
                                color: context.colors.accent,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Muted(details, size: 12),
                            const SizedBox(height: 4),
                            Muted('Demo code · $code', size: 11),
                          ],
                        ),
                      ),
                      Pill(
                        s.promo == code ? 'Applied' : 'Claim',
                        color: gold,
                        ink: Colors.black,
                        onTap: () => _claim(code),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _Payment extends StatelessWidget {
  const _Payment();
  @override
  Widget build(BuildContext context) {
    final s = context.shop;
    return Surface(
      child: PageBody(
        children: [
          const Header('Payment'),
          const SizedBox(height: 28),
          const TitleText('Saved payment method'),
          RadioGroup<String>(
            groupValue: s.payment,
            onChanged: (value) {
              s.payment = value!;
              s.refresh();
            },
            child: Column(
              children: [
                for (final (label, mark) in [
                  ('Apple Pay', 'Apple Pay'),
                  ...s.savedCards.map((card) => (card, 'VISA')),
                  if (s.payment == 'PayPal') ('PayPal', 'PayPal'),
                ])
                  RadioListTile<String>(
                    contentPadding: EdgeInsets.zero,
                    title: Text(label),
                    value: label,
                    activeColor: gold,
                    controlAffinity: ListTileControlAffinity.trailing,
                    secondary: mark == 'Apple Pay'
                        ? const Art('payment-apple', width: 53, height: 32)
                        : _PaymentMark(mark),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          const TitleText('Add payment method'),
          EntryRow(
            Icons.paypal,
            'PayPal',
            iconColor: Colors.blue,
            onTap: () {
              s.payment = 'PayPal';
              s.refresh();
              context.note('PayPal selected for this demo.');
            },
          ),
          EntryRow(
            Icons.credit_card,
            'Debit/Credit card',
            iconColor: Colors.lightBlue,
            onTap: () => context.open(Screen.addCard),
            divider: false,
          ),
        ],
      ),
    );
  }
}

class _PaymentMark extends StatelessWidget {
  const _PaymentMark(this.mark);
  final String mark;
  @override
  Widget build(BuildContext context) => Container(
    alignment: Alignment.center,
    width: 53,
    height: 32,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      mark,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        color: Color(0xff142b67),
        fontSize: 12,
      ),
    ),
  );
}

class _AddCard extends StatefulWidget {
  const _AddCard();
  @override
  State<_AddCard> createState() => _AddCardState();
}

class _AddCardState extends State<_AddCard> {
  final _values = ['', '', ''];
  int _selected = 0;
  String? _error;

  String _format(int index) {
    final value = _values[index];
    if (index == 1 && value.length > 2) {
      return '${value.substring(0, 2)}/${value.substring(2)}';
    }
    if (index == 0) {
      return [
        for (var i = 0; i < value.length; i += 4)
          value.substring(i, (i + 4).clamp(0, value.length)),
      ].join(' ');
    }
    return value;
  }

  void _press(String key) => setState(() {
    _error = null;
    final value = _values[_selected];
    if (key == 'delete') {
      if (value.isNotEmpty) {
        _values[_selected] = value.substring(0, value.length - 1);
      }
    } else if (value.length < [16, 4, 3][_selected]) {
      _values[_selected] += key;
      if (_selected < 2 && _values[_selected].length == [16, 4][_selected]) {
        _selected++;
      }
    }
  });

  void _save() {
    final month =
        int.tryParse(_values[1].length < 2 ? '' : _values[1].substring(0, 2)) ??
        0;
    if (_values[0].length != 16 ||
        _values[1].length != 4 ||
        month < 1 ||
        month > 12 ||
        _values[2].length != 3) {
      setState(
        () => _error =
            'Enter a 16-digit demo card, a valid month and a 3-digit CVC.',
      );
      return;
    }
    final mask = '•••• ${_values[0].substring(12)}';
    final s = context.shop;
    if (!s.savedCards.contains(mask)) s.savedCards.add(mask);
    s.payment = mask;
    s.refresh();
    context.back();
  }

  @override
  Widget build(BuildContext context) => Surface(
    bottom: Padding(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 44),
      child: Primary('Save', _save),
    ),
    child: PageBody(
      children: [
        const Header('Add a card'),
        const SizedBox(height: 22),
        for (final (index, label, hint) in const [
          (0, 'Card number', 'XXXX XXXX XXXX XXXX'),
          (1, 'Expiration', 'mm/yy'),
          (2, 'CVC', 'CVC number'),
        ])
          InkWell(
            onTap: () => setState(() => _selected = index),
            child: InputDecorator(
              isFocused: _selected == index,
              isEmpty: _values[index].isEmpty,
              decoration: InputDecoration(
                labelText: label,
                hintText: hint,
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              child: Text(
                _values[index].isEmpty ? hint : _format(index),
                style: TextStyle(
                  color: _values[index].isEmpty
                      ? context.colors.muted
                      : context.colors.ink,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        const SizedBox(height: 22),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              _error!,
              style: const TextStyle(
                color: Colors.deepOrangeAccent,
                fontSize: 12,
              ),
            ),
          ),
        DigitPad(_press),
      ],
    ),
  );
}

class _Help extends StatelessWidget {
  const _Help();

  @override
  Widget build(BuildContext context) => Surface(
    bottom: Padding(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 44),
      child: Primary(
        'Contact us',
        () => context.note('Support is unavailable in this demo.'),
      ),
    ),
    child: PageBody(
      children: [
        const Header('Help center'),
        const SizedBox(height: 24),
        for (final (index, question, answer) in const [
          (
            0,
            'There was missing/wrong items with my order',
            'Open your order receipt and choose Get help to review your order details.',
          ),
          (
            1,
            'Will I get a penalty if I cancel my order?',
            'Open the order while it is being placed to cancel it. The demo does not charge cancellation fees.',
          ),
          (
            2,
            'What is KingMember?',
            'KingMember includes free delivery within 8 km and offers from selected restaurants.',
          ),
          (
            3,
            'My order was delivered late',
            'Use order tracking and the courier chat to see the latest delivery status.',
          ),
        ])
          ExpansionTile(
            initiallyExpanded: index == 1,
            tilePadding: EdgeInsets.zero,
            title: TitleText(question, size: 14),
            childrenPadding: const EdgeInsets.only(bottom: 15),
            expandedAlignment: Alignment.centerLeft,
            children: [Muted(answer)],
          ),
      ],
    ),
  );
}

class _Notifications extends StatelessWidget {
  const _Notifications();

  @override
  Widget build(BuildContext context) {
    final s = context.shop;
    return Surface(
      bottom: const ShopBar(4),
      child: PageBody(
        children: [
          Header(
            'Notifications',
            trailing: TextButton(
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              onPressed: s.hasNotifications
                  ? () {
                      s.hasNotifications = false;
                      s.refresh();
                    }
                  : null,
              child: const Text('Clear all', style: TextStyle(fontSize: 11)),
            ),
          ),
          const SizedBox(height: 24),
          if (!s.hasNotifications)
            const SizedBox(
              height: 445,
              child: EmptyState('receipt', 'No activities', receipt: true),
            )
          else
            for (final (name, message, art, color, screen) in const [
              (
                'One Bowl Club',
                'Is preparing your order...',
                'dish-burger',
                honey,
                Screen.orders,
              ),
              (
                'One Bowl Club',
                'Your order was delivered!',
                'dish-cupcake',
                blush,
                Screen.orders,
              ),
              (
                'Guy Hawkins',
                'Sent you a message',
                'avatar-guest',
                sky,
                Screen.chat,
              ),
              (
                'Happy Easter Day!',
                'You got a gift from us',
                'hero-snack',
                sky,
                Screen.promotions,
              ),
              (
                'Promotions',
                'Free delivery until Friday',
                'hero-noodles',
                mint,
                Screen.promotions,
              ),
            ])
              Padding(
                padding: const EdgeInsets.only(bottom: 19),
                child: InkWell(
                  onTap: () => context.open(screen),
                  borderRadius: BorderRadius.circular(19),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: color,
                        child: Art(art, width: 44, height: 44),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TitleText(name, size: 15),
                            Muted(message),
                            const Muted('11 Mar 2023, 5:00PM', size: 11),
                          ],
                        ),
                      ),
                      const CircleAvatar(radius: 4, backgroundColor: gold),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
