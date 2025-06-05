import 'package:json_annotation/json_annotation.dart';

part 'artwork_dimensions_model.g.dart';

@JsonSerializable()
class ArtworkDimensionsModel {
  final double depth;
  final double height;
  final String unit;
  final double width;

  ArtworkDimensionsModel({
    required this.depth,
    required this.height,
    required this.unit,
    required this.width,
  });

  factory ArtworkDimensionsModel.fromJson(Map<String, dynamic> json) => 
      _$ArtworkDimensionsModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$ArtworkDimensionsModelToJson(this);
}
