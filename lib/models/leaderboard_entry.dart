class LeaderboardEntry {
  final int userId;
  final String username;
  final int rank;
  final int points;
  final int badgeCount;

  LeaderboardEntry({
    required this.userId,
    required this.username,
    required this.rank,
    required this.points,
    required this.badgeCount,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      userId: json['userId'],
      username: json['username'],
      rank: json['rank'],
      points: json['points'],
      badgeCount: json['badgeCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'rank': rank,
      'points': points,
      'badgeCount': badgeCount,
    };
  }
}
