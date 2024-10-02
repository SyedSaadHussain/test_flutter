import 'package:mosque_management_system/data/repositories/custom_odoo_client.dart';
import 'package:mosque_management_system/utils/json_utils.dart';
import 'package:mosque_management_system/utils/paged_data.dart';
import 'package:mosque_management_system/utils/shared_preference.dart';
import 'package:odoo_rpc/odoo_rpc.dart';

class City {
  final int id;
  final String? name;
  final String?  zipcode;

  City({
    required this.id,
    required this.name,
    this.zipcode
  });

  factory City.fromJson(Map<String, dynamic> json) {
   
    return City(
      id: JsonUtils.toInt(json['id'])!.toInt(),
      name: JsonUtils.toText(json['name']),
      zipcode: JsonUtils.toText(json['zipcode']),
    );
  }


}

class CityData extends PagedData<City>{

}

