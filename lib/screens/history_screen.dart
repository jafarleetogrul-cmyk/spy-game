import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../l10n/strings.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<GameHistoryEntry> _history = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await StorageService.getHistory();
    setState(() { _history = data; _loading = false; });
  }

  Future<void> _clear() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Tarixçəni sil?', style: TextStyle(color: AppTheme.textMain)),
        content: const Text('Bütün oyun tarixçəsi silinəcək.', style: TextStyle(color: AppTheme.textSub)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Ləğv et', style: TextStyle(color: AppTheme.textSub))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sil', style: TextStyle(color: AppTheme.spyRed))),
        ],
      ),
    );
    if (confirm == true) {
      await StorageService.clearHistory();
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
              title: Text(L.t('history')),
              actions: [
                if (_history.isNotEmpty)
                  IconButton(icon: const Icon(Icons.delete_outline, color: AppTheme.spyRed), onPressed: _clear),
              ],
              floating: true,
            ),
            if (_loading)
              const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: AppTheme.primary)))
            else if (_history.isEmpty)
              SliverFillRemaining(
                child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.history, color: AppTheme.textSub, size: 80),
                  const SizedBox(height: 16),
                  Text(L.t('no_history'), style: const TextStyle(color: AppTheme.textSub, fontSize: 16)),
                ])),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList(delegate: SliverChildBuilderDelegate(
                  (ctx, i) => _HistoryCard(entry: _history[i], index: i),
                  childCount: _history.length,
                )),
              ),
          ]),
        ),
      ),
    );
  }
}

class _HistoryCard extends StatefulWidget {
  final GameHistoryEntry entry;
  final int index;
  const _HistoryCard({required this.entry, required this.index});
  @override
  State<_HistoryCard> createState() => _HistoryCardState();
}

class _HistoryCardState extends State<_HistoryCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final e = widget.entry;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(children: [
        // Header
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(shape: BoxShape.circle, gradient: AppTheme.primaryGradient),
                child: Center(child: Text('${widget.index + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16))),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('🏆 ${e.winnerName}', style: const TextStyle(color: AppTheme.textMain, fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 3),
                Text('${e.date}  •  ${e.roundsPlayed} raund  •  ${e.players.length} oyunçu',
                  style: const TextStyle(color: AppTheme.textSub, fontSize: 12)),
              ])),
              Icon(_expanded ? Icons.expand_less : Icons.expand_more, color: AppTheme.textSub),
            ]),
          ),
        ),
        // Expanded players
        if (_expanded) ...[
          const Divider(color: Colors.white10, height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Oyunçular:', style: TextStyle(color: AppTheme.textSub, fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                ...e.players.asMap().entries.map((en) {
                  final p = en.value;
                  final stats = p['stats'] as Map<String, dynamic>;
                  final pts = stats['total_points'] as int? ?? 0;
                  final spyW = stats['spy_wins'] as int? ?? 0;
                  final civW = stats['civil_wins'] as int? ?? 0;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(children: [
                      Text(en.key == 0 ? '🥇' : en.key == 1 ? '🥈' : en.key == 2 ? '🥉' : '${en.key + 1}.', style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Expanded(child: Text(p['name'] as String? ?? '', style: const TextStyle(color: AppTheme.textMain, fontSize: 13))),
                      Text('🕵️$spyW  👥$civW  ', style: const TextStyle(color: AppTheme.textSub, fontSize: 11)),
                      Text('$pts xal', style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w700, fontSize: 13)),
                    ]),
                  );
                }),
              ],
            ),
          ),
        ],
      ]),
    ).animate().fadeIn(delay: (widget.index * 60).ms).slideY(begin: 0.1);
  }
}
