// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blastbiometricstorage.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BlastBiometricStorageData _$BlastBiometricStorageDataFromJson(
        Map<String, dynamic> json) =>
    BlastBiometricStorageData(
      password: json['Password'] as String,
      cloudCredentials: json['CloudCredentials'] as String,
    );

Map<String, dynamic> _$BlastBiometricStorageDataToJson(
        BlastBiometricStorageData instance) =>
    <String, dynamic>{
      'Password': instance.password,
      'CloudCredentials': instance.cloudCredentials,
    };
