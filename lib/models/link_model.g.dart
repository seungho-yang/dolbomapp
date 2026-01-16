// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'link_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LinkModel _$LinkModelFromJson(Map<String, dynamic> json) => LinkModel(
      id: (json['id'] as num?)?.toInt(),
      classification: json['classification'] as String?,
      blog: json['blog'] as String?,
      thumbnail: json['thumbNail'] as String?,
    );

Map<String, dynamic> _$LinkModelToJson(LinkModel instance) => <String, dynamic>{
      'id': instance.id,
      'classification': instance.classification,
      'blog': instance.blog,
      'thumbNail': instance.thumbnail,
    };
