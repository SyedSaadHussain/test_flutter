import 'package:mosque_management_system/data/repositories/custom_odoo_client.dart';
import 'package:mosque_management_system/utils/json_utils.dart';
import 'package:mosque_management_system/utils/paged_data.dart';
import 'package:mosque_management_system/utils/shared_preference.dart';
import 'package:odoo_rpc/odoo_rpc.dart';

class MoiCenter {
  final int id;
  final String? name;
  final String?  countryState;
  final int?  countryStateId;
  final int?  cityId;
  final String?  city;
  final String?  centerCode;

  // Add more fields as needed

  MoiCenter({
    required this.id,
    required this.name,
    this.centerCode,
    this.city,
    this.cityId,
    this.countryState,
    this.countryStateId
  });

  factory MoiCenter.fromJson(Map<String, dynamic> json) {
  
    return MoiCenter(
      id: JsonUtils.toInt(json['id'])!.toInt(),
      name: JsonUtils.toText(json['name']),
      centerCode: JsonUtils.toText(json['center_code']),
    );
  }


}

class MoiCenterData extends PagedData<MoiCenter>{

}

