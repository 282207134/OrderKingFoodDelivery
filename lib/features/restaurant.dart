import 'package:flutter/material.dart';

import '../core/catalog.dart';
import '../core/screen.dart';
import '../core/ui.dart';

class RestaurantPage extends StatelessWidget {
  const RestaurantPage(this.screen, {super.key, this.dish});
  final Screen screen;
  final Dish? dish;

  @override
  Widget build(BuildContext context) => switch (screen) {
    Screen.store ||
    Screen.storeFull => _Store(full: screen == Screen.storeFull),
    Screen.dish => _DishForm(dish ?? pizza),
    _ => _Menu(screen),
  };
}

const _sections = [
  (FoodSection.appetizer, 'Appetizer'),
  (FoodSection.main, 'Main course'),
  (FoodSection.dessert, 'Dessert'),
];

class _Menu extends StatefulWidget {
  const _Menu(this.screen);
  final Screen screen;

  @override
  State<_Menu> createState() => _MenuState();
}

class _MenuState extends State<_Menu> {
  final _sectionsKeys = {
    for (final (section, _) in _sections) section: GlobalKey(),
  };
  FoodSection _selected = FoodSection.main;

  void _findDish() async {
    final result = await showSearch<Dish?>(
      context: context,
      delegate: _DishSearch(),
    );
    if (mounted && result != null) context.open(Screen.dish, data: result);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.shop;
    final scrolled = widget.screen == Screen.restaurantScrolled;
    final pickup = widget.screen == Screen.pickupRestaurant;
    final store = s.store;
    final favorite = s.favorites.contains(store);
    return Surface(
      bottom: ShopBar(pickup ? 1 : 0),
      glow: scrolled ? Glow.pink : Glow.none,
      child: PageBody(
        padding: const EdgeInsets.only(bottom: 22),
        children: [
          if (scrolled)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 44, 24, 14),
              child: Header(
                store.name,
                trailing: IconTile(
                  Icons.search,
                  _findDish,
                  label: 'Find menu item',
                ),
              ),
            )
          else ...[
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(32),
              ),
              child: SizedBox(
                height: 230,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (pickup)
                      MapArt(
                        context.colors.dark ? 'map-restaurant' : 'map-checkout',
                        height: 230,
                        radius: 0,
                      )
                    else ...[
                      const ColoredBox(color: lavender),
                      const Positioned(
                        left: 25,
                        bottom: -25,
                        child: Art('hero-bowl', width: 229, height: 199),
                      ),
                      const Positioned(
                        right: -11,
                        top: -8,
                        child: Art('hero-carrot', width: 132, height: 133),
                      ),
                      const Positioned(
                        left: 5,
                        bottom: 53,
                        child: CircleAvatar(
                          backgroundColor: Color(0xffb093ff),
                          radius: 10,
                        ),
                      ),
                      const Positioned(
                        right: 60,
                        bottom: 77,
                        child: CircleAvatar(
                          backgroundColor: Color(0xffffa7dd),
                          radius: 6,
                        ),
                      ),
                    ],
                    Positioned(
                      top: 48,
                      left: 24,
                      child: IconTile(
                        Icons.chevron_left,
                        context.back,
                        label: 'Back',
                      ),
                    ),
                    Positioned(
                      top: 48,
                      right: 24,
                      child: Row(
                        children: [
                          IconTile(
                            pickup ? Icons.near_me_outlined : Icons.search,
                            pickup
                                ? () => context.open(Screen.store)
                                : _findDish,
                            label: pickup ? 'Store location' : 'Find menu item',
                          ),
                          const SizedBox(width: 12),
                          IconTile(
                            favorite ? Icons.favorite : Icons.favorite_border,
                            () => s.toggleFavorite(store),
                            label: favorite
                                ? 'Remove favorite'
                                : 'Add favorite',
                            color: Colors.deepOrangeAccent,
                          ),
                        ],
                      ),
                    ),
                    if (pickup)
                      Positioned(
                        bottom: 24,
                        left: 125,
                        child: Pill(
                          '2km',
                          icon: Icons.location_on_outlined,
                          onTap: () => context.open(Screen.store),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () => context.open(Screen.store),
                    child: Row(
                      children: [
                        Expanded(child: TitleText(store.name, size: 24)),
                        Icon(Icons.chevron_right, color: context.colors.muted),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: gold, size: 18),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Muted(
                          '${store.rating} (50+ reviews)  •  \$\$  •  ${store.cuisine}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 11),
                  const Wrap(
                    spacing: 8,
                    children: [
                      Pill(
                        'KingMember',
                        color: mint,
                        ink: Colors.black,
                        icon: Icons.diamond_outlined,
                      ),
                      Pill(
                        'Pickup 10% off',
                        color: lavender,
                        ink: Colors.black,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ModeSwitch(pickup || s.pickup, (value) {
                    if (value == pickup) return;
                    s.chooseMode(value);
                    context.swap(
                      value ? Screen.pickupRestaurant : Screen.restaurant,
                    );
                  }),
                ],
              ),
            ),
          ],
          if (scrolled)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                children: [
                  for (final (section, name) in _sections)
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() => _selected = section);
                          Scrollable.ensureVisible(
                            _sectionsKeys[section]!.currentContext!,
                            duration: const Duration(milliseconds: 250),
                          );
                        },
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                width: 2,
                                color: _selected == section
                                    ? gold
                                    : context.colors.rule,
                              ),
                            ),
                          ),
                          child: Text(
                            name,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          for (final (section, name)
              in scrolled
                  ? [_sections[1], _sections[2], _sections[0]]
                  : _sections)
            Padding(
              key: _sectionsKeys[section],
              padding: const EdgeInsets.fromLTRB(24, 21, 24, 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TitleText(name),
                  const SizedBox(height: 13),
                  for (final dish in menu.where(
                    (dish) => dish.section == section,
                  )) ...[_DishMenuRow(dish), const SizedBox(height: 15)],
                ],
              ),
            ),
          if (!scrolled)
            Center(
              child: Pill(
                'Browse by category',
                onTap: () => context.open(Screen.restaurantScrolled),
              ),
            ),
        ],
      ),
    );
  }
}

