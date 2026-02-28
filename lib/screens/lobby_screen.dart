import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../providers/game_provider.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import '../l10n/strings.dart';

class LobbyScreen extends StatefulWidget {
  const LobbyScreen({super.key});
  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<GameProvider>().startPolling());
  }

  @override
  void dispose() {
    context.read<GameProvider>().stopPolling();
    super.dispose();
  }

  Future<void> _startGame() async {
    final gp = context.read<GameProvider>();
    try {
      await gp.startGame();
      if (mounted) {
        gp.stopPolling();
        await gp.fetchMyCard();
        if (mounted) Navigator.pushReplacementNamed(context, '/role_card');
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final gp = context.watch<GameProvider>();
    final session = gp.session;
    final state = gp.roomState;

    if (state?.status == RoomStatus.playing && !gp.isHost) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        gp.stopPolling();
        await gp.fetchMyCard();
        if (mounted) Navigator.pushReplacementNamed(context, '/role_card');
      });
    }

    final players = state?.players ?? [];
    final canStart = gp.isHost && players.length >= 3;
    final qrData = gp.buildJoinQrData();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: LoadingOverlay(
            isLoading: gp.isLoading,
            child: CustomScrollView(slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                automaticallyImplyLeading: false,
                title: Text('Lobby – ${session?.roomCode ?? ''}', style: const TextStyle(letterSpacing: 2)),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.exit_to_app, color: Colors.white70),
                    onPressed: () { gp.resetGame(); Navigator.pushNamedAndRemoveUntil(context, '/menu', (_) => false); },
                  ),
                ],
                floating: true,
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList(delegate: SliverChildListDelegate([
                  ErrorBanner(error: gp.lastError, onDismiss: gp.clearError),
                  // QR Card
                  GlassCard(
                    borderColor: AppTheme.primary.withOpacity(0.3),
                    child: Column(children: [
                      Row(children: [
                        const Icon(Icons.qr_code_2, color: AppTheme.primary, size: 22),
                        const SizedBox(width: 8),
                        const Expanded(child: Text('Qoşulma QR Kodu', style: TextStyle(color: AppTheme.textMain, fontWeight: FontWeight.w600, fontSize: 16))),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: session?.roomCode ?? ''));
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(L.t('code_copied')), backgroundColor: AppTheme.accent));
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.primary.withOpacity(0.4))),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              Text(session?.roomCode ?? '', style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: 2)),
                              const SizedBox(width: 6),
                              const Icon(Icons.copy, size: 14, color: AppTheme.primary),
                            ]),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 16),
                      Center(child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                        child: qrData.isEmpty
                            ? const SizedBox(width: 200, height: 200, child: Center(child: CircularProgressIndicator()))
                            : QrImageView(data: qrData, version: QrVersions.auto, size: 200),
                      )),
                      const SizedBox(height: 8),
                      Text('Bu QR-i dostlarınıza göstərin', style: TextStyle(color: AppTheme.textSub.withOpacity(0.7), fontSize: 12)),
                    ]),
                  ).animate().fadeIn(delay: 100.ms),
                  const SizedBox(height: 20),
                  // Players
                  Row(children: [
                    Text(L.t('players'), style: const TextStyle(color: AppTheme.textMain, fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                      child: Text('${players.length}/${state?.maxPlayers ?? '?'}', style: const TextStyle(color: AppTheme.primary, fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ]).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 12),
                  ...players.asMap().entries.map((e) => PlayerTile(name: e.value.name, isHost: e.value.isHost, index: e.key)),
                  const SizedBox(height: 24),
                  if (gp.isHost)
                    Column(children: [
                      if (!canStart)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(L.t('need_3_players'), textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textSub.withOpacity(0.7), fontSize: 13)),
                        ),
                      GradientButton(label: L.t('start_game'), onTap: canStart ? _startGame : null, icon: Icons.play_arrow_rounded),
                    ]).animate().fadeIn(delay: 400.ms)
                  else
                    GlassCard(
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary.withOpacity(0.7))),
                        const SizedBox(width: 12),
                        Text(L.t('waiting_host'), style: const TextStyle(color: AppTheme.textSub, fontSize: 14)),
                      ]),
                    ).animate().fadeIn(delay: 400.ms),
                  const SizedBox(height: 28),
                ])),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
