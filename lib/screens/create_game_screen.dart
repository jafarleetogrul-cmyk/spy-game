import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import '../l10n/strings.dart';

class CreateGameScreen extends StatefulWidget {
  const CreateGameScreen({super.key});
  @override
  State<CreateGameScreen> createState() => _CreateGameScreenState();
}

class _CreateGameScreenState extends State<CreateGameScreen> {
  int _max = 6, _spies = 1, _rounds = 3, _time = 5;

  @override
  void initState() {
    super.initState();
    _time = context.read<GameProvider>().defaultRoundTime;
  }

  Future<void> _create() async {
    final gp = context.read<GameProvider>();
    try {
      await gp.createGame(maxPlayers: _max, spiesCount: _spies, roundsCount: _rounds, roundTimeMinutes: _time);
      if (mounted) Navigator.pushReplacementNamed(context, '/lobby');
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final gp = context.watch<GameProvider>();
    return LoadingOverlay(
      isLoading: gp.isLoading,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppTheme.bgGrad),
          child: SafeArea(child: CustomScrollView(slivers: [
            SliverAppBar(backgroundColor: Colors.transparent, floating: true,
              leading: IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: () => Navigator.pop(context)),
              title: Text(L.t('create_game'))),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverList(delegate: SliverChildListDelegate([
                const SizedBox(height: 8),
                ErrorBanner(error: gp.lastError, onDismiss: gp.clearError),
                // User card
                GlassCard(
                  borderColor: AppTheme.primary.withOpacity(0.3),
                  child: Row(children: [
                    CircleAvatar(radius: 22, backgroundColor: AppTheme.primary,
                      child: Text((gp.currentUser?.username ?? '?')[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))),
                    const SizedBox(width: 12),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(gp.currentUser?.username ?? '', style: const TextStyle(color: AppTheme.textMain, fontWeight: FontWeight.w700, fontSize: 16)),
                      const Text('Host kimi oyun yaradırsın', style: TextStyle(color: AppTheme.textSub, fontSize: 12)),
                    ]),
                  ]),
                ).animate().fadeIn(delay: 100.ms),
                const SizedBox(height: 12),
                _counter(L.t('player_count'), Icons.group, _max, 3, 20, (v) => setState(() { _max=v; if(_spies>=v) _spies=v-1; })).animate().fadeIn(delay: 160.ms),
                const SizedBox(height: 10),
                _counter(L.t('spy_count'), Icons.person_search, _spies, 1, _max-1, (v) => setState(() => _spies=v)).animate().fadeIn(delay: 220.ms),
                const SizedBox(height: 10),
                _counter(L.t('round_count'), Icons.refresh, _rounds, 1, 20, (v) => setState(() => _rounds=v)).animate().fadeIn(delay: 280.ms),
                const SizedBox(height: 10),
                _counter(L.t('round_time'), Icons.timer, _time, 1, 15, (v) => setState(() => _time=v)).animate().fadeIn(delay: 340.ms),
                const SizedBox(height: 24),
                GradientButton(label: L.t('create'), icon: Icons.check_circle_outline, onTap: _create)
                  .animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
                const SizedBox(height: 24),
              ])),
            ),
          ])),
        ),
      ),
    );
  }

  Widget _counter(String label, IconData icon, int val, int min, int max, ValueChanged<int> onChange) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(children: [
        Icon(icon, color: AppTheme.primary, size: 20), const SizedBox(width: 12),
        Expanded(child: Text(label, style: const TextStyle(color: AppTheme.textMain, fontSize: 14, fontWeight: FontWeight.w500))),
        _CBtn(Icons.remove, val > min ? () => onChange(val-1) : null),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('$val', style: const TextStyle(color: AppTheme.primary, fontSize: 22, fontWeight: FontWeight.w700))),
        _CBtn(Icons.add, val < max ? () => onChange(val+1) : null),
      ]),
    );
  }
}

class _CBtn extends StatelessWidget {
  final IconData icon; final VoidCallback? onTap;
  const _CBtn(this.icon, this.onTap);
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 36, height: 36,
      decoration: BoxDecoration(
        color: onTap != null ? AppTheme.primary.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(color: onTap != null ? AppTheme.primary.withOpacity(0.5) : Colors.grey.withOpacity(0.2))),
      child: Icon(icon, color: onTap != null ? AppTheme.primary : Colors.grey, size: 18)),
  );
}