class _DishMenuRow extends StatelessWidget {
  const _DishMenuRow(this.dish);
  final Dish dish;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => context.open(Screen.dish, data: dish),
    borderRadius: BorderRadius.circular(16),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DishArt(dish),
        const SizedBox(width: 9),
        Expanded(
          child: SizedBox(
            height: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 1),
                TitleText(dish.name, size: 15),
                const SizedBox(height: 3),
                Expanded(
                  child: Muted(
                    dish == pizza
                        ? 'A classic Italian pizza made with a thin and crispy crust'
                        : dish.description,
                  ),
                ),
                Text(
                  money(dish.cents),
                  style: TextStyle(
                    color: context.colors.accent,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        Icon(Icons.chevron_right, color: context.colors.muted, size: 18),
      ],
    ),
  );
}

class _DishSearch extends SearchDelegate<Dish?> {
  @override
  List<Widget> buildActions(BuildContext context) => [
    IconButton(
      onPressed: () => query = '',
      tooltip: 'Clear',
      icon: const Icon(Icons.close),
    ),
  ];
  @override
  Widget buildLeading(BuildContext context) => IconButton(
    onPressed: () => close(context, null),
    tooltip: 'Back',
    icon: const Icon(Icons.chevron_left),
  );
  @override
  Widget buildResults(BuildContext context) => buildSuggestions(context);
  @override
  Widget buildSuggestions(BuildContext context) => ListView(
    children: [
      for (final item in menu.where(
        (dish) => dish.name.toLowerCase().contains(query.toLowerCase()),
      ))
        ListTile(
          title: Text(item.name),
          subtitle: Text(money(item.cents)),
          onTap: () => close(context, item),
        ),
    ],
  );
}

