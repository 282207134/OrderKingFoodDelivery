import 'package:flutter/material.dart';

import 'catalog.dart';
import 'screen.dart';
import 'session.dart';

class Palette {
  const Palette(this.dark);

  final bool dark;
  Color get base => dark ? const Color(0xff050505) : const Color(0xfff1f4f4);
  Color get card => dark ? const Color(0xff1e1e23) : const Color(0xfff8f8f8);
  Color get field => dark ? const Color(0xff2e2e2e) : const Color(0xffe8e9e9);
  Color get ink => dark ? const Color(0xfff7f7f7) : const Color(0xff010101);
  Color get muted => dark ? const Color(0xffaab0b0) : const Color(0xff5b6061);
  Color get rule => dark ? const Color(0xff333338) : const Color(0xffdbdfdf);
  Color get accent => dark ? gold : amberText;
}

extension PageContext on BuildContext {
  Session get shop => SessionScope.of(this);
  Palette get colors => Palette(Theme.of(this).brightness == Brightness.dark);

  Future<T?> open<T>(Screen screen, {Object? data}) async =>
      await Navigator.of(this).pushNamed<Object?>(screen.name, arguments: data)
          as T?;

  void swap(Screen screen, {Object? data}) =>
      Navigator.of(this)
          .pushReplacementNamed<Object?, Object?>(screen.name, arguments: data);

  void reset(Screen screen) =>
      Navigator.of(this)
          .pushNamedAndRemoveUntil<Object?>(screen.name, (route) => false);

  void back([Object? result]) {
    if (Navigator.of(this).canPop()) {
      Navigator.of(this).pop(result);
    } else {
      reset(Screen.home);
    }
  }

  void note(String message) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class Art extends StatelessWidget {
  const Art(
    this.name, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });

  final String name;
  final double? width;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/images/$name.webp',
    width: width,
    height: height,
    fit: fit,
    excludeFromSemantics: true,
  );
}

enum Glow { pink, blue, account, warm, none }

class Surface extends StatelessWidget {
  const Surface({
    super.key,
    required this.child,
    this.glow = Glow.pink,
    this.bottom,
    this.resize = true,
  });

  final Widget child;
  final Glow glow;
  final Widget? bottom;
  final bool resize;

  @override
  Widget build(BuildContext context) {
    final p = context.colors;
    final (center, tint) = switch (glow) {
      Glow.pink => (
        const Alignment(-.65, -1.05),
        p.dark ? const Color(0xff755869) : const Color(0xfff8dfef),
      ),
      Glow.blue => (
        const Alignment(-.65, -1),
        p.dark ? const Color(0xff2f3a54) : const Color(0xffdfeef6),
      ),
      Glow.account => (
        const Alignment(.9, -1),
        p.dark ? const Color(0xff846877) : const Color(0xfff9ddef),
      ),
      Glow.warm => (
        const Alignment(-.7, -1),
        p.dark ? const Color(0xff473918) : const Color(0xffffedc9),
      ),
      Glow.none => (Alignment.topCenter, p.base),
    };
    return Scaffold(
      resizeToAvoidBottomInset: resize,
      backgroundColor: p.base,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: center,
            radius: .78,
            colors: [tint, p.base],
            stops: const [0, 1],
          ),
        ),
        child: SizedBox.expand(child: SafeArea(bottom: false, child: child)),
      ),
      bottomNavigationBar: bottom == null
          ? null
          : SafeArea(top: false, child: bottom!),
    );
  }
}

class PageBody extends StatelessWidget {
  const PageBody({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.fromLTRB(24, 44, 24, 24),
    this.controller,
  });

  final List<Widget> children;
  final EdgeInsets padding;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) => ListView(
    controller: controller,
    padding: padding,
    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
    children: children,
  );
}

class TitleText extends StatelessWidget {
  const TitleText(this.value, {super.key, this.size = 20, this.align});

  final String value;
  final double size;
  final TextAlign? align;

  @override
  Widget build(BuildContext context) => Text(
    value,
    textAlign: align,
    style: TextStyle(fontSize: size, fontWeight: FontWeight.w600, height: 1.4),
  );
}

class Muted extends StatelessWidget {
  const Muted(this.value, {super.key, this.size = 13, this.align});

  final String value;
  final double size;
  final TextAlign? align;

