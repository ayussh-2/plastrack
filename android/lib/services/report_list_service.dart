import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:waste2ways/config/constants.dart';
import 'dart:developer' as developer;
import 'package:waste2ways/models/report_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReportListService {
  final String _baseUrl = Constants.baseUrl;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get userId => _auth.currentUser?.uid;

  Future<List<Report>> getUserReports() async {
    try {
      final String? currentUserId = userId;
      if (currentUserId == null) {
        throw Exception('User not logged in');
      }

      developer.log(
        'getUserReports response: $currentUserId',
        name: 'ReportListService',
      );
      final response = await http.post(
        Uri.parse('$_baseUrl/trash/my-reports'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'firebaseId': currentUserId}),
      );
      developer.log(response.toString(), name: "ReportListService");
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonData = json.decode(response.body);

        if (jsonData['success'] == true && jsonData['data'] != null) {
          List<Report> reports = [];

          for (var item in jsonData['data']) {
            final reportJson = item['report'];
            final feedbackText = item['feedback'] as String?;

            reports.add(Report.fromJson(reportJson, feedback: feedbackText));
          }

          return reports;
        } else {
          throw Exception('Invalid response format: ${response.body}');
        }
      } else {
        throw Exception(
          'Server error: ${response.statusCode}, body: ${response.body}',
        );
      }
    } catch (e) {
      developer.log(
        'Error fetching user reports: $e',
        name: 'ReportListService',
        error: e,
      );
      throw Exception('Error fetching reports: $e');
    }
  }
}
