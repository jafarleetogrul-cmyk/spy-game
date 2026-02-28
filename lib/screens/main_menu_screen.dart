import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import '../l10n/strings.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<GameProvider>();
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(children: [
              const Spacer(flex: 2),
              // Logo
              Column(children: [
                Container(
                  width: 110, height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle, gradient: AppTheme.primaryGradient,
                    boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.5), blurRadius: 40, spreadRadius: 8)],
                  ),
                  child: const Icon(Icons.visibility, color: Colors.white, size: 58),
                ).animate().scale(begin: const Offset(0, 0), duration: 600.ms, curve: Curves.elasticOut).fadeIn(),
                const SizedBox(height: 20),
                Text('SPY GAME',
                  style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w900,
                    letterSpacing: 6, shadows: [Shadow(color: AppTheme.primary.withOpacity(0.5), blurRadius: 20)]),
                ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2),
                const SizedBox(height: 6),
                Text(L.t('tagline'), style: const TextStyle(color: AppTheme.textSub, fontSize: 14)).animate(delay: 300.ms).fadeIn(),
              ]),
              const Spacer(flex: 2),
              // Main buttons
              GradientButton(
                label: L.t('create_game'), icon: Icons.add_circle_outline,
                onTap: () => Navigator.pushNamed(context, '/create'),
              ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.3),
              const SizedBox(height: 14),
              GradientButton(
                label: L.t('join_game'), icon: Icons.qr_code_scanner,
                gradient: LinearGradient(colors: [AppTheme.secondary, AppTheme.secondary.withOpacity(0.7)]),
                onTap: () => Navigator.pushNamed(context, '/join'),
              ).animate(delay: 500.ms).fadeIn().slideY(begin: 0.3),
              const Spacer(),
              // Secondary buttons row
              Row(children: [
                Expanded(child: _SecondaryBtn(icon: Icons.leaderboard, label: L.t('leaderboard'), route: '/leaderboard')),
                const SizedBox(width: 10),
                Expanded(child: _SecondaryBtn(icon: Icons.history, label: L.t('history'), route: '/history')),
                const SizedBox(width: 10),
                Expanded(child: _SecondaryBtn(icon: Icons.settings, label: L.t('settings'), route: '/settings')),
              ]).animate(delay: 700.ms).fadeIn(),
              const SizedBox(height: 24),
            ]),
          ),
        ),
      ),
    );
  }
}

class _SecondaryBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  const _SecondaryBtn({required this.icon, required this.label, required this.route});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: AppTheme.primary, size: 24),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: AppTheme.textSub, fontSize: 11), textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}
