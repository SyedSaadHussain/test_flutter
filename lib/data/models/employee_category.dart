import 'package:mosque_management_system/data/repositories/custom_odoo_client.dart';
import 'package:mosque_management_system/utils/json_utils.dart';
import 'package:mosque_management_system/utils/paged_data.dart';
import 'package:mosque_management_system/utils/shared_preference.dart';
import 'package:odoo_rpc/odoo_rpc.dart';

class EmployeeCategory {
  final int id;
  final String? name;
  final String? type;
  final int?  color;

  EmployeeCategory({
    required this.id,
    required this.name,
    this.color,
    this.type
  });

  factory EmployeeCategory.fromJson(Map<String, dynamic> json) {
    
    return EmployeeCategory(
      id: JsonUtils.toInt(json['id'])!.toInt(),
      name: JsonUtils.toText(json['display_name']),
      color: JsonUtils.toInt(json['color']),
      type: JsonUtils.toText(json['type']),
    );
  }


}

class EmployeeCategoryData extends PagedData<EmployeeCategory>{

}

