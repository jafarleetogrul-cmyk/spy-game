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
  final _nameController = TextEditingController();
  int _maxPlayers = 6;
  int _spiesCount = 1;
  int _roundsCount = 3;
  int _roundTime = 5;

  @override
  void initState() {
    super.initState();
    _roundTime = context.read<GameProvider>().defaultRoundTime;
  }

  @override
  void dispose() { _nameController.dispose(); super.dispose(); }

  Future<void> _create() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(L.t('your_name')), backgroundColor: AppTheme.spyRed));
      return;
    }
    final gp = context.read<GameProvider>();
    try {
      await gp.createGame(
        creatorName: name, maxPlayers: _maxPlayers,
        spiesCount: _spiesCount, roundsCount: _roundsCount,
        roundTimeMinutes: _roundTime,
      );
      if (mounted) Navigator.pushReplacementNamed(context, '/lobby');
    } catch (_) {}
  }

  Widget _counter({required String label, required IconData icon, required int value, required int min, required int max, required ValueChanged<int> onChanged}) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(children: [
        Icon(icon, color: AppTheme.primary, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: const TextStyle(color: AppTheme.textMain, fontSize: 14, fontWeight: FontWeight.w500))),
        _CounterBtn(icon: Icons.remove, onTap: value > min ? () => onChanged(value - 1) : null),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('$value', style: const TextStyle(color: AppTheme.primary, fontSize: 22, fontWeight: FontWeight.w700)),
        ),
        _CounterBtn(icon: Icons.add, onTap: value < max ? () => onChanged(value + 1) : null),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gp = context.watch<GameProvider>();
    return LoadingOverlay(
      isLoading: gp.isLoading,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
          child: SafeArea(
            child: CustomScrollView(slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                leading: IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: () => Navigator.pop(context)),
                title: Text(L.t('create_game')),
                floating: true,
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList(delegate: SliverChildListDelegate([
                  const SizedBox(height: 8),
                  ErrorBanner(error: gp.lastError, onDismiss: gp.clearError),
                  GlassCard(
                    child: TextField(
                      controller: _nameController,
                      style: const TextStyle(color: AppTheme.textMain, fontSize: 16),
                      decoration: InputDecoration(
                        labelText: L.t('your_name'),
                        prefixIcon: const Icon(Icons.person, color: AppTheme.primary),
                        border: InputBorder.none, filled: false,
                      ),
                      textCapitalization: TextCapitalization.words,
                    ),
                  ).animate().fadeIn(delay: 100.ms),
                  const SizedBox(height: 12),
                  _counter(label: L.t('player_count'), icon: Icons.group, value: _maxPlayers, min: 3, max: 20,
                    onChanged: (v) => setState(() { _maxPlayers = v; if (_spiesCount >= v) _spiesCount = v - 1; }),
                  ).animate().fadeIn(delay: 180.ms),
                  const SizedBox(height: 10),
                  _counter(label: L.t('spy_count'), icon: Icons.person_search, value: _spiesCount, min: 1, max: _maxPlayers - 1,
                    onChanged: (v) => setState(() => _spiesCount = v),
                  ).animate().fadeIn(delay: 240.ms),
                  const SizedBox(height: 10),
                  _counter(label: L.t('round_count'), icon: Icons.refresh, value: _roundsCount, min: 1, max: 20,
                    onChanged: (v) => setState(() => _roundsCount = v),
                  ).animate().fadeIn(delay: 300.ms),
                  const SizedBox(height: 10),
                  _counter(label: L.t('round_time'), icon: Icons.timer, value: _roundTime, min: 1, max: 15,
                    onChanged: (v) => setState(() => _roundTime = v),
                  ).animate().fadeIn(delay: 360.ms),
                  const SizedBox(height: 16),
                  GlassCard(
                    borderColor: AppTheme.primary.withOpacity(0.3),
                    child: Row(children: [
                      const Icon(Icons.info_outline, color: AppTheme.primary, size: 18),
                      const SizedBox(width: 10),
                      const Expanded(child: Text(
                        'Şpion: məkanı bilmir, anlamağa çalışır (+2 xal)\nMülki: məkanı bilir, şpionu tapır (+1 xal)',
                        style: TextStyle(color: AppTheme.textSub, fontSize: 12, height: 1.5),
                      )),
                    ]),
                  ).animate().fadeIn(delay: 420.ms),
                  const SizedBox(height: 24),
                  GradientButton(label: L.t('create'), onTap: _create, icon: Icons.check_circle_outline)
                      .animate().fadeIn(delay: 480.ms).slideY(begin: 0.2),
                  const SizedBox(height: 24),
                ])),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class _CounterBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _CounterBtn({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: onTap != null ? AppTheme.primary.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(color: onTap != null ? AppTheme.primary.withOpacity(0.5) : Colors.grey.withOpacity(0.2)),
        ),
        child: Icon(icon, color: onTap != null ? AppTheme.primary : Colors.grey, size: 18),
      ),
    );
  }
}
