import 'package:json_annotation/json_annotation.dart';
import 'profile_model.dart';

part 'message_profile_model.g.dart';

/// 채팅 메시지 모델 (chats 배열용)
class ChatItem {
  final int? id;
  final String? message;
  final String? reception;
  final int? type;
  final int? bot;

  ChatItem({
    this.id,
    this.message,
    this.reception,
    this.type,
    this.bot,
  });

  factory ChatItem.fromJson(Map<String, dynamic> json) {
    return ChatItem(
      id: json['id'] as int?,
      message: json['message'] as String?,
      reception: json['reception'] as String?,
      type: json['type'] as int?,
      bot: json['bot'] as int?,
    );
  }
}

/// Message_Profile_Model - 인형(보호대상자) 정보
/// Java의 Message_Profile_Model과 동일한 구조
@JsonSerializable()
class MessageProfileModel {
  @JsonKey(name: 'id', fromJson: _dynamicToString)
  final String? id;

  @JsonKey(name: 'name', fromJson: _dynamicToString)
  final String? name;

  @JsonKey(name: 'bot', fromJson: _dynamicToInt)
  final int? bot;

  @JsonKey(name: 'battery', fromJson: _dynamicToString)
  final String? battery;

  @JsonKey(name: 'state', fromJson: _dynamicToInt)
  final int? state;

  @JsonKey(name: 'serial', fromJson: _dynamicToString)
  final String? serial;

  @JsonKey(name: 'port', fromJson: _dynamicToInt)
  final int? port;

  @JsonKey(name: 'profile')
  final ProfileModel? profile;

  // 서버에서 타입이 다양하게 올 수 있으므로 변환 처리
  static String? _dynamicToString(dynamic value) {
    if (value == null) return null;
    return value.toString();
  }

  static int? _dynamicToInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }

  // chats 배열 - 마지막 채팅 정보 (API 응답에서 파싱)
  @JsonKey(name: 'chats', fromJson: _chatsFromJson, includeToJson: false)
  List<ChatItem>? chats;

  static List<ChatItem>? _chatsFromJson(dynamic value) {
    if (value == null) return null;
    if (value is List) {
      return value.map((item) => ChatItem.fromJson(item as Map<String, dynamic>)).toList();
    }
    return null;
  }

  // UI용 필드 (API 응답 외)
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? batteryImagePath;

  @JsonKey(includeFromJson: false, includeToJson: false)
  String? lastDialog;

  @JsonKey(includeFromJson: false, includeToJson: false)
  String? lastTime;

  MessageProfileModel({
    this.id,
    this.name,
    this.bot,
    this.battery,
    this.state,
    this.serial,
    this.port,
    this.profile,
    this.chats,
    this.batteryImagePath,
    this.lastDialog,
    this.lastTime,
  });

  /// 마지막 채팅 메시지 반환
  String? get lastChatMessage {
    if (chats != null && chats!.isNotEmpty) {
      return chats!.first.message;
    }
    return lastDialog;
  }

  /// 마지막 채팅 시간 반환 (포맷팅됨)
  String? get lastChatTime {
    if (chats != null && chats!.isNotEmpty) {
      final reception = chats!.first.reception;
      if (reception != null) {
        try {
          final dateTime = DateTime.parse(reception);
          final now = DateTime.now();
          final diff = now.difference(dateTime);

          if (diff.inDays > 0) {
            return '${dateTime.month}/${dateTime.day}';
          } else {
            return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
          }
        } catch (e) {
          return null;
        }
      }
    }
    return lastTime;
  }

  factory MessageProfileModel.fromJson(Map<String, dynamic> json) =>
      _$MessageProfileModelFromJson(json);

  Map<String, dynamic> toJson() => _$MessageProfileModelToJson(this);

  /// 이름에서 _ 이후 부분만 추출 (Java 로직과 동일)
  String get displayName {
    if (name == null) return '';
    if (name!.contains('_')) {
      final parts = name!.split('_');
      return parts.last;
    }
    return name!;
  }

  /// bot 값에 따른 이미지 경로 반환
  String get botImagePath {
    switch (bot) {
      case 8:
        return 'assets/images/mapodong.png';
      case 13:
        return 'assets/images/kingstrawberry.png';
      case 14:
        return 'assets/images/dongdaemun.png';
      case 17:
        return 'assets/images/haeon.png';
      case 19:
        return 'assets/images/hamo.png';
      case 20:
        return 'assets/images/atongii.png';
      case 22:
        return 'assets/images/gumdoll.png';
      case 23:
        return 'assets/images/gumsunii.png';
      case 24:
        return 'assets/images/bamangii.png';
      case 25:
        return 'assets/images/sangii.png';
      case 26:
        return 'assets/images/pepper.png';
      case 27:
        return 'assets/images/organic.png';
      case 28:
        return 'assets/images/future.png';
      case 30:
        return 'assets/images/sun_on.png';
      case 31:
        return 'assets/images/jangsangii.png';
      case 32:
      case 33:
        return 'assets/images/jadu.png';
      case 34:
        return 'assets/images/rumi.png';
      case 35:
        return 'assets/images/gold_dragon.png';
      default:
        return 'assets/images/bokdongii.png';
    }
  }
}
