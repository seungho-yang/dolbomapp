// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_chat_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageChatModel _$MessageChatModelFromJson(Map<String, dynamic> json) =>
    MessageChatModel(
      id: json['id']?.toString(),
      message: json['message'] as String?,
      reception: json['reception'] == null
          ? null
          : DateTime.parse(json['reception'] as String),
      type: (json['type'] as num?)?.toInt(),
      bot: (json['bot'] as num?)?.toInt(),
      image: json['image'] as String?,
      isDangerousWords: json['isDangerousWords'] as bool?,
    );

Map<String, dynamic> _$MessageChatModelToJson(MessageChatModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'message': instance.message,
      'reception': instance.reception?.toIso8601String(),
      'type': instance.type,
      'bot': instance.bot,
      'image': instance.image,
      'isDangerousWords': instance.isDangerousWords,
    };
