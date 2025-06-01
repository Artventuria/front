import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final int id;
  final String username;
  final String email;
  final int points;
  
  @JsonKey(name: 'lastLogin')
  final String lastLogin;
  
  @JsonKey(name: 'createdAt')
  final String createdAt;
  
  @JsonKey(name: 'updatedAt')
  final String updatedAt;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.points,
    required this.lastLogin,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
