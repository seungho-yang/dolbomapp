import 'package:json_annotation/json_annotation.dart';

part 'alarm_model.g.dart';

@JsonSerializable()
class AlarmModel {
  final String? id;
  final String? title;
  final String? contents;
  final bool? on;
  final int? classification;
  final String? division;
  final String? time;
  final int? ai;
  final String? name;

  AlarmModel({
    this.id,
    this.title,
    this.contents,
    this.on,
    this.classification,
    this.division,
    this.time,
    this.ai,
    this.name,
  });

  factory AlarmModel.fromJson(Map<String, dynamic> json) =>
      _$AlarmModelFromJson(json);

  Map<String, dynamic> toJson() => _$AlarmModelToJson(this);
}
