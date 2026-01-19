import 'package:json_annotation/json_annotation.dart';

part 'link_model.g.dart';

/// Link 모델 - 공지사항 및 FAQ 데이터
/// classification: 78 = 'N' (공지사항), 70 = 'F' (FAQ)
@JsonSerializable()
class LinkModel {
  final int? id;
  final int? classification;
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

  /// 공지사항 여부 (78 = 'N')
  bool get isNotice => classification == 78;

  /// FAQ 여부 (70 = 'F')
  bool get isFaq => classification == 70;
}
