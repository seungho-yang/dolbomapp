import 'package:json_annotation/json_annotation.dart';

part 'profile_model.g.dart';

@JsonSerializable()
class ProfileModel {
  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'protectedPerson')
  final String? protectedPerson;

  @JsonKey(name: 'address')
  final String? address;

  @JsonKey(name: 'protectedPhone')
  final String? protectedPhone;

  @JsonKey(name: 'male')
  final bool? male;

  @JsonKey(name: 'phone')
  final String? phone;

  @JsonKey(name: 'agency')
  final String? agency;

  @JsonKey(name: 'latitude')
  final double? latitude;

  @JsonKey(name: 'longitude')
  final double? longitude;

  @JsonKey(name: 'formattedAddress')
  final String? formattedAddress;

  @JsonKey(name: 'administrativeAreaLevel')
  final String? administrativeAreaLevel;

  @JsonKey(name: 'locality')
  final String? locality;

  @JsonKey(name: 'sublocalityLevel')
  final String? sublocalityLevel;

  @JsonKey(name: 'name')
  final String? name;

  ProfileModel({
    this.id,
    this.protectedPerson,
    this.address,
    this.protectedPhone,
    this.male,
    this.phone,
    this.agency,
    this.latitude,
    this.longitude,
    this.formattedAddress,
    this.administrativeAreaLevel,
    this.locality,
    this.sublocalityLevel,
    this.name,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileModelToJson(this);
}
