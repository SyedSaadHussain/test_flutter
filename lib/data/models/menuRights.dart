import 'package:mosque_management_system/data/repositories/custom_odoo_client.dart';
import 'package:mosque_management_system/utils/json_utils.dart';
import 'package:mosque_management_system/utils/shared_preference.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
class Menu{
   bool isRights=false;
  final dynamic filter;

  Menu({this.isRights = false, this.filter=null});

   factory Menu.fromJson(Map<String, dynamic> json) {

     return Menu(
       isRights: (JsonUtils.toBoolean(json['value'])??false),
       filter:  json['filters'],
     );
   }
}

class MenuRights {
  final bool? createMosque;
  final Menu? searchVisit;
  final Menu? mosqueList;
  final bool? createVisit;
  MenuRights({
    this.createMosque,
    this.mosqueList,
    this.createVisit,
    this.searchVisit
  });

  factory MenuRights.fromJson(Map<String, dynamic> json) {
 
    return MenuRights(
      searchVisit: Menu.fromJson(json['SEARCH_VISIT']),
      createMosque:  JsonUtils.toBoolean(json['CREATE_MOSQUE'])??false,
      createVisit:  JsonUtils.toBoolean(json['CREATE_VISIT'])??false,
      mosqueList: Menu.fromJson(json['MOSQUE_LIST']),
    );
  }

}