class HotspotReport {
  final int id;
  final String trashType;
  final int severity;
  final DateTime timestamp;

  HotspotReport({
    required this.id,
    required this.trashType,
    required this.severity,
    required this.timestamp,
  });

  factory HotspotReport.fromJson(Map<String, dynamic> json) {
    return HotspotReport(
      id: json['id'],
      trashType: json['trashType'],
      severity: json['severity'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class Hotspot {
  final double latGroup;
  final double lngGroup;
  final int reportCount;
  final double avgSeverity;
  final List<HotspotReport> reports;

  Hotspot({
    required this.latGroup,
    required this.lngGroup,
    required this.reportCount,
    required this.avgSeverity,
    required this.reports,
  });

  factory Hotspot.fromJson(Map<String, dynamic> json) {
    return Hotspot(
      latGroup: json['latGroup'].toDouble(),
      lngGroup: json['lngGroup'].toDouble(),
      reportCount: json['reportCount'],
      avgSeverity: json['avgSeverity'].toDouble(),
      reports:
          (json['reports'] as List)
              .map((report) => HotspotReport.fromJson(report))
              .toList(),
    );
  }
}
