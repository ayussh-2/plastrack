class TrashClassificationResponse {
  final String material;
  final int confidence;
  final String recyclability;
  final Map<String, dynamic> infrastructureSuitability;
  final Map<String, dynamic> environmentalImpact;
  final String notes;
  final String image;
  final int id;

  TrashClassificationResponse({
    required this.material,
    required this.confidence,
    required this.recyclability,
    required this.infrastructureSuitability,
    required this.environmentalImpact,
    required this.notes,
    required this.image,
    required this.id,
  });

  factory TrashClassificationResponse.fromJson(Map<String, dynamic> json) {
    return TrashClassificationResponse(
      material: json['material'] ?? 'Unknown',
      confidence: json['confidence'] ?? 0,
      recyclability: json['recyclability'] ?? 'Unknown',
      infrastructureSuitability: json['infrastructure_suitability'] ?? {},
      environmentalImpact: json['environmental_impact'] ?? {},
      notes: json['notes'] ?? '',
      image: json['image'] ?? '',
      id: json['id'] ?? 0,
    );
  }
}

class TrashApiResponse {
  final bool success;
  final String message;
  final TrashClassificationResponse? data;

  TrashApiResponse({required this.success, required this.message, this.data});

  factory TrashApiResponse.fromJson(Map<String, dynamic> json) {
    return TrashApiResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data:
          json['data'] != null
              ? TrashClassificationResponse.fromJson(json['data'])
              : null,
    );
  }
}
