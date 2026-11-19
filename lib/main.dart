import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const StrengthArenaApp());
}

class StrengthArenaApp extends StatefulWidget {
  const StrengthArenaApp({super.key});

  @override
  State<StrengthArenaApp> createState() => _StrengthArenaAppState();
}

class _StrengthArenaAppState extends State<StrengthArenaApp> {
  Locale _locale = const Locale('ar');

  void _toggleLanguage() {
    setState(() {
      _locale = _locale.languageCode == 'ar'
          ? const Locale('en')
          : const Locale('ar');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Strength Arena',
      locale: _locale,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF090B0E),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE53935),
          secondary: Color(0xFFFFB300),
          surface: Color(0xFF12161D),
        ),
        useMaterial3: true,
      ),
      builder: (context, child) {
        final isRtl = _locale.languageCode == 'ar';
        return Directionality(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: SplashArenaScreen(
        isArabic: _locale.languageCode == 'ar',
        onToggleLanguage: _toggleLanguage,
      ),
    );
  }
}

class SplashArenaScreen extends StatefulWidget {
  final bool isArabic;
  final VoidCallback onToggleLanguage;

  const SplashArenaScreen({
    super.key,
    required this.isArabic,
    required this.onToggleLanguage,
  });

  @override
  State<SplashArenaScreen> createState() => _SplashArenaScreenState();
}

