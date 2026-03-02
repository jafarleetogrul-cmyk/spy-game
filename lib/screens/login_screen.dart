import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import '../l10n/strings.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLogin = true;
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() { _userCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    final username = _userCtrl.text.trim();
    final password = _passCtrl.text.trim();

    if (username.length < 3) {
      _showSnack(L.t('username_error'), isError: true); return;
    }
    if (password.length < 4) {
      _showSnack(L.t('password_error'), isError: true); return;
    }

    final gp = context.read<GameProvider>();
    try {
      if (_isLogin) {
        await gp.login(username, password);
      } else {
        await gp.register(username, password);
      }
      if (mounted) Navigator.pushReplacementNamed(context, '/menu');
    } catch (e) {
      _showSnack(e.toString(), isError: true);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? AppTheme.spyRed : AppTheme.accent,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final gp = context.watch<GameProvider>();
    return LoadingOverlay(
      isLoading: gp.isLoading,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppTheme.bgGrad),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(children: [
                const SizedBox(height: 60),
                // Logo
                Container(
                  width: 90, height: 90,
                  decoration: BoxDecoration(shape: BoxShape.circle, gradient: AppTheme.primaryGrad,
                    boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.5), blurRadius: 30)]),
                  child: const Icon(Icons.visibility, color: Colors.white, size: 48),
                ).animate().scale(begin: const Offset(0,0), duration: 600.ms, curve: Curves.elasticOut),
                const SizedBox(height: 16),
                const Text('SPY GAME', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 6))
                  .animate(delay: 200.ms).fadeIn(),
                const SizedBox(height: 40),

                // Tab
                Container(
                  decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(14)),
                  child: Row(children: [
                    _Tab(label: L.t('login'), selected: _isLogin, onTap: () => setState(() => _isLogin = true)),
                    _Tab(label: L.t('register'), selected: !_isLogin, onTap: () => setState(() => _isLogin = false)),
                  ]),
                ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.2),
                const SizedBox(height: 24),

                // Fields
                GlassCard(
                  child: Column(children: [
                    TextField(
                      controller: _userCtrl,
                      style: const TextStyle(color: AppTheme.textMain),
                      decoration: InputDecoration(
                        labelText: L.t('username'),
                        prefixIcon: const Icon(Icons.person, color: AppTheme.primary),
                        border: InputBorder.none, filled: false,
                      ),
                      textCapitalization: TextCapitalization.none,
                      autocorrect: false,
                    ),
                    const Divider(color: Colors.white10),
                    TextField(
                      controller: _passCtrl,
                      obscureText: _obscure,
                      style: const TextStyle(color: AppTheme.textMain),
                      decoration: InputDecoration(
                        labelText: L.t('password'),
                        prefixIcon: const Icon(Icons.lock, color: AppTheme.primary),
                        suffixIcon: IconButton(
                          icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off, color: AppTheme.textSub, size: 20),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                        border: InputBorder.none, filled: false,
                      ),
                      onSubmitted: (_) => _submit(),
                    ),
                  ]),
                ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.2),
                const SizedBox(height: 20),

                GradientButton(
                  label: _isLogin ? L.t('login') : L.t('register'),
                  icon: _isLogin ? Icons.login : Icons.person_add,
                  onTap: _submit,
                ).animate(delay: 500.ms).fadeIn().slideY(begin: 0.2),
                const SizedBox(height: 20),

                TextButton(
                  onPressed: () => setState(() => _isLogin = !_isLogin),
                  child: Text(_isLogin ? L.t('no_account') : L.t('have_account'),
                    style: const TextStyle(color: AppTheme.primary, fontSize: 14)),
                ).animate(delay: 600.ms).fadeIn(),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label; final bool selected; final VoidCallback onTap;
  const _Tab({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => Expanded(child: GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        gradient: selected ? AppTheme.primaryGrad : null,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(label, textAlign: TextAlign.center, style: TextStyle(
        color: selected ? Colors.white : AppTheme.textSub,
        fontWeight: selected ? FontWeight.w700 : FontWeight.normal, fontSize: 15,
      )),
    ),
  ));
}
