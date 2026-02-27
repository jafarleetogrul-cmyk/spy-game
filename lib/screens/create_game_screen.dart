import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';

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

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showError('Adınızı daxil edin');
      return;
    }
    final gp = context.read<GameProvider>();
    try {
      await gp.createGame(
        creatorName: name,
        maxPlayers: _maxPlayers,
        spiesCount: _spiesCount,
        roundsCount: _roundsCount,
      );
      if (mounted) Navigator.pushReplacementNamed(context, '/lobby');
    } catch (_) {}
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppTheme.spyRed),
    );
  }

  Widget _counter({
    required String label,
    required int value,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
  }) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
              child: Text(label,
                  style: const TextStyle(
                      color: AppTheme.textMain,
                      fontSize: 15,
                      fontWeight: FontWeight.w500))),
          _CounterBtn(
            icon: Icons.remove,
            onTap: value > min ? () => onChanged(value - 1) : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '$value',
              style: const TextStyle(
                  color: AppTheme.primary,
                  fontSize: 22,
                  fontWeight: FontWeight.w700),
            ),
          ),
          _CounterBtn(
            icon: Icons.add,
            onTap: value < max ? () => onChanged(value + 1) : null,
          ),
        ],
      ),
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
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  title: const Text('Oyun Yarat'),
                  floating: true,
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 8),
                      ErrorBanner(
                          error: gp.lastError,
                          onDismiss: gp.clearError),
                      // Name field
                      GlassCard(
                        child: TextField(
                          controller: _nameController,
                          style: const TextStyle(
                              color: AppTheme.textMain, fontSize: 16),
                          decoration: const InputDecoration(
                            labelText: 'Adınız',
                            prefixIcon: Icon(Icons.person,
                                color: AppTheme.primary),
                            border: InputBorder.none,
                            filled: false,
                          ),
                          textCapitalization: TextCapitalization.words,
                        ),
                      ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
                      const SizedBox(height: 16),

                      // Counters
                      _counter(
                        label: 'Oyunçu sayı',
                        value: _maxPlayers,
                        min: 3,
                        max: 20,
                        onChanged: (v) {
                          setState(() {
                            _maxPlayers = v;
                            if (_spiesCount >= v) {
                              _spiesCount = v - 1;
                            }
                          });
                        },
                      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                      const SizedBox(height: 12),

                      _counter(
                        label: 'Şpion sayı',
                        value: _spiesCount,
                        min: 1,
                        max: _maxPlayers - 1,
                        onChanged: (v) => setState(() => _spiesCount = v),
                      ).animate().fadeIn(delay: 280.ms).slideY(begin: 0.1),
                      const SizedBox(height: 12),

                      _counter(
                        label: 'Raund sayı',
                        value: _roundsCount,
                        min: 1,
                        max: 20,
                        onChanged: (v) => setState(() => _roundsCount = v),
                      ).animate().fadeIn(delay: 360.ms).slideY(begin: 0.1),
                      const SizedBox(height: 8),

                      // Info card
                      GlassCard(
                        borderColor: AppTheme.primary.withOpacity(0.3),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline,
                                color: AppTheme.primary, size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Şpionlar məkanı bilmir. Mülkilər məkanı bilir. '
                                'Şpion kimi qazanmaq = 2 xal, mülki kimi = 1 xal.',
                                style: TextStyle(
                                    color: AppTheme.textSub.withOpacity(0.9),
                                    fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 440.ms),
                      const SizedBox(height: 24),

                      GradientButton(
                        label: 'Oyun Yarat',
                        onTap: _create,
                        icon: Icons.check_circle_outline,
                      ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),
                      const SizedBox(height: 24),
                    ]),
                  ),
                ),
              ],
            ),
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
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: onTap != null
              ? AppTheme.primary.withOpacity(0.2)
              : Colors.grey.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(
              color: onTap != null
                  ? AppTheme.primary.withOpacity(0.5)
                  : Colors.grey.withOpacity(0.2)),
        ),
        child: Icon(icon,
            color: onTap != null ? AppTheme.primary : Colors.grey,
            size: 18),
      ),
    );
  }
}
