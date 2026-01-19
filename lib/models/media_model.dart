import 'package:json_annotation/json_annotation.dart';

part 'media_model.g.dart';

@JsonSerializable()
class MediaModel {
  final String? id;
  final String? title;
  final String? serial;
  final int? code;
  final String? file;
  final String? path;
  final bool? isClicked;
  final int? procedure;
  final String? description;
  final int? botNum;

  MediaModel({
    this.id,
    this.title,
    this.serial,
    this.code,
    this.file,
    this.path,
    this.isClicked,
    this.procedure,
    this.description,
    this.botNum,
  });

  factory MediaModel.fromJson(Map<String, dynamic> json) =>
      _$MediaModelFromJson(json);

  Map<String, dynamic> toJson() => _$MediaModelToJson(this);
}
