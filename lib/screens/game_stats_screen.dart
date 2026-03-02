import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import '../l10n/strings.dart';

class GameStatsScreen extends StatelessWidget {
  const GameStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gp = context.watch<GameProvider>();
    final scores = gp.scoreboard;
    final rounds = gp.roundResults;
    final myId   = gp.session?.playerId ?? '';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGrad),
        child: SafeArea(
          child: CustomScrollView(slivers: [
            SliverToBoxAdapter(child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(children: [
                const SizedBox(height: 24),
                Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(shape: BoxShape.circle, gradient: AppTheme.goldGrad,
                    boxShadow: [BoxShadow(color: AppTheme.gold.withOpacity(0.5), blurRadius: 40, spreadRadius: 10)]),
                  child: const Icon(Icons.emoji_events, color: Colors.white, size: 56),
                ).animate().scale(begin: const Offset(0,0), duration: 800.ms, curve: Curves.elasticOut),
                const SizedBox(height: 14),
                Text(L.t('game_over'), style: const TextStyle(color: AppTheme.textMain, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 4))
                  .animate(delay: 300.ms).fadeIn().slideY(begin: 0.2),
                const SizedBox(height: 24),
              ]),
            )),

            // ── Scoreboard ───────────────────────────────────
            if (scores.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList(delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                    final s = scores[i];
                    final isMe = s.playerId == myId;
                    final medals = ['🥇','🥈','🥉'];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        gradient: i == 0 ? const LinearGradient(colors: [Color(0xFF2D2500), Color(0xFF3D3000)]) : null,
                        color: i == 0 ? null : isMe ? AppTheme.primary.withOpacity(0.15) : AppTheme.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: i == 0 ? AppTheme.gold.withOpacity(0.5) : isMe ? AppTheme.primary.withOpacity(0.4) : Colors.white.withOpacity(0.06))),
                      child: Row(children: [
                        Text(i < 3 ? medals[i] : '${i+1}.', style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            Text(s.name, style: TextStyle(color: i==0 ? AppTheme.gold : AppTheme.textMain, fontWeight: FontWeight.w700, fontSize: 15)),
                            if (isMe) ...[const SizedBox(width: 6), Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.3), borderRadius: BorderRadius.circular(10)),
                              child: const Text('Sən', style: TextStyle(color: AppTheme.primary, fontSize: 10, fontWeight: FontWeight.w700)))],
                          ]),
                          const SizedBox(height: 3),
                          Text('🕵️ ${s.stats.spyWins}  👥 ${s.stats.civilWins}', style: const TextStyle(color: AppTheme.textSub, fontSize: 12)),
                        ])),
                        Text('${s.stats.totalPoints}', style: TextStyle(color: i==0 ? AppTheme.gold : AppTheme.accent, fontSize: 22, fontWeight: FontWeight.w900)),
                        Text(' ${L.t('points')}', style: const TextStyle(color: AppTheme.textSub, fontSize: 12)),
                      ]),
                    ).animate().fadeIn(delay: (i*80).ms).slideY(begin: 0.1);
                  },
                  childCount: scores.length,
                )),
              ),

            // ── Round details ─────────────────────────────────
            if (rounds.isNotEmpty)
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: Text(L.t('game_stats'), style: const TextStyle(color: AppTheme.textMain, fontSize: 18, fontWeight: FontWeight.w700))
                  .animate().fadeIn(delay: 400.ms),
              )),
            if (rounds.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList(delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                    final r = rounds[i];
                    final spyNames = r.spies.map((sid) {
                      final p = gp.roomState?.players.where((pl) => pl.playerId == sid).firstOrNull;
                      return p?.name ?? sid.substring(0,6);
                    }).join(', ');
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white.withOpacity(0.06))),
                      child: Row(children: [
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(shape: BoxShape.circle, gradient: r.winner == 'spies' ? AppTheme.spyGrad : AppTheme.civilGrad),
                          child: Center(child: Text('${r.round}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)))),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(r.winner == 'spies' ? '🕵️ ${L.t('spies_won')}' : '👥 ${L.t('civilians_won')}',
                            style: TextStyle(color: r.winner == 'spies' ? AppTheme.spyRed : AppTheme.civilBlue, fontWeight: FontWeight.w700, fontSize: 13)),
                          const SizedBox(height: 2),
                          Text('📍 ${r.place}', style: const TextStyle(color: AppTheme.textSub, fontSize: 12)),
                          if (spyNames.isNotEmpty) Text('🕵️ $spyNames', style: const TextStyle(color: AppTheme.textSub, fontSize: 11)),
                        ])),
                      ]),
                    ).animate().fadeIn(delay: (i*60+500).ms);
                  },
                  childCount: rounds.length,
                )),
              ),

            // ── Buttons ───────────────────────────────────────
            SliverToBoxAdapter(child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Row(children: [
                Expanded(child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/leaderboard'),
                  child: Container(height: 52,
                    decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.primary.withOpacity(0.3))),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.leaderboard, color: AppTheme.primary, size: 22),
                      Text(L.t('leaderboard'), style: const TextStyle(color: AppTheme.textSub, fontSize: 11)),
                    ])),
                )),
              ]).animate(delay: 600.ms).fadeIn(),
            )),
            SliverToBoxAdapter(child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
              child: GradientButton(label: L.t('new_game'), icon: Icons.refresh, onTap: () {
                gp.resetGame(); Navigator.pushNamedAndRemoveUntil(context, '/create', (_) => false);
              }).animate(delay: 700.ms).fadeIn().slideY(begin: 0.2),
            )),
            SliverToBoxAdapter(child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: GradientButton(label: L.t('back_to_menu'), icon: Icons.home,
                gradient: LinearGradient(colors: [Colors.white12, Colors.white.withOpacity(0.05)]),
                onTap: () { gp.resetGame(); Navigator.pushNamedAndRemoveUntil(context, '/menu', (_) => false); })
                .animate(delay: 800.ms).fadeIn(),
            )),
          ]),
        ),
      ),
    );
  }
}
