import 'package:mosque_management_system/data/repositories/custom_odoo_client.dart';
import 'package:mosque_management_system/utils/json_utils.dart';
import 'package:mosque_management_system/utils/paged_data.dart';
import 'package:mosque_management_system/utils/shared_preference.dart';
import 'package:odoo_rpc/odoo_rpc.dart';

class DeviceInformation {
   int id;
   int? employeeId;
   String? name;
   String?  os;
   String?  osVersion;
   String?  imei;
   String?  status;
  // Add more fields as needed

  DeviceInformation({
    required this.id,
    this.name,
    this.employeeId,
    this.imei,
    this.status,
    this.osVersion,
    this.os
  });

   factory DeviceInformation.fromJson(Map<String, dynamic> json) {

     return DeviceInformation(
       id: JsonUtils.toInt(json['id'])!.toInt(),
       name: JsonUtils.toText(json['device_name']),
       employeeId: JsonUtils.getId(json['employee_id']),
       imei: JsonUtils.toText(json['imei']),
       status: JsonUtils.toText(json['status']),
       osVersion: JsonUtils.toText(json['os_version']),
       os: JsonUtils.toText(json['device_os']),
     );
   }
}

