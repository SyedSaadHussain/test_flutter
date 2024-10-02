import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:mosque_management_system/utils/extension.dart';
import 'package:mosque_management_system/utils/json_utils.dart';
import 'package:mosque_management_system/utils/paged_data.dart';
import 'package:odoo_rpc/odoo_rpc.dart';

class ComboItem extends EditableGrid {
  String? value;
  dynamic key;


  ComboItem({
    required this.key,
    this.value,
  });
  factory ComboItem.fromJsonObject(Map<String, dynamic> json) {
  
    //json['no_planned']=false;
    return ComboItem(
      key: JsonUtils.toInt(json['id'])!.toInt(),
      value: JsonUtils.toText(json['name']),
    );
  }
  factory ComboItem.fromJson(List<dynamic> json) {

    //json['no_planned']=false;
    return ComboItem(
      key: JsonUtils.toInt(json[0])!.toInt(),
      value: JsonUtils.toText(json[1]),
    );
  }
  factory ComboItem.fromStringJson(List<dynamic> json) {
   
    //json['no_planned']=false;
    return ComboItem(
      key: JsonUtils.toText(json[0]),
      value: JsonUtils.toText(json[1]),
    );
  }
}

class ComboItemData extends PagedData<ComboItem>{

}



class FieldList{
  String? field='';
  String label='';
  List<ComboItem>? list=[];
  FieldList({
    this.field,
    this.label='',
    this.list
  });
  factory FieldList.fromStringJson(String key,Map<String, dynamic> json) {
   
    //json['no_planned']=false;
    return FieldList(
      field:key,
      label: JsonUtils.toText(json['string'])??"",
      list:(json['selection']==null)?null: (json['selection'] as List).map((item) => ComboItem.fromStringJson(item)).toList()
    );
  }
}


class FieldListData{
  List<FieldList> list=[];
  FieldList getField(dynamic key){
    var filteredList = list!.where((rec) => rec.field==key);
    if (filteredList.isNotEmpty) {
      return filteredList.first;
    }else{
      return FieldList(label: "");
    }

  }

  List<ComboItem> getComboList(dynamic field){
    var filteredList = list!.where((rec) => rec.field==field);
    if (filteredList.isNotEmpty) {
      
      return filteredList.first.list!;
    }else{
      return [];
    }
    //return comboList.where((rec) => rec.field==field).first.list;
  }
}

