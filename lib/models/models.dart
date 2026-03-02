// ── Auth ────────────────────────────────────────────────
class UserStats {
  final int spyWins, civilWins, gamesPlayed, totalPoints;
  const UserStats({this.spyWins=0, this.civilWins=0, this.gamesPlayed=0, this.totalPoints=0});
  factory UserStats.fromJson(Map<String,dynamic> j) => UserStats(
    spyWins: j['spy_wins']??0, civilWins: j['civil_wins']??0,
    gamesPlayed: j['games_played']??0, totalPoints: j['total_points']??0,
  );
}

class AuthUser {
  final String userId, username, token;
  final UserStats stats;
  const AuthUser({required this.userId, required this.username, required this.token, required this.stats});
  factory AuthUser.fromJson(Map<String,dynamic> j) => AuthUser(
    userId: j['user_id']??'', username: j['username']??'', token: j['token']??'',
    stats: UserStats.fromJson(j['stats'] ?? {}),
  );
}

// ── Leaderboard ──────────────────────────────────────────
class LeaderEntry {
  final int rank, totalPoints, spyWins, civilWins, gamesPlayed;
  final String userId, username;
  const LeaderEntry({required this.rank, required this.userId, required this.username,
    required this.totalPoints, required this.spyWins, required this.civilWins, required this.gamesPlayed});
  factory LeaderEntry.fromJson(Map<String,dynamic> j) => LeaderEntry(
    rank: j['rank']??0, userId: j['user_id']??'', username: j['username']??'',
    totalPoints: j['total_points']??0, spyWins: j['spy_wins']??0,
    civilWins: j['civil_wins']??0, gamesPlayed: j['games_played']??0,
  );
}

// ── Game ─────────────────────────────────────────────────
class PlayerStats {
  final int spyWins, civilWins, totalPoints;
  const PlayerStats({this.spyWins=0, this.civilWins=0, this.totalPoints=0});
  factory PlayerStats.fromJson(Map<String,dynamic> j) => PlayerStats(
    spyWins: j['spy_wins']??0, civilWins: j['civil_wins']??0, totalPoints: j['total_points']??0,
  );
}

class Player {
  final String playerId, name;
  final bool isHost;
  final PlayerStats stats;
  const Player({required this.playerId, required this.name, required this.isHost, required this.stats});
  factory Player.fromJson(Map<String,dynamic> j) => Player(
    playerId: j['player_id']??'', name: j['name']??'',
    isHost: j['is_host']??false, stats: PlayerStats.fromJson(j['stats']??{}),
  );
}

enum RoomStatus { lobby, playing, finished, unknown }

class RoomState {
  final String roomId, roomCode, hostPlayerId;
  final RoomStatus status;
  final int currentRound, roundsCount, maxPlayers, spiesCount, roundTimeMinutes;
  final List<Player> players;
  final double lastUpdated;
  const RoomState({
    required this.roomId, required this.roomCode, required this.status,
    required this.currentRound, required this.roundsCount, required this.maxPlayers,
    required this.spiesCount, required this.roundTimeMinutes, required this.hostPlayerId,
    required this.players, required this.lastUpdated,
  });
  factory RoomState.fromJson(Map<String,dynamic> j) {
    RoomStatus st;
    switch (j['status']) {
      case 'lobby':    st = RoomStatus.lobby;    break;
      case 'playing':  st = RoomStatus.playing;  break;
      case 'finished': st = RoomStatus.finished; break;
      default:         st = RoomStatus.unknown;
    }
    return RoomState(
      roomId: j['room_id']??'', roomCode: j['room_code']??'',
      status: st, currentRound: j['current_round']??0,
      roundsCount: j['rounds_count']??0, maxPlayers: j['max_players']??0,
      spiesCount: j['spies_count']??0, roundTimeMinutes: j['round_time_minutes']??5,
      hostPlayerId: j['host_player_id']??'',
      players: (j['players'] as List? ?? []).map((p) => Player.fromJson(p)).toList(),
      lastUpdated: (j['last_updated']??0.0).toDouble(),
    );
  }
}

class MyCard {
  final String role;
  final String? place;
  final int roundNumber, roundsCount, roundTimeMinutes;
  bool get isSpy => role == 'spy';
  const MyCard({required this.role, this.place, required this.roundNumber,
    required this.roundsCount, this.roundTimeMinutes=5});
  factory MyCard.fromJson(Map<String,dynamic> j) => MyCard(
    role: j['role']??'civil', place: j['place'],
    roundNumber: j['round_number']??1, roundsCount: j['rounds_count']??1,
    roundTimeMinutes: j['round_time_minutes']??5,
  );
}

class ScoreEntry {
  final String playerId, name;
  final PlayerStats stats;
  const ScoreEntry({required this.playerId, required this.name, required this.stats});
  factory ScoreEntry.fromJson(Map<String,dynamic> j) => ScoreEntry(
    playerId: j['player_id']??'', name: j['name']??'',
    stats: PlayerStats.fromJson(j['stats']??{}),
  );
}

class RoundResult {
  final int round;
  final String winner, place;
  final List<String> spies;
  const RoundResult({required this.round, required this.winner, required this.place, required this.spies});
  factory RoundResult.fromJson(Map<String,dynamic> j) => RoundResult(
    round: j['round']??0, winner: j['winner']??'', place: j['place']??'',
    spies: List<String>.from(j['spies']??[]),
  );
}

class LocalSession {
  final String roomId, roomCode, playerId, playerToken, joinToken;
  final String? hostToken;
  bool get isHost => hostToken != null;
  const LocalSession({required this.roomId, required this.roomCode, required this.playerId,
    required this.playerToken, this.hostToken, required this.joinToken});
}
