// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfileModel _$ProfileModelFromJson(Map<String, dynamic> json) => ProfileModel(
  id: (json['id'] as num?)?.toInt(),
  protectedPerson: json['protectedPerson'] as String?,
  address: json['address'] as String?,
  protectedPhone: json['protectedPhone'] as String?,
  male: json['male'] as bool?,
  phone: json['phone'] as String?,
  agency: json['agency'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  formattedAddress: json['formattedAddress'] as String?,
  administrativeAreaLevel: json['administrativeAreaLevel'] as String?,
  locality: json['locality'] as String?,
  sublocalityLevel: json['sublocalityLevel'] as String?,
  name: json['name'] as String?,
);

Map<String, dynamic> _$ProfileModelToJson(ProfileModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'protectedPerson': instance.protectedPerson,
      'address': instance.address,
      'protectedPhone': instance.protectedPhone,
      'male': instance.male,
      'phone': instance.phone,
      'agency': instance.agency,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'formattedAddress': instance.formattedAddress,
      'administrativeAreaLevel': instance.administrativeAreaLevel,
      'locality': instance.locality,
      'sublocalityLevel': instance.sublocalityLevel,
      'name': instance.name,
    };
