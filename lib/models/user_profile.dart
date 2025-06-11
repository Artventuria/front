class UserProfile {
  final int id;
  final String username;
  final String email;
  final int points;
  final String lastLogin;
  final String createdAt;
  final String updatedAt;
  final int badgeCount;
  final int artworkCount;

  UserProfile({
    required this.id,
    required this.username,
    required this.email,
    required this.points,
    required this.lastLogin,
    required this.createdAt,
    required this.updatedAt,
    required this.badgeCount,
    required this.artworkCount,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      points: json['points'],
      lastLogin: json['lastLogin'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      badgeCount: json['badgeCount'],
      artworkCount: json['artworkCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'points': points,
      'lastLogin': lastLogin,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'badgeCount': badgeCount,
      'artworkCount': artworkCount,
    };
  }
}
