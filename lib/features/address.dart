import 'package:flutter/material.dart';

import '../core/catalog.dart';
import '../core/screen.dart';
import '../core/session.dart';
import '../core/ui.dart';

const _matches = <Address>[
  (street: '3581 Royal Ln', city: 'Mesa, New Jersey 45463', note: ''),
  (street: '35 Absolute Ave', city: 'Mississauga, ON, L4Z 1Y2', note: ''),
  (street: '35 Eglinton Ave', city: 'Mississauga, ON, L4Z 1Y2', note: ''),
];

class AddressPage extends StatelessWidget {
  const AddressPage(this.screen, {super.key, this.address});
  final Screen screen;
  final Address? address;

  @override
  Widget build(BuildContext context) => switch (screen) {
    Screen.addressDetails => _AddressDetails(address ?? _matches.last),
    Screen.addressPin => const _MapPin(),
    _ => _Addresses(typing: screen == Screen.addressTyping),
  };
}

class _Addresses extends StatefulWidget {
  const _Addresses({required this.typing});
  final bool typing;

  @override
  State<_Addresses> createState() => _AddressesState();
}

class _AddressesState extends State<_Addresses> {
  late final _search = TextEditingController(text: widget.typing ? '35' : '');

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _edit(Address address) {
    FocusScope.of(context).unfocus();
    context.open(Screen.addressDetails, data: address);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.shop;
    final query = _search.text.trim();
    final matches = _matches
        .where(
          (address) =>
              address.street.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
    final custom = (street: query, city: s.address.city, note: '');
    return Surface(
      child: PageBody(
        children: [
          const Header('Addresses'),
          const SizedBox(height: 24),
          SearchBarBox(
            controller: _search,
            hint: 'Enter delivery address',
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) {
              if (query.isNotEmpty) _edit(matches.firstOrNull ?? custom);
            },
            trailing: query.isEmpty
                ? null
                : IconButton(
                    onPressed: () => setState(_search.clear),
                    tooltip: 'Clear',
                    icon: const Icon(Icons.cancel, size: 19),
                  ),
          ),
          const SizedBox(height: 15),
          if (query.isEmpty) ...[
            const TitleText('Near by', size: 15),
            EntryRow(
              Icons.person_pin_circle_outlined,
              s.address.street,
              subtitle: s.address.city,
              divider: false,
              onTap: () => _edit(s.address),
            ),
            const SizedBox(height: 21),
            const TitleText('Saved addresses', size: 15),
            for (final address in s.addresses)
              EntryRow(
                Icons.location_on_outlined,
                address.street,
                subtitle: address.city,
                iconColor: address.street == s.address.street
                    ? context.colors.accent
                    : null,
                trailing: IconButton(
                  onPressed: () => _edit(address),
                  tooltip: 'Edit ${address.street}',
                  icon: const Icon(Icons.edit_outlined, size: 21),
                ),
                onTap: () {
                  s.address = address;
                  s.refresh();
                  context.back();
                },
              ),
          ] else ...[
            for (final item in matches)
              EntryRow(
                Icons.location_on_outlined,
                item.street,
                subtitle: item.city,
                onTap: () => _edit(item),
              ),
            if (matches.isEmpty)
              EntryRow(
                Icons.add_location_alt_outlined,
                'Use “$query”',
                subtitle: 'Add an address manually',
                onTap: () => _edit(custom),
              ),
          ],
        ],
      ),
    );
  }
}

class _AddressDetails extends StatefulWidget {
  const _AddressDetails(this.address);
  final Address address;

  @override
  State<_AddressDetails> createState() => _AddressDetailsState();
}

class _AddressDetailsState extends State<_AddressDetails> {
  final _unit = TextEditingController();
  final _building = TextEditingController();
  late final _note = TextEditingController(
    text: widget.address.note.replaceFirst(
      RegExp(r'^(Leave at door|Meet outside)( · |$)'),
      '',
    ),
  );
  late bool _outside = widget.address.note.startsWith('Meet outside');
  Offset? _pendingPin;

