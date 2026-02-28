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
    final gp = context.watch<GameProvider>();
    final user = gp.currentUser;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGrad),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(children: [
              const Spacer(flex: 1),
              // User info bar
              if (user != null)
                GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(children: [
                    CircleAvatar(
                      radius: 20, backgroundColor: AppTheme.primary,
                      child: Text(user.username[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(user.username, style: const TextStyle(color: AppTheme.textMain, fontWeight: FontWeight.w700, fontSize: 14)),
                      Text('${user.stats.totalPoints} xal • ${user.stats.gamesPlayed} oyun',
                        style: const TextStyle(color: AppTheme.textSub, fontSize: 11)),
                    ])),
                    IconButton(
                      icon: const Icon(Icons.logout, color: AppTheme.textSub, size: 20),
                      onPressed: () async {
                        await gp.logout();
                        if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
                      },
                    ),
                  ]),
                ).animate().fadeIn(delay: 100.ms),
              const Spacer(flex: 1),
              // Logo
              Column(children: [
                Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(shape: BoxShape.circle, gradient: AppTheme.primaryGrad,
                    boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.5), blurRadius: 40, spreadRadius: 8)]),
                  child: const Icon(Icons.visibility, color: Colors.white, size: 54),
                ).animate().scale(begin: const Offset(0,0), duration: 600.ms, curve: Curves.elasticOut).fadeIn(),
                const SizedBox(height: 16),
                Text('SPY GAME', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: 6,
                  shadows: [Shadow(color: AppTheme.primary.withOpacity(0.5), blurRadius: 20)]))
                  .animate(delay: 200.ms).fadeIn(),
                Text(L.t('tagline'), style: const TextStyle(color: AppTheme.textSub, fontSize: 13))
                  .animate(delay: 300.ms).fadeIn(),
              ]),
              const Spacer(flex: 2),
              GradientButton(label: L.t('create_game'), icon: Icons.add_circle_outline,
                onTap: () => Navigator.pushNamed(context, '/create'))
                .animate(delay: 400.ms).fadeIn().slideY(begin: 0.3),
              const SizedBox(height: 14),
              GradientButton(label: L.t('join_game'), icon: Icons.qr_code_scanner,
                gradient: LinearGradient(colors: [AppTheme.secondary, AppTheme.secondary.withOpacity(0.7)]),
                onTap: () => Navigator.pushNamed(context, '/join'))
                .animate(delay: 500.ms).fadeIn().slideY(begin: 0.3),
              const Spacer(),
              Row(children: [
                Expanded(child: _SecBtn(icon: Icons.leaderboard, label: L.t('leaderboard'), route: '/leaderboard')),
                const SizedBox(width: 10),
                Expanded(child: _SecBtn(icon: Icons.settings, label: L.t('settings'), route: '/settings')),
              ]).animate(delay: 700.ms).fadeIn(),
              const SizedBox(height: 24),
            ]),
          ),
        ),
      ),
    );
  }
}

class _SecBtn extends StatelessWidget {
  final IconData icon; final String label, route;
  const _SecBtn({required this.icon, required this.label, required this.route});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => Navigator.pushNamed(context, route),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white.withOpacity(0.08))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: AppTheme.primary, size: 24),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: AppTheme.textSub, fontSize: 11), textAlign: TextAlign.center),
      ]),
    ),
  );
}
