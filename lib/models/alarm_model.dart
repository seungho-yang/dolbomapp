import 'package:json_annotation/json_annotation.dart';

part 'alarm_model.g.dart';

/// AlarmModel - 알람 데이터 모델
/// Java의 Alarm_Model.java와 동일한 구조
///
/// classification:
///   0 = 반복 요일 (division: "0123456" 형식, 일월화수목금토)
///   1 = 특정 날짜 (division: "yyyy-MM-dd" 형식)
@JsonSerializable()
class AlarmModel {
  @JsonKey(fromJson: _idFromJson, toJson: _idToJson)
  final String? id;
  final String? title;
  final String? contents;
  final bool? on;
  final int? classification;  // 0: 반복요일, 1: 특정날짜
  final String? division;     // "0123456" 또는 "yyyy-MM-dd"
  final String? time;         // "HH:mm" 형식
  final int? ai;              // 보호대상자 AI ID
  final String? name;         // 보호대상자 이름

  AlarmModel({
    this.id,
    this.title,
    this.contents,
    this.on,
    this.classification,
    this.division,
    this.time,
    this.ai,
    this.name,
  });

  // id는 서버에서 int로 올 수 있으므로 변환 처리
  static String? _idFromJson(dynamic value) {
    if (value == null) return null;
    return value.toString();
  }

  static dynamic _idToJson(String? value) => value;

  factory AlarmModel.fromJson(Map<String, dynamic> json) =>
      _$AlarmModelFromJson(json);

  Map<String, dynamic> toJson() => _$AlarmModelToJson(this);

  /// copyWith 메서드 - immutable 패턴 지원
  AlarmModel copyWith({
    String? id,
    String? title,
    String? contents,
    bool? on,
    int? classification,
    String? division,
    String? time,
    int? ai,
    String? name,
  }) {
    return AlarmModel(
      id: id ?? this.id,
      title: title ?? this.title,
      contents: contents ?? this.contents,
      on: on ?? this.on,
      classification: classification ?? this.classification,
      division: division ?? this.division,
      time: time ?? this.time,
      ai: ai ?? this.ai,
      name: name ?? this.name,
    );
  }

  /// 요일 문자열을 한글 요일 리스트로 변환
  /// "0135" -> ["일", "월", "수", "금"]
  List<String> get selectedDays {
    if (classification != 0 || division == null || division!.isEmpty) {
      return [];
    }
    const days = ['일', '월', '화', '수', '목', '금', '토'];
    return division!.split('').map((char) {
      final idx = int.tryParse(char);
      if (idx != null && idx >= 0 && idx < days.length) {
        return days[idx];
      }
      return '';
    }).where((d) => d.isNotEmpty).toList();
  }

  /// 특정 날짜 반환 (classification == 1인 경우)
  DateTime? get specificDate {
    if (classification != 1 || division == null) return null;
    try {
      return DateTime.parse(division!);
    } catch (e) {
      return null;
    }
  }

  /// 시간을 TimeOfDay로 변환
  ({int hour, int minute})? get timeOfDay {
    if (time == null || !time!.contains(':')) return null;
    final parts = time!.split(':');
    if (parts.length < 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return (hour: hour, minute: minute);
  }
}

/// AlarmPatchModel - 알람 ON/OFF 토글용 모델
/// Java의 Alarm_Patch_Model.java와 동일
class AlarmPatchModel {
  final String id;
  final bool on;

  AlarmPatchModel({
    required this.id,
    required this.on,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'on': on,
  };
}
