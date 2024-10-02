import 'package:mosque_management_system/data/repositories/custom_odoo_client.dart';
import 'package:mosque_management_system/utils/json_utils.dart';
import 'package:mosque_management_system/utils/paged_data.dart';
import 'package:mosque_management_system/utils/shared_preference.dart';
import 'package:odoo_rpc/odoo_rpc.dart';

class Database {
   int? id;
   String? name;
   String?  dbName;
   String?  langCode;
   String?  clientName;
   String?  baseUrl;

  // Add more fields as needed

   Database({
    this.name,
     this.id,
     this.clientName,
     this.dbName,
     this.baseUrl,
     this.langCode
  });

  factory Database.fromJson(Map<String, dynamic> json) {
  
    return Database(
      id: JsonUtils.toInt(json['Id']),
      name: JsonUtils.toText(json['Name']),
      langCode: JsonUtils.toText(json['LangCode']),
      dbName: JsonUtils.toText(json['DbName']),
      //baseUrl: "http://172.20.10.76:8069",
      baseUrl: JsonUtils.toText(json['BaseURL']),
      clientName: JsonUtils.toText(json['ClientName']),
    );
  }


}


