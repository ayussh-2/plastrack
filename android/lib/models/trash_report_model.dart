class TrashReportModel {
  final int id;
  final String latitude;
  final String longitude;
  final String? trashType; // Make nullable
  final int severity;
  final String image;
  final String timestamp;
  final String firebaseId;
  final String? aiResponse; // Make nullable if needed

  TrashReportModel({
    required this.id,
    required this.latitude,
    required this.longitude,
    this.trashType, // Optional parameter
    required this.severity,
    required this.image,
    required this.timestamp,
    required this.firebaseId,
    this.aiResponse,
    required String userId,
  });

  factory TrashReportModel.fromJson(Map<String, dynamic> json) {
    return TrashReportModel(
      id: json['id'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      trashType: json['trashType'],
      severity: json['severity'],
      image: json['image'],
      timestamp: json['timestamp'],
      firebaseId: json['firebaseId'],
      aiResponse: json['aiResponse'],
      userId: '',
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
      'timestamp': timestamp,
      'firebaseId': firebaseId,
      'aiResponse': aiResponse,
    };
  }
}
