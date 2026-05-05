import 'package:json_annotation/json_annotation.dart';

part 'hub_model.g.dart';

/// SignalR Hub 메시지 모델
/// mode: 68 = 'D' (Dialog), 78 = 'N' (Notification) 등
@JsonSerializable()
class HubModel {
  final int? mode;
  final String? groupName;
  final String? json;

  HubModel({
    this.mode,
    this.groupName,
    this.json,
  });

  factory HubModel.fromJson(Map<String, dynamic> json) =>
      _$HubModelFromJson(json);

  Map<String, dynamic> toJson() => _$HubModelToJson(this);

  /// Dialog 모드 여부 ('D' = 68)
  bool get isDialog => mode == 68;

  /// Notification 모드 여부 ('N' = 78)
  bool get isNotification => mode == 78;

  /// Battery 모드 여부 ('B' = 66)
  bool get isBattery => mode == 66;
}

/// SignalR을 통해 수신되는 메시지 모델
@JsonSerializable()
class HubMessageModel {
  final String? id;
  final String? message;
  final int? bot;
  final int? type;
  final String? reception;

  HubMessageModel({
    this.id,
    this.message,
    this.bot,
    this.type,
    this.reception,
  });

  factory HubMessageModel.fromJson(Map<String, dynamic> json) =>
      _$HubMessageModelFromJson(json);

  Map<String, dynamic> toJson() => _$HubMessageModelToJson(this);
}
