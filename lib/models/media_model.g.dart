// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MediaModel _$MediaModelFromJson(Map<String, dynamic> json) => MediaModel(
  id: (json['id'] as num?)?.toInt(),
  title: json['title'] as String?,
  url: json['url'] as String?,
  code: (json['code'] as num?)?.toInt(),
  thumbnail: json['thumbnail'] as String?,
);

Map<String, dynamic> _$MediaModelToJson(MediaModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'url': instance.url,
      'code': instance.code,
      'thumbnail': instance.thumbnail,
    };
