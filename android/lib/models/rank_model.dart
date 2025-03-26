class RankModel {
  final int rank;
  final int points;

  RankModel({required this.rank, required this.points});

  factory RankModel.fromJson(Map<String, dynamic> json) {
    return RankModel(rank: json['rank'] ?? 0, points: json['points'] ?? 0);
  }

  @override
  String toString() {
    return 'RankModel(rank: $rank, points: $points)';
  }
}
