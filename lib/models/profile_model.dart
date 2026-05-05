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

  ProfileModel copyWith({
    int? id,
    String? protectedPerson,
    String? address,
    String? protectedPhone,
    bool? male,
    String? phone,
    String? agency,
    double? latitude,
    double? longitude,
    String? formattedAddress,
    String? administrativeAreaLevel,
    String? locality,
    String? sublocalityLevel,
    String? name,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      protectedPerson: protectedPerson ?? this.protectedPerson,
      address: address ?? this.address,
      protectedPhone: protectedPhone ?? this.protectedPhone,
      male: male ?? this.male,
      phone: phone ?? this.phone,
      agency: agency ?? this.agency,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      formattedAddress: formattedAddress ?? this.formattedAddress,
      administrativeAreaLevel: administrativeAreaLevel ?? this.administrativeAreaLevel,
      locality: locality ?? this.locality,
      sublocalityLevel: sublocalityLevel ?? this.sublocalityLevel,
      name: name ?? this.name,
    );
  }
}
