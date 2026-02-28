import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import '../l10n/strings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _urlController;
  late String _selectedLang;
  late bool _sound;
  late bool _vibration;
  late int _roundTime;

  @override
  void initState() {
    super.initState();
    final gp = context.read<GameProvider>();
    _urlController = TextEditingController(text: gp.serverUrl);
    _selectedLang = gp.language;
    _sound = gp.soundEnabled;
    _vibration = gp.vibrationEnabled;
    _roundTime = gp.defaultRoundTime;
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await context.read<GameProvider>().saveSettings(
      lang: _selectedLang,
      sound: _sound,
      vibration: _vibration,
      url: _urlController.text.trim(),
      roundTime: _roundTime,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(L.t('settings_saved')), backgroundColor: AppTheme.accent),
      );
      Navigator.pop(context);
    }
  }

  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 10, top: 8),
    child: Text(text, style: const TextStyle(color: AppTheme.textSub, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 1)),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: CustomScrollView(slivers: [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              leading: IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: () => Navigator.pop(context)),
              title: Text(L.t('settings')),
              floating: true,
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverList(delegate: SliverChildListDelegate([
                const SizedBox(height: 8),

                // ── Language ──────────────────────────────
                _sectionTitle('🌐  ${L.t('language')}'),
                GlassCard(
                  padding: const EdgeInsets.all(8),
                  child: Row(children: [
                    _LangBtn(label: '🇦🇿 AZ', value: 'az', selected: _selectedLang, onTap: (v) => setState(() => _selectedLang = v)),
                    const SizedBox(width: 8),
                    _LangBtn(label: '🇷🇺 RU', value: 'ru', selected: _selectedLang, onTap: (v) => setState(() => _selectedLang = v)),
                    const SizedBox(width: 8),
                    _LangBtn(label: '🇬🇧 EN', value: 'en', selected: _selectedLang, onTap: (v) => setState(() => _selectedLang = v)),
                  ]),
                ).animate().fadeIn(delay: 100.ms),
                const SizedBox(height: 16),

                // ── Sound & Vibration ─────────────────────
                _sectionTitle('🔊  ${L.t('sound')} & ${L.t('vibration')}'),
                GlassCard(
                  child: Column(children: [
                    _ToggleRow(
                      icon: Icons.volume_up, label: L.t('sound'),
                      value: _sound, onChanged: (v) => setState(() => _sound = v),
                    ),
                    const Divider(color: Colors.white10, height: 20),
                    _ToggleRow(
                      icon: Icons.vibration, label: L.t('vibration'),
                      value: _vibration, onChanged: (v) => setState(() => _vibration = v),
                    ),
                  ]),
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 16),

                // ── Round Time ────────────────────────────
                _sectionTitle('⏱  ${L.t('round_time')}'),
                GlassCard(
                  child: Column(children: [
                    Row(children: [
                      const Icon(Icons.timer, color: AppTheme.primary, size: 20),
                      const SizedBox(width: 12),
                      Expanded(child: Text('$_roundTime dəqiqə', style: const TextStyle(color: AppTheme.textMain, fontSize: 15))),
                      _CounterMini(value: _roundTime, min: 1, max: 15,
                        onChanged: (v) => setState(() => _roundTime = v)),
                    ]),
                  ]),
                ).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 16),

                // ── Server URL ────────────────────────────
                _sectionTitle('🖥  ${L.t('server_url')}'),
                GlassCard(
                  child: TextField(
                    controller: _urlController,
                    style: const TextStyle(color: AppTheme.textMain, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'http://192.168.1.100:8080',
                      prefixIcon: const Icon(Icons.dns, color: AppTheme.primary),
                      border: InputBorder.none, filled: false,
                    ),
                    keyboardType: TextInputType.url,
                  ),
                ).animate().fadeIn(delay: 400.ms),
                const SizedBox(height: 24),

                GradientButton(label: L.t('save'), onTap: _save, icon: Icons.save)
                    .animate().fadeIn(delay: 500.ms),
                const SizedBox(height: 24),
              ])),
            ),
          ]),
        ),
      ),
    );
  }
}

class _LangBtn extends StatelessWidget {
  final String label, value, selected;
  final ValueChanged<String> onTap;
  const _LangBtn({required this.label, required this.value, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selected;
    return Expanded(child: GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected ? AppTheme.primaryGradient : null,
          color: isSelected ? null : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(label, textAlign: TextAlign.center, style: TextStyle(
          color: isSelected ? Colors.white : AppTheme.textSub,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal, fontSize: 13,
        )),
      ),
    ));
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _ToggleRow({required this.icon, required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, color: AppTheme.primary, size: 20),
      const SizedBox(width: 12),
      Expanded(child: Text(label, style: const TextStyle(color: AppTheme.textMain, fontSize: 15))),
      Switch(value: value, onChanged: onChanged, activeColor: AppTheme.primary),
    ]);
  }
}

class _CounterMini extends StatelessWidget {
  final int value, min, max;
  final ValueChanged<int> onChanged;
  const _CounterMini({required this.value, required this.min, required this.max, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      _btn(Icons.remove, value > min ? () => onChanged(value - 1) : null),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text('$value', style: const TextStyle(color: AppTheme.primary, fontSize: 18, fontWeight: FontWeight.w700)),
      ),
      _btn(Icons.add, value < max ? () => onChanged(value + 1) : null),
    ]);
  }

  Widget _btn(IconData icon, VoidCallback? onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 30, height: 30,
      decoration: BoxDecoration(
        color: onTap != null ? AppTheme.primary.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(color: onTap != null ? AppTheme.primary.withOpacity(0.5) : Colors.grey.withOpacity(0.2)),
      ),
      child: Icon(icon, color: onTap != null ? AppTheme.primary : Colors.grey, size: 16),
    ),
  );
}
