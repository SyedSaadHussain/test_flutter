import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart';
import 'package:mosque_management_system/utils/extension.dart';
import 'package:mosque_management_system/utils/json_utils.dart';
import 'package:mosque_management_system/utils/paged_data.dart';
import 'package:odoo_rpc/odoo_rpc.dart';

class Attachment  extends EditableGrid{
  String? name;
  String? mimetype;
  int id;
  bool isShowDeleteButton;

  String get extension => name==null?'':name!.split('.').last.toUpperCase();

  Widget get icon {

    Widget result = Icon(Icons.archive_outlined);
    //return FaIcon(FontAwesomeIcons.fileExcel, size: 30.0, color: Colors.green);
    switch (this.mimetype ?? "") {
      case "application/zip":
        result = FaIcon(FontAwesomeIcons.fileArchive, size: 30.0, color: Colors.blueAccent);
        break;
      case "application/vnd.ms-powerpoint":
        result = FaIcon(FontAwesomeIcons.filePowerpoint, size: 30.0, color: Colors.brown);
        break;
      case "application/vnd.ms-excel":
        result = FaIcon(FontAwesomeIcons.fileExcel, size: 30.0, color: Colors.green);
        break;
      case "text/plain":
        result = FaIcon(FontAwesomeIcons.fileAlt,color: Colors.orangeAccent,size: 30,);
        break;
      case "text/html":
        result = FaIcon(FontAwesomeIcons.fileCode,color: Colors.blueAccent,size: 30,);
        break;
      case "application/pdf":
        result = FaIcon(FontAwesomeIcons.filePdf,color: Colors.redAccent,size: 30,);
        break;
      case "image/jpeg":
        result = FaIcon(FontAwesomeIcons.fileImage,color: Colors.blue,size: 30,);
        break;
      case "image/png":
        result = FaIcon(FontAwesomeIcons.fileImage,color: Colors.blue,size: 30,);
        break;
      case "application/octet-stream":
        result = FaIcon(FontAwesomeIcons.fileImage,color: Colors.blue,size: 30,);
        break;
      default:
        result = FaIcon(FontAwesomeIcons.file,color: Colors.blueGrey,size: 30,);
    }
    return result;
  }

  Attachment.shallowCopy(Attachment other)
      : id = other.id,
        name = other.name,
        isShowDeleteButton = other.isShowDeleteButton,
        mimetype = other.mimetype;


  Attachment({
    required this.id,
    this.name,
    this.mimetype,
    this.isShowDeleteButton=false
  });

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      id: JsonUtils.toInt(json['id'])!.toInt(),
      name: JsonUtils.toText(json['name']??json["filename"]),
      mimetype: JsonUtils.toText(json['mimetype'])
    );
  }
}