  @override
  Widget build(BuildContext context) => Text(
    value,
    textAlign: align,
    style: TextStyle(color: context.colors.muted, fontSize: size, height: 1.5),
  );
}

class IconTile extends StatelessWidget {
  const IconTile(
    this.icon,
    this.onTap, {
    super.key,
    required this.label,
    this.size = 44,
    this.color,
    this.round = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String label;
  final double size;
  final Color? color;
  final bool round;

  @override
  Widget build(BuildContext context) => Material(
    color: context.colors.card,
    borderRadius: BorderRadius.circular(round ? size / 2 : 16),
    child: IconButton(
      constraints: BoxConstraints.tightFor(width: size, height: size),
      iconSize: 21,
      padding: EdgeInsets.zero,
      tooltip: label,
      onPressed: onTap,
      icon: Icon(icon, color: color),
    ),
  );
}

class Header extends StatelessWidget {
  const Header(
    this.title, {
    super.key,
    this.close = false,
    this.trailing,
    this.onBack,
  });

  final String title;
  final bool close;
  final Widget? trailing;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 44,
    child: Row(
      children: [
        SizedBox(
          width: 60,
          child: Align(
            alignment: Alignment.centerLeft,
            child: IconTile(
              close ? Icons.close : Icons.chevron_left_rounded,
              onBack ?? () => context.back(),
              label: close ? 'Close' : 'Back',
            ),
          ),
        ),
        Expanded(child: TitleText(title, size: 24, align: TextAlign.center)),
        SizedBox(
          width: 60,
          child: Align(alignment: Alignment.centerRight, child: trailing),
        ),
      ],
    ),
  );
}

class Primary extends StatelessWidget {
  const Primary(
    this.label,
    this.action, {
    super.key,
    this.secondary = false,
    this.danger = false,
  });

  final String label;
  final VoidCallback? action;
  final bool secondary;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final p = context.colors;
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: secondary
              ? Colors.transparent
              : danger
              ? const Color(0xffff6746)
              : gold,
          foregroundColor: secondary
              ? p.ink
              : danger
              ? Colors.white
              : const Color(0xff121212),
          disabledBackgroundColor: gold.withValues(alpha: .48),
          disabledForegroundColor: const Color(0xff37301f),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: secondary ? BorderSide(color: p.rule) : BorderSide.none,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        onPressed: action,
        child: Text(label, textAlign: TextAlign.center),
      ),
    );
  }
}

class Pill extends StatelessWidget {
  const Pill(
    this.label, {
    super.key,
    this.color,
    this.ink,
    this.onTap,
    this.icon,
  });

  final String label;
  final Color? color;
  final Color? ink;
  final VoidCallback? onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Material(
    color: color ?? context.colors.card,
    borderRadius: BorderRadius.circular(22),
    child: InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: ink),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: ink,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.action, this.onTap});

  final String title;
  final String? action;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(child: TitleText(title)),
      if (action != null) TextButton(onPressed: onTap, child: Text(action!)),
    ],
  );
}

class Panel extends StatelessWidget {
  const Panel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.color,
    this.radius = 24,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final double radius;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: color ?? context.colors.card,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(
            alpha: context.colors.dark ? .18 : .045,
          ),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Material(
      type: MaterialType.transparency,
      borderRadius: BorderRadius.circular(radius),
      child: Padding(padding: padding, child: child),
    ),
  );
}

class Footer extends StatelessWidget {
  const Footer(this.child, {super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) => Panel(
    radius: 24,
    padding: const EdgeInsets.fromLTRB(24, 20, 24, 25),
    child: child,
  );
}

class EntryRow extends StatelessWidget {
  const EntryRow(
    this.icon,
    this.title, {
    super.key,
    this.subtitle,
    this.onTap,
    this.trailing,
    this.iconColor,
    this.circle = true,
    this.divider = true,
    this.verticalPadding = 12,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color? iconColor;
  final bool circle;
  final bool divider;
  final double verticalPadding;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: verticalPadding),
          child: Row(
            children: [
              Container(
                width: circle ? 44 : 30,
                height: 44,
                decoration: BoxDecoration(
                  color: circle ? context.colors.field : null,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 23, color: iconColor),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TitleText(title, size: 15),
                    if (subtitle != null) Muted(subtitle!),
                  ],
                ),
              ),
              if (trailing != null)
                trailing!
              else if (onTap != null)
                Icon(
                  Icons.chevron_right,
                  color: context.colors.muted,
                  size: 21,
                ),
            ],
          ),
        ),
      ),
      if (divider) Divider(color: context.colors.rule, height: 1),
    ],
  );
}

