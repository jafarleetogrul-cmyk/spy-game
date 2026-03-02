import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final LinearGradient gradient;
  final IconData? icon;
  final double? width;
  const GradientButton({super.key, required this.label, this.onTap, this.gradient=AppTheme.primaryGrad, this.icon, this.width});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width ?? double.infinity, height: 56,
        decoration: BoxDecoration(
          gradient: onTap != null ? gradient : null,
          color: onTap == null ? Colors.grey.shade800 : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: onTap != null ? [BoxShadow(color: gradient.colors.first.withOpacity(0.4), blurRadius: 16, offset: const Offset(0,6))] : null,
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (icon != null) ...[Icon(icon, color: Colors.white, size: 20), const SizedBox(width: 8)],
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color? borderColor;
  const GlassCard({super.key, required this.child, this.padding=const EdgeInsets.all(20), this.borderColor});

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: AppTheme.card.withOpacity(0.85),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: borderColor ?? Colors.white.withOpacity(0.08)),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0,8))],
    ),
    child: child,
  );
}

class CountdownWidget extends StatelessWidget {
  final int seconds;
  final bool isWarning, expired;
  const CountdownWidget({super.key, required this.seconds, this.isWarning=false, this.expired=false});

  String get _display {
    final m = seconds ~/ 60; final s = seconds % 60;
    return '${m.toString().padLeft(2,'0')}:${s.toString().padLeft(2,'0')}';
  }

  @override
  Widget build(BuildContext context) {
    final color = expired ? AppTheme.spyRed : isWarning ? Colors.orange : AppTheme.accent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.4), width: 2)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(expired ? Icons.timer_off : Icons.timer, color: color, size: 20),
        const SizedBox(width: 8),
        Text(expired ? 'VAXT BİTDİ!' : _display,
          style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.w800, fontFeatures: const [FontFeature.tabularFigures()])),
      ]),
    ).animate(target: isWarning ? 1 : 0).shake(duration: 500.ms);
  }
}

class PlayerTile extends StatelessWidget {
  final String name; final bool isHost; final int index;
  const PlayerTile({super.key, required this.name, required this.isHost, required this.index});

  static const _colors = [Color(0xFF6C63FF), Color(0xFFFF6584), Color(0xFF43E97B), Color(0xFFFFD166), Color(0xFF4CC9F0), Color(0xFFF77F00)];

  @override
  Widget build(BuildContext context) {
    final c = _colors[index % _colors.length];
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white.withOpacity(0.06))),
      child: Row(children: [
        CircleAvatar(radius: 20, backgroundColor: c,
          child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
        const SizedBox(width: 12),
        Expanded(child: Text(name, style: const TextStyle(color: AppTheme.textMain, fontSize: 15, fontWeight: FontWeight.w500))),
        if (isHost) Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(gradient: AppTheme.primaryGrad, borderRadius: BorderRadius.circular(20)),
          child: const Text('Host', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600))),
      ]),
    ).animate().fadeIn(duration: 300.ms, delay: (index*60).ms).slideX(begin: 0.15);
  }
}

class LoadingOverlay extends StatelessWidget {
  final bool isLoading; final Widget child;
  const LoadingOverlay({super.key, required this.isLoading, required this.child});

  @override
  Widget build(BuildContext context) => Stack(children: [
    child,
    if (isLoading) Container(color: Colors.black54, child: const Center(child: CircularProgressIndicator(color: AppTheme.primary))),
  ]);
}

class ErrorBanner extends StatelessWidget {
  final String? error; final VoidCallback? onDismiss;
  const ErrorBanner({super.key, this.error, this.onDismiss});

  @override
  Widget build(BuildContext context) {
    if (error == null || error!.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(color: AppTheme.spyRed.withOpacity(0.2), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.spyRed.withOpacity(0.5))),
      child: Row(children: [
        const Icon(Icons.error_outline, color: AppTheme.spyRed, size: 18), const SizedBox(width: 8),
        Expanded(child: Text(error!, style: const TextStyle(color: AppTheme.spyRed, fontSize: 13))),
        if (onDismiss != null) GestureDetector(onTap: onDismiss, child: const Icon(Icons.close, color: AppTheme.spyRed, size: 16)),
      ]),
    ).animate().fadeIn().slideY(begin: -0.2);
  }
}
