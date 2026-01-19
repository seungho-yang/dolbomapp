// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hub_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HubModel _$HubModelFromJson(Map<String, dynamic> json) => HubModel(
      mode: (json['mode'] as num?)?.toInt(),
      groupName: json['groupName'] as String?,
      json: json['json'] as String?,
    );

Map<String, dynamic> _$HubModelToJson(HubModel instance) => <String, dynamic>{
      'mode': instance.mode,
      'groupName': instance.groupName,
      'json': instance.json,
    };

HubMessageModel _$HubMessageModelFromJson(Map<String, dynamic> json) =>
    HubMessageModel(
      id: json['id'] as String?,
      message: json['message'] as String?,
      bot: (json['bot'] as num?)?.toInt(),
      type: (json['type'] as num?)?.toInt(),
      reception: json['reception'] as String?,
    );

Map<String, dynamic> _$HubMessageModelToJson(HubMessageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'message': instance.message,
      'bot': instance.bot,
      'type': instance.type,
      'reception': instance.reception,
    };
