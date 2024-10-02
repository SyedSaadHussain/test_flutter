import 'package:mosque_management_system/data/models/combo_list.dart';
import 'package:mosque_management_system/data/models/mosque.dart';
import 'package:mosque_management_system/data/models/mosque_region.dart';
import 'package:mosque_management_system/data/models/userProfile.dart';
import 'package:mosque_management_system/data/models/visit.dart';
import 'package:mosque_management_system/data/repositories/custom_odoo_client.dart';
import 'package:mosque_management_system/data/repositories/common_repository.dart';
import 'package:mosque_management_system/data/repositories/visit_repository.dart';
import 'package:mosque_management_system/data/services/odoo_service.dart';
import 'package:mosque_management_system/utils/config.dart';
import 'package:mosque_management_system/utils/json_utils.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'package:http/http.dart';

class VisitService extends OdooService{
  // late CommonRepository _repository;
  late VisitRepository _visitRepository;
  // CommonRepository get repository => _repository;
  VisitRepository get visitRepository => _visitRepository;

  void updateUserProfile(UserProfile userProfile){
    visitRepository.userProfile=userProfile;
    repository.userProfile=userProfile;
  }

  VisitService(CustomOdooClient client): super(client) {
    // _repository = CommonRepository(client);
    _visitRepository = VisitRepository(client);
  }

  //
  Future<dynamic> createOnDemandVisit(Visit newVisit) async {
    try {
      var _pram={
        "mosque_seq_no": newVisit.mosqueSequenceNoId,
        "created_by": newVisit.createdById,
        "observer": newVisit.observerId
      };
      dynamic response = await _visitRepository.createVisit(_pram);
      return response;
    }on Exception catch (e){
      throw e;
    }

  }

  Future<List<ComboItem>> getVisitStages() async {
    List<ComboItem> items=[];
    try {
      dynamic response = await repository.getRequestStage(Model.visit);
      // contacts.count=0;//response["length"];
      items =(response as List).map((item) => ComboItem.fromJsonObject(item)).toList();
      return items;
    }catch(e){
      throw e;
    }

  }


  Future<VisitData> getVisits(int pageSize,int pageIndex,String query,{String? filterField,dynamic? filterValue}) async {
    try {
      VisitData contacts =VisitData();
      var _domain=[];
      if(AppUtils.isNotNullOrEmpty(filterField) && filterValue!=null){
        _domain=[
          '&',
          '|',
          [ "mosque_seq_no",
            "ilike",
            query],
          [
            "name",
            "ilike",
            query
          ],
          [
            "stage_id",//change this after API upgrade filterField,
            "=",
            filterValue
          ],


        ];

      }else{
        _domain=[
          '|',
          [ "mosque_seq_no",
            "ilike",
            query],
          [
            "name",
            "ilike",
            query
          ]
        ];
      }




      dynamic response = await _visitRepository.getAllVisits(_domain,pageSize,pageIndex);
      contacts.count=0;//response["length"];
      contacts.list=(response as List).map((item) => Visit.fromJson(item)).toList();
      return contacts;
    }catch(e){
      throw Response("error", 408);
    }

  }

  Future<List<FieldList>> loadVisitView() async {
    try {
      var _domain=[];
      List<FieldList> data=[];
      Mosque mosque =Mosque(id: 0);
      dynamic response = await _visitRepository.loadVisitView();
      FieldList itemData=FieldList(field: "");
      (response as Map<String, dynamic>).forEach((key, value) {
        itemData=FieldList();
        itemData=FieldList.fromStringJson(key,value);
        data.add(itemData);

      });
      return data;
    }catch(e){
      throw e;
    }

  }

  Future<Visit> getVisitDetail(int id) async {
    try {
      Visit mosque =Visit(id: 0);
      var _domain=[];

      dynamic response = await _visitRepository.getVisitDetail(id);
      mosque = Visit.fromJson(response[0]);
      return mosque;
    }catch(e){
      throw e;
    }

  }

