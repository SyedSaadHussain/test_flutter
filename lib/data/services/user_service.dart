import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mosque_management_system/data/models/app_version.dart';
import 'package:mosque_management_system/data/models/center.dart';
import 'package:mosque_management_system/data/models/combo_list.dart';
import 'package:mosque_management_system/data/models/device_info.dart';
import 'package:mosque_management_system/data/models/distract.dart';
import 'package:mosque_management_system/data/models/employee.dart';
import 'package:mosque_management_system/data/models/employee_category.dart';
import 'package:mosque_management_system/data/models/ir_attachment.dart';
import 'package:mosque_management_system/data/models/menuRights.dart';
import 'package:mosque_management_system/data/models/meter.dart';
import 'package:mosque_management_system/data/models/mosque.dart';
import 'package:mosque_management_system/data/models/mosque_region.dart';
import 'package:mosque_management_system/data/models/prayer_time.dart';
import 'package:mosque_management_system/data/models/region.dart';
import 'package:mosque_management_system/data/models/res_city.dart';
import 'package:mosque_management_system/data/models/res_partner.dart';
import 'package:mosque_management_system/data/models/userProfile.dart';
import 'package:mosque_management_system/data/repositories/custom_odoo_client.dart';
import 'package:mosque_management_system/data/repositories/common_repository.dart';
import 'package:mosque_management_system/data/services/odoo_service.dart';
import 'package:mosque_management_system/utils/config.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'package:http/http.dart';
import 'package:package_info_plus/package_info_plus.dart';

class UserService extends OdooService{
  // late CommonRepository _repository;
  //CommonRepository get repository => _repository;

  UserService(CustomOdooClient client): super(client) {
    //_repository = CommonRepository(client);
  }

  void updateUserProfile(UserProfile userProfile){
    repository.userProfile=userProfile;
  }
  Future<Employee> createEmployee(Employee mosque) async {
    try {
      var _domain=[];

      dynamic response = await repository.createEmployee(mosque);
      mosque.id=response;

      return mosque;
    }on Exception catch (e){
      throw e;
    }

  }


  Future<List<FieldList>> loadEmployeeView() async {
    try {
      List<FieldList> data=[];
      dynamic response = await repository.loadEmployeeView();
      FieldList itemData=FieldList(field: "");
      (response as Map<String, dynamic>).forEach((key, value) {
        itemData=FieldList();
        itemData=FieldList.fromStringJson(key,value);
        data.add(itemData);

      });
      return data;
    }catch(e){
      throw Response("error", 408);
    }

  }

  Future<bool> authenticate(String dbName, String username, String password) async {
    return true;
  }

  Future<dynamic> getEmployeeDetail() async {
    try {
      dynamic response = await repository.getEmployeeDetail();
     
      return response;
    }catch(e){
      throw Response("error", 408);
    }

  }
  Future<List<Employee>> getEmployeesByIds(List<int> ids) async {
    List<Employee> partners=[];
    try {

      dynamic response = await repository.getEmployeeByIds(ids);
      partners=(response as List).map((item) => Employee.fromJson(item)).toList();
      return partners;
    }catch(e){
      throw Response("error", 408);
    }

  }
  Future<List<ResPartner>> getPartnerByIds(List<int> ids) async {
    List<ResPartner> partners=[];
    try {

      dynamic response = await repository.getPartnerByIds(ids);
      partners=(response as List).map((item) => ResPartner.fromJson(item)).toList();
      return partners;
    }catch(e){
      throw Response("error", 408);
    }

  }


  Future<List<MoiCenter>> getCenter(int pageSize,int pageIndex,int cityId,String query) async {
    List<MoiCenter> regions=[];
    try {
      dynamic response = await repository.getCenter(pageSize,pageIndex,cityId,query);
      regions=(response as List).map((item) => MoiCenter.fromJson(item)).toList();
      return regions;
    }catch(e){
      throw Response("error", 408);
    }

  }

