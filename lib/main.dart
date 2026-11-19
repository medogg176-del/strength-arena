import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const String kSupabaseUrl = 'https://onxvcxnmrtidgzuokyds.supabase.co';
const String kSupabasePublishableKey = 'sb_publishable_inibW7-1N98La8CGVZ5OgA__700dgod';
const String kRedirectUrl = 'io.supabase.strengtharena://login-callback';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: kSupabaseUrl,
    anonKey: kSupabasePublishableKey,
  );

  runApp(const StrengthArenaApp());
}

final supabase = Supabase.instance.client;

class StrengthArenaApp extends StatelessWidget {
  const StrengthArenaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Strength Arena',
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<AuthState>(
        stream: supabase.auth.onAuthStateChange,
        builder: (context, snapshot) {
          final session = supabase.auth.currentSession;
          if (session != null) {
            return const ArenaHomeScreen();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signInWithEmail() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user != null) {
        await _ensureProfileExists(response.user!, providerName: 'email');
      }
    } on AuthException catch (e) {
      _showMsg(e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signUpWithEmail() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );
      if (response.user != null) {
        await _ensureProfileExists(response.user!, providerName: 'email');
      }
      _showMsg(
          'تم إرسال طلب التسجيل، راجع بريدك الإلكتروني إذا كان التفعيل مطلوباً.');
    } on AuthException catch (e) {
      _showMsg(e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithOAuth(OAuthProvider provider) async {
    setState(() => _isLoading = true);
    try {
      await supabase.auth.signInWithOAuth(
        provider,
        redirectTo: kRedirectUrl,
      );
    } on AuthException catch (e) {
      _showMsg(e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _ensureProfileExists(
    User user, {
    required String providerName,
  }) async {
    final existing = await supabase
        .from('profiles')
        .select('id')
        .eq('id', user.id)
        .maybeSingle();

    if (existing == null) {
      await supabase.from('profiles').insert({
        'id': user.id,
        'email': user.email,
        'full_name':
            user.userMetadata?['full_name'] ?? user.email?.split('@').first,
        'provider': providerName,
      });
    }
  }

  void _showMsg(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Strength Arena - Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const CircularProgressIndicator()
            else ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _signInWithEmail,
                      child: const Text('Sign In'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _signUpWithEmail,
                      child: const Text('Sign Up'),
                    ),
                  ),
                ],
              ),
              const Divider(height: 32),
              ElevatedButton.icon(
                onPressed: () => _signInWithOAuth(OAuthProvider.facebook),
                icon: const Icon(Icons.facebook),
                label: const Text('Continue with Facebook'),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () => _signInWithOAuth(OAuthProvider.twitter),
                icon: const Icon(Icons.alternate_email),
                label: const Text('Continue with X / Twitter'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ArenaHomeScreen extends StatefulWidget {
  const ArenaHomeScreen({super.key});

  @override
  State<ArenaHomeScreen> createState() => _ArenaHomeScreenState();
}

class _ArenaHomeScreenState extends State<ArenaHomeScreen> {
  Map<String, dynamic>? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final providerFromMeta =
        user.appMetadata['provider'] as String? ?? 'email';

    var data = await supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (data == null) {
      data = await supabase
          .from('profiles')
          .insert({
            'id': user.id,
            'email': user.email,
            'full_name':
                user.userMetadata?['full_name'] ?? user.email?.split('@').first,
            'provider': providerFromMeta,
          })
          .select()
          .single();
    }

    if (mounted) {
      setState(() => _profile = data);
    }
  }

  Future<void> _addXpAndWin() async {
    if (_profile == null) return;
    final newXp = (_profile!['xp'] as int? ?? 0) + 50;
    final newWins = (_profile!['wins'] as int? ?? 0) + 1;
    final newLevel = (newXp ~/ 100) + 1;

    final updated = await supabase
        .from('profiles')
        .update({
          'xp': newXp,
          'wins': newWins,
          'level': newLevel,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', _profile!['id'])
        .select()
        .single();

    if (mounted) {
      setState(() => _profile = updated);
    }
  }

  Future<void> _signOut() async {
    await supabase.auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final p = _profile;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Strength Arena'),
        actions: [
          IconButton(onPressed: _signOut, icon: const Icon(Icons.logout)),
        ],
      ),
      body: p == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Name: ${p['full_name'] ?? '-'}'),
                  Text('Email: ${p['email'] ?? '-'}'),
                  Text('Provider: ${p['provider'] ?? '-'}'),
                  Text('Country: ${p['country'] ?? 'EG'}'),
                  const SizedBox(height: 12),
                  Text('XP: ${p['xp']}'),
                  Text('Level: ${p['level']}'),
                  Text('Wins: ${p['wins']}'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _addXpAndWin,
                    child: const Text('+50 XP & +1 Win'),
                  ),
                ],
              ),
            ),
    );
  }
}
