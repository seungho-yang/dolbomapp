// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alarm_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AlarmModel _$AlarmModelFromJson(Map<String, dynamic> json) => AlarmModel(
  id: json['id'] as String?,
  title: json['title'] as String?,
  contents: json['contents'] as String?,
  on: json['on'] as bool?,
  classification: (json['classification'] as num?)?.toInt(),
  division: json['division'] as String?,
  time: json['time'] as String?,
  ai: (json['ai'] as num?)?.toInt(),
  name: json['name'] as String?,
);

Map<String, dynamic> _$AlarmModelToJson(AlarmModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'contents': instance.contents,
      'on': instance.on,
      'classification': instance.classification,
      'division': instance.division,
      'time': instance.time,
      'ai': instance.ai,
      'name': instance.name,
    };