  Future<List<Region>> getRegions(int pageSize,int pageIndex,String query,int countryId) async {
    List<Region> regions=[];
    try {
      dynamic response = await repository.getRegions(pageSize,pageIndex,query,countryId);
      regions=(response as List).map((item) => Region.fromJson(item)).toList();
      return regions;
    }catch(e){
      throw e;
    }

  }

  Future<List<City>> getCities(int pageSize,int pageIndex,int? regionId,String query) async {
    List<City> items=[];
    try {
      dynamic response = await repository.getCities(pageSize,pageIndex,regionId,query);
      items=(response as List).map((item) => City.fromJson(item)).toList();
      return items;
    }catch(e){
      throw e;
    }

  }

  Future<List<Distract>> getDistracts(int pageSize,int pageIndex,String query) async {
    List<Distract> items=[];
    try {
      dynamic response = await repository.getDistracts(pageSize,pageIndex,query);
      items=(response as List).map((item) => Distract.fromJson(item)).toList();
      return items;
    }catch(e){
      throw Response("error", 408);
    }

  }

  Future<List<Employee>> getMosqueObservors(int pageSize,int pageIndex,String query,String type) async {
    List<Employee> items=[];
    try {
      dynamic domain=[];

      if(type=='obs'){
        domain=[
          '&',
          '&',
          ["classification_id.code",
            "=",
            type
          ],
          [
            "parent_id",
            "=",
            false
          ],
          [
            "name",
            "ilike",
            query??""
          ]
        ];
      }else{
        domain=[
          '&',
          [
            "category_ids.type",
            "=",
            type
          ],
          [
            "name",
            "ilike",
            query??""
          ]
        ];
      }

      dynamic response = await repository.getMosqueUser(pageSize,pageIndex,domain);
      items=(response as List).map((item) => Employee.fromJsonSearch(item)).toList();
      return items;
    }on Exception catch (e){
      throw e;
    }

  }

  Future<List<Employee>> getMosqueUser(int pageSize,int pageIndex,String query,String type,int? supervisorId) async {
    List<Employee> items=[];
    try {
      dynamic domain=[];

      if(type=='obs'){
        domain=[
          '&',
          '&',
          '|',
          [
            "name",
            "ilike",
            query??""
          ],
          [
            "identification_id",
            "ilike",
            query??""
          ],
           ["classification_id.code",
            "=",
            type
          ],
          [
            "parent_id",
            "=",
            supervisorId??false
          ],
        ];
      }else{
        domain=[
          '&',
          '|',
          [
            "name",
            "ilike",
            query??""
          ],
          [
            "identification_id",
            "ilike",
            query??""
          ],
          [
            "category_ids.type",
            "=",
            type
          ],

        ];
      }

      dynamic response = await repository.getMosqueUser(pageSize,pageIndex,domain);
      items=(response as List).map((item) => Employee.fromJsonSearch(item)).toList();
      return items;
    }on Exception catch (e){
      throw e;
    }

  }

  Future<List<ComboItem>> getClassification() async {
    List<ComboItem> items=[];
    try {
      dynamic _payload={
        "args": [],
        "model": "mosque.classification",
        "method": "name_search",
        "kwargs": {
          "name": "",
          "args": [],
          "operator": "ilike",
          "limit": 8,
          "context": {
            "lang": "en_US",
            "tz": "Asia/Riyadh",
            "uid": 2,
            "allowed_company_ids": [
              1
            ]
          }
        }
      };
      dynamic response = await repository.getComboList(_payload);
      items=(response as List).map((item) => ComboItem.fromJson(item)).toList();
      return items;
    }catch(e){
      throw Response("error", 408);
    }

  }

  Future<List<EmployeeCategory>> getEmployeeCategory() async {

    List<EmployeeCategory> items=[];
    try {
      dynamic response = await repository.getEmployeeCategory();
      items=(response as List).map((item) => EmployeeCategory.fromJson(item)).toList();
      return items;
    }catch(e){
      throw Response("error", 408);
    }

  }