class _Store extends StatelessWidget {
  const _Store({required this.full});
  final bool full;

  @override
  Widget build(BuildContext context) => Surface(
    child: PageBody(
      children: [
        Header(context.shop.store.name),
        const SizedBox(height: 23),
        const MapArt('map-store'),
        EntryRow(
          Icons.location_on_outlined,
          '60 Eglinton Ave',
          subtitle: 'Mississauga, ON, L4Z 1Y2',
          onTap: () => context.open(Screen.addressPin),
        ),
        EntryRow(
          Icons.phone_outlined,
          '647-000-0000',
          onTap: () => context.note('Store number: 647-000-0000'),
        ),
        EntryRow(
          Icons.schedule,
          'Open now',
          subtitle: 'Accept orders until 11PM',
          onTap: () => full ? context.back() : context.open(Screen.storeFull),
          trailing: Icon(full ? Icons.expand_less : Icons.expand_more),
        ),
        if (full)
          for (final (i, day) in const [
            'Mon',
            'Tue',
            'Wed',
            'Thu',
            'Fri',
            'Sat',
            'Sun',
          ].indexed)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 19),
              child: Row(
                children: [
                  Expanded(child: Muted(day)),
                  Expanded(child: Muted(i > 4 ? '10AM – 11PM' : '10AM – 9PM')),
                ],
              ),
            ),
        EntryRow(
          Icons.star_border_rounded,
          '4.5 (50+ reviews)',
          onTap: () => full ? context.back() : context.open(Screen.storeFull),
          trailing: Icon(full ? Icons.expand_less : Icons.expand_more),
        ),
        if (full) ...[
          for (final (name, avatar) in const [
            ('Robert Fox', 'avatar-review'),
            ('Devon Lane', 'avatar-profile'),
            ('Jenny Wilson', 'avatar-guest'),
            ('Floyd Miles', 'avatar-courier'),
          ])
            _Review(name, avatar),
          const SizedBox(height: 15),
          Center(
            child: Pill(
              'More comments',
              onTap: () => context.note('All demo comments are visible.'),
            ),
          ),
        ],
      ],
    ),
  );
}

class _Review extends StatefulWidget {
  const _Review(this.name, this.avatar);
  final String name;
  final String avatar;

  @override
  State<_Review> createState() => _ReviewState();
}

