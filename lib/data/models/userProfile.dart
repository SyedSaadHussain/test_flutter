import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:mosque_management_system/utils/extension.dart';
import 'package:mosque_management_system/utils/json_utils.dart';
import 'package:mosque_management_system/utils/paged_data.dart';
import 'package:odoo_rpc/odoo_rpc.dart';

class UserProfile {
  int userId;
  List<int>? companyIds;
  String? name;
  String? company;
  int? companyId;
  String? jobTitle;
  int? employeeId;
  String? uniqueId;
  int? partnerId;
  String? partner;
  String? mobilePhone;
  String? workEmail;
  String? workLocation;
  String? workAddress;
  String? manager;
  String? signature;
  String language;
  String tz;

  UserProfile({
    required this.userId,
     this.name='',
     this.jobTitle='',
    this.employeeId,
    this.uniqueId='',
    this.companyIds=const [],
    this.partnerId,
    this.partner,
    this.company,
    this.companyId,
    this.mobilePhone,
    this.workEmail,
    this.workLocation,
    this.workAddress,
    this.manager,
    this.signature,
    this.language="ar_001",
    this.tz="Asia/Riyadh"
  });
  factory UserProfile.fromJson(Map<String, dynamic> json) {

    return UserProfile(
      company:(((json['company_id']??false)==false?[]:json['company_id']) as List<dynamic>).getName(),
      companyId:(((json['company_id']??false)==false?[]:json['company_id']) as List<dynamic>).getId(),
      userId: JsonUtils.toInt(json['id'])!.toInt(),
      name: JsonUtils.toText(json['name']),
      jobTitle: JsonUtils.toText(json['job_title']),
      employeeId:(((json['employee_id']??false)==false?[]:json['employee_id']) as List<dynamic>).getId(),
      partner:(((json['partner_id']??false)==false?[]:json['partner_id']) as List<dynamic>).getName(),
      partnerId:(((json['partner_id']??false)==false?[]:json['partner_id']) as List<dynamic>).getId(),
      uniqueId:(json['__last_update']??false)==false?"":json['__last_update'].replaceAll(RegExp(r'[^0-9]'), ''),
      companyIds:(json['company_ids']??false)==false?[]:List.from(json['company_ids'],
      ),
      manager:(((json['employee_parent_id']??false)==false?[]:json['employee_parent_id']) as List<dynamic>).getName(),
      workEmail: JsonUtils.toText(json['work_email']),
      mobilePhone: JsonUtils.toText(json['mobile_phone']),
      workLocation:(((json['work_location_id']??false)==false?[]:json['work_location_id']) as List<dynamic>).getName(),
      signature: JsonUtils.toText(json['signature']),
      workAddress: (((json['address_id']??false)==false?[]:json['address_id']) as List<dynamic>).getName(),
    );
  }


  factory UserProfile.fromJsonSearch(dynamic responseData) {
 
    return UserProfile(
        userId: responseData[0],
        name: responseData[1]
    );
  }
}

class UserProfileData extends PagedData<UserProfile>{

}
