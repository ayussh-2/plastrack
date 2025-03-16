class TrashReportModel {
  final int id;
  final String latitude;
  final String longitude;
  final String? trashType;
  final int severity;
  final String image;
  final DateTime timestamp;
  final String userId;
  final String aiResponse;

  TrashReportModel({
    required this.id,
    required this.latitude,
    required this.longitude,
    this.trashType,
    required this.severity,
    required this.image,
    required this.timestamp,
    required this.userId,
    required this.aiResponse,
  });

  factory TrashReportModel.fromJson(Map<String, dynamic> json) {
    return TrashReportModel(
      id: json['id'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      trashType: json['trashType'],
      severity: json['severity'],
      image: json['image'],
      timestamp: DateTime.parse(json['timestamp']),
      userId: json['userId'],
      aiResponse: json['aiResponse'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'trashType': trashType,
      'severity': severity,
      'image': image,
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
      'aiResponse': aiResponse,
    };
  }
}
