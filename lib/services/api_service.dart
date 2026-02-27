import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});
  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiService {
  final String baseUrl;

  ApiService(this.baseUrl);

  // ── Helpers ─────────────────────────────────
  Map<String, String> get _headers => {'Content-Type': 'application/json'};

  Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> body) async {
    try {
      final res = await http
          .post(Uri.parse('$baseUrl$path'),
              headers: _headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 10));
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode >= 400) {
        throw ApiException(json['error'] ?? 'Unknown error',
            statusCode: res.statusCode);
      }
      return json;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> _get(String path,
      {Map<String, String>? extraHeaders}) async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl$path'), headers: {
            ..._headers,
            ...?extraHeaders,
          })
          .timeout(const Duration(seconds: 10));
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode >= 400) {
        throw ApiException(json['error'] ?? 'Unknown error',
            statusCode: res.statusCode);
      }
      return json;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  // ── Endpoints ───────────────────────────────

  /// Creates a room. Returns session data.
  Future<Map<String, dynamic>> createRoom({
    required String creatorName,
    required int maxPlayers,
    required int spiesCount,
    required int roundsCount,
  }) =>
      _post('/api/create_room', {
        'creator_name': creatorName,
        'max_players': maxPlayers,
        'spies_count': spiesCount,
        'rounds_count': roundsCount,
      });

  /// Joins a room by room_id+join_token OR room_code+join_token.
  Future<Map<String, dynamic>> joinRoom({
    String? roomId,
    String? roomCode,
    required String joinToken,
    required String playerName,
  }) =>
      _post('/api/join_room', {
        if (roomId != null) 'room_id': roomId,
        if (roomCode != null) 'room_code': roomCode,
        'join_token': joinToken,
        'player_name': playerName,
      });

  /// Polls room state (used for long-polling lobby refresh).
  Future<RoomState> getRoomState(String roomId) async {
    final j = await _get('/api/room_state?room_id=$roomId');
    return RoomState.fromJson(j);
  }

  /// Host starts the game.
  Future<void> startGame({
    required String roomId,
    required String hostToken,
  }) =>
      _post('/api/start_game', {
        'room_id': roomId,
        'host_token': hostToken,
      });

  /// Get current role card for this player.
  Future<MyCard> getMyCard({
    required String roomId,
    required String playerToken,
  }) async {
    final j = await _get(
      '/api/my_card?room_id=$roomId',
      extraHeaders: {'player-token': playerToken},
    );
    return MyCard.fromJson(j);
  }

  /// Host ends a round.
  Future<Map<String, dynamic>> endRound({
    required String roomId,
    required String hostToken,
    required String winner, // "spies" | "civilians"
  }) =>
      _post('/api/end_round', {
        'room_id': roomId,
        'host_token': hostToken,
        'winner': winner,
      });

  /// Get scoreboard.
  Future<List<ScoreEntry>> getScoreboard(String roomId) async {
    final j = await _get('/api/scoreboard?room_id=$roomId');
    return (j['scoreboard'] as List)
        .map((e) => ScoreEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Health check – returns true if server reachable.
  Future<bool> ping() async {
    try {
      await _get('/api/health');
      return true;
    } catch (_) {
      return false;
    }
  }
}
