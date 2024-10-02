import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:mosque_management_system/utils/extension.dart';
import 'package:mosque_management_system/utils/json_utils.dart';
import 'package:mosque_management_system/utils/paged_data.dart';
import 'package:odoo_rpc/odoo_rpc.dart';

class Employee {
  int? id;
  String? name;
  String? jobNumber;
  String? birthday;
  String? identificationId;
  String? uniqueId;
  String? staffRelationType;
  List<int>? categoryIds;
  int? classificationId;
  String? classification;

  Employee.shallowCopy(Employee other)
      : id = other.id,
        name = other.name,
        jobNumber = other.jobNumber,
        birthday=other.birthday,
        identificationId=other.identificationId,
        staffRelationType=other.staffRelationType,
        categoryIds=other.categoryIds,
        classificationId=other.classificationId,
        classification=other.classification,
        uniqueId=other.uniqueId;


  Employee({
    this.id,
    this.name='',
    this.birthday,
    this.categoryIds,
    this.identificationId,
    this.jobNumber,
    this.staffRelationType,
    this.classificationId,
    this.uniqueId

  });
  factory Employee.fromJson(Map<String, dynamic> json) {
  
    return Employee(
      id: JsonUtils.toInt(json['id'])!.toInt(),
      name: JsonUtils.toText(json['display_name']),
      birthday: JsonUtils.toText(json['birthday']),
      categoryIds: JsonUtils.toList(json['category_ids']),
      identificationId: JsonUtils.toText(json['identification_id']),
      jobNumber: JsonUtils.toText(json['number']),
      staffRelationType: JsonUtils.toText(json['staff_relation_type']),
    );
  }


  factory Employee.fromJsonSearch(Map<String, dynamic> json) {
  
    return Employee(
      id: JsonUtils.toInt(json['id'])!.toInt(),
      name: JsonUtils.toText(json['name']),
      identificationId: JsonUtils.toText(json['identification_id']),
      uniqueId: JsonUtils.toUniqueId(json['__last_update']),
    );
  }
}

class EmployeeData extends PagedData<Employee>{

}