  Future<List<EmployeeCategory>> getEmployeeCategoryIds({List<int>? ids}) async {

    List<EmployeeCategory> items=[];
    try {

      dynamic response = await repository.getEmployeeCategoryByIds(ids??[]);
      items=(response as List).map((item) => EmployeeCategory.fromJson(item)).toList();
      return items;
    }catch(e){
      throw e;
    }

  }

  Future<List<ResPartner>> getPartner(int pageSize,int pageIndex,String? query) async {
    List<ResPartner> items=[];
    try {
      dynamic _domain=[];
      if(query!='' && query!.isNotEmpty)
        _domain=[
          [
            "display_name",
            "ilike",
            query
          ]
        ];
      dynamic response = await repository.getAllPartners(pageSize,pageIndex,_domain);
      items=(response as List).map((item) => ResPartner.fromJson(item)).toList();
      return items;
    }on Exception catch (e){
      throw e;
    }

  }

  Future<PrayerTime?> getPrayerTime(int cityId) async {
    PrayerTime? time;
    try {
      dynamic _domain=[];

      dynamic response = await repository.getPrayerTime(_domain);
     
      if(response.length>0)
        time=PrayerTime.fromJson(response[0]);

      return time;
    }on Exception catch (e){
      throw e;
    }

  }

  Future<dynamic> getDashboardAPI() async {
    List<Meter> list=[];
    try {

      dynamic response = await repository.getDashboardAPI();

      return response;
    }catch(e){
      throw e;
    }

  }

  Future<dynamic> getMasjidSummaryAPI() async {
    List<Meter> list=[];
    try {

      dynamic response = await repository.getMasjidSummaryAPI();

      return response;
    }catch(e){
      throw e;
    }

  }

  Future<List<DeviceInformation>> getUserImei(int employeeId) async {
    List<DeviceInformation> items=[];
    try {

      dynamic response = await repository.getUserImei(employeeId);
      items=(response as List).map((item) => DeviceInformation.fromJson(item)).toList();
      return items;
    }catch(e){
      throw e;
    }

  }

  Future<bool> saveImei(DeviceInformation device) async {
    List<DeviceInformation> items=[];
    try {

      dynamic response = await repository.saveImei(device);
      return true;
    }on Exception catch (e){
      throw e;
    }

  }

  Future<MenuRights> getMenuRightsAPI() async {
    MenuRights object;
    try {

      dynamic response = await repository.getMenuRights();
      response['mosqueRequest'];
      object=MenuRights.fromJson(response['mosqueRequest']);

      return object;
    }catch(e){
      throw Response("error", 408);
    }

  }

  Future<Attachment?> uploadAttachment(String path) async {

    File file = File(path);
    Attachment? attachment;
    var urlToOpen="${repository.client.baseURL}/web/binary/upload_attachment";
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(urlToOpen),
    );
    request.headers.addAll(headersMap);
    request.fields['model'] = 'hr.leave';
    request.fields['csrf_token'] = csrfToken;
    request.fields['id'] = "0";
    request.fields['ufile'] = "";
    request.files.add(
      await http.MultipartFile.fromPath(
        'ufile',
        path,
      ),
    );
    var response = await request.send();
    if (response.statusCode == 200) {
      var result=await response.stream.bytesToString();

      attachment=Attachment.fromJson(json.decode(result)[0]);

      return attachment;

    } else {

      String error=await response.stream.bytesToString();

      throw error;
      return attachment;
    }

  }

  Future<List<Attachment>> getAllAttachment(List<int> ids) async {
    List<Attachment> list=[];
    try {
      dynamic response = await repository.getAllAttachment(ids);
      list=(response as List).map((item) => Attachment.fromJson(item)).toList();
      return list;
    }catch(e){

      throw e;
    }

  }

  Future<AppVersion?> getAppVersion() async {
    AppVersion? version;
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    List<Attachment> list=[];
    try {

      dynamic response = await repository.getAppVersion();
 
      version=AppVersion.fromJson(response);

      version.localVersion =packageInfo.version;
     return version;
    }catch(e){
      
      throw e;
    }
  }
}