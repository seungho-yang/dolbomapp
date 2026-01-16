// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dangerous_word_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DangerousWordModel _$DangerousWordModelFromJson(Map<String, dynamic> json) =>
    DangerousWordModel(
      id: (json['id'] as num?)?.toInt(),
      word: json['word'] as String?,
    );

Map<String, dynamic> _$DangerousWordModelToJson(DangerousWordModel instance) =>
    <String, dynamic>{'id': instance.id, 'word': instance.word};
