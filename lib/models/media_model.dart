import 'package:json_annotation/json_annotation.dart';

part 'media_model.g.dart';

@JsonSerializable()
class MediaModel {
  final int? id;
  final String? title;
  final String? url;
  final int? code;
  final String? thumbnail;

  MediaModel({
    this.id,
    this.title,
    this.url,
    this.code,
    this.thumbnail,
  });

  factory MediaModel.fromJson(Map<String, dynamic> json) =>
      _$MediaModelFromJson(json);

  Map<String, dynamic> toJson() => _$MediaModelToJson(this);
}
