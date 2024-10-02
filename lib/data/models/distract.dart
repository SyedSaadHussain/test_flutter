import 'package:mosque_management_system/data/repositories/custom_odoo_client.dart';
import 'package:mosque_management_system/utils/json_utils.dart';
import 'package:mosque_management_system/utils/paged_data.dart';
import 'package:mosque_management_system/utils/shared_preference.dart';
import 'package:odoo_rpc/odoo_rpc.dart';

class Distract {
  final int id;
  final String? name;
  final String?  code;
  final String?  distractCode;
  // Add more fields as needed

  Distract({
    required this.id,
    required this.name,
    this.code,
    this.distractCode
  });

  factory Distract.fromJson(Map<String, dynamic> json) {

    return Distract(
      id: JsonUtils.toInt(json['id'])!.toInt(),
      name: JsonUtils.toText(json['name']),
      code: JsonUtils.toText(json['code']),
      distractCode: JsonUtils.toText(json['distract_code']),
    );
  }


}

class DistractData extends PagedData<Distract>{

}

