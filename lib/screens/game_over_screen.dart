import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';

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
      await context.read<GameProvider>().fetchScoreboard();
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
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 28),
                      // Trophy
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppTheme.primaryGradient,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withOpacity(0.4),
                              blurRadius: 30,
                              spreadRadius: 8,
                            )
                          ],
                        ),
                        child: const Icon(Icons.emoji_events,
                            color: Colors.white, size: 56),
                      )
                          .animate()
                          .scale(
                              begin: const Offset(0, 0),
                              duration: 700.ms,
                              curve: Curves.elasticOut)
                          .fadeIn(),
                      const SizedBox(height: 16),
                      const Text(
                        'OYUN BİTDİ!',
                        style: TextStyle(
                          color: AppTheme.textMain,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4,
                        ),
                      ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.2),
                      const SizedBox(height: 6),
                      Text(
                        'Yekun hesab',
                        style: TextStyle(
                            color: AppTheme.textSub.withOpacity(0.7),
                            fontSize: 14),
                      ).animate(delay: 400.ms).fadeIn(),
                      const SizedBox(height: 28),
                    ],
                  ),
                ),
              ),

              // Scoreboard
              if (scores.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) {
                        final s = scores[i];
                        return ScoreRow(
                          rank: i + 1,
                          name: s.name,
                          spyWins: s.stats.spyWins,
                          civilWins: s.stats.civilWins,
                          totalPoints: s.stats.totalPoints,
                        );
                      },
                      childCount: scores.length,
                    ),
                  ),
                )
              else
                const SliverToBoxAdapter(
                  child: Center(
                      child: CircularProgressIndicator(
                          color: AppTheme.primary)),
                ),

              // Winner highlight
              if (scores.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    child: GlassCard(
                      borderColor: const Color(0xFFFFD700).withOpacity(0.4),
                      child: Row(
                        children: [
                          const Text('🏆', style: TextStyle(fontSize: 32)),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Qalib',
                                    style: TextStyle(
                                        color: AppTheme.textSub,
                                        fontSize: 12)),
                                Text(
                                  scores.first.name,
                                  style: const TextStyle(
                                    color: Color(0xFFFFD700),
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${scores.first.stats.totalPoints} xal',
                            style: const TextStyle(
                              color: Color(0xFFFFD700),
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ).animate(delay: 600.ms).fadeIn().scale(
                        begin: const Offset(0.9, 0.9)),
                  ),
                ),

              // Buttons
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                  child: Column(
                    children: [
                      if (gp.isHost)
                        GradientButton(
                          label: 'Yeni Oyun',
                          onTap: () {
                            gp.resetGame();
                            Navigator.pushNamedAndRemoveUntil(
                                context, '/create', (_) => false);
                          },
                          icon: Icons.refresh,
                        ).animate(delay: 700.ms).fadeIn().slideY(begin: 0.2),
                      const SizedBox(height: 12),
                      GradientButton(
                        label: 'Ana Menüyə Qayıt',
                        onTap: () {
                          gp.resetGame();
                          Navigator.pushNamedAndRemoveUntil(
                              context, '/menu', (_) => false);
                        },
                        gradient: LinearGradient(colors: [
                          Colors.white12,
                          Colors.white.withOpacity(0.05)
                        ]),
                        icon: Icons.home,
                      ).animate(delay: 800.ms).fadeIn().slideY(begin: 0.2),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
