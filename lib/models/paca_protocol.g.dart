// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paca_protocol.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PacaProtocolModel _$PacaProtocolModelFromJson(Map<String, dynamic> json) {
  return PacaProtocolModel(
      event: json['event'] as String, payload: json['payload'] as String);
}

Map<String, dynamic> _$PacaProtocolModelToJson(PacaProtocolModel instance) =>
    <String, dynamic>{'event': instance.event, 'payload': instance.payload};
