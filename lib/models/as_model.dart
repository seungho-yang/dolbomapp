import 'package:json_annotation/json_annotation.dart';

part 'as_model.g.dart';

@JsonSerializable()
class AsModel {
  @JsonKey(name: 'dateOfReceipt')
  final String? dateOfReceipt;

  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'symptom')
  final String? symptom;

  @JsonKey(name: 'processingStatus')
  final int? processingStatus;

  @JsonKey(name: 'note')
  final String? note;

  @JsonKey(name: 'phone')
  final String? phone;

  @JsonKey(name: 'receptionist')
  final String? receptionist;

  @JsonKey(name: 'isClicked')
  final bool? isClicked;

  @JsonKey(name: 'address')
  final String? address;

  @JsonKey(name: 'sync')
  final String? sync;

  AsModel({
    this.dateOfReceipt,
    this.id,
    this.symptom,
    this.processingStatus,
    this.note,
    this.phone,
    this.receptionist,
    this.isClicked,
    this.address,
    this.sync,
  });

  factory AsModel.fromJson(Map<String, dynamic> json) =>
      _$AsModelFromJson(json);

  Map<String, dynamic> toJson() => _$AsModelToJson(this);
}