class ModeSwitch extends StatelessWidget {
  const ModeSwitch(this.pickup, this.onChanged, {super.key});
  final bool pickup;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: context.colors.field,
      borderRadius: BorderRadius.circular(34),
    ),
    child: Row(
      children: [
        for (final (value, title, details) in const [
          (false, 'Delivery', '20–30 min  •  \$3'),
          (true, 'Pick-up', '10–15 min  •  5km'),
        ])
          Expanded(
            child: Material(
              color: pickup == value ? context.colors.card : Colors.transparent,
              borderRadius: BorderRadius.circular(29),
              child: InkWell(
                borderRadius: BorderRadius.circular(29),
                onTap: () => onChanged(value),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Column(
                    children: [
                      TitleText(title, size: 15),
                      Muted(details, size: 11),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

class SearchBarBox extends StatelessWidget {
  const SearchBarBox({
    super.key,
    this.controller,
    this.hint = 'Search food, restaurant,...',
    this.onTap,
    this.onSubmitted,
    this.onChanged,
    this.leading,
    this.trailing,
    this.error = false,
  });

  final TextEditingController? controller;
  final String hint;
  final VoidCallback? onTap;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final Widget? leading;
  final Widget? trailing;
  final bool error;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: context.colors.dark ? context.colors.field : context.colors.card,
      borderRadius: BorderRadius.circular(13),
      border: error ? Border.all(color: Colors.deepOrange) : null,
    ),
    child: TextField(
      controller: controller,
      readOnly: onTap != null,
      onTap: onTap,
      onSubmitted: onSubmitted,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        hintText: hint,
        hintStyle: TextStyle(color: context.colors.muted, fontSize: 13),
        prefixIcon: leading ?? Icon(Icons.search, color: context.colors.muted),
        suffixIcon: trailing,
        isDense: true,
      ),
    ),
  );
}

class ShopBar extends StatelessWidget {
  const ShopBar(this.tab, {super.key});
  final int tab;

  @override
  Widget build(BuildContext context) {
    final session = context.shop;
    return SizedBox(
      height: 94,
      child: CustomPaint(
        painter: _TabShape(context.colors.card),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(17, 3, 17, 14),
          child: Row(
            children: [
              for (final (index, icon, label, screen) in const [
                (0, Icons.storefront_outlined, 'Home', Screen.home),
                (1, Icons.person_pin_circle_outlined, 'Pickup', Screen.pickup),
                (2, Icons.shopping_bag_outlined, 'Cart', Screen.cart),
                (3, Icons.sticky_note_2_outlined, 'Orders', Screen.orders),
                (4, Icons.account_circle_outlined, 'Account', Screen.account),
              ])
                Expanded(
                  child: Semantics(
                    button: true,
                    selected: tab == index,
                    label: label,
                    child: Tooltip(
                      message: label,
                      child: InkResponse(
                        onTap: () {
                          if (tab == index &&
                              (screen == Screen.home ||
                                  screen == Screen.pickup)) {
                            context.reset(screen);
                          } else {
                            context.reset(switch (screen) {
                              Screen.cart when session.cart.isEmpty =>
                                Screen.cartEmpty,
                              Screen.orders when session.orders.isEmpty =>
                                Screen.ordersEmpty,
                              _ => screen,
                            });
                          }
                        },
                        child: index == 2
                            ? Center(
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: gold,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.shopping_bag_outlined,
                                        color: Colors.black,
                                        size: 24,
                                      ),
                                    ),
                                    if (session.count > 0)
                                      Positioned(
                                        right: -1,
                                        top: -3,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: Color(0xffff6746),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Text(
                                            '${session.count}',
                                            style: const TextStyle(
                                              fontSize: 9,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 13),
                                  Icon(
                                    icon,
                                    color: tab == index
                                        ? gold
                                        : context.colors.ink,
                                    size: 23,
                                  ),
                                  const SizedBox(height: 7),
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: tab == index
                                          ? gold
                                          : Colors.transparent,
                                      shape: BoxShape.circle,
                                    ),
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
      ),
    );
  }
}

class _TabShape extends CustomPainter {
  const _TabShape(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final middle = size.width / 2;
    final path = Path()
      ..moveTo(0, 37)
      ..quadraticBezierTo(0, 8, 26, 8)
      ..lineTo(middle - 53, 8)
      ..cubicTo(middle - 29, 8, middle - 28, -10, middle, -10)
      ..cubicTo(middle + 28, -10, middle + 29, 8, middle + 53, 8)
      ..lineTo(size.width - 26, 8)
      ..quadraticBezierTo(size.width, 8, size.width, 37)
      ..lineTo(size.width, size.height - 24)
      ..quadraticBezierTo(size.width, size.height, size.width - 24, size.height)
      ..lineTo(24, size.height)
      ..quadraticBezierTo(0, size.height, 0, size.height - 24)
      ..close();
    canvas.drawShadow(path, const Color(0x16000000), 10, false);
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_TabShape oldDelegate) => color != oldDelegate.color;
}

class Qty extends StatelessWidget {
  const Qty(this.value, this.onChange, {super.key, this.vertical = false});
  final int value;
  final ValueChanged<int> onChange;
  final bool vertical;

  @override
  Widget build(BuildContext context) {
    final minus = IconButton(
      onPressed: () => onChange(-1),
      tooltip: 'Decrease quantity',
      visualDensity: VisualDensity.compact,
      icon: const Icon(Icons.remove, size: 16),
    );
    final plus = IconButton(
      onPressed: () => onChange(1),
      tooltip: 'Increase quantity',
      visualDensity: VisualDensity.compact,
      icon: const Icon(Icons.add, size: 16),
    );
    final label = Text(
      '$value',
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
    );
    return Material(
      color: context.colors.field,
      borderRadius: BorderRadius.circular(15),
      child: vertical
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [plus, label, minus],
            )
          : Row(mainAxisSize: MainAxisSize.min, children: [minus, label, plus]),
    );
  }
}

class DishArt extends StatelessWidget {
  const DishArt(this.dish, {super.key, this.size = 100});
  final Dish dish;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: dish.color,
      borderRadius: BorderRadius.circular(size * .24),
    ),
    padding: EdgeInsets.all(size * .12),
    child: Art(dish.asset),
  );
}

class MapArt extends StatelessWidget {
  const MapArt(
    this.name, {
    super.key,
    this.height = 172,
    this.radius = 24,
    this.onTap,
  });
  final String name;
  final double height;
  final double radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Art(
              '$name${context.colors.dark ? '-dark' : ''}',
              fit: BoxFit.cover,
            ),
            if (name == 'map-address' ||
                (name == 'map-store' && context.colors.dark))
              const Align(
                alignment: Alignment(0, -.22),
                child: CircleAvatar(
                  radius: 17,
                  backgroundColor: Color(0xff232328),
                  child: Icon(
                    Icons.home_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

class EmptyState extends StatelessWidget {
  const EmptyState(
    this.asset,
    this.title, {
    super.key,
    this.subtitle,
    this.receipt = false,
  });

  final String asset;
  final String title;
  final String? subtitle;
  final bool receipt;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 222,
          height: 195,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(top: 9, left: 10, child: _Confetti(13, lavender)),
              Positioned(bottom: 3, right: 5, child: _Confetti(14, honey)),
              Art(asset, width: 175, height: 175),
              if (receipt)
                const Positioned(
                  bottom: 7,
                  right: 11,
                  child: Art('monocle', width: 91),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        TitleText(title, size: 28, align: TextAlign.center),
        if (subtitle != null) ...[
          const SizedBox(height: 10),
          SizedBox(
            width: 240,
            child: Muted(subtitle!, size: 15, align: TextAlign.center),
          ),
        ],
        const SizedBox(height: 18),
        Pill('Start shopping', onTap: () => context.reset(Screen.home)),
      ],
    ),
  );
}

class _Confetti extends StatelessWidget {
  const _Confetti(this.size, this.color);
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

Future<String?> editText(
  BuildContext context,
  String title,
  String initial, {
  TextInputType keyboard = TextInputType.text,
}) async {
  var value = initial;
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextFormField(
        autofocus: true,
        initialValue: initial,
        keyboardType: keyboard,
        onChanged: (text) => value = text,
        onFieldSubmitted: (text) => Navigator.pop(context, text.trim()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, value.trim()),
          child: const Text('Save'),
        ),
      ],
    ),
  );
}
