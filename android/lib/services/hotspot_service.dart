import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:waste2ways/config/constants.dart';
import 'package:waste2ways/models/hotspot_model.dart';
import 'dart:developer' as developer;

class HotspotService {
  final String _baseUrl = Constants.baseUrl;

  Future<List<Hotspot>> getHotspots() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/trash/hotspots'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonData = json.decode(response.body);

        if (jsonData['success'] == true && jsonData['data'] != null) {
          final List<dynamic> hotspotList = jsonData['data'];
          return hotspotList.map((data) => Hotspot.fromJson(data)).toList();
        } else {
          throw Exception('Failed to get hotspots: ${jsonData['message']}');
        }
      } else {
        throw Exception(
          'Server error: ${response.statusCode}, body: ${response.body}',
        );
      }
    } catch (e) {
      developer.log(
        'Error fetching hotspots: $e',
        name: 'HotspotService',
        error: e,
      );
      throw Exception('Error fetching hotspots: $e');
    }
  }
}
