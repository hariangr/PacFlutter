import 'package:json_annotation/json_annotation.dart';

part 'paca_protocol.g.dart';

@JsonSerializable()
class PacaProtocolModel {
  String event;
  String payload;

  PacaProtocolModel({this.event, this.payload});

  factory PacaProtocolModel.fromJson(Map<String, dynamic> json) =>
      _$PacaProtocolModelFromJson(json);

  Map<String, dynamic> toJson() => _$PacaProtocolModelToJson(this);
}
