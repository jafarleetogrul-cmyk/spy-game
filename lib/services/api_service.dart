import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class ApiException implements Exception {
  final String message; final int? statusCode;
  ApiException(this.message, {this.statusCode});
  @override String toString() => message;
}

class ApiService {
  String baseUrl;
  String? _authToken;

  ApiService(this.baseUrl);

  void setToken(String? token) => _authToken = token;

  Map<String,String> get _headers => {
    'Content-Type': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  Future<Map<String,dynamic>> _post(String path, Map<String,dynamic> body) async {
    try {
      final res = await http.post(Uri.parse('$baseUrl$path'), headers: _headers, body: jsonEncode(body)).timeout(const Duration(seconds: 10));
      final j = jsonDecode(res.body) as Map<String,dynamic>;
      if (res.statusCode >= 400) throw ApiException(j['error'] ?? 'Xəta', statusCode: res.statusCode);
      return j;
    } on ApiException { rethrow; } catch (e) { throw ApiException('Şəbəkə xətası: $e'); }
  }

  Future<Map<String,dynamic>> _get(String path, {Map<String,String>? extra}) async {
    try {
      final res = await http.get(Uri.parse('$baseUrl$path'), headers: {..._headers, ...?extra}).timeout(const Duration(seconds: 10));
      final j = jsonDecode(res.body) as Map<String,dynamic>;
      if (res.statusCode >= 400) throw ApiException(j['error'] ?? 'Xəta', statusCode: res.statusCode);
      return j;
    } on ApiException { rethrow; } catch (e) { throw ApiException('Şəbəkə xətası: $e'); }
  }

  // ── Auth ────────────────────────────────────────────────
  Future<AuthUser> register(String username, String password) async {
    final j = await _post('/api/auth/register', {'username': username, 'password': password});
    return AuthUser.fromJson(j);
  }

  Future<AuthUser> login(String username, String password) async {
    final j = await _post('/api/auth/login', {'username': username, 'password': password});
    return AuthUser.fromJson(j);
  }

  Future<AuthUser> getMe() async {
    final j = await _get('/api/auth/me');
    return AuthUser(userId: j['user_id'], username: j['username'], token: _authToken ?? '', stats: UserStats.fromJson(j['stats'] ?? {}));
  }

  Future<void> logout() async {
    try { await _post('/api/auth/logout', {}); } catch (_) {}
    _authToken = null;
  }

  // ── Leaderboard ─────────────────────────────────────────
  Future<List<LeaderEntry>> getLeaderboard() async {
    final j = await _get('/api/leaderboard');
    return (j['leaderboard'] as List).map((e) => LeaderEntry.fromJson(e as Map<String,dynamic>)).toList();
  }

  Future<LeaderEntry?> getMyRank() async {
    try {
      final j = await _get('/api/leaderboard/my_rank');
      return LeaderEntry.fromJson(j);
    } catch (_) { return null; }
  }

  // ── Game ─────────────────────────────────────────────────
  Future<Map<String,dynamic>> createRoom({required int maxPlayers, required int spiesCount,
    required int roundsCount, required int roundTimeMinutes, required String lang}) =>
      _post('/api/create_room', {'max_players': maxPlayers, 'spies_count': spiesCount,
        'rounds_count': roundsCount, 'round_time_minutes': roundTimeMinutes, 'lang': lang});

  Future<Map<String,dynamic>> joinRoom({String? roomId, String? roomCode, required String joinToken}) =>
      _post('/api/join_room', {
        if (roomId != null) 'room_id': roomId,
        if (roomCode != null) 'room_code': roomCode,
        'join_token': joinToken,
      });

  Future<RoomState> getRoomState(String roomId) async {
    final j = await _get('/api/room_state?room_id=$roomId');
    return RoomState.fromJson(j);
  }

  Future<void> startGame({required String roomId, required String hostToken}) =>
      _post('/api/start_game', {'room_id': roomId, 'host_token': hostToken});

  Future<MyCard> getMyCard({required String roomId, required String playerToken}) async {
    final j = await _get('/api/my_card?room_id=$roomId', extra: {'player-token': playerToken});
    return MyCard.fromJson(j);
  }

  Future<Map<String,dynamic>> endRound({required String roomId, required String hostToken, required String winner}) =>
      _post('/api/end_round', {'room_id': roomId, 'host_token': hostToken, 'winner': winner});

  Future<Map<String,dynamic>> getScoreboardRaw(String roomId) =>
      _get('/api/scoreboard?room_id=$roomId');

  Future<bool> ping() async {
    try { await _get('/api/health'); return true; } catch (_) { return false; }
  }
}
