import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:mosque_management_system/utils/extension.dart';
import 'package:mosque_management_system/utils/json_utils.dart';
import 'package:mosque_management_system/utils/paged_data.dart';
import 'package:odoo_rpc/odoo_rpc.dart';

class ResPartner {
  int? id;
  String? name;
  String? displayName;
  String? title;


  ResPartner({
    required this.id,
    this.name,
    this.displayName,
    this.title,
  });
  factory ResPartner.fromJson(Map<String, dynamic> json) {
    return ResPartner(
      id: JsonUtils.toInt(json['id']),
      name: JsonUtils.toText(json['name']),
      displayName: JsonUtils.toText(json['display_name']),
      title: JsonUtils.toText(json['title']),
    );
  }

}

class ResPartnerData extends PagedData<ResPartner>{

}