class _ReviewState extends State<_Review> {
  bool _liked = false;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 15),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipOval(
          child: Art(widget.avatar, width: 36, height: 36, fit: BoxFit.cover),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: TitleText(widget.name, size: 13)),
                  for (var i = 0; i < 5; i++)
                    const Icon(Icons.star_rounded, color: gold, size: 14),
                ],
              ),
              const Muted(
                'The burger here was amazing. Juicy, flavorful, and cooked to perfection',
              ),
              Row(
                children: [
                  const Muted('1 week ago', size: 11),
                  TextButton(
                    onPressed: () => setState(() => _liked = !_liked),
                    child: Text(_liked ? 'Liked' : 'Like'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _DishForm extends StatefulWidget {
  const _DishForm(this.dish);
  final Dish dish;

  @override
  State<_DishForm> createState() => _DishFormState();
}

class _DishFormState extends State<_DishForm> {
  final _notes = TextEditingController();
  static const _doughOptions = ['Regular dough', 'Thin crust', 'Thick crust'];
  static const _sauceOptions = [
    'No sauce',
    'Butter chicken',
    'Creamy garlic sauce',
    'Texas BBQ',
  ];
  static const _toppings = [
    'Broccoli',
    'Olives',
    'Peppers',
    'Red onion',
    'Spinach',
  ];
  int _dough = 0;
  int _sauce = 0;
  int _quantity = 1;
  final _veggies = <String>{};

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dish = widget.dish;
    final isPizza = dish == pizza;
    final price = dish.cents + (_sauce == 0 ? 0 : 145) + _veggies.length * 199;
    return Surface(
      glow: Glow.none,
      bottom: Footer(
        Row(
          children: [
            Qty(
              _quantity,
              (change) =>
                  setState(() => _quantity = (_quantity + change).clamp(1, 99)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Primary('Add to cart   ${money(price * _quantity)}', () {
                final details = [
                  if (isPizza) ...[
                    _doughOptions[_dough],
                    _sauceOptions[_sauce],
                    ..._veggies,
                  ],
                  if (_notes.text.trim().isNotEmpty) _notes.text.trim(),
                ];
                context.shop.add(dish, details.join(', '), price, _quantity);
                context.back();
              }),
            ),
          ],
        ),
      ),
      child: PageBody(
        padding: EdgeInsets.zero,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(30),
            ),
            child: Container(
              color: lavender,
              height: 230,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Art(dish.asset, width: 220, height: 215),
                  Positioned(
                    left: 24,
                    top: 44,
                    child: IconTile(
                      Icons.chevron_left,
                      context.back,
                      label: 'Back',
                    ),
                  ),
                  Positioned(
                    right: 24,
                    top: 44,
                    child: IconTile(
                      Icons.ios_share,
                      () => context.note(dish.name),
                      label: 'Share dish',
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 17, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TitleText(dish.name, size: 24),
                const SizedBox(height: 6),
                const Row(
                  children: [
                    Icon(Icons.star_rounded, color: gold, size: 20),
                    SizedBox(width: 5),
                    Muted('50+ recommended'),
                  ],
                ),
                const SizedBox(height: 13),
                Muted(dish.description),
                if (isPizza) ...[
                  const SizedBox(height: 22),
                  const _OptionTitle('Dough', requiredChoice: true),
                  RadioGroup<int>(
                    groupValue: _dough,
                    onChanged: (v) => setState(() => _dough = v!),
                    child: Column(
                      children: [
                        for (final (i, label) in _doughOptions.indexed)
                          _OptionRadio(i, label),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const _OptionTitle('Base sauce', requiredChoice: true),
                  RadioGroup<int>(
                    groupValue: _sauce,
                    onChanged: (v) => setState(() => _sauce = v!),
                    child: Column(
                      children: [
                        for (final (i, label) in _sauceOptions.indexed)
                          _OptionRadio(
                            i,
                            label,
                            price: i == 0 ? '\$0' : '\$1.45',
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const _OptionTitle('Veggie'),
                  for (final item in _toppings)
                    CheckboxListTile(
                      title: Text(item),
                      subtitle: const Muted('\$1.99', size: 11),
                      contentPadding: EdgeInsets.zero,
                      activeColor: gold,
                      checkColor: Colors.black,
                      value: _veggies.contains(item),
                      onChanged: (value) => setState(() {
                        if (value == true) {
                          _veggies.add(item);
                        } else {
                          _veggies.remove(item);
                        }
                      }),
                    ),
                ],
                const SizedBox(height: 17),
                const TitleText('Special instructions', size: 17),
                const SizedBox(height: 8),
                TextField(
                  controller: _notes,
                  minLines: 2,
                  maxLines: 3,
                  maxLength: 160,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: context.colors.field,
                    hintText: 'Leave an instruction note',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
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
}

class _OptionTitle extends StatelessWidget {
  const _OptionTitle(this.title, {this.requiredChoice = false});
  final String title;
  final bool requiredChoice;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(child: TitleText(title)),
      Pill(
        requiredChoice ? 'Required' : 'Optional',
        color: requiredChoice ? blush : context.colors.field,
        ink: requiredChoice ? Colors.black : null,
      ),
    ],
  );
}

class _OptionRadio extends StatelessWidget {
  const _OptionRadio(this.value, this.label, {this.price});
  final int value;
  final String label;
  final String? price;

  @override
  Widget build(BuildContext context) => RadioListTile<int>(
    value: value,
    activeColor: gold,
    title: Text(label),
    subtitle: price == null ? null : Muted(price!, size: 11),
    controlAffinity: ListTileControlAffinity.trailing,
    contentPadding: EdgeInsets.zero,
  );
}
