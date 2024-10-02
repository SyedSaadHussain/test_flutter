import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:mosque_management_system/utils/extension.dart';
import 'package:mosque_management_system/utils/json_utils.dart';
import 'package:mosque_management_system/utils/paged_data.dart';
import 'package:odoo_rpc/odoo_rpc.dart';

class MosqueRegion {
  int? id;
  String? name;
  int? number;
  String? code;


  MosqueRegion({
    required this.id,
    this.name,
    this.code,
    this.number
  });
  factory MosqueRegion.fromJson(Map<String, dynamic> json) {
    return MosqueRegion(
      id: JsonUtils.toInt(json['id']),
      name: JsonUtils.toText(json['name']),
      code: JsonUtils.toText(json['code']),
      number: JsonUtils.toInt(json['number']),
    );
  }

}

