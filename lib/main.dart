import 'dart:async';
import 'package:flutter/material.dart';

enum AppLang { ar, en, fr, es, zh }

final ValueNotifier<AppLang> appLangNotifier = ValueNotifier<AppLang>(AppLang.ar);

void cycleAppLanguage() {
  final values = AppLang.values;
  final nextIndex = (values.indexOf(appLangNotifier.value) + 1) % values.length;
  appLangNotifier.value = values[nextIndex];
}

String _langLabel(AppLang lang) {
  switch (lang) {
    case AppLang.ar:
      return 'العربية';
    case AppLang.en:
      return 'English';
    case AppLang.fr:
      return 'Français';
    case AppLang.es:
      return 'Español';
    case AppLang.zh:
      return '中文';
  }
}

Map<String, String> _strings(AppLang lang) {
  switch (lang) {
    case AppLang.ar:
      return {
        'badge': 'ساحة التحديات والقوة',
        'tagline': 'تحديات حقيقية، مستويات قوة، وترتيب محلي وعالمي',
        'loading': 'جاري تجهيز الساحة...',
        'loginTitle': 'ادخل الساحة وأثبت قوتك',
        'loginSub': 'سجّل أرقامك، واجه منافسيك 1v1، واصعد في الترتيب',
        'google': 'دخول فوري عبر Google',
        'facebook': 'دخول فوري عبر Facebook',
        'x': 'دخول فوري عبر X',
        'apple': 'دخول فوري عبر Apple',
        'footer': 'تقدّمك وأرقامك محفوظة لحسابك في كل تحدٍ',
        'notice': 'تم اختيار الدخول عبر {p} — سنربط المصادقة الفعلية في الخطوة القادمة.',
      };
    case AppLang.en:
      return {
        'badge': 'GLOBAL STRENGTH ARENA',
        'tagline': 'Head-to-head challenges, strength tiers & global rankings',
        'loading': 'Preparing the arena...',
        'loginTitle': 'Enter the Arena. Prove Your Power.',
        'loginSub': 'Track your lifts, battle 1v1 rivals, and climb the ranks',
        'google': 'Continue with Google',
        'facebook': 'Continue with Facebook',
        'x': 'Continue with X',
        'apple': 'Continue with Apple',
        'footer': 'Your stats, tiers, and wins stay locked to your profile',
        'notice': '{p} sign-in selected — live auth connection comes next.',
      };
    case AppLang.fr:
      return {
        'badge': 'ARÈNE DE FORCE MONDIALE',
        'tagline': 'Défis en face-à-face, niveaux de force et classements',
        'loading': 'Préparation de l’arène...',
        'loginTitle': 'Entrez dans l’Arène. Prouvez votre force.',
        'loginSub': 'Suivez vos performances, affrontez en 1v1 et grimpez au classement',
        'google': 'Continuer avec Google',
        'facebook': 'Continuer avec Facebook',
        'x': 'Continuer avec X',
        'apple': 'Continuer avec Apple',
        'footer': 'Vos records, niveaux et victoires restent liés à votre compte',
        'notice': 'Connexion {p} sélectionnée — la liaison réelle arrive ensuite.',
      };
    case AppLang.es:
      return {
        'badge': 'ARENA DE FUERZA GLOBAL',
        'tagline': 'Desafíos 1v1, niveles de fuerza y rankings mundiales',
        'loading': 'Preparando la arena...',
        'loginTitle': 'Entra a la Arena. Demuestra tu fuerza.',
        'loginSub': 'Registra tus marcas, compite 1v1 y sube en el ranking',
        'google': 'Continuar con Google',
        'facebook': 'Continuar con Facebook',
        'x': 'Continuar con X',
        'apple': 'Continuar con Apple',
        'footer': 'Tus marcas, niveles y victorias quedan guardados en tu perfil',
        'notice': 'Acceso con {p} seleccionado — la conexión real viene después.',
      };
    case AppLang.zh:
      return {
        'badge': '全球力量竞技场',
        'tagline': '一对一真实挑战、力量段位与全球排行榜',
        'loading': '正在准备竞技场...',
        'loginTitle': '踏入竞技场，证明你的实力',
        'loginSub': '记录你的成绩、迎战 1v1 对手、攀登排行榜',
        'google': '使用 Google 继续',
        'facebook': '使用 Facebook 继续',
        'x': '使用 X 继续',
        'apple': '使用 Apple 继续',
        'footer': '你的数据、段位与胜场将永久绑定至个人档案',
        'notice': '已选择通过 {p} 登录 — 真实身份验证将在下一步接入。',
      };
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const StrengthArenaApp());
}

