import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

// ──────────────────────────────────────────────────────────
// GradientButton
// ──────────────────────────────────────────────────────────
class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final LinearGradient gradient;
  final double? width;
  final IconData? icon;

  const GradientButton({
    super.key,
    required this.label,
    required this.onTap,
    this.gradient = AppTheme.primaryGradient,
    this.width,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: width ?? double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: onTap != null ? gradient : null,
          color: onTap == null ? Colors.grey.shade800 : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: onTap != null
              ? [
                  BoxShadow(
                    color: gradient.colors.first.withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
// GlassCard
// ──────────────────────────────────────────────────────────
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color? borderColor;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppTheme.card.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor ?? Colors.white.withOpacity(0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ──────────────────────────────────────────────────────────
// PlayerTile
// ──────────────────────────────────────────────────────────
class PlayerTile extends StatelessWidget {
  final String name;
  final bool isHost;
  final int index;

  const PlayerTile({
    super.key,
    required this.name,
    required this.isHost,
    required this.index,
  });

  static const _avatarColors = [
    Color(0xFF6C63FF), Color(0xFFFF6584), Color(0xFF43E97B),
    Color(0xFFFFD166), Color(0xFF4CC9F0), Color(0xFFF77F00),
    Color(0xFF7B2D8B), Color(0xFF06D6A0),
  ];

  @override
  Widget build(BuildContext context) {
    final avatarColor = _avatarColors[index % _avatarColors.length];
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: avatarColor,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                  color: AppTheme.textMain,
                  fontSize: 15,
                  fontWeight: FontWeight.w500),
            ),
          ),
          if (isHost)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Host',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms, delay: (index * 60).ms)
        .slideX(begin: 0.15, end: 0);
  }
}

// ──────────────────────────────────────────────────────────
// ScoreRow
// ──────────────────────────────────────────────────────────
class ScoreRow extends StatelessWidget {
  final String name;
  final int spyWins;
  final int civilWins;
  final int totalPoints;
  final int rank;

  const ScoreRow({
    super.key,
    required this.name,
    required this.spyWins,
    required this.civilWins,
    required this.totalPoints,
    required this.rank,
  });

  @override
  Widget build(BuildContext context) {
    final medals = ['🥇', '🥈', '🥉'];
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: rank == 1
            ? AppTheme.primary.withOpacity(0.2)
            : AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: rank == 1
              ? AppTheme.primary.withOpacity(0.4)
              : Colors.white.withOpacity(0.06),
        ),
      ),
      child: Row(
        children: [
          Text(rank <= 3 ? medals[rank - 1] : '$rank.',
              style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        color: AppTheme.textMain,
                        fontWeight: FontWeight.w600,
                        fontSize: 15)),
                const SizedBox(height: 2),
                Text(
                  'Şpion: $spyWins qalıb (+${spyWins * 2}) | Mülki: $civilWins qalıb (+${civilWins * 1})',
                  style: const TextStyle(
                      color: AppTheme.textSub, fontSize: 11),
                ),
              ],
            ),
          ),
          Text(
            '$totalPoints xal',
            style: const TextStyle(
                color: AppTheme.accent,
                fontWeight: FontWeight.bold,
                fontSize: 16),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: (rank * 80).ms)
        .slideY(begin: 0.1, end: 0);
  }
}

// ──────────────────────────────────────────────────────────
// LoadingOverlay
// ──────────────────────────────────────────────────────────
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black54,
            child: const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            ),
          ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────
// ErrorBanner
// ──────────────────────────────────────────────────────────
class ErrorBanner extends StatelessWidget {
  final String? error;
  final VoidCallback? onDismiss;

  const ErrorBanner({super.key, this.error, this.onDismiss});

  @override
  Widget build(BuildContext context) {
    if (error == null || error!.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.spyRed.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.spyRed.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppTheme.spyRed, size: 18),
          const SizedBox(width: 8),
          Expanded(
              child: Text(error!,
                  style: const TextStyle(
                      color: AppTheme.spyRed, fontSize: 13))),
          if (onDismiss != null)
            GestureDetector(
                onTap: onDismiss,
                child: const Icon(Icons.close,
                    color: AppTheme.spyRed, size: 16)),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.2, end: 0);
  }
}
