import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import '../l10n/strings.dart';

class RoleCardScreen extends StatefulWidget {
  const RoleCardScreen({super.key});
  @override
  State<RoleCardScreen> createState() => _RoleCardScreenState();
}

class _RoleCardScreenState extends State<RoleCardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  bool _flipped = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _anim = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutBack));
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _flip() {
    if (_flipped) _ctrl.reverse(); else _ctrl.forward();
    setState(() => _flipped = !_flipped);
    SoundService.cardFlip();
  }

  @override
  Widget build(BuildContext context) {
    final gp = context.watch<GameProvider>();
    final card = gp.myCard;
    if (card == null) return Scaffold(body: Container(decoration: const BoxDecoration(gradient: AppTheme.bgGrad), child: const Center(child: CircularProgressIndicator(color: AppTheme.primary))));

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGrad),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(children: [
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white12)),
                child: Text('${L.t('round')} ${card.roundNumber} / ${card.roundsCount}', style: const TextStyle(color: AppTheme.textSub, fontSize: 14, fontWeight: FontWeight.w500)),
              ).animate().fadeIn(),
              const Spacer(),
              Text(_flipped ? 'Kartınızı gizlədin!' : L.t('tap_to_flip'),
                style: TextStyle(color: AppTheme.textSub.withOpacity(0.8), fontSize: 14)).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _flip,
                child: AnimatedBuilder(
                  animation: _anim,
                  builder: (_, __) {
                    final angle = _anim.value * pi;
                    final isFront = angle < pi / 2;
                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..setEntry(3,2,0.001)..rotateY(angle),
                      child: isFront ? _back() : Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()..rotateY(pi),
                        child: _front(card.isSpy, card.place)),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              if (_flipped)
                GestureDetector(
                  onTap: () => Navigator.pushReplacementNamed(context, '/round_control'),
                  child: Container(
                    width: double.infinity, height: 56,
                    decoration: BoxDecoration(gradient: AppTheme.primaryGrad, borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.4), blurRadius: 16, offset: const Offset(0,6))]),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.visibility_off, color: Colors.white, size: 20), const SizedBox(width: 8),
                      Text(L.t('hide_card'), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ).animate().fadeIn().slideY(begin: 0.2),
              const Spacer(),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _back() => Container(width: 300, height: 420,
    decoration: BoxDecoration(gradient: AppTheme.primaryGrad, borderRadius: BorderRadius.circular(24),
      boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.5), blurRadius: 40, spreadRadius: 5)]),
    child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.visibility_off, color: Colors.white54, size: 80), SizedBox(height: 20),
      Text('Toxunun\nçevirmək üçün', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 18, height: 1.4)),
    ]));

  Widget _front(bool isSpy, String? place) => Container(width: 300, height: 420,
    decoration: BoxDecoration(gradient: isSpy ? AppTheme.spyGrad : AppTheme.civilGrad, borderRadius: BorderRadius.circular(24),
      boxShadow: [BoxShadow(color: (isSpy ? AppTheme.spyRed : AppTheme.civilBlue).withOpacity(0.5), blurRadius: 40, spreadRadius: 5)]),
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 90, height: 90, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.15)),
          child: Icon(isSpy ? Icons.person_search : Icons.location_on, color: Colors.white, size: 48)),
        const SizedBox(height: 24),
        Text(isSpy ? L.t('you_are_spy') : L.t('you_are_civil'), textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1)),
        const SizedBox(height: 20),
        Container(height: 1, color: Colors.white24),
        const SizedBox(height: 20),
        if (isSpy) ...[
          const Icon(Icons.help_outline, color: Colors.white60, size: 32), const SizedBox(height: 12),
          const Text('Məkanı tapmağa çalış\nvə mülki kimi görün!', textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.4)),
        ] else ...[
          const Icon(Icons.place, color: Colors.white60, size: 32), const SizedBox(height: 8),
          Text('${L.t('location')}:', style: const TextStyle(color: Colors.white60, fontSize: 13)),
          const SizedBox(height: 6),
          Text(place ?? '', textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
        ],
      ]),
    ));
}
