// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MediaModel _$MediaModelFromJson(Map<String, dynamic> json) => MediaModel(
      id: json['id'] as String?,
      title: json['title'] as String?,
      serial: json['serial'] as String?,
      code: (json['code'] as num?)?.toInt(),
      file: json['file'] as String?,
      path: json['path'] as String?,
      isClicked: json['isClicked'] as bool?,
      procedure: (json['procedure'] as num?)?.toInt(),
      description: json['description'] as String?,
      botNum: (json['botNum'] as num?)?.toInt(),
    );

Map<String, dynamic> _$MediaModelToJson(MediaModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'serial': instance.serial,
      'code': instance.code,
      'file': instance.file,
      'path': instance.path,
      'isClicked': instance.isClicked,
      'procedure': instance.procedure,
      'description': instance.description,
      'botNum': instance.botNum,
    };
