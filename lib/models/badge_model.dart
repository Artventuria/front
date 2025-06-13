class BadgeModel {
  final int id;
  final String name;
  final String description;
  final String imageUrl;
  final String criteria;
  final int points;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool obtained;
  final int progress;

  BadgeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.criteria,
    required this.points,
    required this.createdAt,
    required this.updatedAt,
    required this.obtained,
    required this.progress,
  });

  factory BadgeModel.fromJson(Map<String, dynamic> json) {
    return BadgeModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      criteria: json['criteria'],
      points: json['points'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      obtained: json['obtained'],
      progress: json['progress'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'criteria': criteria,
      'points': points,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'obtained': obtained,
      'progress': progress,
    };
  }
}