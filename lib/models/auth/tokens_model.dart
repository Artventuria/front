import 'package:json_annotation/json_annotation.dart';

part 'tokens_model.g.dart';

@JsonSerializable()
class TokensModel {
  @JsonKey(name: 'access_token')
  final String accessToken;
  
  @JsonKey(name: 'refresh_token')
  final String refreshToken;
  
  @JsonKey(name: 'expires_in')
  final int expiresIn;
  
  @JsonKey(name: 'token_type')
  final String tokenType;

  TokensModel({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.tokenType,
  });

  factory TokensModel.fromJson(Map<String, dynamic> json) => _$TokensModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$TokensModelToJson(this);
}
