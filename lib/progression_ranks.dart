import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RankInfo {
  final int level;
  final String titleAr;
  final String titleEn;
  final Color color;
  final int minXp;
  final int nextXp;

  const RankInfo({
    required this.level,
    required this.titleAr,
    required this.titleEn,
    required this.color,
    required this.minXp,
    required this.nextXp,
  });

  String title(bool isAr) => isAr ? titleAr : titleEn;

  double progressFor(int xp) {
    final span = (nextXp - minXp).clamp(1, 999999);
    return ((xp - minXp) / span).clamp(0.0, 1.0);
  }
}

class LeaderboardEntry {
  final String name;
  final String countryCode;
  final String countryLabel;
  final int xp;
  final int wins;
  final bool isCurrentUser;

  const LeaderboardEntry({
    required this.name,
    required this.countryCode,
    required this.countryLabel,
    required this.xp,
    required this.wins,
    this.isCurrentUser = false,
  });
}

class ProgressionService {
  static const _xpKey = 'arena_xp_v1';
  static const _winsKey = 'arena_wins_v1';
  static const _countryKey = 'arena_country_v1';

  static const List> countries = [
    {'code': 'EG', 'ar': 'مصر', 'en': 'Egypt'},
    {'code': 'SA', 'ar': 'السعودية', 'en': 'Saudi Arabia'},
    {'code': 'AE', 'ar': 'الإمارات', 'en': 'UAE'},
    {'code': 'MA', 'ar': 'المغرب', 'en': 'Morocco'},
    {'code': 'DZ', 'ar': 'الجزائر', 'en': 'Algeria'},
    {'code': 'JO', 'ar': 'الأردن', 'en': 'Jordan'},
    {'code': 'IQ', 'ar': 'العراق', 'en': 'Iraq'},
    {'code': 'GLOBAL', 'ar': 'عالمي', 'en': 'Global'},
  ];

  static String countryName(String code, bool isAr) {
    final match = countries.firstWhere(
      (c) => c['code'] == code,
      orElse: () => {'code': 'EG', 'ar': 'مصر', 'en': 'Egypt'},
    );
    return isAr ? match['ar']! : match['en']!;
  }

  static RankInfo rankForXp(int xp) {
    if (xp >= 2500) {
      return const RankInfo(
        level: 6,
        titleAr: 'أسطورة الحلبة',
        titleEn: 'ARENA LEGEND',
        color: Color(0xFFF59E0B),
        minXp: 2500,
        nextXp: 5000,
      );
    } else if (xp >= 1400) {
      return const RankInfo(
        level: 5,
        titleAr: 'بطل محترف',
        titleEn: 'PRO CHAMPION',
        color: Color(0xFFEF4444),
        minXp: 1400,
        nextXp: 2500,
      );
    } else if (xp >= 750) {
      return const RankInfo(
        level: 4,
        titleAr: 'مقاتل نخبوي',
        titleEn: 'ELITE FIGHTER',
        color: Color(0xFF38BDF8),
        minXp: 750,
        nextXp: 1400,
      );
    } else if (xp >= 350) {
      return const RankInfo(
        level: 3,
        titleAr: 'محارب متقدم',
        titleEn: 'VANGUARD',
        color: Color(0xFF22C55E),
        minXp: 350,
        nextXp: 750,
      );
    } else if (xp >= 120) {
      return const RankInfo(
        level: 2,
        titleAr: 'متحدٍ صاعد',
        titleEn: 'CONTENDER',
        color: Color(0xFFFF5A1F),
        minXp: 120,
        nextXp: 350,
      );
    }
    return const RankInfo(
      level: 1,
      titleAr: 'مبتدئ الساحة',
      titleEn: 'ROOKIE',
      color: Color(0xFF94A3B8),
      minXp: 0,
      nextXp: 120,
    );
  }