class StrengthArenaApp extends StatelessWidget {
  const StrengthArenaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLang>(
      valueListenable: appLangNotifier,
      builder: (context, lang, _) {
        final isRtl = lang == AppLang.ar;
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Strength Arena',
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
            return Directionality(
              textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
              child: child ?? const SizedBox.shrink(),
            );
          },
          home: const SplashArenaScreen(),
        );
      },
    );
  }
}

class _ArenaBackgroundLayer extends StatelessWidget {
  final double imageOpacity;
  final List<Color> gradientColors;

  const _ArenaBackgroundLayer({
    required this.imageOpacity,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: Color(0xFF090B0E)),
        Opacity(
          opacity: imageOpacity,
          child: Image.asset(
            'images (1).jpeg',
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: gradientColors,
              stops: const [0.0, 0.45, 0.78, 1.0],
            ),
          ),
        ),
      ],
    );
  }
}

class SplashArenaScreen extends StatefulWidget {
  const SplashArenaScreen({super.key});

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
      duration: const Duration(milliseconds: 2200),
    );
    _progress = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
    _controller.forward();

    _navTimer = Timer(const Duration(milliseconds: 2500), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 450),
          pageBuilder: (_, __, ___) => const LoginArenaScreen(),
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
    return ValueListenableBuilder<AppLang>(
      valueListenable: appLangNotifier,
      builder: (context, lang, _) {
        final t = _strings(lang);

        return Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              const _ArenaBackgroundLayer(
                imageOpacity: 0.92,
                gradientColors: [
                  Color(0x33090B0E),
                  Color(0x73090B0E),
                  Color(0xEB090B0E),
                  Color(0xFF090B0E),
                ],
              ),
              SafeArea(
                child: Align(
                  alignment: AlignmentDirectional.topEnd,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: InkWell(
                      onTap: cycleAppLanguage,
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
                          _langLabel(lang),
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
                          color: const Color(0xFFE53935).withOpacity(0.18),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: const Color(0xFFE53935).withOpacity(0.45),
                          ),
                        ),
                        child: Text(
                          t['badge']!,
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
                        t['tagline']!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13.5,
                          color: Colors.white.withOpacity(0.75),
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
                                  backgroundColor:
                                      Colors.white.withOpacity(0.12),
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                    Color(0xFFE53935),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    t['loading']!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white.withOpacity(0.70),
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
      },
    );
  }
}

class LoginArenaScreen extends StatelessWidget {
  const LoginArenaScreen({super.key});

  void _showProviderNotice(
    BuildContext context,
    String provider,
    Map<String, String> t,
  ) {
    final msg = t['notice']!.replaceAll('{p}', provider);
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
    return ValueListenableBuilder<AppLang>(
      valueListenable: appLangNotifier,
      builder: (context, lang, _) {
        final t = _strings(lang);

        return Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              const _ArenaBackgroundLayer(
                imageOpacity: 0.26,
                gradientColors: [
                  Color(0xB8090B0E),
                  Color(0xCC0D1016),
                  Color(0xE6090B0E),
                  Color(0xF5090B0E),
                ],
              ),
              SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                            onTap: cycleAppLanguage,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF151A24).withOpacity(0.9),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.14),
                                ),
                              ),
                              child: Text(
                                _langLabel(lang),
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
                          color: const Color(0xFF12161E).withOpacity(0.92),
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
                                color:
                                    const Color(0xFFE53935).withOpacity(0.15),
                                border: Border.all(
                                  color:
                                      const Color(0xFFE53935).withOpacity(0.5),
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
                              t['loginTitle']!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              t['loginSub']!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.68),
                              ),
                            ),
                            const SizedBox(height: 24),
                            _SocialAuthButton(
                              label: t['google']!,
                              icon: Icons.g_mobiledata_rounded,
                              accentColor: const Color(0xFFEA4335),
                              onTap: () =>
                                  _showProviderNotice(context, 'Google', t),
                            ),
                            const SizedBox(height: 12),
                            _SocialAuthButton(
                              label: t['facebook']!,
                              icon: Icons.facebook_rounded,
                              accentColor: const Color(0xFF1877F2),
                              onTap: () =>
                                  _showProviderNotice(context, 'Facebook', t),
                            ),
                            const SizedBox(height: 12),
                            _SocialAuthButton(
                              label: t['x']!,
                              icon: Icons.alternate_email_rounded,
                              accentColor: Colors.white,
                              onTap: () => _showProviderNotice(context, 'X', t),
                            ),
                            const SizedBox(height: 12),
                            _SocialAuthButton(
                              label: t['apple']!,
                              icon: Icons.apple_rounded,
                              accentColor: Colors.white,
                              onTap: () =>
                                  _showProviderNotice(context, 'Apple', t),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        t['footer']!,
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
            ],
          ),
        );
      },
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
