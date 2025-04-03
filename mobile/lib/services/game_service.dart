import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;

import '../config/constants.dart';
import '../models/rank_model.dart';
import '../models/leaderboard_user_model.dart';

class GameService {
  Future<RankModel?> getUserRank(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${Constants.baseUrl}/game/rank/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      developer.log('Rank API response: ${response.body}', name: 'GameService');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          return RankModel.fromJson(responseData['data']);
        }
      }

      developer.log(
        'Failed to get user rank: ${response.statusCode} ${response.body}',
        name: 'GameService',
      );
      return null;
    } catch (e) {
      developer.log('Error getting user rank: $e', name: 'GameService');
      return null;
    }
  }

  Future<LeaderboardResponse?> getLeaderboard(int page, int limit) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${Constants.baseUrl}/game/leaderboard?page=$page&limit=$limit',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      developer.log(
        'Leaderboard API response: ${response.body}',
        name: 'GameService',
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          return LeaderboardResponse.fromJson(responseData);
        }
      }

      developer.log(
        'Failed to get leaderboard: ${response.statusCode} ${response.body}',
        name: 'GameService',
      );
      return null;
    } catch (e) {
      developer.log('Error getting leaderboard: $e', name: 'GameService');
      return null;
    }
  }
}
