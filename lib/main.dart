import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const String kSupabaseUrl = 'https://bhgtbwyuxbalxdwzdmii.supabase.co';
const String kSupabaseAnonKey = 'ضع_مفتاح_ANON_الخاص_بمشروعك_هنا';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: kSupabaseUrl,
    anonKey: kSupabaseAnonKey,
  );

  runApp(const StrengthArenaApp());
}

class StrengthArenaApp extends StatelessWidget {
  const StrengthArenaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Strength Arena',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF090B0E),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF4500),
          secondary: Color(0xFF00E676),
          surface: Color(0xFF12161C),
        ),
      ),
      home: const ArenaHomeScreen(),
    );
  }
}

class ArenaHomeScreen extends StatefulWidget {
  const ArenaHomeScreen({super.key});

  @override
  State<ArenaHomeScreen> createState() => _ArenaHomeScreenState();
}

class _ArenaHomeScreenState extends State<ArenaHomeScreen> {
  bool _isConnected = false;
  String _statusText = 'جاري التحقق من الاتصال بـ Supabase...';

  @override
  void initState() {
    super.initState();
    _checkBackend();
  }

  Future<void> _checkBackend() async {
    try {
      final client = Supabase.instance.client;
      await client.from('profiles').select().limit(1);
      if (!mounted) return;
      setState(() {
        _isConnected = true;
        _statusText = 'متصل بقاعدة بيانات Strength Arena بنجاح';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isConnected = false;
        _statusText = 'تم تهيئة العميل — تأكد من مفتاح ANON وصلاحيات الجداول';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF090B0E),
        elevation: 0,
        title: const Text(
          'STRENGTH ARENA',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            color: Color(0xFFFF4500),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF12161C),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isConnected
                      ? const Color(0xFF00E676)
                      : const Color(0xFFFF4500),
                  width: 1.2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'حالة النظام السحابي',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _statusText,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFFB0B7C3),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4500),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _checkBackend,
              child: const Text(
                'إعادة فحص الاتصال',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