class _SplashArenaScreenState extends State<SplashArenaScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _progress;
  Timer? _navTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1900),
    );
    _progress = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
    _controller.forward();

    _navTimer = Timer(const Duration(milliseconds: 2150), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 450),
          pageBuilder: (_, __, ___) => LoginArenaScreen(
            isArabic: widget.isArabic,
            onToggleLanguage: widget.onToggleLanguage,
          ),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ar = widget.isArabic;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(
            painter: _AthleticSilhouettePainter(),
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x66090B0E),
                  Color(0x99090B0E),
                  Color(0xF2090B0E),
                  Color(0xFF090B0E),
                ],
                stops: [0.0, 0.45, 0.78, 1.0],
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: AlignmentDirectional.topEnd,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: InkWell(
                  onTap: widget.onToggleLanguage,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141922).withOpacity(0.85),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.14),
                      ),
                    ),
                    child: Text(
                      ar ? 'English' : 'العربية',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 44),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE53935).withOpacity(0.16),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: const Color(0xFFE53935).withOpacity(0.45),
                      ),
                    ),
                    child: Text(
                      ar ? 'ساحة التحديات والقوة' : 'GLOBAL STRENGTH ARENA',
                      style: const TextStyle(
                        fontSize: 11,
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFFF6E6A),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'STRENGTH ARENA',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.8,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ar
                        ? 'تحديات حقيقية، مستويات قوة، وترتيب محلي وعالمي'
                        : 'Head-to-head challenges, strength tiers & global rankings',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: Colors.white.withOpacity(0.72),
                    ),
                  ),
                  const SizedBox(height: 26),
                  AnimatedBuilder(
                    animation: _progress,
                    builder: (context, _) {
                      final pct = (_progress.value * 100).round();
                      return Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: _progress.value,
                              minHeight: 5,
                              backgroundColor: Colors.white.withOpacity(0.10),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFFE53935),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                ar ? 'جاري تجهيز الساحة...' : 'Preparing the arena...',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.65),
                                ),
                              ),
                              Text(
                                '$pct%',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFFFB300),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LoginArenaScreen extends StatelessWidget {
  final bool isArabic;
  final VoidCallback onToggleLanguage;

  const LoginArenaScreen({
    super.key,
    required this.isArabic,
    required this.onToggleLanguage,
  });

  void _showProviderNotice(BuildContext context, String provider) {
    final msg = isArabic
        ? 'تم اختيار الدخول عبر $provider — سنربط المصادقة الفعلية في الخطوة القادمة.'
        : '$provider sign-in selected — live auth connection comes next.';
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1A202C),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ar = isArabic;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.55),
            radius: 1.15,
            colors: [
              Color(0xFF1E1316),
              Color(0xFF0D1016),
              Color(0xFF090B0E),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'STRENGTH ARENA',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: Colors.white70,
                      ),
                    ),
                    InkWell(
                      onTap: onToggleLanguage,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF151A24),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.14),
                          ),
                        ),
                        child: Text(
                          ar ? 'English' : 'العربية',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 420),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF12161E).withOpacity(0.94),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.10),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.55),
                        blurRadius: 28,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 62,
                        height: 62,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFE53935).withOpacity(0.15),
                          border: Border.all(
                            color: const Color(0xFFE53935).withOpacity(0.5),
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.fitness_center_rounded,
                          color: Color(0xFFFF6E6A),
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        ar ? 'سجّل دخولك إلى الساحة' : 'Sign In to the Arena',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        ar
                            ? 'احفظ مستواك، دولتك، ونتائج تحدياتك 1v1'
                            : 'Save your strength tier, country & 1v1 records',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.68),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _SocialAuthButton(
                        label: ar ? 'المتابعة باستخدام Google' : 'Continue with Google',
                        icon: Icons.g_mobiledata_rounded,
                        accentColor: const Color(0xFFEA4335),
                        onTap: () => _showProviderNotice(context, 'Google'),
                      ),
                      const SizedBox(height: 12),
                      _SocialAuthButton(
                        label: ar ? 'المتابعة باستخدام Facebook' : 'Continue with Facebook',
                        icon: Icons.facebook_rounded,
                        accentColor: const Color(0xFF1877F2),
                        onTap: () => _showProviderNotice(context, 'Facebook'),
                      ),
                      const SizedBox(height: 12),
                      _SocialAuthButton(
                        label: ar ? 'المتابعة باستخدام X' : 'Continue with X',
                        icon: Icons.alternate_email_rounded,
                        accentColor: Colors.white,
                        onTap: () => _showProviderNotice(context, 'X'),
                      ),
                      const SizedBox(height: 12),
                      _SocialAuthButton(
                        label: ar ? 'المتابعة باستخدام Apple' : 'Continue with Apple',
                        icon: Icons.apple_rounded,
                        accentColor: Colors.white,
                        onTap: () => _showProviderNotice(context, 'Apple'),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  ar
                      ? 'حساب شخصي مرتبط بتحدياتك وترتيبك فقط'
                      : 'Personal account tied to your challenges & rank',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.50),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialAuthButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  const _SocialAuthButton({
    required this.label,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: Material(
        color: const Color(0xFF191F2B),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withOpacity(0.12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: accentColor, size: 24),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Colors.white.withOpacity(0.45),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AthleticSilhouettePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;

    final auraPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -0.18),
        radius: 0.65,
        colors: [
          const Color(0xFFE53935).withOpacity(0.24),
          const Color(0xFFFFB300).withOpacity(0.08),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), auraPaint);

    final ringPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(Offset(cx, h * 0.36), math.min(w, h) * 0.34, ringPaint);
    canvas.drawCircle(Offset(cx, h * 0.36), math.min(w, h) * 0.43, ringPaint);

    final bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF28303F),
          const Color(0xFF151A23),
          const Color(0xFF0C0F14),
        ],
      ).createShader(Rect.fromLTWH(0, h * 0.15, w, h * 0.65));

    final headCenter = Offset(cx, h * 0.21);
    canvas.drawCircle(headCenter, w * 0.068, bodyPaint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, h * 0.275),
          width: w * 0.09,
          height: h * 0.045,
        ),
        const Radius.circular(10),
      ),
      bodyPaint,
    );

    final torso = Path()
      ..moveTo(cx - w * 0.24, h * 0.31)
      ..quadraticBezierTo(cx, h * 0.285, cx + w * 0.24, h * 0.31)
      ..lineTo(cx + w * 0.14, h * 0.52)
      ..quadraticBezierTo(cx, h * 0.545, cx - w * 0.14, h * 0.52)
      ..close();
    canvas.drawPath(torso, bodyPaint);

    final leftArm = Path()
      ..moveTo(cx - w * 0.23, h * 0.315)
      ..quadraticBezierTo(cx - w * 0.31, h * 0.42, cx - w * 0.27, h * 0.55)
      ..lineTo(cx - w * 0.20, h * 0.55)
      ..quadraticBezierTo(cx - w * 0.22, h * 0.43, cx - w * 0.18, h * 0.34)
      ..close();
    canvas.drawPath(leftArm, bodyPaint);

    final rightArm = Path()
      ..moveTo(cx + w * 0.23, h * 0.315)
      ..quadraticBezierTo(cx + w * 0.31, h * 0.42, cx + w * 0.27, h * 0.55)
      ..lineTo(cx + w * 0.20, h * 0.55)
      ..quadraticBezierTo(cx + w * 0.22, h * 0.43, cx + w * 0.18, h * 0.34)
      ..close();
    canvas.drawPath(rightArm, bodyPaint);

    final leftLeg = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - w * 0.135, h * 0.51, w * 0.11, h * 0.24),
      const Radius.circular(18),
    );
    final rightLeg = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx + w * 0.025, h * 0.51, w * 0.11, h * 0.24),
      const Radius.circular(18),
    );
    canvas.drawRRect(leftLeg, bodyPaint);
    canvas.drawRRect(rightLeg, bodyPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