  @override
  void dispose() {
    _unit.dispose();
    _building.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.shop;
    final address = widget.address;
    return Surface(
      bottom: Footer(
        Primary('Save address', () {
          final addressLabel = [
            address.street,
            _unit.text.trim(),
            _building.text.trim(),
          ].where((item) => item.isNotEmpty).join(', ');
          final note = _note.text.trim();
          final instruction = _outside ? 'Meet outside' : 'Leave at door';
          final saved = (
            street: addressLabel,
            city: address.city,
            note: note.isEmpty || note == instruction
                ? instruction
                : '$instruction · $note',
          );
          s.addresses.removeWhere(
            (item) =>
                item.street == addressLabel || item.street == address.street,
          );
          s.addresses.insert(0, saved);
          s.address = saved;
          if (_pendingPin != null) s.mapPin = _pendingPin!;
          s.refresh();
          context.back();
        }),
      ),
      child: PageBody(
        children: [
          const Header('Address details'),
          const SizedBox(height: 24),
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              const MapArt('map-address'),
              Positioned(
                bottom: 13,
                child: Pill(
                  'Adjust pin',
                  icon: Icons.location_on_outlined,
                  onTap: () async {
                    final pin = await context.open<Offset>(
                      Screen.addressPin,
                      data: _pendingPin ?? s.mapPin,
                    );
                    if (mounted && pin != null) {
                      setState(() => _pendingPin = pin);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TitleText(address.street, size: 16),
          Muted(address.city),
          const SizedBox(height: 20),
          const TitleText('Address info'),
          const SizedBox(height: 12),
          TextField(
            controller: _unit,
            decoration: const InputDecoration(
              labelText: 'Apartment/Suite',
              hintText: 'e.g. Unit 12',
              floatingLabelBehavior: FloatingLabelBehavior.always,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _building,
            decoration: const InputDecoration(
              labelText: 'Building name',
              hintText: 'e.g. Apartment/company’s name',
              floatingLabelBehavior: FloatingLabelBehavior.always,
            ),
          ),
          const SizedBox(height: 24),
          const Muted('Delivery options'),
          const SizedBox(height: 9),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              Pill(
                'Leave at door',
                icon: Icons.door_front_door_outlined,
                color: !_outside ? gold : null,
                ink: !_outside ? Colors.black : null,
                onTap: () => setState(() => _outside = false),
              ),
              Pill(
                'Meet outside',
                icon: Icons.person_outline,
                color: _outside ? gold : null,
                ink: _outside ? Colors.black : null,
                onTap: () => setState(() => _outside = true),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _note,
            minLines: 2,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Leave an instruction note',
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
    );
  }
}

class _MapPin extends StatefulWidget {
  const _MapPin();
  @override
  State<_MapPin> createState() => _MapPinState();
}

class _MapPinState extends State<_MapPin> {
  Offset? _position;

  @override
  Widget build(BuildContext context) {
    final session = context.shop;
    final initial = ModalRoute.of(context)?.settings.arguments as Offset?;
    final point = _position ?? initial ?? session.mapPin;
    return Surface(
      bottom: Footer(
        Primary('Save', () {
          if (initial == null) {
            session.mapPin = point;
            session.refresh();
          }
          context.back(point);
        }),
      ),
      child: PageBody(
        children: [
          const Header('Adjust pin', close: true),
          const SizedBox(height: 22),
          LayoutBuilder(
            builder: (context, box) {
              final height = (MediaQuery.sizeOf(context).height - 232).clamp(
                210.0,
                630.0,
              );
              void move(Offset location) => setState(
                () => _position = Offset(
                  (location.dx / box.maxWidth).clamp(.04, .96),
                  (location.dy / height).clamp(.04, .96),
                ),
              );
              return GestureDetector(
                onTapDown: (event) => move(event.localPosition),
                onPanUpdate: (event) => move(event.localPosition),
                child: SizedBox(
                  height: height,
                  child: Stack(
                    children: [
                      Positioned.fill(child: MapArt('map-pin', height: height)),
                      Positioned(
                        top: point.dy * height - 20,
                        left: point.dx * box.maxWidth - 16,
                        child: const CircleAvatar(
                          radius: 17,
                          backgroundColor: Color(0xff232328),
                          child: Icon(
                            Icons.home,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 13,
                        bottom: 13,
                        child: IconTile(
                          Icons.my_location,
                          () => setState(
                            () => _position = const Offset(.52, .52),
                          ),
                          label: 'Center map',
                          round: true,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
