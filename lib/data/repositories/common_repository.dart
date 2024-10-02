import 'dart:convert';

import 'package:mosque_management_system/data/models/User.dart';
import 'package:mosque_management_system/data/models/app_version.dart';
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
import 'package:package_info_plus/package_info_plus.dart';


class CommonRepository {
  late CustomOdooClient client;
  late UserProfile _userProfile;

  CommonRepository(client){
    this.client = client;
  }
  set userProfile(UserProfile user) {
    _userProfile = user;
  }

  // Getter for age
  UserProfile get userProfile => _userProfile;

  //region For User Service


  Future<dynamic> getEmployeeDetail() async {

    try{
      dynamic _payload={
        "args": [
          [
            _userProfile.employeeId
          ],
          [

            "job_title",
            "category_ids",
            "birthday",
            "identification_id",
            "staff_relation_type",
            "classification_id",
            "mobile_phone",
            "work_phone",
            "work_email",
            "address_id",
            "new_city_id",
            "moi_center",
            "district_id",
            "parent_id",
            "display_name"
          ]
        ],
        "model": "hr.employee",
        "method": "read",
        "kwargs": {
          "context": {
            "lang": _userProfile.language,
            "tz": _userProfile.tz,
            "uid": _userProfile.userId,
            "allowed_company_ids": [
              _userProfile.companyId
            ],
            "bin_size": true,
            "chat_icon": true
          }
        }
      };
  
      dynamic response = await client.callKwCustom(_payload);


      return response;
    }catch(e){

      throw e;

    }

  }

