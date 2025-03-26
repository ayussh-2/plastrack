class LeaderboardUserModel {
  final String name;
  final int points;
  final String profilePicture;
  final String city;
  final String state;

  LeaderboardUserModel({
    required this.name,
    required this.points,
    required this.profilePicture,
    required this.city,
    required this.state,
  });

  factory LeaderboardUserModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardUserModel(
      name: json['name'] ?? '',
      points: json['points'] ?? 0,
      profilePicture: json['profilePicture'] ?? 'default-avatar.png',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
    );
  }
}

class LeaderboardResponse {
  final List<LeaderboardUserModel> users;
  final int totalPages;
  final int currentPage;

  LeaderboardResponse({
    required this.users,
    required this.totalPages,
    required this.currentPage,
  });

  factory LeaderboardResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final users =
        (data['users'] as List)
            .map((user) => LeaderboardUserModel.fromJson(user))
            .toList();

    return LeaderboardResponse(
      users: users,
      totalPages: data['totalPages'] ?? 1,
      currentPage: data['currentPage'] ?? 1,
    );
  }
}
