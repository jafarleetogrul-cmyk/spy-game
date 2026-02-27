import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';

class RoundControlScreen extends StatefulWidget {
  const RoundControlScreen({super.key});

  @override
  State<RoundControlScreen> createState() => _RoundControlScreenState();
}

class _RoundControlScreenState extends State<RoundControlScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameProvider>().startPolling();
    });
  }

  @override
  void dispose() {
    context.read<GameProvider>().stopPolling();
    super.dispose();
  }

  void _showWinnerDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Kim uddu?',
          style: TextStyle(
              color: AppTheme.textMain,
              fontSize: 20,
              fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Spies won
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                _endRound('spies');
              },
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: AppTheme.spyGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.spyRed.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_search, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Şpionlar Uddu!',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
            // Civilians won
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                _endRound('civilians');
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: AppTheme.civilGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.civilBlue.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.groups, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Mülkilər Uddu!',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ləğv et',
                style: TextStyle(color: AppTheme.textSub)),
          )
        ],
      ),
    );
  }

  Future<void> _endRound(String winner) async {
    final gp = context.read<GameProvider>();
    try {
      final finished = await gp.endRound(winner);
      if (!mounted) return;
      if (finished) {
        await gp.fetchScoreboard();
        Navigator.pushReplacementNamed(context, '/game_over');
      } else {
        // Show next role card
        await gp.fetchMyCard();
        Navigator.pushReplacementNamed(context, '/role_card');
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final gp = context.watch<GameProvider>();
    final state = gp.roomState;
    final card = gp.myCard;
    final isHost = gp.isHost;

    // Non-host: watch for game state changes
    if (state?.status == RoomStatus.finished && !isHost) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        gp.stopPolling();
        await gp.fetchScoreboard();
        if (mounted) Navigator.pushReplacementNamed(context, '/game_over');
      });
    }

    // If playing and round changed (non-host), get new card
    final currentRound = state?.currentRound ?? 0;
    final cardRound = card?.roundNumber ?? 0;
    if (!isHost && currentRound > cardRound && currentRound > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        gp.stopPolling();
        await gp.fetchMyCard();
        if (mounted) Navigator.pushReplacementNamed(context, '/role_card');
      });
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: LoadingOverlay(
            isLoading: gp.isLoading,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  // Header
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Raund',
                                style: TextStyle(
                                    color: AppTheme.textSub, fontSize: 13)),
                            Text(
                              '${state?.currentRound ?? card?.roundNumber ?? 1} / ${state?.roundsCount ?? card?.roundsCount ?? 1}',
                              style: const TextStyle(
                                  color: AppTheme.textMain,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ),
                      // Role badge
                      if (card != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: card.isSpy
                                ? AppTheme.spyGradient
                                : AppTheme.civilGradient,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                  card.isSpy
                                      ? Icons.person_search
                                      : Icons.location_on,
                                  color: Colors.white,
                                  size: 16),
                              const SizedBox(width: 6),
                              Text(
                                card.isSpy ? 'Şpion' : 'Mülki',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ).animate().fadeIn(),

                  const SizedBox(height: 24),
                  ErrorBanner(
                      error: gp.lastError, onDismiss: gp.clearError),

                  // Role reminder
                  if (card != null)
                    GlassCard(
                      borderColor: (card.isSpy
                              ? AppTheme.spyRed
                              : AppTheme.civilBlue)
                          .withOpacity(0.3),
                      child: Column(
                        children: [
                          Icon(
                            card.isSpy
                                ? Icons.person_search
                                : Icons.location_on,
                            color: card.isSpy
                                ? AppTheme.spyRed
                                : AppTheme.civilBlue,
                            size: 36,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            card.isSpy
                                ? 'Sən ŞPİONSAN'
                                : 'Məkan: ${card.place}',
                            style: TextStyle(
                              color: card.isSpy
                                  ? AppTheme.spyRed
                                  : AppTheme.civilBlue,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (!card.isSpy) ...[
                            const SizedBox(height: 6),
                            Text(
                              'Şpionu tap!',
                              style: TextStyle(
                                  color: AppTheme.textSub.withOpacity(0.8),
                                  fontSize: 13),
                            ),
                          ] else ...[
                            const SizedBox(height: 6),
                            Text(
                              'Məkanı anlamağa çalış!',
                              style: TextStyle(
                                  color: AppTheme.textSub.withOpacity(0.8),
                                  fontSize: 13),
                            ),
                          ],
                        ],
                      ),
                    ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.1),

                  const SizedBox(height: 20),

                  // Player list (compact)
                  GlassCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Oyunçular (${state?.players.length ?? 0})',
                          style: const TextStyle(
                              color: AppTheme.textSub,
                              fontSize: 13,
                              fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: (state?.players ?? [])
                              .map((p) => Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: p.playerId ==
                                              gp.session?.playerId
                                          ? AppTheme.primary
                                              .withOpacity(0.25)
                                          : Colors.white.withOpacity(0.06),
                                      borderRadius:
                                          BorderRadius.circular(20),
                                      border: Border.all(
                                          color: p.playerId ==
                                                  gp.session?.playerId
                                              ? AppTheme.primary
                                                  .withOpacity(0.5)
                                              : Colors.transparent),
                                    ),
                                    child: Text(
                                      p.name,
                                      style: TextStyle(
                                          color: p.playerId ==
                                                  gp.session?.playerId
                                              ? AppTheme.primary
                                              : AppTheme.textMain,
                                          fontSize: 13,
                                          fontWeight: p.playerId ==
                                                  gp.session?.playerId
                                              ? FontWeight.w700
                                              : FontWeight.normal),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                  ).animate(delay: 200.ms).fadeIn(),

                  const Spacer(),

                  // Host controls
                  if (isHost) ...[
                    GradientButton(
                      label: 'Raundu Bitir',
                      onTap: _showWinnerDialog,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                      ),
                      icon: Icons.flag,
                    ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.2),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: () {
                        gp.resetGame();
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/menu', (_) => false);
                      },
                      icon: const Icon(Icons.exit_to_app,
                          color: AppTheme.textSub, size: 16),
                      label: const Text('Oyundan çıx',
                          style: TextStyle(
                              color: AppTheme.textSub, fontSize: 13)),
                    ),
                  ] else ...[
                    GlassCard(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.primary.withOpacity(0.7)),
                          ),
                          const SizedBox(width: 12),
                          const Text('Host raundu bitirməsini gözlə…',
                              style: TextStyle(
                                  color: AppTheme.textSub, fontSize: 14)),
                        ],
                      ),
                    ).animate(delay: 300.ms).fadeIn(),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        gp.resetGame();
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/menu', (_) => false);
                      },
                      child: const Text('Çıx',
                          style: TextStyle(color: AppTheme.textSub)),
                    ),
                  ],
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
