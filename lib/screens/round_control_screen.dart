import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/models.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import '../l10n/strings.dart';

class RoundControlScreen extends StatefulWidget {
  const RoundControlScreen({super.key});
  @override
  State<RoundControlScreen> createState() => _RoundControlScreenState();
}

class _RoundControlScreenState extends State<RoundControlScreen> {
  bool _timerStarted = false;

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

  void _startTimer() {
    final gp = context.read<GameProvider>();
    final minutes = gp.myCard?.roundTimeMinutes ?? gp.defaultRoundTime;
    gp.startCountdown(minutes);
    setState(() => _timerStarted = true);
    SoundService.buttonTap();
  }

  void _showWinnerDialog() {
    SoundService.buttonTap();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(L.t('who_won'), textAlign: TextAlign.center,
          style: const TextStyle(color: AppTheme.textMain, fontSize: 20, fontWeight: FontWeight.w700)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          _WinnerBtn(label: L.t('spies_won'), gradient: AppTheme.spyGradient, glowColor: AppTheme.spyRed, icon: Icons.person_search,
            onTap: () { Navigator.pop(context); _endRound('spies'); }),
          const SizedBox(height: 12),
          _WinnerBtn(label: L.t('civilians_won'), gradient: AppTheme.civilGradient, glowColor: AppTheme.civilBlue, icon: Icons.groups,
            onTap: () { Navigator.pop(context); _endRound('civilians'); }),
        ]),
        actions: [TextButton(onPressed: () => Navigator.pop(context),
          child: Text(L.t('cancel'), style: const TextStyle(color: AppTheme.textSub)))],
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
        await gp.saveGameToHistory();
        await SoundService.gameOver();
        Navigator.pushReplacementNamed(context, '/game_over');
      } else {
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

    // Non-host: watch for status changes
    if (state?.status == RoomStatus.finished && !isHost) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        gp.stopPolling();
        await gp.fetchScoreboard();
        await gp.saveGameToHistory();
        if (mounted) Navigator.pushReplacementNamed(context, '/game_over');
      });
    }
    final currentRound = state?.currentRound ?? 0;
    final cardRound = card?.roundNumber ?? 0;
    if (!isHost && currentRound > cardRound && currentRound > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        gp.stopPolling();
        await gp.fetchMyCard();
        setState(() => _timerStarted = false);
        if (mounted) Navigator.pushReplacementNamed(context, '/role_card');
      });
    }

    final isWarning = gp.countdownSeconds <= 30 && gp.countdownSeconds > 0;
    final isExpired = _timerStarted && !gp.timerRunning && gp.countdownSeconds == 0;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: LoadingOverlay(
            isLoading: gp.isLoading,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(children: [
                const SizedBox(height: 16),
                // Round header
                Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(L.t('round'), style: const TextStyle(color: AppTheme.textSub, fontSize: 13)),
                    Text('${state?.currentRound ?? card?.roundNumber ?? 1} / ${state?.roundsCount ?? card?.roundsCount ?? 1}',
                      style: const TextStyle(color: AppTheme.textMain, fontSize: 28, fontWeight: FontWeight.w800)),
                  ])),
                  if (card != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(gradient: card.isSpy ? AppTheme.spyGradient : AppTheme.civilGradient, borderRadius: BorderRadius.circular(20)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(card.isSpy ? Icons.person_search : Icons.location_on, color: Colors.white, size: 16),
                        const SizedBox(width: 6),
                        Text(card.isSpy ? L.t('spy') : L.t('civil'),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                      ]),
                    ),
                ]).animate().fadeIn(),
                const SizedBox(height: 16),
                ErrorBanner(error: gp.lastError, onDismiss: gp.clearError),

                // ── Timer ──────────────────────────────────────
                if (_timerStarted || isHost)
                  Column(children: [
                    if (_timerStarted)
                      CountdownTimerWidget(seconds: gp.countdownSeconds, isWarning: isWarning, expired: isExpired),
                    if (!_timerStarted && isHost)
                      GestureDetector(
                        onTap: _startTimer,
                        child: Container(
                          width: double.infinity, height: 52,
                          decoration: BoxDecoration(
                            color: AppTheme.card, borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppTheme.accent.withOpacity(0.4)),
                          ),
                          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            const Icon(Icons.timer, color: AppTheme.accent, size: 20),
                            const SizedBox(width: 8),
                            Text('Taymer başlat', style: const TextStyle(color: AppTheme.accent, fontSize: 15, fontWeight: FontWeight.w600)),
                          ]),
                        ),
                      ),
                    const SizedBox(height: 14),
                  ]).animate().fadeIn(delay: 100.ms),

                if (isExpired)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppTheme.spyRed.withOpacity(0.15), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.spyRed.withOpacity(0.5))),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.warning, color: AppTheme.spyRed, size: 18),
                      const SizedBox(width: 8),
                      Text(L.t('time_up'), style: const TextStyle(color: AppTheme.spyRed, fontSize: 14, fontWeight: FontWeight.w700)),
                    ]),
                  ).animate().shake().fadeIn(),

                // ── Role reminder ──────────────────────────────
                if (card != null)
                  GlassCard(
                    borderColor: (card.isSpy ? AppTheme.spyRed : AppTheme.civilBlue).withOpacity(0.3),
                    child: Column(children: [
                      Icon(card.isSpy ? Icons.person_search : Icons.location_on,
                        color: card.isSpy ? AppTheme.spyRed : AppTheme.civilBlue, size: 36),
                      const SizedBox(height: 10),
                      Text(card.isSpy ? L.t('you_are_spy') : '${L.t('location')}: ${card.place}',
                        style: TextStyle(color: card.isSpy ? AppTheme.spyRed : AppTheme.civilBlue,
                          fontSize: 20, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 6),
                      Text(card.isSpy ? L.t('find_location') : L.t('find_spy'),
                        style: TextStyle(color: AppTheme.textSub.withOpacity(0.8), fontSize: 13)),
                    ]),
                  ).animate(delay: 100.ms).fadeIn(),

                const SizedBox(height: 12),

                // Players compact
                GlassCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${L.t('players')} (${state?.players.length ?? 0})',
                      style: const TextStyle(color: AppTheme.textSub, fontSize: 13, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: (state?.players ?? []).map((p) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: p.playerId == gp.session?.playerId ? AppTheme.primary.withOpacity(0.25) : Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: p.playerId == gp.session?.playerId ? AppTheme.primary.withOpacity(0.5) : Colors.transparent),
                        ),
                        child: Text(p.name, style: TextStyle(
                          color: p.playerId == gp.session?.playerId ? AppTheme.primary : AppTheme.textMain,
                          fontSize: 13, fontWeight: p.playerId == gp.session?.playerId ? FontWeight.w700 : FontWeight.normal)),
                      )).toList(),
                    ),
                  ]),
                ).animate(delay: 200.ms).fadeIn(),

                const Spacer(),

                // Host buttons
                if (isHost) ...[
                  GradientButton(
                    label: L.t('end_round'), icon: Icons.flag, onTap: _showWinnerDialog,
                    gradient: const LinearGradient(colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)]),
                  ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.2),
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: () { gp.resetGame(); Navigator.pushNamedAndRemoveUntil(context, '/menu', (_) => false); },
                    icon: const Icon(Icons.exit_to_app, color: AppTheme.textSub, size: 16),
                    label: Text(L.t('leave'), style: const TextStyle(color: AppTheme.textSub, fontSize: 13)),
                  ),
                ] else ...[
                  GlassCard(
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary.withOpacity(0.7))),
                      const SizedBox(width: 12),
                      Text(L.t('waiting_round_end'), style: const TextStyle(color: AppTheme.textSub, fontSize: 14)),
                    ]),
                  ).animate(delay: 300.ms).fadeIn(),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () { gp.resetGame(); Navigator.pushNamedAndRemoveUntil(context, '/menu', (_) => false); },
                    child: Text(L.t('leave'), style: const TextStyle(color: AppTheme.textSub)),
                  ),
                ],
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class _WinnerBtn extends StatelessWidget {
  final String label;
  final LinearGradient gradient;
  final Color glowColor;
  final IconData icon;
  final VoidCallback onTap;
  const _WinnerBtn({required this.label, required this.gradient, required this.glowColor, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: gradient, borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: glowColor.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }
}
