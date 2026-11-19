import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'ai_referee_screen.dart';
import 'progression_ranks.dart';

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
  } catch (_) {}

  runApp(const StrengthArenaApp());
}

class StrengthArenaApp extends StatefulWidget {
  const StrengthArenaApp({super.key});

  static _StrengthArenaAppState? of(BuildContext context) {
    return context.findAncestorStateOfType<_StrengthArenaAppState>();
  }

  @override
  State<StrengthArenaApp> createState() => _StrengthArenaAppState();
}

class _StrengthArenaAppState extends State<StrengthArenaApp> {
  Locale _locale = const Locale('ar');

  Locale get locale => _locale;

  void toggleLanguage() {
    setState(() {
      _locale = _locale.languageCode == 'ar'
          ? const Locale('en')
          : const Locale('ar');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Strength Arena',
      debugShowCheckedModeBanner: false,
      locale: _locale,
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

class AppStrings {
  final bool isAr;
  const AppStrings(this.isAr);

  static AppStrings of(BuildContext context) {
    final code = StrengthArenaApp.of(context)?.locale.languageCode ?? 'ar';
    return AppStrings(code == 'ar');
  }

  String get tagline =>
      isAr ? '1v1 • ضغط • عقلة • بطن' : '1v1 • PUSH-UPS • PULL-UPS • SIT-UPS';
  String get loading => isAr ? 'جاري التحميل...' : 'Loading...';
  String get start => isAr ? 'بدء' : 'START';
  String get challengesTitle => isAr ? 'التحديات' : 'CHALLENGES';
  String get langButton => isAr ? 'EN' : 'عربي';
  String get yourNameHint => isAr ? 'اكتب اسمك هنا...' : 'Enter your name...';
  String get defaultPlayerName => isAr ? 'بطل الساحة' : 'Arena Fighter';
  String get editProfile => isAr ? 'تعديل الاسم والصورة' : 'Edit Name & Photo';
  String get save => isAr ? 'حفظ' : 'Save';
  String get pickPhoto => isAr ? 'اختر صورتك' : 'Pick Photo';

  String get pushupTitle => isAr ? 'تحدي الضغط' : 'Push-Up Challenge';
  String get pushupSub => isAr
      ? 'نزول كامل وزاوية كوع مضبوطة مع ثبات الجسم'
      : 'Full depth, proper elbow angle & body alignment';

  String get pullupTitle => isAr ? 'تحدي العقلة' : 'Pull-Up Challenge';
  String get pullupSub => isAr
      ? 'صعود واضح للذقن وفرد الذراعين بالكامل بدون غش'
      : 'Clear chin over bar & full arm extension';

  String get situpTitle => isAr ? 'تحدي البطن' : 'Sit-Up Challenge';
  String get situpSub => isAr
      ? 'حركة جذع واضحة نحو الركبتين بدون تحايل'
      : 'Clean torso crunch toward knees with no cheating';

  String get searchingOpponent => isAr
      ? 'جاري البحث عن خصم متصل في نفس التحدي...'
      : 'Searching for an online opponent in this challenge...';

  String get aiRefereeNote => isAr
      ? 'تحكيم الذكاء الاصطناعي: الكاميرا تراقب عدّاتك فقط والخصم لا يرى الفيديو'
      : 'AI Referee: Only AI inspects your camera; opponent never sees your video';

  String get startMatchNow =>
      isAr ? 'ابدأ التحدي بالكاميرا الآن' : 'START CAMERA AI MATCH';
  String get cancelSearch => isAr ? 'إلغاء البحث' : 'Cancel';
  String get youLabel => isAr ? 'أنت' : 'YOU';
  String get opponentLabel => isAr ? 'خصم عشوائي (1v1)' : 'RANDOM OPPONENT (1v1)';
}

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
    final s = AppStrings.of(context);
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
                  Text(
                    s.tagline,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFCBD5E1),
                    ),
                  ),
                  const SizedBox(height: 28),
                  if (_isLoading)
                    Column(
                      children: [
                        const SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.8,
                            color: Color(0xFFFF5A1F),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          s.loading,
                          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
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
                                shadowColor:
                                    const Color(0xFFFF5A1F).withOpacity(0.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    s.start,
                                    style: const TextStyle(
                                      fontSize: 21,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.play_arrow_rounded, size: 26),
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

class ChallengesHomeScreen extends StatefulWidget {
  const ChallengesHomeScreen({super.key});

  @override
  State<ChallengesHomeScreen> createState() => _ChallengesHomeScreenState();
}

class _ChallengesHomeScreenState extends State<ChallengesHomeScreen> {
  String _playerName = '';
  String? _avatarPath;
  int _xp = 0;
  int _wins = 0;
  String _countryCode = 'EG';
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    final prefs = await SharedPreferences.getInstance();
    final stats = await ProgressionService.loadStats();
    if (!mounted) return;
    setState(() {
      _playerName = prefs.getString('player_name') ?? '';
      _avatarPath = prefs.getString('player_avatar');
      _xp = stats.xp;
      _wins = stats.wins;
      _countryCode = stats.countryCode;
    });
  }

  Future<void> _saveProfile(String name, String? avatarPath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('player_name', name.trim());
    if (avatarPath != null && avatarPath.isNotEmpty) {
      await prefs.setString('player_avatar', avatarPath);
    }
    if (!mounted) return;
    setState(() {
      _playerName = name.trim();
      if (avatarPath != null && avatarPath.isNotEmpty) {
        _avatarPath = avatarPath;
      }
    });
  }

  Future<void> _openProfileEditor() async {
    final s = AppStrings.of(context);
    final controller = TextEditingController(
      text: _playerName.isEmpty ? s.defaultPlayerName : _playerName,
    );
    String? tempAvatar = _avatarPath;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF141821),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    s.editProfile,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 18),
                  GestureDetector(
                    onTap: () async {
                      final XFile? file = await _picker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 75,
                      );
                      if (file != null) {
                        setSheetState(() => tempAvatar = file.path);
                      }
                    },
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        _PlayerAvatar(imagePath: tempAvatar, size: 86),
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF5A1F),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    s.pickPhoto,
                    style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12.5),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: s.yourNameHint,
                      hintStyle: const TextStyle(color: Color(0xFF64748B)),
                      filled: true,
                      fillColor: const Color(0xFF0A0C10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        await _saveProfile(controller.text, tempAvatar);
                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF5A1F),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        s.save,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openRankings(String displayName) {
    final s = AppStrings.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RankingsSheet(
        playerName: displayName,
        initialCountryCode: _countryCode,
        userXp: _xp,
        userWins: _wins,
        isAr: s.isAr,
        onCountryChanged: (code) => setState(() => _countryCode = code),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final displayName =
        _playerName.trim().isEmpty ? s.defaultPlayerName : _playerName.trim();
    final rank = ProgressionService.rankForXp(_xp);
    final countryText = ProgressionService.countryName(_countryCode, s.isAr);

    final challenges = [
      _ChallengeCardData(
        id: 'pushup',
        type: ChallengeType.pushup,
        title: s.pushupTitle,
        subtitle: s.pushupSub,
        color: const Color(0xFFFF5A1F),
        icon: Icons.fitness_center_rounded,
      ),
      _ChallengeCardData(
        id: 'pullup',
        type: ChallengeType.pullup,
        title: s.pullupTitle,
        subtitle: s.pullupSub,
        color: const Color(0xFF38BDF8),
        icon: Icons.accessibility_new_rounded,
      ),
      _ChallengeCardData(
        id: 'situp',
        type: ChallengeType.situp,
        title: s.situpTitle,
        subtitle: s.situpSub,
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
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141821).withOpacity(0.92),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: _openProfileEditor,
                          borderRadius: BorderRadius.circular(24),
                          child: Row(
                            children: [
                              _PlayerAvatar(imagePath: _avatarPath, size: 42),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    displayName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    '$countryText • LVL ${rank.level} (${rank.title(s.isAr)})',
                                    style: TextStyle(
                                      color: rank.color,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => _openRankings(displayName),
                          icon: const Icon(Icons.leaderboard_rounded, color: Color(0xFFF59E0B)),
                          tooltip: s.isAr ? 'الترتيب والمستويات' : 'Rankings',
                        ),
                        OutlinedButton(
                          onPressed: () =>
                              StrengthArenaApp.of(context)?.toggleLanguage(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(color: Colors.white.withOpacity(0.22)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                          ),
                          child: Text(
                            s.langButton,
                            style: const TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    s.challengesTitle,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: ListView.separated(
                      itemCount: challenges.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final item = challenges[index];
                        return InkWell(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MatchmakingWaitingScreen(
                                  challenge: item,
                                  playerName: displayName,
                                  playerAvatarPath: _avatarPath,
                                ),
                              ),
                            );
                            _loadAllData();
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

class MatchmakingWaitingScreen extends StatefulWidget {
  final _ChallengeCardData challenge;
  final String playerName;
  final String? playerAvatarPath;

  const MatchmakingWaitingScreen({
    super.key,
    required this.challenge,
    required this.playerName,
    this.playerAvatarPath,
  });

  @override
  State<MatchmakingWaitingScreen> createState() =>
      _MatchmakingWaitingScreenState();
}

class _MatchmakingWaitingScreenState extends State<MatchmakingWaitingScreen> {
  RealtimeChannel? _queueChannel;
  int _elapsedSeconds = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _elapsedSeconds++);
      }
    });
    _joinQueueChannel();
  }

  void _joinQueueChannel() {
    try {
      final client = Supabase.instance.client;
      final channel = client.channel('queue-${widget.challenge.id}');
      channel.subscribe((status, [error]) async {
        if (status == RealtimeSubscribeStatus.subscribed) {
          await channel.track({
            'name': widget.playerName,
            'challenge': widget.challenge.id,
            'joined_at': DateTime.now().toIso8601String(),
          });
        }
      });
      _queueChannel = channel;
    } catch (_) {}
  }

  @override
  void dispose() {
    _timer?.cancel();
    if (_queueChannel != null) {
      try {
        Supabase.instance.client.removeChannel(_queueChannel!);
      } catch (_) {}
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0C10),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.challenge.title,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF141821),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: widget.challenge.color.withOpacity(0.35)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        _PlayerAvatar(imagePath: widget.playerAvatarPath, size: 70),
                        const SizedBox(height: 8),
                        Text(
                          widget.playerName,
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w800),
                        ),
                        Text(
                          s.youLabel,
                          style: const TextStyle(
                              color: Color(0xFF4ADE80), fontSize: 12),
                        ),
                      ],
                    ),
                    Text(
                      'VS',
                      style: TextStyle(
                        color: widget.challenge.color,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Column(
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E2433),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(0.15)),
                          ),
                          child: const Icon(Icons.person_search_rounded,
                              color: Colors.white70, size: 32),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          s.opponentLabel,
                          style: const TextStyle(
                              color: Colors.white70, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          '${_elapsedSeconds}s',
                          style: const TextStyle(
                              color: Color(0xFF94A3B8), fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  CircularProgressIndicator(color: widget.challenge.color),
                  const SizedBox(height: 16),
                  Text(
                    s.searchingOpponent,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141821),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: Text(
                      s.aiRefereeNote,
                      textAlign: TextAlign.center,
                      style:
                          const TextStyle(color: Color(0xFF94A3B8), fontSize: 12.5),
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AiRefereeMatchScreen(
                              challengeType: widget.challenge.type,
                              challengeTitle: widget.challenge.title,
                              accentColor: widget.challenge.color,
                              playerName: widget.playerName,
                              isAr: s.isAr,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.challenge.color,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        s.startMatchNow,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      s.cancelSearch,
                      style: const TextStyle(color: Color(0xFF94A3B8)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayerAvatar extends StatelessWidget {
  final String? imagePath;
  final double size;

  const _PlayerAvatar({this.imagePath, required this.size});

  @override
  Widget build(BuildContext context) {
    final hasFile = imagePath != null &&
        imagePath!.isNotEmpty &&
        File(imagePath!).existsSync();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF1E2433),
        border: Border.all(
            color: const Color(0xFFFF5A1F).withOpacity(0.6), width: 2),
      ),
      child: ClipOval(
        child: hasFile
            ? Image.file(
                File(imagePath!),
                fit: BoxFit.cover,
              )
            : const Icon(
                Icons.person_rounded,
                color: Colors.white70,
                size: 28,
              ),
      ),
    );
  }
}

class _ChallengeCardData {
  final String id;
  final ChallengeType type;
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;

  const _ChallengeCardData({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
  });
}
