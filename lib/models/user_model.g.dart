// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: json['Id'] as String?,
  token: json['Token'] as String?,
  refreshToken: json['RefreshToken'] as String?,
  name: json['Name'] as String?,
  nickName: json['NickName'] as String?,
  lastName: json['LastName'] as String?,
  email: json['Email'] as String?,
  gender: json['Gender'] as String?,
  birthday: json['Birthday'] as String?,
  pictureUrl: json['PictureUrl'] as String?,
  loggedInWithSNSAccount: json['LoggedInWithSNSAccount'] as bool?,
  phoneNumber: json['PhoneNumber'] as String?,
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'Id': instance.id,
  'Token': instance.token,
  'RefreshToken': instance.refreshToken,
  'Name': instance.name,
  'NickName': instance.nickName,
  'LastName': instance.lastName,
  'Email': instance.email,
  'Gender': instance.gender,
  'Birthday': instance.birthday,
  'PictureUrl': instance.pictureUrl,
  'LoggedInWithSNSAccount': instance.loggedInWithSNSAccount,
  'PhoneNumber': instance.phoneNumber,
};