  static Future<({int xp, int wins, String countryCode})> loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    return (
      xp: prefs.getInt(_xpKey) ?? 0,
      wins: prefs.getInt(_winsKey) ?? 0,
      countryCode: prefs.getString(_countryKey) ?? 'EG',
    );
  }

  static Future<void> setCountry(String countryCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_countryKey, countryCode);
  }

  static Future<({int xp, int wins, int gainedXp})> recordMatchResult({
    required int validReps,
    required bool wonMatch,
    required bool drawMatch,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final currentXp = prefs.getInt(_xpKey) ?? 0;
    final currentWins = prefs.getInt(_winsKey) ?? 0;

    final repXp = validReps * 10;
    final bonusXp = wonMatch ? 120 : (drawMatch ? 50 : 25);
    final gainedXp = repXp + bonusXp;

    final newXp = currentXp + gainedXp;
    final newWins = wonMatch ? currentWins + 1 : currentWins;

    await prefs.setInt(_xpKey, newXp);
    await prefs.setInt(_winsKey, newWins);

    return (xp: newXp, wins: newWins, gainedXp: gainedXp);
  }

  static List<LeaderboardEntry> buildLeaderboard({
    required String playerName,
    required String countryCode,
    required int userXp,
    required int userWins,
    required bool isAr,
    required bool countryOnly,
  }) {
    final bots = [
      LeaderboardEntry(
        name: isAr ? 'كابتن طارق' : 'Capt. Tariq',
        countryCode: 'EG',
        countryLabel: countryName('EG', isAr),
        xp: 2680,
        wins: 29,
      ),
      LeaderboardEntry(
        name: isAr ? 'فهد القحطاني' : 'Fahad Al-Qahtani',
        countryCode: 'SA',
        countryLabel: countryName('SA', isAr),
        xp: 1850,
        wins: 21,
      ),
      LeaderboardEntry(
        name: isAr ? 'ياسين المنصور' : 'Yassine Mansour',
        countryCode: 'MA',
        countryLabel: countryName('MA', isAr),
        xp: 1120,
        wins: 14,
      ),
      LeaderboardEntry(
        name: isAr ? 'عمر الشامي' : 'Omar Al-Shami',
        countryCode: 'JO',
        countryLabel: countryName('JO', isAr),
        xp: 620,
        wins: 8,
      ),
      LeaderboardEntry(
        name: isAr ? 'كريم حسن' : 'Karim Hassan',
        countryCode: 'EG',
        countryLabel: countryName('EG', isAr),
        xp: 430,
        wins: 6,
      ),
      LeaderboardEntry(
        name: isAr ? 'راشد الظاهري' : 'Rashid Al-Dhaheri',
        countryCode: 'AE',
        countryLabel: countryName('AE', isAr),
        xp: 210,
        wins: 3,
      ),
    ];

    final all = <LeaderboardEntry>[
      ...bots,
      LeaderboardEntry(
        name: playerName,
        countryCode: countryCode,
        countryLabel: countryName(countryCode, isAr),
        xp: userXp,
        wins: userWins,
        isCurrentUser: true,
      ),
    ];

    final filtered = countryOnly
        ? all.where((e) => e.countryCode == countryCode).toList()
        : all;

    filtered.sort((a, b) => b.xp.compareTo(a.xp));
    return filtered;
  }
}

class RankingsSheet extends StatefulWidget {
  final String playerName;
  final String initialCountryCode;
  final int userXp;
  final int userWins;
  final bool isAr;
  final ValueChanged<String> onCountryChanged;

  const RankingsSheet({
    super.key,
    required this.playerName,
    required this.initialCountryCode,
    required this.userXp,
    required this.userWins,
    required this.isAr,
    required this.onCountryChanged,
  });

  @override
  State<RankingsSheet> createState() => _RankingsSheetState();
}

class _RankingsSheetState extends State<RankingsSheet> {
  late String _selectedCountry;
  bool _countryTab = false;

  @override
  void initState() {
    super.initState();
    _selectedCountry = widget.initialCountryCode;
  }

  @override
  Widget build(BuildContext context) {
    final rank = ProgressionService.rankForXp(widget.userXp);
    final entries = ProgressionService.buildLeaderboard(
      playerName: widget.playerName,
      countryCode: _selectedCountry,
      userXp: widget.userXp,
      userWins: widget.userWins,
      isAr: widget.isAr,
      countryOnly: _countryTab,
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF141821),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.isAr ? 'المستويات والترتيب' : 'LEVELS & RANKINGS',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              DropdownButton<String>(
                value: _selectedCountry,
                dropdownColor: const Color(0xFF1E2433),
                underline: const SizedBox.shrink(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                items: ProgressionService.countries.map((c) {
                  return DropdownMenuItem<String>(
                    value: c['code'],
                    child: Text(widget.isAr ? c['ar']! : c['en']!),
                  );
                }).toList(),
                onChanged: (val) async {
                  if (val == null) return;
                  setState(() => _selectedCountry = val);
                  await ProgressionService.setCountry(val);
                  widget.onCountryChanged(val);
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF0A0C10),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: rank.color.withOpacity(0.45)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'LVL ${rank.level} • ${rank.title(widget.isAr)}',
                      style: TextStyle(
                        color: rank.color,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      '${widget.userXp} XP',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: rank.progressFor(widget.userXp),
                    minHeight: 8,
                    backgroundColor: Colors.white12,
                    valueColor: AlwaysStoppedAnimation<Color>(rank.color),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: Text(widget.isAr ? 'الترتيب العالمي' : 'Global Rank'),
                  selected: !_countryTab,
                  onSelected: (_) => setState(() => _countryTab = false),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ChoiceChip(
                  label: Text(
                    widget.isAr
                        ? 'ترتيب ${ProgressionService.countryName(_selectedCountry, true)}'
                        : '${ProgressionService.countryName(_selectedCountry, false)} Rank',
                  ),
                  selected: _countryTab,
                  onSelected: (_) => setState(() => _countryTab = true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 260),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: entries.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = entries[index];
                final itemRank = ProgressionService.rankForXp(item.xp);
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: item.isCurrentUser
                        ? const Color(0xFFFF5A1F).withOpacity(0.16)
                        : const Color(0xFF0A0C10),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: item.isCurrentUser
                          ? const Color(0xFFFF5A1F)
                          : Colors.white.withOpacity(0.06),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '#${index + 1}',
                        style: TextStyle(
                          color: index < 3 ? const Color(0xFFF59E0B) : Colors.white70,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              '${item.countryLabel} • LVL ${itemRank.level}',
                              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${item.xp} XP',
                        style: const TextStyle(
                          color: Color(0xFF4ADE80),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
