import 'package:json_annotation/json_annotation.dart';

part 'dangerous_word_model.g.dart';

@JsonSerializable()
class DangerousWordModel {
  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'word')
  final String? word;

  DangerousWordModel({
    this.id,
    this.word,
  });

  factory DangerousWordModel.fromJson(Map<String, dynamic> json) =>
      _$DangerousWordModelFromJson(json);

  Map<String, dynamic> toJson() => _$DangerousWordModelToJson(this);
}
