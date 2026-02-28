import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import '../l10n/strings.dart';

class GameOverScreen extends StatefulWidget {
  const GameOverScreen({super.key});
  @override
  State<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final gp = context.read<GameProvider>();
      if (gp.scoreboard.isEmpty) await gp.fetchScoreboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final gp = context.watch<GameProvider>();
    final scores = gp.scoreboard;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: CustomScrollView(slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(children: [
                  const SizedBox(height: 28),
                  // Trophy
                  Container(
                    width: 110, height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppTheme.goldGradient,
                      boxShadow: [BoxShadow(color: AppTheme.gold.withOpacity(0.5), blurRadius: 40, spreadRadius: 10)],
                    ),
                    child: const Icon(Icons.emoji_events, color: Colors.white, size: 60),
                  ).animate().scale(begin: const Offset(0, 0), duration: 800.ms, curve: Curves.elasticOut).fadeIn(),
                  const SizedBox(height: 16),
                  Text(L.t('game_over'),
                    style: const TextStyle(color: AppTheme.textMain, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 4),
                  ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.2),
                  const SizedBox(height: 6),
                  Text(L.t('final_score'), style: TextStyle(color: AppTheme.textSub.withOpacity(0.7), fontSize: 14))
                      .animate(delay: 400.ms).fadeIn(),
                  const SizedBox(height: 28),
                ]),
              ),
            ),

            // Scoreboard
            if (scores.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList(delegate: SliverChildBuilderDelegate(
                  (ctx, i) => ScoreRow(
                    rank: i + 1, name: scores[i].name,
                    spyWins: scores[i].stats.spyWins,
                    civilWins: scores[i].stats.civilWins,
                    totalPoints: scores[i].stats.totalPoints,
                  ),
                  childCount: scores.length,
                )),
              )
            else
              const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator(color: AppTheme.primary))),

            // Winner highlight
            if (scores.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: GlassCard(
                    borderColor: AppTheme.gold.withOpacity(0.4),
                    child: Row(children: [
                      const Text('🏆', style: TextStyle(fontSize: 36)),
                      const SizedBox(width: 16),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(L.t('winner'), style: const TextStyle(color: AppTheme.textSub, fontSize: 12)),
                        Text(scores.first.name, style: const TextStyle(color: AppTheme.gold, fontSize: 22, fontWeight: FontWeight.w800)),
                      ])),
                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text('${scores.first.stats.totalPoints}', style: const TextStyle(color: AppTheme.gold, fontSize: 28, fontWeight: FontWeight.w900)),
                        Text(L.t('points'), style: const TextStyle(color: AppTheme.textSub, fontSize: 12)),
                      ]),
                    ]),
                  ).animate(delay: 600.ms).fadeIn().scale(begin: const Offset(0.9, 0.9)),
                ),
              ),

            // Buttons
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: Row(children: [
                  Expanded(child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/leaderboard'),
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.primary.withOpacity(0.3))),
                      child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.leaderboard, color: AppTheme.primary, size: 22),
                        SizedBox(height: 2),
                        Text('Liderboard', style: TextStyle(color: AppTheme.textSub, fontSize: 11)),
                      ]),
                    ),
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/history'),
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.accent.withOpacity(0.3))),
                      child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.history, color: AppTheme.accent, size: 22),
                        SizedBox(height: 2),
                        Text('Tarixçə', style: TextStyle(color: AppTheme.textSub, fontSize: 11)),
                      ]),
                    ),
                  )),
                ]).animate(delay: 700.ms).fadeIn(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                child: GradientButton(
                  label: L.t('new_game'), icon: Icons.refresh,
                  onTap: () {
                    gp.resetGame();
                    Navigator.pushNamedAndRemoveUntil(context, '/create', (_) => false);
                  },
                ).animate(delay: 800.ms).fadeIn().slideY(begin: 0.2),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: GradientButton(
                  label: L.t('back_to_menu'), icon: Icons.home,
                  gradient: LinearGradient(colors: [Colors.white12, Colors.white.withOpacity(0.05)]),
                  onTap: () {
                    gp.resetGame();
                    Navigator.pushNamedAndRemoveUntil(context, '/menu', (_) => false);
                  },
                ).animate(delay: 900.ms).fadeIn().slideY(begin: 0.2),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
