import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'theme.dart';
import 'screens/app_layout.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
      ],
      child: const MailMindApp(),
    ),
  );
}

class MailMindApp extends StatelessWidget {
  const MailMindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MailMind AI',
      debugShowCheckedModeBanner: false,
      theme: MailMindTheme.darkTheme,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    return state.isAuthenticated ? const AppLayout() : const LoginScreen();
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userCtrl = TextEditingController(text: 'demo');
  final _passCtrl = TextEditingController(text: 'demo123');
  bool _isLoading = false;

  void _handleLogin() async {
    final state = Provider.of<AppState>(context, listen: false);
    setState(() => _isLoading = true);
    try {
      await state.login(_userCtrl.text, _passCtrl.text);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid credentials. Hint: use demo / demo123')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final showPromo = width >= 800;

    return Scaffold(
      body: Row(
        children: [
          // Onboarding Info Side Column
          if (showPromo)
            Expanded(
              flex: 5,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0F0E17), Color(0xFF1E1B29)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.all(48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.psychology, size: 64, color: MailMindTheme.accent),
                    const SizedBox(height: 24),
                    Text(
                      'MailMind AI',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 36, letterSpacing: 1),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'The Intelligent Operating System for Multi-Account Inbox Management.',
                      style: TextStyle(fontSize: 18, color: Colors.white70, height: 1.4),
                    ),
                    const SizedBox(height: 48),
                    _buildPromoBullet(Icons.auto_awesome, 'Unified AI Inbox aggregates and categorizes emails dynamically'),
                    _buildPromoBullet(Icons.timeline, 'Automatic job & internship application milestones tracker'),
                    _buildPromoBullet(Icons.gpp_bad, 'Security scan guards isolating phishing scams and malicious attachments'),
                    _buildPromoBullet(Icons.calendar_today, 'AI Deadline Extraction & Smart Calendar integration events'),
                  ],
                ),
              ),
            ),

          // Login Form Column
          Expanded(
            flex: 4,
            child: Container(
              color: MailMindTheme.background,
              padding: const EdgeInsets.symmetric(horizontal: 48),
              alignment: Alignment.center,
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: MailMindTheme.glassBox(color: const Color(0xFF16161A)),
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Welcome Back',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Log in to explore your email intelligence workspace.',
                        style: TextStyle(fontSize: 12, color: MailMindTheme.textMuted),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      TextField(
                        controller: _userCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          prefixIcon: Icon(Icons.person_outline, size: 18),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passCtrl,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock_outline, size: 18),
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (_isLoading)
                        const Center(child: CircularProgressIndicator(color: MailMindTheme.accent))
                      else
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: MailMindTheme.accent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: _handleLogin,
                          child: const Text('Log In', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      const SizedBox(height: 16),
                      const Text(
                        'Demo Mode: credentials are prefilled.',
                        style: TextStyle(color: MailMindTheme.textMuted, fontSize: 10),
                        textAlign: TextAlign.center,
                      )
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPromoBullet(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: MailMindTheme.accent, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: MailMindTheme.textMuted, height: 1.4),
            ),
          )
        ],
      ),
    );
  }
}
