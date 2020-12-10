// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nftData.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NFTData _$NFTDataFromJson(Map<String, dynamic> json) {
  return NFTData()
    ..description = json['description'] as String
    ..externalUrl = json['external_url'] as String
    ..image = json['image'] as String
    ..name = json['name'] as String;
}

Map<String, dynamic> _$NFTDataToJson(NFTData instance) => <String, dynamic>{
      'description': instance.description,
      'external_url': instance.externalUrl,
      'image': instance.image,
      'name': instance.name,
    };
