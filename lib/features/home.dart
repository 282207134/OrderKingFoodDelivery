import 'package:flutter/material.dart';

import '../core/catalog.dart';
import '../core/screen.dart';
import '../core/ui.dart';

class HomePage extends StatelessWidget {
  const HomePage(this.screen, {super.key});
  final Screen screen;

  @override
  Widget build(BuildContext context) => switch (screen) {
    Screen.home || Screen.homeFull => _Home(full: screen == Screen.homeFull),
    Screen.search ||
    Screen.searchResults => _Search(results: screen == Screen.searchResults),
    Screen.filter => const _Filter(),
    Screen.pickup || Screen.pickupFull || Screen.pickupPin => _Pickup(screen),
    _ => Surface(
      child: PageBody(
        children: [
          const Header('Favorites'),
          const SizedBox(height: 24),
          if (context.shop.favorites.isEmpty)
            const EmptyState(
              'hero-noodles',
              'No favorites yet',
              subtitle: 'Tap a heart to save a restaurant.',
            ),
          for (final restaurant in context.shop.favorites)
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: RestaurantCard(restaurant),
            ),
        ],
      ),
    ),
  };
}

class _Home extends StatelessWidget {
  const _Home({required this.full});
  final bool full;

  @override
  Widget build(BuildContext context) => Surface(
    bottom: full ? null : const ShopBar(0),
    child: PageBody(
      padding: const EdgeInsets.fromLTRB(0, 44, 0, 28),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Location(false, () => context.open(Screen.addresses)),
              const SizedBox(height: 24),
              const _SearchEntry(),
              const SizedBox(height: 23),
              _Lead('Categories', 'See all', () => context.open(Screen.search)),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const _CategoryStrip(),
        const SizedBox(height: 24),
        SizedBox(
          height: 139,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            scrollDirection: Axis.horizontal,
            children: [
              _Deal(
                'Up to 30% off everyday',
                'hero-noodles',
                const Color(0xff9c97ef),
                const Color(0xffb8b4fa),
              ),
              const SizedBox(width: 12),
              _Deal(
                'Free delivery 1st order',
                'hero-snack',
                const Color(0xfff7a1dc),
                const Color(0xffffc0ec),
              ),
            ],
          ),
        ),
        const SizedBox(height: 31),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: TitleText('Trending now'),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            scrollDirection: Axis.horizontal,
            children: [
              for (final (i, restaurant) in [yogurt, pho, dumplings].indexed)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: SizedBox(
                    width: 243,
                    child: RestaurantCard(
                      restaurant,
                      compact: true,
                      badge: '${i + 1}',
                    ),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              _Lead(
                'Picked for you',
                full ? null : 'See all',
                () => context.open(Screen.homeFull),
              ),
              const SizedBox(height: 11),
              for (final restaurant in [sandwich, yogurt, dumplings]) ...[
                RestaurantCard(
                  restaurant,
                  badge: 'Buy 1 get 1',
                  image: restaurant == yogurt ? 'photo-smoothie' : null,
                ),
                const SizedBox(height: 20),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}

class _Lead extends StatelessWidget {
  const _Lead(this.title, this.label, this.action);
  final String title;
  final String? label;
  final VoidCallback action;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(child: TitleText(title)),
      if (label != null)
        InkWell(
          onTap: action,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Muted(label!),
          ),
        ),
    ],
  );
}

class _Location extends StatelessWidget {
  const _Location(this.pickup, this.action);
  final bool pickup;
  final VoidCallback action;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: action,
    child: Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Muted(pickup ? 'Pickup now' : 'Deliver to', size: 14),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TitleText(
                pickup
                    ? 'Map location'
                    : context.shop.address.city
                          .split(',')
                          .take(2)
                          .join(',')
                          .trim()
                          .split(' L4Z')
                          .first,
                size: 16,
              ),
              const SizedBox(width: 5),
              const Icon(Icons.keyboard_arrow_down, size: 18),
            ],
          ),
        ],
      ),
    ),
  );
}

