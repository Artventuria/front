import 'package:json_annotation/json_annotation.dart';
import 'artwork_dimensions_model.dart';

part 'artwork_metadata_model.g.dart';

@JsonSerializable()
class ArtworkMetadataModel {
  final String id;
  
  @JsonKey(name: 'artwork_id')
  final int artworkId;
  
  @JsonKey(name: 'description_extended')
  final String descriptionExtended;
  
  @JsonKey(name: 'historical_context')
  final String historicalContext;
  
  final List<String> materials;
  final ArtworkDimensionsModel dimensions;
  final List<String> tags;
  
  @JsonKey(name: 'external_links')
  final List<String> externalLinks;
  
  @JsonKey(name: 'image_url')
  final String imageUrl;
  
  @JsonKey(name: 'temporary_exhibition')
  final bool temporaryExhibition;
  
  @JsonKey(name: 'additional_details')
  final String additionalDetails;
  
  @JsonKey(name: 'created_at')
  final String createdAt;
  
  @JsonKey(name: 'updated_at')
  final String updatedAt;

  ArtworkMetadataModel({
    required this.id,
    required this.artworkId,
    required this.descriptionExtended,
    required this.historicalContext,
    required this.materials,
    required this.dimensions,
    required this.tags,
    required this.externalLinks,
    required this.imageUrl,
    required this.temporaryExhibition,
    required this.additionalDetails,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ArtworkMetadataModel.fromJson(Map<String, dynamic> json) => 
      _$ArtworkMetadataModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$ArtworkMetadataModelToJson(this);
}
