// ──────────────────────────────────────────────────
// models.dart  –  all data models for Spy Game
// ──────────────────────────────────────────────────

class PlayerStats {
  final int spyWins;
  final int civilWins;
  final int totalPoints;

  const PlayerStats({
    this.spyWins = 0,
    this.civilWins = 0,
    this.totalPoints = 0,
  });

  factory PlayerStats.fromJson(Map<String, dynamic> j) => PlayerStats(
        spyWins: j['spy_wins'] ?? 0,
        civilWins: j['civil_wins'] ?? 0,
        totalPoints: j['total_points'] ?? 0,
      );
}

class Player {
  final String playerId;
  final String name;
  final bool isHost;
  final PlayerStats stats;

  const Player({
    required this.playerId,
    required this.name,
    required this.isHost,
    required this.stats,
  });

  factory Player.fromJson(Map<String, dynamic> j) => Player(
        playerId: j['player_id'] ?? '',
        name: j['name'] ?? '',
        isHost: j['is_host'] ?? false,
        stats: PlayerStats.fromJson(j['stats'] ?? {}),
      );
}

enum RoomStatus { lobby, playing, finished, unknown }

class RoomState {
  final String roomId;
  final String roomCode;
  final RoomStatus status;
  final int currentRound;
  final int roundsCount;
  final int maxPlayers;
  final int spiesCount;
  final String hostPlayerId;
  final List<Player> players;
  final double lastUpdated;

  const RoomState({
    required this.roomId,
    required this.roomCode,
    required this.status,
    required this.currentRound,
    required this.roundsCount,
    required this.maxPlayers,
    required this.spiesCount,
    required this.hostPlayerId,
    required this.players,
    required this.lastUpdated,
  });

  factory RoomState.fromJson(Map<String, dynamic> j) {
    RoomStatus status;
    switch (j['status']) {
      case 'lobby':    status = RoomStatus.lobby;    break;
      case 'playing':  status = RoomStatus.playing;  break;
      case 'finished': status = RoomStatus.finished; break;
      default:         status = RoomStatus.unknown;
    }
    final players = (j['players'] as List? ?? [])
        .map((p) => Player.fromJson(p as Map<String, dynamic>))
        .toList();

    return RoomState(
      roomId: j['room_id'] ?? '',
      roomCode: j['room_code'] ?? '',
      status: status,
      currentRound: j['current_round'] ?? 0,
      roundsCount: j['rounds_count'] ?? 0,
      maxPlayers: j['max_players'] ?? 0,
      spiesCount: j['spies_count'] ?? 0,
      hostPlayerId: j['host_player_id'] ?? '',
      players: players,
      lastUpdated: (j['last_updated'] ?? 0.0).toDouble(),
    );
  }
}

class MyCard {
  final String role;       // "spy" | "civil"
  final String? place;
  final int roundNumber;
  final int roundsCount;

  bool get isSpy => role == 'spy';

  const MyCard({
    required this.role,
    this.place,
    required this.roundNumber,
    required this.roundsCount,
  });

  factory MyCard.fromJson(Map<String, dynamic> j) => MyCard(
        role: j['role'] ?? 'civil',
        place: j['place'],
        roundNumber: j['round_number'] ?? 1,
        roundsCount: j['rounds_count'] ?? 1,
      );
}

class ScoreEntry {
  final String playerId;
  final String name;
  final PlayerStats stats;

  const ScoreEntry({
    required this.playerId,
    required this.name,
    required this.stats,
  });

  factory ScoreEntry.fromJson(Map<String, dynamic> j) => ScoreEntry(
        playerId: j['player_id'] ?? '',
        name: j['name'] ?? '',
        stats: PlayerStats.fromJson(j['stats'] ?? {}),
      );
}

// ── Local session info (stored in provider, not server) ──
class LocalSession {
  final String roomId;
  final String roomCode;
  final String playerId;
  final String playerToken;
  final String? hostToken;  // only host has this
  final String joinToken;

  bool get isHost => hostToken != null;

  const LocalSession({
    required this.roomId,
    required this.roomCode,
    required this.playerId,
    required this.playerToken,
    this.hostToken,
    required this.joinToken,
  });
}
