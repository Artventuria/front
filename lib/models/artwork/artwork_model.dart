import 'package:json_annotation/json_annotation.dart';
import 'artwork_metadata_model.dart';

part 'artwork_model.g.dart';

@JsonSerializable()
class ArtworkModel {
  final int id;
  final String title;
  final String artist;
  final String description;
  final String status;
  final String location;
  final ArtworkMetadataModel metadata;
  final String? nextPageCursor;
  
  @JsonKey(name: 'creation_date')
  final String creationDate;
  
  @JsonKey(name: 'rarity_points')
  final int rarityPoints;
  
  @JsonKey(name: 'venue_id')
  final String venueId;
  
  @JsonKey(name: 'nfc_tag_id')
  final int nfcTagId;
  
  @JsonKey(name: 'created_at')
  final String createdAt;
  
  @JsonKey(name: 'updated_at')
  final String updatedAt;

  ArtworkModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.description,
    required this.status,
    required this.location,
    required this.metadata,
    required this.creationDate,
    required this.rarityPoints,
    required this.venueId,
    required this.nfcTagId,
    required this.createdAt,
    required this.updatedAt,
    this.nextPageCursor,
  });

  factory ArtworkModel.fromJson(Map<String, dynamic> json) => 
      _$ArtworkModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$ArtworkModelToJson(this);
}