class _FilterIcon extends StatelessWidget {
  const _FilterIcon(this.action);
  final VoidCallback action;

  @override
  Widget build(BuildContext context) => Material(
    color: gold,
    borderRadius: BorderRadius.circular(13),
    child: IconButton(
      tooltip: 'Filter',
      icon: const Icon(Icons.tune, color: Colors.black, size: 23),
      constraints: const BoxConstraints.tightFor(width: 48, height: 48),
      onPressed: action,
    ),
  );
}

class _SearchEntry extends StatelessWidget {
  const _SearchEntry();
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(child: SearchBarBox(onTap: () => context.open(Screen.search))),
      const SizedBox(width: 12),
      _FilterIcon(() => context.open(Screen.filter)),
    ],
  );
}

void _searchFor(BuildContext context, String text) {
  context.shop.search(text);
  context.open(Screen.searchResults);
}

class _CategoryStrip extends StatelessWidget {
  const _CategoryStrip();

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 93,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: categories.length,
      separatorBuilder: (_, _) => const SizedBox(width: 12),
      itemBuilder: (context, index) {
        final (name, asset, _) = categories[index];
        return Semantics(
          button: true,
          label: name,
          child: InkWell(
            onTap: () => _searchFor(context, name),
            borderRadius: BorderRadius.circular(40),
            child: SizedBox(
              width: 68,
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: context.colors.field,
                      shape: BoxShape.circle,
                    ),
                    child: Art(asset),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}

class _Deal extends StatelessWidget {
  const _Deal(this.subtitle, this.asset, this.start, this.end);
  final String subtitle;
  final String asset;
  final Color start;
  final Color end;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: (MediaQuery.sizeOf(context).width - 48).clamp(250.0, 400.0),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [start, end]),
        ),
        child: Stack(
          children: [
            Positioned(
              right: 20,
              top: 16,
              child: Art(asset, width: 117, height: 107),
            ),
            Positioned(
              right: 113,
              top: 30,
              child: CircleAvatar(radius: 6, backgroundColor: honey),
            ),
            Positioned(
              right: 23,
              bottom: 27,
              child: CircleAvatar(radius: 4, backgroundColor: Colors.white),
            ),
            Positioned(
              left: 24,
              top: 21,
              bottom: 15,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Special deals',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Pill('Order now', onTap: () => _searchFor(context, '')),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class RestaurantCard extends StatelessWidget {
  const RestaurantCard(
    this.restaurant, {
    super.key,
    this.badge,
    this.compact = false,
    this.pickup = false,
    this.image,
  });
  final Restaurant restaurant;
  final String? badge;
  final bool compact;
  final bool pickup;
  final String? image;

  @override
  Widget build(BuildContext context) {
    final session = context.shop;
    final favorite = session.favorites.contains(restaurant);
    final p = context.colors;
    void visit() {
      session.store = restaurant;
      session.chooseMode(pickup);
      context.open(pickup ? Screen.pickupRestaurant : Screen.restaurant);
    }

    return Semantics(
      button: true,
      label: 'Open ${restaurant.name}',
      child: InkWell(
        onTap: visit,
        borderRadius: BorderRadius.circular(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: SizedBox(
                height: compact ? 134 : 165,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Art(image ?? restaurant.asset, fit: BoxFit.cover),
                    if (badge != null)
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 5,
                          ),
                          decoration: const BoxDecoration(
                            color: gold,
                            borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(21),
                            ),
                          ),
                          child: Text(
                            badge!,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                              fontSize: compact ? 16 : 12,
                            ),
                          ),
                        ),
                      ),
                    if (!compact)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: IconTile(
                          favorite ? Icons.favorite : Icons.favorite_border,
                          () => session.toggleFavorite(restaurant),
                          label: favorite ? 'Remove favorite' : 'Add favorite',
                          color: favorite ? Colors.deepOrangeAccent : null,
                          size: 35,
                          round: true,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: TitleText(restaurant.name, size: 16)),
                const Icon(Icons.star_rounded, size: 17, color: gold),
                Text(
                  restaurant.rating,
                  style: TextStyle(fontSize: 11, color: p.accent),
                ),
              ],
            ),
            Muted(
              '${pickup
                  ? '3km'
                  : restaurant == pho
                  ? 'Free delivery'
                  : '\$3 delivery fee'}  •  ${restaurant.minutes}',
              size: 11,
            ),
            if (!compact) ...[
              const SizedBox(height: 7),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  if (!pickup && restaurant != pho)
                    const _Tag('KingMember', mint),
                  const _Tag('Pickup 10% off', lavender),
                  if (!pickup) const _Tag('\$5 coupon', blush),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.label, this.color);
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(7),
    ),
    child: Text(
      label,
      style: const TextStyle(color: Colors.black, fontSize: 10),
    ),
  );
}

