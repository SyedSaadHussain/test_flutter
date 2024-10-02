import 'package:mosque_management_system/data/repositories/custom_odoo_client.dart';
import 'package:mosque_management_system/utils/json_utils.dart';
import 'package:mosque_management_system/utils/paged_data.dart';
import 'package:mosque_management_system/utils/shared_preference.dart';
import 'package:odoo_rpc/odoo_rpc.dart';

class Region {
  final int id;
  final String? name;
  final String?  code;
  // Add more fields as needed

  Region({
    required this.id,
    required this.name,
    this.code
  });

  factory Region.fromJson(Map<String, dynamic> json) {
    
    return Region(
      id: JsonUtils.toInt(json['id'])!.toInt(),
      name: JsonUtils.toText(json['name']),
      code: JsonUtils.toText(json['code']),
    );
  }


}

class RegionData extends PagedData<Region>{

}

