import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_model.dart';
import '../services/storage_service.dart';
import '../theme.dart';
import 'home_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  Future<void> _signup() async {
    if (_nameCtrl.text.trim().isEmpty ||
        _emailCtrl.text.trim().isEmpty ||
        _passCtrl.text.isEmpty) {
      setState(() => _error = 'Please fill in all fields.');
      return;
    }
    if (_passCtrl.text.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters.');
      return;
    }

    setState(() { _loading = true; _error = null; });

    final exists =
    await StorageService.emailExists(_emailCtrl.text.trim());
    if (exists) {
      setState(() {
        _loading = false;
        _error = 'This email is already registered. Try logging in.';
      });
      return;
    }

    final user = UserModel(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
    );

    await StorageService.registerUser(user);
    await StorageService.saveSession(user);
    setState(() => _loading = false);

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => HomeScreen(user: user)),
          (route) => false,
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: AppTheme.primary,
        elevation: 0,
        leading: const BackButton(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                'Create Account 🎓',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Join your campus community',
                style: TextStyle(fontSize: 15, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 36),

              _label('Full name'),
              TextField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: 'Rahul Sharma',
                  prefixIcon: Icon(Icons.person_outline, size: 20),
                ),
              ),
              const SizedBox(height: 16),

              _label('College email'),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'rahul@college.edu',
                  prefixIcon: Icon(Icons.email_outlined, size: 20),
                ),
              ),
              const SizedBox(height: 16),

              _label('Password'),
              TextField(
                controller: _passCtrl,
                obscureText: _obscure,
                decoration: InputDecoration(
                  hintText: 'Min 6 characters',
                  prefixIcon:
                  const Icon(Icons.lock_outline, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _obscure = !_obscure),
                  ),
                ),
              ),

              if (_error != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.lostColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppTheme.lostColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    _error!,
                    style: const TextStyle(
                      color: AppTheme.lostColor,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 28),

              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _signup,
                child: const Text('Create Account'),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppTheme.primary,
      ),
    ),
  );
}