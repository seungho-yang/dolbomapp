import 'package:json_annotation/json_annotation.dart';

part 'message_chat_model.g.dart';

@JsonSerializable()
class MessageChatModel {
  final String? id;
  final String? message;

  @JsonKey(name: 'reception')
  final DateTime? reception;

  final int? type;
  final int? bot;
  final String? image;

  @JsonKey(name: 'isDangerousWords')
  final bool? isDangerousWords;

  MessageChatModel({
    this.id,
    this.message,
    this.reception,
    this.type,
    this.bot,
    this.image,
    this.isDangerousWords,
  });

  factory MessageChatModel.fromJson(Map<String, dynamic> json) =>
      _$MessageChatModelFromJson(json);

  Map<String, dynamic> toJson() => _$MessageChatModelToJson(this);
}
