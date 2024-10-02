import 'dart:convert';

import 'package:mosque_management_system/data/models/User.dart';
import 'package:mosque_management_system/data/models/device_info.dart';
import 'package:mosque_management_system/data/models/employee.dart';
import 'package:mosque_management_system/data/models/mosque.dart';
import 'package:mosque_management_system/data/models/mosque_region.dart';
import 'package:mosque_management_system/data/models/userProfile.dart';
import 'package:mosque_management_system/data/models/visit.dart';
import 'package:mosque_management_system/data/repositories/custom_odoo_client.dart';
import 'package:mosque_management_system/utils/config.dart';
import 'package:mosque_management_system/utils/shared_preference.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'package:http/http.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:core';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;


class VisitRepository {
  late CustomOdooClient client;
  late UserProfile _userProfile;

  VisitRepository(client){
    this.client = client;
  }
  set userProfile(UserProfile user) {
    _userProfile = user;
  }

  // Getter for age
  UserProfile get userProfile => _userProfile;

  //region For Visits
  Future<List<dynamic>> getAllVisits(dynamic domain,int pageSize,int pageIndex) async {

    try {
      dynamic _payload={
        'model': 'visit.visit',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'limit': pageSize,
          "offset" :  ((pageIndex-1)*pageSize),
          'context': {
            "lang": _userProfile.language,
            "tz": "Asia/Riyadh",
            "uid": _userProfile.userId,
            "allowed_company_ids": [
              _userProfile.companyId
            ],
            "bin_size": true
          },
          'domain': domain,
          'fields': ["name", "mosque_seq_no", "date_of_visit", "priority","observer",'__last_update','state','stage_id'],
          "order":"stage_id asc,priority desc"
        },

      };
     

      var response = await client.callKwCustom(_payload);
    
      return response.toList();
    }catch (e) {


      throw e;
    }
  }



  Future<dynamic> getVisitDetail(int id) async {
    try {

      dynamic _payload={
        "args": [
          [
            id
          ],
          [
            "active",
            "__last_update",
            "state",
            "display_button_send",
            "display_button_accept",
            "display_button_refuse",
            "stage_id",
            "display_button_set_to_draft",
            "btn_start",
            "request_type_id",
            "name",
            "mosque_seq_no",
            "date_of_visit",
            "prayer_name",
            "created_by",
            "is_friday",
            "khateeb_id",
            "khateeb_present",
            "khateeb_absent_gomaa",
            "khateeb_notes",
            "imam_emp_id",
            "imam_present",
            "imam_off_work",
            "imam_off_work_date",
            "imam_off_prayers",
            "imam_off_prayers_id",
            "imam_notes",
            "muazzin_emp_id",
            "moazen_present",
            "moazen_exist",
            "moazen_off_work",
            "moazen_off_prayers",
            "moazen_off_prayers_id",
            "moazen_notes",
            "servant_id",
            "worker_present",
            "worker_exist",
            "worker_rate",
            "worker_notes",
            "mosque_clean",
            "mosque_clean_notes",
            "carpet_quality",
            "carpet_quality_notes",
            "wc_clean",
            "wc_clean_notes",
            "air_condition",
            "air_condition_notes",
            "sound_system",
            "sound_system_notes",
            "close_outside_horn",
            "inside_horn",
            "outside_horn",
            "wc_maintenance",
            "wc_maintenance_notes",
            "ablution_wash",
            "ablution_wash_notes",
            "observer",
            "visit_type",
            "electric_meter_violation",
            "electric_meter_violation_note",
            "electric_meter_violation_attachment",
            "water_meter_violation",
            "water_meter_violation_note",
            "water_meter_violation_attachment",
            "mosque_violation",
            "mosque_violation_note",
            "mosque_violation_attachment",
            "cleaning_material",
            "holy_quran_violation",
            "holy_quran_violation_note",
            "binary_holy_quran_violation_attachment",
            "description",
            "message_follower_ids",
            "activity_ids",
            "message_ids",
            "display_name"
          ]
        ],
        "model": "visit.visit",
        "method": "read",
        "kwargs": {
          "context": {
            "lang": _userProfile.language,
            "tz": "Asia/Riyadh",
            "uid": _userProfile.userId,
            "allowed_company_ids": [
              _userProfile.companyId
            ],
            "bin_size": true,
          }
        }
      };
      var response = await client.callKwCustom(_payload);

      return response;
    } catch (e) {

      return e;
    }
  }

  Future<dynamic> loadVisitView() async {
    try {

      dynamic payload={
        "model": "visit.visit",
        "method": "load_views",
        "args": [],
        "kwargs": {
          "views": [
            [
              false,
              "list"
            ],
            [
              false,
              "form"
            ],
            [
              false,
              "search"
            ]
          ],
          "options": {
            "action_id": 991,
            "load_filters": true,
            "toolbar": true
          },
          "context": {
            "lang": _userProfile.language,
            "tz": _userProfile.tz,
            "uid": _userProfile.userId,
            "allowed_company_ids": [
              _userProfile.companyId
            ],
          }
        }
      };

      var response = await client.callKwCustom(payload);

      return response['fields'];
    }on Exception catch (e) {

      throw e;
    } catch (e) {

      throw e;
    }
  }

  Future<dynamic> getVisitDisclaimer(int visitId) async {

  
    try{
      dynamic _payload={
        "args": [
          [],
          {},
          [],
          {
            "text": "",
            "accept_terms": ""
          }
        ],
        "model": "visit.confirmation.wizard",
        "method": "onchange",
        "kwargs": {
          "context": {
            "lang": "en_AU",
            "tz": "Asia/Riyadh",
            "uid": _userProfile.userId,
            "allowed_company_ids": [
              _userProfile.companyId
            ],
            "active_model": "visit.visit",
            "active_id": visitId,
            "active_ids": [
              visitId
            ],
            "current_id": visitId
          }
        }
      };
     
      dynamic response = await client.callKwCustom(_payload);
  


      return response;
    }catch(e){


      throw e;

    }

  }

  Future<dynamic> updateVisit(Visit visit,dynamic pram) async {
    try {

      dynamic payload={
        "args": [
          [
            visit.id
          ],
          pram
        ],
        "model": "visit.visit",
        "method": "write",
        "kwargs": {
          "context": {
            "lang": _userProfile.language,
            "tz": "Asia/Riyadh",
            "uid": _userProfile.userId,
            "allowed_company_ids": [
              _userProfile.companyId
            ]
          }
        }
      };
      var response = await client.callKwCustom(payload);

      return response;
    }on Exception catch (e) {

      throw e;
    } catch (e) {

      throw e;
    }
  }

  Future<dynamic> startVisit(int id) async {
    try {

      dynamic payload={
        "args": [
          [
            id
          ]
        ],
        "kwargs": {
          "context": {
            "lang": _userProfile.language,
            "tz": "Asia/Riyadh",
            "uid": _userProfile.userId,
            "allowed_company_ids": [
              _userProfile.companyId
            ],
          }
        },
        "method": "fill_date_field",
        "model": "visit.visit"
      };
      var response = await client.callKwCustom(payload);

      return response;
    }on Exception catch (e) {

      throw e;
    } catch (e) {

      throw e;
    }
  }

  Future<dynamic> sendVisit(int id) async {
    try {

      dynamic payload={
        "args": [
          [
            id
          ]
        ],
        "kwargs": {
        },
        "method": "action_send",
        "model": "visit.visit"
      };

      var response = await client.callKwCustom(payload);
      return response;
    } catch (e) {


      throw e;
    }
  }

  Future<dynamic> acceptTermsVisit(int id) async {
    try {

      // dynamic payload={
      //   "args": [
      //     [
      //       id
      //     ]
      //   ],
      //   "kwargs": {
      //   },
      //   "method": "action_send",
      //   "model": "visit.visit"
      // };
      dynamic payload={
        "args": [
          {
            "accept_terms": true
          }
        ],
        "model": "visit.confirmation.wizard",
        "method": "create",
        "kwargs": {
          "context": {
            "lang": _userProfile.language,
            "tz": _userProfile.tz,
            "uid": _userProfile.userId,
            "allowed_company_ids": [
              _userProfile.companyId
            ],
            "active_model": "visit.visit",
            "active_id": id,
            "active_ids": [
              id
            ],
            "current_id": id
          }
        }
      };
      
      var response = await client.callKwCustom(payload);
   
      dynamic final_payload={
        "args": [
          [
            response
          ]
        ],
        "kwargs": {
          "context": {
            "lang": _userProfile.language,
            "tz": _userProfile.tz,
            "uid": _userProfile.userId,
            "allowed_company_ids": [
              _userProfile.companyId
            ],
            "active_model": "visit.visit",
            "active_id": id,
            "active_ids": [
              id
            ],
            "current_id": id
          }
        },
        "method": "action_confirm",
        "model": "visit.confirmation.wizard"
      };

      var responseConfirm = await client.callKwCustom(final_payload);

      return responseConfirm;
    } catch (e) {
   

      throw e;
    }
  }

  Future<dynamic> acceptVisit(int id) async {
    try {

      dynamic payload={
        "args": [
          [
            id
          ]
        ],
        "kwargs": {
          "context": {
            "lang": _userProfile.language,
            "tz": _userProfile.tz,
            "uid": _userProfile.userId,
            "allowed_company_ids": [
              _userProfile.companyId
            ],
          }
        },
        "method": "action_accept",
        "model": "visit.visit"
      };
      var response = await client.callKwCustom(payload);

      return response;
    }on Exception catch (e) {

      throw e;
    } catch (e) {

      throw e;
    }
  }

  Future<dynamic> refuseVisit(int id) async {
    try {

      dynamic payload={
        "args": [
          [
            id
          ]
        ],
        "kwargs": {
          "context": {
            "lang": _userProfile.language,
            "tz": _userProfile.tz,
            "uid": _userProfile.userId,
            "allowed_company_ids": [
              _userProfile.companyId
            ],
          }
        },
        "method": "action_refuse",
        "model": "visit.visit"
      };
      var response = await client.callKwCustom(payload);

      return response;
    }on Exception catch (e) {

      throw e;
    } catch (e) {

      throw e;
    }
  }

  Future<dynamic> setDraftVisit(int id) async {
    try {

      dynamic payload={
        "args": [
          [
            id
          ]
        ],
        "kwargs": {
          "context": {
            "lang": _userProfile.language,
            "tz": _userProfile.tz,
            "uid": _userProfile.userId,
            "allowed_company_ids": [
              _userProfile.companyId
            ],
          }
        },
        "method": "set_to_draft",
        "model": "visit.visit"
      };
      var response = await client.callKwCustom(payload);

      return response;
    }on Exception catch (e) {

      throw e;
    } catch (e) {

      throw e;
    }
  }

  Future<dynamic> createVisit(dynamic visit) async {
    try {

      dynamic payload={
        "args": [
          visit
        ],
        "model": "visit.visit",
        "method": "create",
        "kwargs": {
          "context": {
            "lang": _userProfile.language,
            "tz": _userProfile.tz,
            "uid": _userProfile.userId,
            "allowed_company_ids": [
              _userProfile.companyId
            ]
          }
        }
      };
     
      var response = await client.callKwCustom(payload);


      return response;
    }on Exception catch (e) {

      throw e;
    } catch (e) {

      throw e;
    }
  }

//endregion

}