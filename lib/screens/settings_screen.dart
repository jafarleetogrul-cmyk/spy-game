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
  late String _lang;
  late bool _sound, _vib;
  late int _roundTime;

  @override
  void initState() {
    super.initState();
    final gp = context.read<GameProvider>();
    _lang      = gp.language;
    _sound     = gp.soundEnabled;
    _vib       = gp.vibrationEnabled;
    _roundTime = gp.defaultRoundTime;
  }

  Future<void> _save() async {
    await context.read<GameProvider>().saveSettings(
      lang: _lang, sound: _sound, vibration: _vib, roundTime: _roundTime,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(L.t('settings_saved')), backgroundColor: AppTheme.accent));
      Navigator.pop(context);
    }
  }

  Widget _section(String text) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 8),
    child: Text(text, style: const TextStyle(color: AppTheme.textSub, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1)),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGrad),
        child: SafeArea(child: CustomScrollView(slivers: [
          SliverAppBar(backgroundColor: Colors.transparent, floating: true,
            leading: IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: () => Navigator.pop(context)),
            title: Text(L.t('settings'))),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList(delegate: SliverChildListDelegate([

              _section('🌐  ${L.t('language')}'),
              GlassCard(padding: const EdgeInsets.all(8),
                child: Row(children: [
                  _LBtn(label: '🇦🇿 AZ', val: 'az', sel: _lang, onTap: (v) => setState(() => _lang = v)),
                  const SizedBox(width: 8),
                  _LBtn(label: '🇷🇺 RU', val: 'ru', sel: _lang, onTap: (v) => setState(() => _lang = v)),
                  const SizedBox(width: 8),
                  _LBtn(label: '🇬🇧 EN', val: 'en', sel: _lang, onTap: (v) => setState(() => _lang = v)),
                ]),
              ).animate().fadeIn(delay: 100.ms),

              _section('🔊  ${L.t('sound')} & ${L.t('vibration')}'),
              GlassCard(child: Column(children: [
                _Toggle(icon: Icons.volume_up, label: L.t('sound'), val: _sound, onChanged: (v) => setState(() => _sound = v)),
                const Divider(color: Colors.white10, height: 20),
                _Toggle(icon: Icons.vibration, label: L.t('vibration'), val: _vib, onChanged: (v) => setState(() => _vib = v)),
              ])).animate().fadeIn(delay: 180.ms),

              _section('⏱  ${L.t('round_time')}'),
              GlassCard(child: Row(children: [
                const Icon(Icons.timer, color: AppTheme.primary, size: 20), const SizedBox(width: 12),
                Expanded(child: Text('$_roundTime dəqiqə', style: const TextStyle(color: AppTheme.textMain, fontSize: 15))),
                _CntBtn(Icons.remove, _roundTime > 1 ? () => setState(() => _roundTime--) : null),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('$_roundTime', style: const TextStyle(color: AppTheme.primary, fontSize: 18, fontWeight: FontWeight.w700))),
                _CntBtn(Icons.add, _roundTime < 15 ? () => setState(() => _roundTime++) : null),
              ])).animate().fadeIn(delay: 260.ms),

              // Server info - read only, dəyişdirilmir
              const SizedBox(height: 16),
              GlassCard(
                borderColor: AppTheme.accent.withOpacity(0.2),
                child: Row(children: [
                  const Icon(Icons.cloud_done, color: AppTheme.accent, size: 20),
                  const SizedBox(width: 12),
                  const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Server', style: TextStyle(color: AppTheme.textSub, fontSize: 11)),
                    Text('spygameserver.pythonanywhere.com',
                      style: TextStyle(color: AppTheme.textMain, fontSize: 12, fontWeight: FontWeight.w500)),
                  ])),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: AppTheme.accent.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                    child: const Text('AKTIV', style: TextStyle(color: AppTheme.accent, fontSize: 10, fontWeight: FontWeight.w700)),
                  ),
                ]),
              ).animate().fadeIn(delay: 320.ms),

              const SizedBox(height: 24),
              GradientButton(label: L.t('save'), icon: Icons.save, onTap: _save)
                .animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 32),
            ])),
          ),
        ])),
      ),
    );
  }
}

class _LBtn extends StatelessWidget {
  final String label, val, sel; final ValueChanged<String> onTap;
  const _LBtn({required this.label, required this.val, required this.sel, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final s = val == sel;
    return Expanded(child: GestureDetector(
      onTap: () => onTap(val),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: s ? AppTheme.primaryGrad : null,
          color: s ? null : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10)),
        child: Text(label, textAlign: TextAlign.center, style: TextStyle(
          color: s ? Colors.white : AppTheme.textSub,
          fontWeight: s ? FontWeight.w700 : FontWeight.normal, fontSize: 13)),
      ),
    ));
  }
}

class _Toggle extends StatelessWidget {
  final IconData icon; final String label; final bool val; final ValueChanged<bool> onChanged;
  const _Toggle({required this.icon, required this.label, required this.val, required this.onChanged});
  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, color: AppTheme.primary, size: 20), const SizedBox(width: 12),
    Expanded(child: Text(label, style: const TextStyle(color: AppTheme.textMain, fontSize: 15))),
    Switch(value: val, onChanged: onChanged, activeColor: AppTheme.primary),
  ]);
}

class _CntBtn extends StatelessWidget {
  final IconData icon; final VoidCallback? onTap;
  const _CntBtn(this.icon, this.onTap);
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 30, height: 30,
      decoration: BoxDecoration(
        color: onTap != null ? AppTheme.primary.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(color: onTap != null ? AppTheme.primary.withOpacity(0.5) : Colors.grey.withOpacity(0.2))),
      child: Icon(icon, color: onTap != null ? AppTheme.primary : Colors.grey, size: 16)),
  );
}
