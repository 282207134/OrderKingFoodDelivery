import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/catalog.dart';
import '../core/screen.dart';
import '../core/ui.dart';

class AuthPage extends StatelessWidget {
  const AuthPage(this.screen, {super.key, this.data, required this.preview});

  final Screen screen;
  final Object? data;
  final bool preview;

  @override
  Widget build(BuildContext context) => switch (screen) {
    Screen.loading => _Loading(preview),
    Screen.onboarding1 => const _Onboarding(0),
    Screen.onboarding2 => const _Onboarding(1),
    Screen.onboarding3 => const _Onboarding(2),
    Screen.signIn ||
    Screen.signInFilled ||
    Screen.signInError => _SignIn(screen),
    _ => _SignUp(screen, data: data as String?),
  };
}

class _Loading extends StatefulWidget {
  const _Loading(this.preview);
  final bool preview;

  @override
  State<_Loading> createState() => _LoadingState();
}

class _LoadingState extends State<_Loading> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (!widget.preview) {
      _timer = Timer(
        const Duration(milliseconds: 850),
        () => context.swap(Screen.onboarding1),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const Surface(
    glow: Glow.blue,
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Art('logo', width: 111, height: 156),
          SizedBox(height: 25),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 15,
                height: 15,
                child: CircularProgressIndicator(strokeWidth: 1.6, value: .73),
              ),
              SizedBox(width: 5),
              Muted('Welcome to OrderKing', size: 12),
            ],
          ),
          SizedBox(height: 120),
        ],
      ),
    ),
  );
}

class _Onboarding extends StatelessWidget {
  const _Onboarding(this.page);
  final int page;

