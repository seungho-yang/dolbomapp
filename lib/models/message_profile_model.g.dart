// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageProfileModel _$MessageProfileModelFromJson(Map<String, dynamic> json) =>
    MessageProfileModel(
      id: MessageProfileModel._dynamicToString(json['id']),
      name: MessageProfileModel._dynamicToString(json['name']),
      bot: MessageProfileModel._dynamicToInt(json['bot']),
      battery: MessageProfileModel._dynamicToString(json['battery']),
      state: MessageProfileModel._dynamicToInt(json['state']),
      serial: MessageProfileModel._dynamicToString(json['serial']),
      port: MessageProfileModel._dynamicToInt(json['port']),
      profile: json['profile'] == null
          ? null
          : ProfileModel.fromJson(json['profile'] as Map<String, dynamic>),
      chats: MessageProfileModel._chatsFromJson(json['chats']),
    );

Map<String, dynamic> _$MessageProfileModelToJson(
  MessageProfileModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'bot': instance.bot,
  'battery': instance.battery,
  'state': instance.state,
  'serial': instance.serial,
  'port': instance.port,
  'profile': instance.profile,
};
