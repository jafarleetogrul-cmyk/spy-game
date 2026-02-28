import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import '../l10n/strings.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});
  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<LeaderboardEntry> _entries = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await StorageService.getLeaderboard();
    setState(() { _entries = data; _loading = false; });
  }

  Future<void> _clear() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Sıfırla?', style: TextStyle(color: AppTheme.textMain)),
        content: const Text('Bütün liderboard məlumatları silinəcək.', style: TextStyle(color: AppTheme.textSub)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Ləğv et', style: TextStyle(color: AppTheme.textSub))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sil', style: TextStyle(color: AppTheme.spyRed))),
        ],
      ),
    );
    if (confirm == true) {
      await StorageService.clearLeaderboard();
      _load();
    }
  }

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
              title: Text(L.t('leaderboard')),
              actions: [
                if (_entries.isNotEmpty)
                  IconButton(icon: const Icon(Icons.delete_outline, color: AppTheme.spyRed), onPressed: _clear),
              ],
              floating: true,
            ),
            if (_loading)
              const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: AppTheme.primary)))
            else if (_entries.isEmpty)
              SliverFillRemaining(
                child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.leaderboard, color: AppTheme.textSub, size: 80),
                  const SizedBox(height: 16),
                  Text(L.t('no_leaderboard'), style: const TextStyle(color: AppTheme.textSub, fontSize: 16)),
                  const SizedBox(height: 8),
                  const Text('Oyun oynadıqdan sonra burada görünəcək', style: TextStyle(color: AppTheme.textSub, fontSize: 13)),
                ])),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList(delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                    final e = _entries[i];
                    final medals = ['🥇', '🥈', '🥉'];
                    final isTop = i < 3;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: i == 0 ? AppTheme.goldGradient.scale(0.15) : null,
                        color: i == 0 ? null : AppTheme.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: i == 0 ? AppTheme.gold.withOpacity(0.4) : Colors.white.withOpacity(0.06)),
                      ),
                      child: Row(children: [
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: isTop ? AppTheme.primaryGradient : null,
                            color: isTop ? null : Colors.white.withOpacity(0.05),
                          ),
                          child: Center(child: Text(isTop ? medals[i] : '${i+1}', style: TextStyle(fontSize: isTop ? 20 : 14, fontWeight: FontWeight.bold, color: Colors.white))),
                        ),
                        const SizedBox(width: 14),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(e.name, style: TextStyle(color: i == 0 ? AppTheme.gold : AppTheme.textMain, fontWeight: FontWeight.w700, fontSize: 16)),
                          const SizedBox(height: 4),
                          Row(children: [
                            _StatChip('🎮 ${e.gamesPlayed}', AppTheme.primary),
                            const SizedBox(width: 6),
                            _StatChip('🕵️ ${e.spyWins}', AppTheme.spyRed),
                            const SizedBox(width: 6),
                            _StatChip('👥 ${e.civilWins}', AppTheme.civilBlue),
                          ]),
                        ])),
                        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                          Text('${e.totalPoints}', style: TextStyle(color: i == 0 ? AppTheme.gold : AppTheme.accent, fontSize: 22, fontWeight: FontWeight.w900)),
                          Text(L.t('points'), style: const TextStyle(color: AppTheme.textSub, fontSize: 11)),
                        ]),
                      ]),
                    ).animate().fadeIn(delay: (i * 60).ms).slideX(begin: 0.1);
                  },
                  childCount: _entries.length,
                )),
              ),
          ]),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String text;
  final Color color;
  const _StatChip(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

extension on LinearGradient {
  LinearGradient scale(double opacity) => LinearGradient(
    colors: colors.map((c) => c.withOpacity(opacity)).toList(),
    begin: begin, end: end,
  );
}