  @override
  Widget build(BuildContext context) {
    const titles = [
      'Fast, reliable,\nand delicious',
      'Delivery to\nyour doorstep',
      'Satisfy your\ncravings with us',
    ];
    const images = ['hero-bowl', 'hero-delivery', 'hero-cravings'];
    const next = [Screen.onboarding2, Screen.onboarding3, Screen.signIn];
    final height = MediaQuery.sizeOf(context).height;
    final heroHeight = (height * .46).clamp(210.0, 390.0);
    return Surface(
      glow: page == 2 ? Glow.account : Glow.blue,
      bottom: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 44),
        child: Row(
          children: [
            Expanded(
              child: Primary(
                'Skip',
                () => context.reset(Screen.signIn),
                secondary: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Primary(page == 2 ? 'Get started' : 'Next', () {
                if (page == 2) {
                  context.reset(Screen.signIn);
                } else {
                  context.open(next[page]);
                }
              }),
            ),
          ],
        ),
      ),
      child: PageBody(
        padding: EdgeInsets.fromLTRB(24, height < 710 ? 18 : 30, 24, 16),
        children: [
          SizedBox(
            height: heroHeight,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: Opacity(
                    opacity: context.colors.dark ? .3 : .76,
                    child: Art('pattern-${page + 1}', fit: BoxFit.contain),
                  ),
                ),
                Align(
                  alignment: const Alignment(0, .32),
                  child: Art(
                    images[page],
                    width: 276,
                    height: math.min(256, heroHeight * .74),
                  ),
                ),
                for (final (alignment, size, color) in const [
                  (Alignment(-.88, .72), 16.0, Color(0xfff7a8dc)),
                  (Alignment(.96, -.12), 20.0, Color(0xffabdffd)),
                  (Alignment(-.12, -.82), 10.0, Color(0xff9c80ed)),
                ])
                  Align(
                    alignment: alignment,
                    child: Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          TitleText(titles[page], size: 36, align: TextAlign.center),
          const SizedBox(height: 8),
          const Muted(
            'Elevate your dining experience with our restaurant delivery service',
            size: 14,
            align: TextAlign.center,
          ),
          SizedBox(height: height < 710 ? 19 : 35),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < images.length; i++)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: i == page ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == page ? gold : context.colors.rule,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SignIn extends StatefulWidget {
  const _SignIn(this.screen);
  final Screen screen;

  @override
  State<_SignIn> createState() => _SignInState();
}

class _SignInState extends State<_SignIn> {
  late final _phone = TextEditingController(
    text: switch (widget.screen) {
      Screen.signInFilled => '9052360000',
      Screen.signInError => '12345',
      _ => '',
    },
  );
  late final _password = TextEditingController(
    text: switch (widget.screen) {
      Screen.signInFilled => 'ABC2303!',
      Screen.signInError => 'incorrect',
      _ => '',
    },
  );
  late bool _show = widget.screen == Screen.signInFilled;
  late bool _submitted = widget.screen == Screen.signInError;

  bool get _validPhone =>
      _phone.text.replaceAll(RegExp(r'\D'), '').length == 10;
  bool get _validPassword =>
      _password.text.length >= 6 && _password.text != 'incorrect';

  void _signIn() {
    FocusScope.of(context).unfocus();
    setState(() => _submitted = true);
    if (_validPhone && _validPassword) context.reset(Screen.home);
  }

  @override
  void dispose() {
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Surface(
    glow: Glow.blue,
    child: LayoutBuilder(
      builder: (context, box) => PageBody(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: (box.maxHeight * .30).clamp(140, 246),
            child: const Center(child: Art('logo', width: 111, height: 156)),
          ),
          Panel(
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 32),
            radius: 28,
            color: context.colors.card.withValues(alpha: .74),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const TitleText('Sign in', size: 28, align: TextAlign.center),
                const SizedBox(height: 22),
                TextField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Phone number',
                    hintText: 'Enter your phone number',
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    errorText: _submitted && !_validPhone
                        ? 'Invalid phone number'
                        : null,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 14),
                PasswordField(
                  _password,
                  _show,
                  () => setState(() => _show = !_show),
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (_) => _signIn(),
                  error: _submitted && !_validPassword
                      ? 'Wrong password!'
                      : null,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.open(Screen.signUp, data: ''),
                    child: const Text('Forgot password?'),
                  ),
                ),
                SizedBox(height: (box.maxHeight * .06).clamp(14, 48)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (final label in const ['Facebook', 'Google', 'Apple'])
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Semantics(
                          label: 'Continue with $label',
                          child: InkResponse(
                            onTap: () => context.note(
                              '$label sign-in is unavailable in this demo.',
                            ),
                            child: CircleAvatar(
                              radius: 26,
                              backgroundColor: Colors.white,
                              child: Art(
                                'social-${label.toLowerCase()}',
                                width: 24,
                                height: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: (box.maxHeight * .035).clamp(10, 28)),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Muted('Do not have an account?'),
                    TextButton(
                      onPressed: () => context.open(Screen.signUp, data: ''),
                      child: const Text('Sign up'),
                    ),
                  ],
                ),
                Primary(
                  'Sign in',
                  _phone.text.isEmpty || _password.text.isEmpty
                      ? null
                      : _signIn,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class PasswordField extends StatelessWidget {
  const PasswordField(
    this.controller,
    this.visible,
    this.toggle, {
    super.key,
    this.error,
    this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final bool visible;
  final VoidCallback toggle;
  final String? error;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    obscureText: !visible,
    onChanged: onChanged,
    onSubmitted: onSubmitted,
    decoration: InputDecoration(
      labelText: 'Password',
      hintText: 'Enter your password',
      floatingLabelBehavior: FloatingLabelBehavior.always,
      errorText: error,
      suffixIcon: IconButton(
        onPressed: toggle,
        tooltip: visible ? 'Hide password' : 'Show password',
        icon: Icon(
          visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          size: 19,
        ),
      ),
    ),
  );
}

class DigitPad extends StatelessWidget {
  const DigitPad(this.press, {super.key});
  final ValueChanged<String> press;

  @override
  Widget build(BuildContext context) => Panel(
    padding: const EdgeInsets.all(12),
    child: Column(
      children: [
        for (final line in const [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
          ['', '0', 'delete'],
        ])
          Row(
            children: [
              for (final digit in line)
                Expanded(
                  child: SizedBox(
                    height: 66,
                    child: digit.isEmpty
                        ? const SizedBox.shrink()
                        : TextButton(
                            onPressed: () => press(digit),
                            style: TextButton.styleFrom(
                              foregroundColor: context.colors.ink,
                            ),
                            child: digit == 'delete'
                                ? const Icon(
                                    Icons.backspace_outlined,
                                    size: 21,
                                    semanticLabel: 'Delete digit',
                                  )
                                : Text(
                                    digit,
                                    style: const TextStyle(fontSize: 24),
                                  ),
                          ),
                  ),
                ),
            ],
          ),
      ],
    ),
  );
}

class _SignUp extends StatefulWidget {
  const _SignUp(this.screen, {this.data});
  final Screen screen;
  final String? data;

  @override
  State<_SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<_SignUp> {
  late String _digits = switch (widget.screen) {
    Screen.signUp when widget.data == null => '9052360',
    Screen.signUpCode when widget.data == null => '24',
    _ => '',
  };
  late final _password = TextEditingController(
    text: widget.data == null ? 'ABC2303!' : '',
  );
  late final _confirm = TextEditingController(
    text: widget.data == null ? 'ABC2303!' : '',
  );
  bool _showFirst = false;
  bool _showSecond = true;
  String? _error;

  bool get _code => widget.screen == Screen.signUpCode;
  bool get _passwordStep => widget.screen == Screen.signUpPassword;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _next() {
    if (_passwordStep) {
      if (_password.text.length < 6 || _password.text != _confirm.text) {
        setState(
          () => _error = 'Use at least 6 characters and matching passwords.',
        );
      } else {
        final session = context.shop;
        if (widget.data != null) {
          final p = session.profile;
          session.profile = (
            first: p.first,
            last: p.last,
            phone: widget.data!,
            email: p.email,
          );
        }
        context.reset(Screen.home);
      }
    } else if (_code) {
      if (_digits == '2242') {
        context.open(Screen.signUpPassword, data: widget.data ?? '9052360000');
      } else {
        setState(() => _error = 'Invalid code. The demo code is 2242.');
      }
    } else if (_digits.length == 10) {
      context.open(Screen.signUpCode, data: _digits);
    } else {
      setState(() => _error = 'Enter a 10-digit phone number.');
    }
  }

  void _press(String key) {
    setState(() {
      _error = null;
      if (key == 'delete') {
        if (_digits.isNotEmpty) {
          _digits = _digits.substring(0, _digits.length - 1);
        }
      } else if (_digits.length < (_code ? 4 : 10)) {
        _digits += key;
      }
    });
  }

  @override
  Widget build(BuildContext context) => Surface(
    glow: Glow.blue,
    bottom: Padding(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 44),
      child: Primary(_passwordStep ? 'Create account' : 'Continue', _next),
    ),
    child: LayoutBuilder(
      builder: (context, box) => PageBody(
        children: [
          const Header('Sign up'),
          const SizedBox(height: 37),
          if (_passwordStep) ...[
            const Muted('Set up your password'),
            const SizedBox(height: 20),
            PasswordField(
              _password,
              _showFirst,
              () => setState(() => _showFirst = !_showFirst),
            ),
            const SizedBox(height: 16),
            PasswordField(
              _confirm,
              _showSecond,
              () => setState(() => _showSecond = !_showSecond),
            ),
          ] else ...[
            Muted(
              _code
                  ? 'We have sent you a verification code via SMS. Please enter the code'
                  : 'Enter your phone number',
            ),
            const SizedBox(height: 11),
            if (_code)
              Row(
                children: [
                  for (var i = 0; i < 4; i++)
                    Expanded(
                      child: Container(
                        height: 58,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: i < _digits.length
                                  ? gold
                                  : context.colors.rule,
                            ),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: TitleText(
                          i < _digits.length ? _digits[i] : '',
                          size: 23,
                        ),
                      ),
                    ),
                ],
              )
            else ...[
              TitleText(_digits.isEmpty ? '—' : _digits, size: 18),
              Divider(color: context.colors.rule),
            ],
            SizedBox(height: (box.maxHeight * .10).clamp(22, 75)),
            DigitPad(_press),
          ],
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.deepOrange),
              ),
            ),
        ],
      ),
    ),
  );
}
