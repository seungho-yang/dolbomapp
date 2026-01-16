import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  @JsonKey(name: 'Id')
  final String? id;

  @JsonKey(name: 'Token')
  final String? token;

  @JsonKey(name: 'RefreshToken')
  final String? refreshToken;

  @JsonKey(name: 'Name')
  final String? name;

  @JsonKey(name: 'NickName')
  final String? nickName;

  @JsonKey(name: 'LastName')
  final String? lastName;

  @JsonKey(name: 'Email')
  final String? email;

  @JsonKey(name: 'Gender')
  final String? gender;

  @JsonKey(name: 'Birthday')
  final String? birthday;

  @JsonKey(name: 'PictureUrl')
  final String? pictureUrl;

  @JsonKey(name: 'LoggedInWithSNSAccount')
  final bool? loggedInWithSNSAccount;

  @JsonKey(name: 'PhoneNumber')
  final String? phoneNumber;

  UserModel({
    this.id,
    this.token,
    this.refreshToken,
    this.name,
    this.nickName,
    this.lastName,
    this.email,
    this.gender,
    this.birthday,
    this.pictureUrl,
    this.loggedInWithSNSAccount,
    this.phoneNumber,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
