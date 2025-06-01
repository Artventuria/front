import 'package:json_annotation/json_annotation.dart';

import 'tokens_model.dart';
import 'user_model.dart';

part 'auth_response_model.g.dart';

@JsonSerializable()
class AuthResponseModel {
  final TokensModel tokens;
  final UserModel user;

  AuthResponseModel({
    required this.tokens,
    required this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) => 
      _$AuthResponseModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$AuthResponseModelToJson(this);
}
