// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'as_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AsModel _$AsModelFromJson(Map<String, dynamic> json) => AsModel(
  dateOfReceipt: json['dateOfReceipt'] as String?,
  id: (json['id'] as num?)?.toInt(),
  symptom: json['symptom'] as String?,
  processingStatus: (json['processingStatus'] as num?)?.toInt(),
  note: json['note'] as String?,
  phone: json['phone'] as String?,
  receptionist: json['receptionist'] as String?,
  isClicked: json['isClicked'] as bool?,
  address: json['address'] as String?,
  sync: json['sync'] as String?,
);

Map<String, dynamic> _$AsModelToJson(AsModel instance) => <String, dynamic>{
  'dateOfReceipt': instance.dateOfReceipt,
  'id': instance.id,
  'symptom': instance.symptom,
  'processingStatus': instance.processingStatus,
  'note': instance.note,
  'phone': instance.phone,
  'receptionist': instance.receptionist,
  'isClicked': instance.isClicked,
  'address': instance.address,
  'sync': instance.sync,
};