  Future<bool> updatePrayerTime(Visit visit) async {
    try {
      var _pram={
        "prayer_name": visit.prayerName
      };

     

      dynamic response = await _visitRepository.updateVisit(visit,_pram);

      return true;
    }on Exception catch (e){
      throw e;
    }

  }

  Future<bool> updateVisit(Visit oldVisit,Visit visit) async {
    try {
      var _pram={
        "prayer_name": visit.prayerName,
        "imam_off_prayers_id": visit.prayerName,
        "moazen_off_prayers_id": visit.prayerName,

        "imam_present": visit.imamPresent,
        "imam_off_work": visit.imamOffWork,
        "imam_notes": visit.imamNotes,

        "moazen_present": visit.moazenPresent,
        "moazen_exist": visit.moazenExist,
        "moazen_off_work": visit.moazenOffWork,
        "moazen_notes": visit.moazenNotes,

        "worker_present": visit.workerPresent,
        "worker_exist": visit.workerExist,
        "worker_rate": visit.workerRate,
        "worker_notes": visit.workerNotes,


        "moazen_present":visit.moazenPresent,
        "mosque_clean":visit.mosqueClean,
        "mosque_clean_notes":visit.mosqueCleanNotes,
        "carpet_quality":visit.carpetQuality,
        "carpet_quality_notes":visit.carpetQualityNotes,
        "wc_clean":visit.wcClean,
        "wc_clean_notes":visit.wcCleanNotes,
        "air_condition":visit.airCondition,
        "air_condition_notes":visit.airConditionNotes,
        "sound_system":visit.soundSystem,
        "sound_system_notes":visit.soundSystemNotes,
        "close_outside_horn":visit.closeOutsideHorn,
        "inside_horn":visit.insideHorn,
        "outside_horn":visit.outsideHorn,
        "wc_maintenance":visit.wcMaintenance,
        "wc_maintenance_notes":visit.wcMaintenanceNotes,
        "ablution_wash":visit.ablutionWash,
        "ablution_wash_notes":visit.ablutionWashNotes,
        "electric_meter_violation":visit.electricMeterViolation,
        "water_meter_violation":visit.waterMeterViolation,
        "mosque_violation":visit.mosqueViolation,
        "cleaning_material":visit.cleaningMaterial,
        "holy_quran_violation":visit.holyQuranViolation,
        "description":visit.description,
      };

      dynamic response = await _visitRepository.updateVisit(visit,_pram);

      return true;
    }on Exception catch (e){
      throw e;
    }

  }

  Future<bool> startVisit(int id) async {
    try {
      dynamic response = await _visitRepository.startVisit(id);

      return true;
    }on Exception catch (e){
      throw e;
    }

  }

  Future<dynamic> getVisitDisclaimer(int visitId) async {
    try {
      dynamic response = await _visitRepository.getVisitDisclaimer(visitId);

      return response;
    }on Exception catch (e){
      throw e;
    }

  }

  Future<bool> sendVisit(int id) async {
    try {
      dynamic response = await _visitRepository.sendVisit(id);


      return true;
    }on Exception catch (e){
      throw e;
    }

  }

  Future<bool> acceptTermsVisit(int id) async {
    try {
      dynamic response = await _visitRepository.acceptTermsVisit(id);
     

      return true;
    }on Exception catch (e){
      throw e;
    }

  }

  Future<bool> acceptVisit(int id) async {
    try {
      dynamic response = await _visitRepository.acceptVisit(id);


      return true;
    }on Exception catch (e){
      throw e;
    }

  }

  Future<bool> refuseVisit(int id) async {
    try {
      dynamic response = await _visitRepository.refuseVisit(id);

      return true;
    }on Exception catch (e){
      throw e;
    }

  }

  Future<bool> setDraftVisit(int id) async {
    try {
      dynamic response = await _visitRepository.setDraftVisit(id);

      return true;
    }on Exception catch (e){
      throw e;
    }

  }

}