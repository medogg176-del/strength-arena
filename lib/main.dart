import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const String kSupabaseUrl = 'https://onxvcxnmrtidgzuokyds.supabase.co';
const String kSupabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
const String kPhysiqueAsset = 'images (1).jpeg';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Supabase.initialize(
      url: kSupabaseUrl,
      anonKey: kSupabaseAnonKey,
    );
  } catch (_) {
    // يسمح بفتح الواجهة حتى لو لم يُضبط مفتاح Supabase بعد
  }

  runApp(const StrengthArenaApp());
}

class StrengthArenaApp extends StatelessWidget {
  const StrengthArenaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Strength Arena',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0C10),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF5A1F),
          secondary: Color(0xFF22C55E),
          surface: Color(0xFF141821),
        ),
      ),
      home: const SplashStartScreen(),
    );
  }
}

/// شاشة البداية: صورة كمال الأجسام + تحميل ثانيتين + زر "بدء"
class SplashStartScreen extends StatefulWidget {
  const SplashStartScreen({super.key});

  @override
  State<SplashStartScreen> createState() => _SplashStartScreenState();
}

class _SplashStartScreenState extends State<SplashStartScreen> {
  bool _isLoading = true;
  bool _showStartButton = false;

  @override
  void initState() {
    super.initState();
    _runIntro();
  }

  Future<void> _runIntro() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _showStartButton = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            kPhysiqueAsset,
            fit: BoxFit.cover,
            gaplessPlayback: true,
            errorBuilder: (_, __, ___) => Container(
              color: const Color(0xFF12161F),
              child: const Center(
                child: Icon(
                  Icons.fitness_center_rounded,
                  size: 76,
                  color: Color(0xFFFF5A1F),
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.20),
                  Colors.black.withOpacity(0.55),
                  Colors.black.withOpacity(0.95),
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'STRENGTH ARENA',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.4,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '1v1 • ضغط • عقلة • بطن',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFCBD5E1),
                    ),
                  ),
                  const SizedBox(height: 28),
                  if (_isLoading)
                    const Column(
                      children: [
                        SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.8,
                            color: Color(0xFFFF5A1F),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'جاري التحميل...',
                          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                        ),
                      ],
                    ),
                  AnimatedOpacity(
                    opacity: _showStartButton ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 350),
                    child: _showStartButton
                        ? SizedBox(
                            width: double.infinity,
                            height: 58,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ChallengesHomeScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF5A1F),
                                foregroundColor: Colors.white,
                                elevation: 10,
                                shadowColor: const Color(0xFFFF5A1F).withOpacity(0.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'بدء',
                                    style: TextStyle(
                                      fontSize: 21,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.play_arrow_rounded, size: 26),
                                ],
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
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

/// شاشة التحديات الرئيسية مع خلفية التطبيق
class ChallengesHomeScreen extends StatelessWidget {
  const ChallengesHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final challenges = [
      _ChallengeCardData(
        title: 'تحدي الضغط',
        subtitle: 'نزول كامل وزاوية كوع مضبوطة مع ثبات الجسم',
        color: const Color(0xFFFF5A1F),
        icon: Icons.fitness_center_rounded,
      ),
      _ChallengeCardData(
        title: 'تحدي العقلة',
        subtitle: 'صعود واضح للذقن وفرد الذراعين بالكامل بدون غش',
        color: const Color(0xFF38BDF8),
        icon: Icons.accessibility_new_rounded,
      ),
      _ChallengeCardData(
        title: 'تحدي البطن',
        subtitle: 'حركة جذع واضحة نحو الركبتين بدون تحايل',
        color: const Color(0xFF22C55E),
        icon: Icons.sports_gymnastics_rounded,
      ),
    ];

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Opacity(
            opacity: 0.16,
            child: Image.asset(
              kPhysiqueAsset,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF0A0C10).withOpacity(0.84),
                  const Color(0xFF0A0C10).withOpacity(0.95),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141821).withOpacity(0.92),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: const Text(
                      'التحديات',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.separated(
                      itemCount: challenges.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final item = challenges[index];
                        return InkWell(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('تم اختيار ${item.title} — جاهز لخطوة الكاميرا والـ 1v1'),
                                backgroundColor: const Color(0xFF1E2433),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: const Color(0xFF141821).withOpacity(0.92),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: item.color.withOpacity(0.35)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: item.color.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(item.icon, color: item.color, size: 28),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.title,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        item.subtitle,
                                        style: const TextStyle(
                                          fontSize: 12.5,
                                          color: Color(0xFF94A3B8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: item.color,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
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

class _ChallengeCardData {
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;

  const _ChallengeCardData({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
  });
}