class _Search extends StatefulWidget {
  const _Search({required this.results});
  final bool results;

  @override
  State<_Search> createState() => _SearchState();
}

class _SearchState extends State<_Search> {
  final _query = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.results && _query.text.isEmpty) _query.text = context.shop.query;
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  List<Restaurant> _results(BuildContext context) {
    final s = context.shop;
    final query = s.query.toLowerCase();
    var matches = query == 'asian food'
        ? [pho, sandwich, secondSandwich]
        : restaurants
              .where(
                (r) => '${r.name} ${r.cuisine}'.toLowerCase().contains(query),
              )
              .toList();
    if (matches.isEmpty &&
        [
          'pizza',
          'burger',
          'hotdog',
          'sushi',
          'fast food',
          'italian',
        ].contains(query)) {
      matches = [bowlClub];
    }
    if (s.maxFee < 3) matches.removeWhere((r) => r != pho);
    if (s.dealsOnly) {
      matches.removeWhere(
        (r) => !const [pho, bowlClub, sandwich, secondSandwich].contains(r),
      );
    }
    if (s.memberOnly) {
      matches.removeWhere(
        (r) =>
            !const [bowlClub, sandwich, secondSandwich, dumplings].contains(r),
      );
    }
    if (s.prices.isNotEmpty) {
      matches.removeWhere((r) => !s.prices.contains(r == pho ? 1 : 2));
    }
    if (s.sort == 'Top rated') {
      matches.sort((a, b) => b.rating.compareTo(a.rating));
    }
    if (s.sort == 'Fastest delivery') {
      matches.sort((a, b) => a.minutes.compareTo(b.minutes));
    }
    if (s.sort == 'Lowest delivery fee') {
      matches.sort((a, b) => (a == pho ? 0 : 3).compareTo(b == pho ? 0 : 3));
    }
    return matches;
  }

  void _submit(String query) {
    FocusScope.of(context).unfocus();
    if (widget.results) {
      context.shop.search(query);
      setState(() {});
    } else {
      _searchFor(context, query);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = context.shop;
    final matches = widget.results ? _results(context) : const <Restaurant>[];
    return Surface(
      child: PageBody(
        children: [
          Row(
            children: [
              Expanded(
                child: SearchBarBox(
                  controller: _query,
                  onSubmitted: _submit,
                  leading: IconButton(
                    onPressed: context.back,
                    tooltip: 'Back',
                    icon: const Icon(Icons.chevron_left),
                  ),
                  trailing: IconButton(
                    onPressed: () => _submit(_query.text),
                    tooltip: 'Search',
                    icon: const Icon(Icons.search),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _FilterIcon(
                () => context.open(Screen.filter, data: widget.results),
              ),
            ],
          ),
          const SizedBox(height: 21),
          if (widget.results) ...[
            TitleText('${matches.length} Results'),
            const SizedBox(height: 13),
            if (matches.isEmpty)
              const Muted('No restaurants match your search.'),
            for (final restaurant in matches) ...[
              RestaurantCard(
                restaurant,
                badge: restaurant == pho ? 'Free delivery' : 'Buy 1 get 1',
              ),
              const SizedBox(height: 20),
            ],
          ] else ...[
            const TitleText('History'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 7,
              runSpacing: 6,
              children: [
                for (final value in session.history.take(6))
                  InputChip(
                    label: Text(value),
                    onPressed: () => _submit(value),
                    onDeleted: () {
                      session.history.remove(value);
                      session.refresh();
                    },
                  ),
              ],
            ),
            const SizedBox(height: 18),
            const TitleText('Discovery 🔥'),
            for (final label in const ['Sushi', 'Chinese food', 'Noodles'])
              EntryRow(
                Icons.local_fire_department_outlined,
                label,
                iconColor: Colors.deepOrangeAccent,
                onTap: () => _submit(
                  label == 'Chinese food' || label == 'Noodles'
                      ? 'Asian food'
                      : label,
                ),
                circle: false,
              ),
            const SizedBox(height: 18),
            const TitleText('All categories'),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, box) => Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final (label, art, tint) in categories)
                    SizedBox(
                      width: (box.maxWidth - 10) / 2,
                      height: 66,
                      child: Material(
                        color: tint,
                        borderRadius: BorderRadius.circular(16),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () =>
                              _submit(label == 'Asian' ? 'Asian food' : label),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    label,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Art(art, width: 61, height: 60),
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
        ],
      ),
    );
  }
}

class _Filter extends StatefulWidget {
  const _Filter();
  @override
  State<_Filter> createState() => _FilterState();
}

class _FilterState extends State<_Filter> {
  static const choices = [
    'Picked for you (default)',
    'Lowest delivery fee',
    'Top rated',
    'Fastest delivery',
  ];
  String? _sort;
  bool? _deals;
  bool? _memberOnly;
  double? _fee;
  Set<int>? _prices;

  @override
  Widget build(BuildContext context) {
    final s = context.shop;
    final sort = _sort ?? s.sort;
    final deals = _deals ?? s.dealsOnly;
    final memberOnly = _memberOnly ?? s.memberOnly;
    final fee = _fee ?? s.maxFee.toDouble();
    final prices = _prices ??= {...s.prices};
    return Surface(
      glow: Glow.none,
      bottom: Footer(
        Primary('Show results', () {
          s.sort = sort;
          s.dealsOnly = deals;
          s.memberOnly = memberOnly;
          s.maxFee = fee.round();
          s.prices
            ..clear()
            ..addAll(prices);
          s.refresh();
          if (ModalRoute.of(context)?.settings.arguments == true) {
            context.back();
          } else {
            context.swap(Screen.searchResults);
          }
        }),
      ),
      child: PageBody(
        children: [
          Header(
            'Filter',
            close: true,
            trailing: TextButton(
              onPressed: () => setState(() {
                _sort = choices.first;
                _deals = false;
                _memberOnly = false;
                _fee = 6;
                prices.clear();
              }),
              child: const Text('Reset', style: TextStyle(fontSize: 11)),
            ),
          ),
          const SizedBox(height: 28),
          const TitleText('Sort'),
          for (final (i, choice) in choices.indexed)
            EntryRow(
              [
                Icons.recommend_outlined,
                Icons.payments_outlined,
                Icons.star_border,
                Icons.timer_outlined,
              ][i],
              choice,
              iconColor: [
                Colors.deepPurpleAccent,
                Colors.pinkAccent,
                Colors.green,
                Colors.blue,
              ][i],
              divider: false,
              onTap: () => setState(() => _sort = choice),
              trailing: Icon(
                Icons.check,
                color: sort == choice ? gold : Colors.transparent,
              ),
            ),
          const SizedBox(height: 17),
          const TitleText('Deals'),
          EntryRow(
            Icons.local_offer_outlined,
            'Offers',
            iconColor: Colors.green,
            divider: false,
            trailing: Switch(
              value: deals,
              onChanged: (v) => setState(() => _deals = v),
            ),
          ),
          EntryRow(
            Icons.workspace_premium_outlined,
            'KingMember',
            iconColor: Colors.deepPurpleAccent,
            divider: false,
            trailing: Switch(
              value: memberOnly,
              onChanged: (v) => setState(() => _memberOnly = v),
            ),
          ),
          const SizedBox(height: 16),
          const TitleText('Price'),
          const SizedBox(height: 7),
          Row(
            children: [
              for (var i = 1; i < 5; i++)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: i < 4 ? 5 : 0),
                    child: FilterChip(
                      label: Text(List.filled(i, '\$').join()),
                      selected: prices.contains(i),
                      showCheckmark: false,
                      selectedColor: gold,
                      labelStyle: TextStyle(
                        fontSize: 11,
                        color: prices.contains(i)
                            ? Colors.black
                            : context.colors.muted,
                      ),
                      onSelected: (value) => setState(() {
                        if (value) {
                          prices.add(i);
                        } else {
                          prices.remove(i);
                        }
                      }),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 17),
          const TitleText('Delivery fee'),
          Slider(
            value: fee,
            divisions: 4,
            min: 2,
            max: 6,
            label: '\$${fee.round()}',
            onChanged: (value) => setState(() => _fee = value),
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Muted('\$2'), Muted('\$6+')],
          ),
        ],
      ),
    );
  }
}

class _Pickup extends StatelessWidget {
  const _Pickup(this.screen);
  final Screen screen;

  @override
  Widget build(BuildContext context) {
    final full = screen == Screen.pickupFull;
    final pin = screen == Screen.pickupPin;
    return Surface(
      bottom: const ShopBar(1),
      child: PageBody(
        padding: EdgeInsets.zero,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 44, 24, 14),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: _Location(true, () => context.open(Screen.addressPin)),
                ),
                const SizedBox(height: 18),
                const _SearchEntry(),
              ],
            ),
          ),
          if (!full)
            LayoutBuilder(
              builder: (context, box) => SizedBox(
                height: pin ? 517 : 305,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: MapArt(
                        'map-pickup',
                        height: pin ? 517 : 305,
                        radius: 0,
                      ),
                    ),
                    for (final (i, x, y, rating) in const [
                      (0, .16, 59.0, '4.5'),
                      (1, .40, 90.0, '4.0'),
                      (2, .51, 151.0, '4.5'),
                      (3, .79, 214.0, '4.5'),
                      (4, .25, 209.0, '4.3'),
                    ])
                      Positioned(
                        left: box.maxWidth * x,
                        top: y,
                        child: Pill(
                          rating,
                          color: pin && i == 2 ? gold : null,
                          ink: pin && i == 2 ? Colors.black : null,
                          onTap: () => context.swap(
                            pin ? Screen.pickup : Screen.pickupPin,
                          ),
                        ),
                      ),
                    Positioned(
                      top: 11,
                      right: 24,
                      child: IconTile(
                        Icons.my_location,
                        () => context.open(Screen.addressPin),
                        label: 'Map location',
                        size: 34,
                        round: true,
                      ),
                    ),
                    if (pin)
                      Positioned(
                        left: 24,
                        right: 24,
                        bottom: 17,
                        child: Panel(
                          padding: const EdgeInsets.all(9),
                          child: const RestaurantCard(dumplings, pickup: true),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          if (!pin) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: GestureDetector(
                      onVerticalDragEnd: (_) => context.swap(
                        full ? Screen.pickup : Screen.pickupFull,
                      ),
                      child: Semantics(
                        button: true,
                        label: full ? 'Show map' : 'Expand restaurant list',
                        child: InkWell(
                          onTap: () => context.swap(
                            full ? Screen.pickup : Screen.pickupFull,
                          ),
                          child: SizedBox(
                            width: 65,
                            height: 18,
                            child: Center(
                              child: Container(
                                width: 42,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: context.colors.rule,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const TitleText('Categories'),
                ],
              ),
            ),
            const _CategoryStrip(),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TitleText('Near you'),
                  const SizedBox(height: 10),
                  for (final restaurant in [dumplings, donuts, bowlClub]) ...[
                    RestaurantCard(restaurant, pickup: true),
                    const SizedBox(height: 20),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
