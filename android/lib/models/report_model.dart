import 'package:intl/intl.dart';

class Report {
  final int id;
  final String latitude;
  final String longitude;
  final String trashType;
  final int severity;
  final String image;
  final DateTime timestamp;
  final String firebaseId;
  final String aiResponse;
  final String? feedback;

  Report({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.trashType,
    required this.severity,
    required this.image,
    required this.timestamp,
    required this.firebaseId,
    required this.aiResponse,
    this.feedback,
  });

  factory Report.fromJson(Map<String, dynamic> reportJson, {String? feedback}) {
    return Report(
      id: reportJson['id'],
      latitude: reportJson['latitude'],
      longitude: reportJson['longitude'],
      trashType: reportJson['trashType'] ?? 'Unknown',
      severity: reportJson['severity'],
      image: reportJson['image'],
      timestamp: DateTime.parse(reportJson['timestamp']),
      firebaseId: reportJson['firebaseId'],
      aiResponse: reportJson['aiResponse'] ?? '',
      feedback: feedback,
    );
  }

  String getFormattedDate() {
    return DateFormat('MMM dd, yyyy').format(timestamp);
  }

  String getSeverityText() {
    switch (severity) {
      case 1:
        return 'Low';
      case 2:
        return 'Medium';
      case 3:
        return 'High';
      default:
        return 'Unknown';
    }
  }
}