  Future<UserProfile> getUserInfo(dynamic userId) async {

    UserProfile userInfo;
    try{
      dynamic response = await client.callKwCustom({
        'model': 'res.users',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'context': {},
          'domain': [['id','=',userId]],
          'fields': ['name','job_title','user_id','__last_update','employee_id','company_ids','partner_id','company_id'],
          'limit': 1,
        },
      });
     
      userInfo=UserProfile.fromJson(response[0]);
      return userInfo;
    }catch(e){
      throw e;
    }
  }

  Future<UserProfile> getUserDetail(dynamic userId) async {

    UserProfile userInfo;
   
    try{
      dynamic response = await client.callKwCustom({
        'model': 'res.users',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'context': {},
          'domain': [['id','=',userId]],
          'fields': ['name','job_title','user_id','__last_update','employee_id','company_ids','partner_id','company_id',
          'mobile_phone','work_email','work_location_id','employee_parent_id','signature','address_id'],
          'limit': 1,
        },
      });
    
      userInfo=UserProfile.fromJson(response[0]);
   
      return userInfo;
    }on OdooSessionExpiredException {
    
      throw Response("error", 408);
      // Add logic to re-authenticate the user or refresh the session token
      // Example: await reAuthenticateUser();
    }catch(e){
    
      throw Response("error", 408);

    }

  }

  Future<List<dynamic>> getEmployeeByIds(List<int> ids) async {

    try{
      
      dynamic pram={
        "args": [
          ids,
          [
            "display_name"
          ]
        ],
        "model": "hr.employee",
        "method": "read",
        "kwargs": {
          "context": {
            "lang": _userProfile.language,
            "tz": "Asia/Riyadh",
            "uid": _userProfile.userId,
            "allowed_company_ids": [
              _userProfile.companyId
            ],
          }
        }
      };
      
      dynamic response = await client.callKwCustom(pram);
     
      return response;
    }on OdooSessionExpiredException {
      throw Response("error", 408);
    }catch(e){
     
      throw Response("error", 408);

    }

  }

  Future<List<dynamic>> getPartnerByIds(List<int> ids) async {

    try{
      dynamic response = await client.callKwCustom({
        "args": [
          ids,
          [
            "id",
            "name",
            "title",
          ]
        ],
        "model": "res.partner",
        "method": "read",
        "kwargs": {
          "context": {
            "lang": _userProfile.language,
            "tz": "Asia/Riyadh",
            "uid": _userProfile.userId,
          }
        }
      });
   
      return response;
    }on OdooSessionExpiredException {
      throw Response("error", 408);
    }catch(e){
    
      throw Response("error", 408);

    }

  }

  Future<List<dynamic>> getAllPartners(int pageSize,int pageIndex,dynamic? domain) async {
    
    try{
     
      dynamic _payload={
        'model': 'res.partner',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'context': {
            "lang": _userProfile.language,
            "tz": "Asia/Riyadh",
            "uid": _userProfile.userId,
            "allowed_company_ids": [
              _userProfile.companyId,
            ],
            "bin_size": true
          },

          'domain':domain,
          'fields': ['id', 'display_name'],
          'limit': pageSize,
          "offset" :  ((pageIndex-1)*pageSize),
          "order":"display_name"
        },
      };
   
      dynamic response = await client.callKwCustom(_payload);
   
      return response;
    }on OdooSessionExpiredException {
      throw Response("error", 408);
    }catch(e){
   
      throw e;

    }

  }

  Future<List<dynamic>> getRegions(int pageSize,int pageIndex,String? query,int countryId) async {

    try{
   
      dynamic _payload={
        'model': 'res.country.state',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'context': {
            "lang": _userProfile.language,
            "tz": "Asia/Riyadh",
            "uid": _userProfile.userId,
            "allowed_company_ids": [
              _userProfile.companyId,
            ],
            "bin_size": true
          },
          'domain': [
            "&",
            "&",
            [
              "country_id",
              "=",
              countryId
            ],
            [
              "branch_id",
              "!=",
              false
            ],
            [
              "name",
              "ilike",
              query??""
            ]
          ],
          'fields': ["name", "code", "country_id"],
          'limit': pageSize,
          "offset" :  ((pageIndex-1)*pageSize),
          "order":"name"

        },
        "sort":""
      };

      dynamic response = await client.callKwCustom(_payload);

      return response;
    }on OdooException catch (e) {


      throw e;
    } catch (e) {

      throw e;
    }

  }

  Future<List<dynamic>> getCenter(int pageSize,int pageIndex,int cityId,String? query) async {

    try{
    
      dynamic _payload={
        'model': 'moia.center',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'context': {
            "lang": _userProfile.language,
            "tz": "Asia/Riyadh",
            "uid": _userProfile.userId,
            "allowed_company_ids": [
              _userProfile.companyId
            ],
            "bin_size": true
          },
          'domain': [
            "&",
            ["city_id", "=", cityId],
            [
              "name",
              "ilike",
              query??""
            ]
          ],
          'fields': [
            "name",
             // "country_state_id",
            // "city_id",
             "center_code"
          ],
          'limit': pageSize,
          "offset" :  ((pageIndex-1)*pageSize),
          "order":"name"
        },
      };
     
      dynamic response = await client.callKwCustom(_payload);
     
      return response;
    }on OdooSessionExpiredException {
      throw Response("error", 408);
    }catch(e){
     
      throw Response("error", 408);

    }

  }

  Future<List<dynamic>> getDistracts(int pageSize,int pageIndex,String? query) async {
    
    try{
   
      dynamic _payload={
        'model': 'res.distracts',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'context': {
            "lang": _userProfile.language,
            "tz": "Asia/Riyadh",
            "uid": _userProfile.userId,
            "allowed_company_ids": [
              _userProfile.companyId
            ],
            "bin_size": true
          },
          'domain': [
            [
              "name",
              "ilike",
              query??""
            ]
          ],
          'fields': [
            "code",
            "distract_code",
            "name",
            // "city_id"
          ],
          'limit': pageSize,
          "offset" :  ((pageIndex-1)*pageSize),
          "order":"name"

        },
        "sort":""
      };
 
      dynamic response = await client.callKwCustom(_payload);
     
      return response;
    }on OdooSessionExpiredException {
      throw Response("error", 408);
    }catch(e){
   
      throw Response("error", 408);

    }

  }

  Future<List<dynamic>> getCities(int pageSize,int pageIndex,int? regionId,String? query) async {
   
    try{
 
      dynamic _payload={
        'model': 'res.city',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'context': {
            "lang": _userProfile.language,
            "tz": "Asia/Riyadh",
            "uid": _userProfile.userId,
            "allowed_company_ids": [
              _userProfile.companyId
            ],
            "bin_size": true
          },
          'domain': [
            "&",
            [
              "state_id",
              "=",
              regionId
            ],
            [
              "name",
              "ilike",
              query??""
            ]
          ],
          'fields': [
            "name",
            "zipcode",
            "country_id",
            "state_id"
          ],
          'limit': pageSize,
          "offset" :  ((pageIndex-1)*pageSize),
          "order":"name"

        },
        "sort":""
      };

    
      dynamic response = await client.callKwCustom(_payload);
    
      return response;
    }on OdooSessionExpiredException {
      throw Response("error", 408);
    }catch(e){
     
      throw Response("error", 408);

    }

  }

  Future<List<dynamic>> getMosqueUser(int pageSize,int pageIndex,dynamic domain) async {
  
    try{
     
      dynamic _payload={
        'model': 'hr.employee',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'context': {'bin_size': true},
          'domain': domain,
          'fields': ['id', 'name','identification_id',"__last_update"],
          'limit': pageSize,
          "offset" :  ((pageIndex-1)*pageSize),
          "order":"name"
        },
      };
     
      dynamic response = await client.callKwCustom(_payload);
   
      return response;
    }on OdooSessionExpiredException {
      throw Response("error", 408);
    }catch(e){
   
      throw e;

    }

  }

  Future<List<dynamic>> getComboList(dynamic payload) async {
    try{
      dynamic response = await client.callKwCustom(payload);
      return response;
    }on OdooSessionExpiredException {
      throw Response("error", 408);
    }catch(e){
  
      throw Response("error", 408);

    }

  }

  Future<List<dynamic>> getEmployeeCategory() async {
 
    try{

      dynamic _payload={
        'model': 'hr.employee.category',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'context': {'bin_size': true},
          'domain': [

          ],
          'fields': ['display_name','id','color','type'],
          'limit': 100,
          // "offset" :  ((pageIndex-1)*pageSize),
          "order":"name"
        },
      };


      dynamic response = await client.callKwCustom(_payload);
  
      return response;
    }on OdooSessionExpiredException {
      throw Response("error", 408);
    }catch(e){
     
      throw Response("error", 408);

    }

  }

  Future<List<dynamic>> getEmployeeCategoryByIds(List<int> ids) async {

    try{

      dynamic _payload={
        "args": [
          ids,
          [
            "display_name",
            "type",
            "color"
          ]
        ],
        "model": "hr.employee.category",
        "method": "read",
        "kwargs": {
          "context": {
            "lang": "en_AU",
            "tz": "Asia/Riyadh",
            "uid": _userProfile.userId,
            "allowed_company_ids": [
              _userProfile.companyId
            ],
            "chat_icon": true
          }
        }
      };

      dynamic response = await client.callKwCustom(_payload);

      return response;
    }catch(e){

      throw e;

    }

  }
  //endregion

  //region for security

  Future<List<dynamic>> getUserImei(int employeeId) async {

    try{

      dynamic _payload={
        'model': 'employee.app.device',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'context': {'bin_size': true},
          //'domain': ["|",["employee_id",_userProfile.employeeId,],["imei","=",imei]],
          'domain': ['&',["employee_id","=",employeeId,],["status", "!=", "not_use"]],
          'fields': [
            "id",
            "device_name",
            "device_os",
            "os_version",
            "status",
            "imei"
          ],
        },
      };

      dynamic response = await client.callKwCustom(_payload);

      return response;
    }catch(e){

      throw e;

    }

  }

  Future<dynamic> saveImei(DeviceInformation device) async {

    try{

      dynamic _payload={
        "args": [
          {
            "status": device.status,
            "employee_id": _userProfile.employeeId,
            "device_name": device.name,
            "device_os": device.os,
            "os_version": device.osVersion,
            // "make": false,
            // "model": false,
            "imei": device.imei,
            // "start_date": false,
            // "end_date": false,
            // "created_date": "2024-08-11 13:12:43",
            // "comments": false,
            // "message_follower_ids": [],
            // "activity_ids": [],
            // "message_ids": []
          }
        ],
        "model": "employee.app.device",
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
      dynamic response = await client.callKwCustom(_payload);
      return response;
    }catch(e){


      throw e;

    }

  }

  //endregion

  //region For App Methods

  Future<bool> ischeckSessionExpire() async{
    var result=false;
    try{
      result=await client.checkSessionCustom().then((value){

        return false;
      });
    }
    on OdooSessionExpiredException{

      return true;
    }
    catch(e){

      (e);
      return false;
    }
    return result;


  }

  Future<dynamic> getAppVersion() async {
    try {
      Map<String, dynamic> jsonMap = json.decode("{}");
      return jsonMap;


      // Response response = await get(
      //   Uri.parse(Config.baseUrl),
      //   headers: {
      //
      //   },
      // );
      //
      // if (response.statusCode == 200) {
      //   var responseData = json.decode(utf8.decode(response.bodyBytes));
      //   return responseData;
      // }
      //
      // return null;

    }catch (e) {

      throw e;
    }
  }

  //endregion



  Future<Map<String, dynamic>> authenticate(String url,String dbName, String username, String password) async {
    var result;
    try {
//http://172.20.21.161:8085
//       OdooSession response=await client.authenticateCustom(dbName, username, password).
//       timeout( Duration(seconds: 30));


      OdooSession response=await client.authenticate(dbName, username, password).
      timeout( Duration(seconds: 30));

   
      User authUser = User(userId: response.userId,session: response,userName:response.userName );
      UserPreferences().saveUser(authUser);


      result = {'statusCode':'','status': true, 'message': 'Successful', 'user': authUser};

    } on OdooException catch (e) {
  
      result = {
        'status': false,
        'message': 'Invalid_credential'
      };

      // client.close();
    }on Exception catch (_) {   

      result = {
        'status': false,
        'message': _
      };
    }
    return result;
  }

  Future<List<dynamic>> getAllEmployees() async {
    try {
      var response = await client.callKwCustom({
        'model': 'res.users',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'context': {'bin_size': true},
          'domain': [
          ],
          'fields': ['id', 'name'],
        },
      });
      return response.toList();
    }on OdooException catch (e) {
  
      return [];
    } catch (e) {

      return [];
    }
  }

  Future<List<dynamic>> getAllAttachment(List<int> ids) async {
    try {
      var response = await client.callKwCustom({
        "args": [
          ids,
          [
            "name",
            "mimetype"
          ]
        ],
        "model": "ir.attachment",
        "method": "read",
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
      });
      return response.toList();
    } catch (e) {

      throw e;
    }
  }

  //region for  Employee

  Future<dynamic> loadEmployeeView() async {
    try {
 
      dynamic payload={
        "model": "hr.employee",
        "method": "load_views",
        "args": [],
        "kwargs": {
          "views": [
            // [
            //   false,
            //   "kanban"
            // ],
            // [
            //   false,
            //   "list"
            // ],
            [
              false,
              "form"
            ],
            // [
            //   false,
            //   "activity"
            // ],
            // [
            //   802,
            //   "search"
            // ]
          ],
          "context": {
            "lang": _userProfile.language,
            "tz": _userProfile.tz,
            "uid":  _userProfile.userId,
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

  Future<dynamic?> getClassificationIdByCode(String code) async {
    try {
      dynamic payload={
    'model': 'employee.classification',
    'method': 'search_read',
    'args': [],
    'kwargs': {

        'context': {
          "lang": _userProfile.language,
          "tz": _userProfile.tz,
          "uid": _userProfile.userId,
          "allowed_company_ids": [
            _userProfile.companyId
          ],
          "bin_size": true
        },
        'domain':[
          ["code", "=", code]
        ],
        'fields': ['name','code'],
        },

    };
      var response = await client.callKwCustom(payload).timeout(Duration(seconds: 3));
      if(response.length>0)
        return response[0]['id'];
      else
        return null;

    }on Exception catch (e) {
      throw e;
    } catch (e) {
      throw e;
    }
  }

  Future<dynamic> createEmployee(Employee newEmployee) async {
    try {
      dynamic payload={
        "args": [
          {
            "name": newEmployee.name,
            // "number": newEmployee.jobNumber,
            "category_ids": [
              [
                6,
                false,
                newEmployee.categoryIds
              ]
            ],
            "birthday": newEmployee.birthday,
            "identification_id": (newEmployee.identificationId??""),
            "staff_relation_type": newEmployee.staffRelationType,
            "company_id": _userProfile.companyId,
            "classification_id": newEmployee.classificationId??false,
          },
        ],
        "kwargs":{
          "context": {
            "lang": _userProfile.language,
            "tz": "Asia/Riyadh",
            "uid": _userProfile.userId,
            "allowed_company_ids": [
              _userProfile.companyId
            ],
            "chat_icon": true
          }
        },
        "model": "hr.employee",
        "method": "create",

      };
      var response = await client.callKwCustom(payload);
      return response;
    }on Exception catch (e) {
      throw e;
    } catch (e) {
      throw e;
    }
  }

  Future<dynamic> validateYakeenAPI(Employee newEmployee,String dob) async {
    try {

      dynamic payload={
        "kwargs":{
          "context": {
            "lang": _userProfile.language,
            "tz": "Asia/Riyadh",
            "uid": _userProfile.userId,
            "allowed_company_ids": [
              _userProfile.companyId
            ],
            "chat_icon": true
          }
        },
        'args': ["identity", "birth_date"],
        "model": "yakeen.verification.method",
        "method": "verify_employee",
        //'args': ["", "2561253747","1993-06"],
        'args': ["", newEmployee.identificationId,dob],

      };

      var response = await client.callKwCustom(payload);

   
      return response;
    }on Exception catch (e) {

      throw e;
    } catch (e) {
  
      throw e;
    }
  }

  Future<dynamic> validateNationalId(Employee newEmployee) async {
    try {

      dynamic payload={
        "args": [
          [
            newEmployee.id
          ]
        ],
        "kwargs": {
          "context": {
            "lang": _userProfile.language,
            "tz": "Asia/Riyadh",
            "uid":  _userProfile.userId,
            "allowed_company_ids": [
              _userProfile.companyId
            ]
          }
        },
        "method": "action_validate_national_id",
        "model": "hr.employee"
      };
     
      var response = await client.callKwCustom(payload);
   
      (response);
      return response;
    }on Exception catch (e) {
 
      throw e;
    } catch (e) {
     
      throw e;
    }
  }

  //endregion



  //region For Cusomt API
  Future<dynamic> getDashboardAPI() async {
    try {
 

      dynamic payload={};

      dynamic response = await client.post("/getDashboarKPI",{});

  
      if(response["body"]["status"]==200){
        return response["body"];
      }else{
        throw response["body"]["message"];
      }
      return response;
    }on Exception catch (e) {
    
      throw e;
    } catch (e) {
    
      throw e;
    }
  }

  Future<dynamic> getMasjidSummaryAPI() async {
    try {


      dynamic payload={};

      dynamic response = await client.post("/api/mosque/get",{});

      if(response["body"]["status"]==200){
        return response["body"];
      }else{
        throw response["body"]["message"];
      }
      return response;
    }on Exception catch (e) {

      throw e;
    } catch (e) {

      throw e;
    }
  }

  Future<dynamic> getMenuRights() async {
    try {
      

      dynamic payload={};
   
      dynamic response = await client.post("/getMenuRights",{});
      if(response["body"]["status"]==200){
        return response["body"];
      }else{
        throw response["body"]["message"];
      }
      return response;
    }on Exception catch (e) {
  
     
      throw e;
    } catch (e) {
     
      throw e;
    }
  }

  //endregion

//region for Common Methods
  Future<List<dynamic>> getRequestStage(String model) async {

    try {
      dynamic _payload={
        'model': 'request.stage',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'limit': 50,
          'context': {
            "lang": _userProfile.language,
            "tz": "Asia/Riyadh",
            "uid": _userProfile.userId,
            "allowed_company_ids": [
              _userProfile.companyId
            ],
            "bin_size": true
          },
          'domain': [['res_model', '=',model]],
          'fields': ["name"],
        },

      };
      var response = await client.callKwCustom(_payload);

      return response.toList();
    }catch (e) {
      (e);
      throw e;
    }
  }

  Future<dynamic> getPrayerTime(dynamic payload) async {

    try {
      dynamic _payload={
        "model": "prayer.time",
        "domain": payload,
        "fields": [
          "name",
          "date",
          "month",
          "year",
          "fajar_time",
          "dhuhr_time",
          "asr_time",
          "maghrib_time",
          "isha_time"
        ],
        "limit": 1,
        "sort": "",
        "context": {
          "lang": _userProfile.language,
          "tz": _userProfile.tz,
          "uid": _userProfile.userId,
          "allowed_company_ids": [
            _userProfile.companyId
          ],
          "bin_size": true
        }
      };
      var response = await client.callKwCustom(_payload);

      return response.toList();
    }catch (e) {
      (e);
      throw e;
    }
  }
//endregion

}