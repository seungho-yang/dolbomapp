import 'package:json_annotation/json_annotation.dart';

part 'link_model.g.dart';

/// Link 모델 - 공지사항 및 FAQ 데이터
/// classification: 'N' = 공지사항, 'F' = FAQ
@JsonSerializable()
class LinkModel {
  final int? id;
  final String? classification;
  final String? blog;
  @JsonKey(name: 'thumbNail')
  final String? thumbnail;

  LinkModel({
    this.id,
    this.classification,
    this.blog,
    this.thumbnail,
  });

  factory LinkModel.fromJson(Map<String, dynamic> json) =>
      _$LinkModelFromJson(json);

  Map<String, dynamic> toJson() => _$LinkModelToJson(this);

  /// 공지사항 여부
  bool get isNotice => classification == 'N';

  /// FAQ 여부
  bool get isFaq => classification == 'F';
}
