import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:mosque_management_system/utils/extension.dart';
import 'package:mosque_management_system/utils/json_utils.dart';
import 'package:mosque_management_system/utils/paged_data.dart';
import 'package:odoo_rpc/odoo_rpc.dart';

class Meter extends EditableGrid {
  String? name;
  String? attachmentId;
  bool? mosqueShared;
  String? uniqueId;
  int id;

  Meter.shallowCopy(Meter other)
      : id = other.id,
        name = other.name,
        mosqueShared = other.mosqueShared,
        attachmentId=other.attachmentId,
        uniqueId=other.uniqueId;


  Meter({
    required this.id,
    this.name,
    this.attachmentId,
    this.mosqueShared,
    this.uniqueId
  });
  factory Meter.fromJsonObject(Map<String, dynamic> json) {
  

    //json['no_planned']=false;
    return Meter(
      id: JsonUtils.toInt(json['id'])!.toInt(),
      name: JsonUtils.toText(json['name']),
      attachmentId: JsonUtils.toText(json['attachment_id']),
      mosqueShared: JsonUtils.toBoolean(json['mosque_shared']),
      uniqueId: JsonUtils.toUniqueId(json['__last_update']),
    );
  }
}