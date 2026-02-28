import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import '../l10n/strings.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});
  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<LeaderEntry> _board = [];
  LeaderEntry? _myEntry;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    final gp = context.read<GameProvider>();
    try {
      final api = ApiService(gp.serverUrl);
      if (gp.currentUser != null) api.setToken(gp.currentUser!.token);

      final board = await api.getLeaderboard();
      final myRank = gp.currentUser != null ? await api.getMyRank() : null;

      setState(() { _board = board; _myEntry = myRank; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final gp = context.watch<GameProvider>();
    final myId = gp.currentUser?.userId ?? '';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGrad),
        child: SafeArea(
          child: CustomScrollView(slivers: [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              leading: IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: () => Navigator.pop(context)),
              title: Text(L.t('leaderboard')),
              actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)],
              floating: true,
            ),

            // ── My rank card (always visible if logged in) ────
            if (_myEntry != null)
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGrad,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.4), blurRadius: 20, offset: const Offset(0,6))],
                  ),
                  child: Row(children: [
                    Container(
                      width: 52, height: 52, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.2)),
                      child: Center(child: Text('#${_myEntry!.rank}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18))),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        const Text('⭐ ', style: TextStyle(fontSize: 14)),
                        Text(L.t('your_rank'), style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      ]),
                      Text(_myEntry!.username, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
                      Text('🕵️ ${_myEntry!.spyWins}  👥 ${_myEntry!.civilWins}  🎮 ${_myEntry!.gamesPlayed}',
                        style: const TextStyle(color: Colors.white70, fontSize: 11)),
                    ])),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text('${_myEntry!.totalPoints}', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
                      Text(L.t('points'), style: const TextStyle(color: Colors.white70, fontSize: 11)),
                    ]),
                  ]),
                ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95)),
              )),

            SliverToBoxAdapter(child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Row(children: [
                const Icon(Icons.leaderboard, color: AppTheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(L.t('global_top'), style: const TextStyle(color: AppTheme.textMain, fontSize: 18, fontWeight: FontWeight.w700)),
                const Spacer(),
                Text('${_board.length} oyunçu', style: const TextStyle(color: AppTheme.textSub, fontSize: 12)),
              ]),
            )),

            if (_loading)
              const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: AppTheme.primary)))
            else if (_error != null)
              SliverFillRemaining(child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.wifi_off, color: AppTheme.textSub, size: 60),
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: AppTheme.textSub)),
                const SizedBox(height: 16),
                GradientButton(label: 'Yenidən cəhd et', onTap: _load, width: 200),
              ])))
            else if (_board.isEmpty)
              SliverFillRemaining(child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.leaderboard, color: AppTheme.textSub, size: 80),
                const SizedBox(height: 16),
                const Text('Hələ oyun oynanmayıb', style: TextStyle(color: AppTheme.textSub, fontSize: 16)),
              ])))
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList(delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                    final e = _board[i];
                    final isMe = e.userId == myId;
                    final medals = ['🥇','🥈','🥉'];
                    final medalColors = [AppTheme.gold, AppTheme.silver, AppTheme.bronze];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isMe ? AppTheme.primary.withOpacity(0.2) : AppTheme.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isMe
                              ? AppTheme.primary.withOpacity(0.6)
                              : i < 3 ? medalColors[i].withOpacity(0.3) : Colors.white.withOpacity(0.06),
                          width: isMe ? 2 : 1,
                        ),
                        boxShadow: isMe ? [BoxShadow(color: AppTheme.primary.withOpacity(0.25), blurRadius: 12)] : null,
                      ),
                      child: Row(children: [
                        // Rank badge
                        SizedBox(
                          width: 42,
                          child: i < 3
                              ? Text(medals[i], style: const TextStyle(fontSize: 24), textAlign: TextAlign.center)
                              : Container(
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.06),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(child: Text('${e.rank}',
                                    style: const TextStyle(color: AppTheme.textSub, fontSize: 13, fontWeight: FontWeight.w700))),
                                ),
                        ),
                        const SizedBox(width: 10),
                        // Avatar
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: isMe ? AppTheme.primary : AppTheme.primary.withOpacity(0.3),
                          child: Text(e.username[0].toUpperCase(),
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: isMe ? 15 : 13)),
                        ),
                        const SizedBox(width: 10),
                        // Name + stats
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            Flexible(child: Text(e.username,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: i == 0 ? AppTheme.gold : isMe ? AppTheme.primary : AppTheme.textMain,
                                fontWeight: isMe ? FontWeight.w800 : FontWeight.w600, fontSize: 14))),
                            if (isMe) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(8)),
                                child: const Text('SƏN', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
                              ),
                            ],
                          ]),
                          const SizedBox(height: 2),
                          Text('🕵️${e.spyWins} 👥${e.civilWins} 🎮${e.gamesPlayed}',
                            style: const TextStyle(color: AppTheme.textSub, fontSize: 10)),
                        ])),
                        // Points
                        Text('${e.totalPoints}',
                          style: TextStyle(
                            color: i == 0 ? AppTheme.gold : isMe ? AppTheme.accent : AppTheme.textMain,
                            fontSize: 18, fontWeight: FontWeight.w900)),
                        Text(' ${L.t('points')}', style: const TextStyle(color: AppTheme.textSub, fontSize: 10)),
                      ]),
                    ).animate().fadeIn(delay: (i * 40).ms).slideX(begin: 0.05);
                  },
                  childCount: _board.length,
                )),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ]),
        ),
      ),
    );
  }
}
