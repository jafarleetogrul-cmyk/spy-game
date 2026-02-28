import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// ── Game History Entry ───────────────────────────────────
class GameHistoryEntry {
  final String date;
  final int roundsPlayed;
  final String winnerName;
  final int winnerPoints;
  final List<Map<String, dynamic>> players;

  GameHistoryEntry({
    required this.date,
    required this.roundsPlayed,
    required this.winnerName,
    required this.winnerPoints,
    required this.players,
  });

  Map<String, dynamic> toJson() => {
    'date': date,
    'rounds_played': roundsPlayed,
    'winner_name': winnerName,
    'winner_points': winnerPoints,
    'players': players,
  };

  factory GameHistoryEntry.fromJson(Map<String, dynamic> j) =>
      GameHistoryEntry(
        date: j['date'] ?? '',
        roundsPlayed: j['rounds_played'] ?? 0,
        winnerName: j['winner_name'] ?? '',
        winnerPoints: j['winner_points'] ?? 0,
        players: List<Map<String, dynamic>>.from(j['players'] ?? []),
      );
}

// ── Leaderboard Entry ────────────────────────────────────
class LeaderboardEntry {
  final String name;
  int totalPoints;
  int gamesPlayed;
  int spyWins;
  int civilWins;

  LeaderboardEntry({
    required this.name,
    this.totalPoints = 0,
    this.gamesPlayed = 0,
    this.spyWins = 0,
    this.civilWins = 0,
  });

  double get winRate =>
      gamesPlayed == 0 ? 0 : (spyWins + civilWins) / gamesPlayed * 100;

  Map<String, dynamic> toJson() => {
    'name': name,
    'total_points': totalPoints,
    'games_played': gamesPlayed,
    'spy_wins': spyWins,
    'civil_wins': civilWins,
  };

  factory LeaderboardEntry.fromJson(Map<String, dynamic> j) =>
      LeaderboardEntry(
        name: j['name'] ?? '',
        totalPoints: j['total_points'] ?? 0,
        gamesPlayed: j['games_played'] ?? 0,
        spyWins: j['spy_wins'] ?? 0,
        civilWins: j['civil_wins'] ?? 0,
      );
}

// ── Storage Service ──────────────────────────────────────
class StorageService {
  static const _historyKey = 'game_history';
  static const _leaderboardKey = 'leaderboard';
  static const _settingsKey = 'settings';

  // ── History ─────────────────────────────────────────────
  static Future<List<GameHistoryEntry>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_historyKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => GameHistoryEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> addHistory(GameHistoryEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();
    history.insert(0, entry);
    // Keep last 20 games
    final trimmed = history.take(20).toList();
    await prefs.setString(
        _historyKey, jsonEncode(trimmed.map((e) => e.toJson()).toList()));
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  // ── Leaderboard ─────────────────────────────────────────
  static Future<List<LeaderboardEntry>> getLeaderboard() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_leaderboardKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> updateLeaderboard(
      List<Map<String, dynamic>> players) async {
    final board = await getLeaderboard();

    for (final p in players) {
      final name = p['name'] as String;
      final stats = p['stats'] as Map<String, dynamic>;
      final existing = board.where((e) => e.name == name).firstOrNull;

      if (existing != null) {
        existing.totalPoints += (stats['total_points'] as int? ?? 0);
        existing.spyWins += (stats['spy_wins'] as int? ?? 0);
        existing.civilWins += (stats['civil_wins'] as int? ?? 0);
        existing.gamesPlayed += 1;
      } else {
        board.add(LeaderboardEntry(
          name: name,
          totalPoints: stats['total_points'] as int? ?? 0,
          spyWins: stats['spy_wins'] as int? ?? 0,
          civilWins: stats['civil_wins'] as int? ?? 0,
          gamesPlayed: 1,
        ));
      }
    }

    board.sort((a, b) => b.totalPoints.compareTo(a.totalPoints));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _leaderboardKey, jsonEncode(board.map((e) => e.toJson()).toList()));
  }

  static Future<void> clearLeaderboard() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_leaderboardKey);
  }

  // ── Settings ─────────────────────────────────────────────
  static Future<Map<String, dynamic>> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_settingsKey);
    if (raw == null) {
      return {
        'language': 'az',
        'sound': true,
        'vibration': true,
        'server_url': 'http://10.0.2.2:8080',
        'round_time': 5,
      };
    }
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  static Future<void> saveSettings(Map<String, dynamic> settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, jsonEncode(settings));
  }
}
