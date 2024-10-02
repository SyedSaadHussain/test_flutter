import 'package:hijri/hijri_calendar.dart';
import 'package:mosque_management_system/data/models/combo_list.dart';
import 'package:mosque_management_system/data/models/employee.dart';
import 'package:mosque_management_system/data/models/ir_attachment.dart';
import 'package:mosque_management_system/data/models/meter.dart';
import 'package:mosque_management_system/data/models/mosque.dart';
import 'package:mosque_management_system/data/models/mosque_region.dart';
import 'package:mosque_management_system/data/models/userProfile.dart';
import 'package:mosque_management_system/data/repositories/custom_odoo_client.dart';
import 'package:mosque_management_system/data/repositories/common_repository.dart';
import 'package:mosque_management_system/data/repositories/mosque_repository.dart';
import 'package:mosque_management_system/data/services/odoo_service.dart';
import 'package:mosque_management_system/utils/config.dart';
import 'package:mosque_management_system/utils/json_utils.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'package:http/http.dart';

class MosqueService extends OdooService{
  // late CommonRepository _repository;
  late MosqueRepository _mosqueRepository;
  // CommonRepository get repository => _repository;
  MosqueRepository get mosqueRepository => _mosqueRepository;

  MosqueService(CustomOdooClient client): super(client) {
    // _repository = CommonRepository(client);
    _mosqueRepository = MosqueRepository(client);
  }

  void updateUserProfile(UserProfile userProfile){
    _mosqueRepository.userProfile=userProfile;
    repository.userProfile=userProfile;
  }

  Future<List<ComboItem>> getInstrumentEntities() async {
    List<ComboItem> items=[];
    try {
      dynamic response = await _mosqueRepository.getInstrumentEntities();
      items=(response as List).map((item) => ComboItem.fromJson(item)).toList();
      return items;
    }catch(e){
      throw Response("error", 408);
    }

  }

  Future<List<ComboItem>> getMosqueStages() async {

    List<ComboItem> items=[];
    try {

      dynamic response = await repository.getRequestStage(Model.mosque);
      // contacts.count=0;//response["length"];
      items =(response as List).map((item) => ComboItem.fromJsonObject(item)).toList();
      return items;
    }catch(e){
      throw e;
    }
  }

  Future<List<ComboItem>> getBuildingTypes() async {

    List<ComboItem> items=[];
    try {
      dynamic response = await _mosqueRepository.getBuildingTypes();
      items=(response as List).map((item) => ComboItem.fromJson(item)).toList();
      return items;
    }catch(e){
      throw Response("error", 408);
    }

  }

  Future<MosqueData> getAllMosques(int pageSize,int pageIndex,String query,{String? filterField,dynamic? filterValue}) async {
    try {
      MosqueData contacts =MosqueData();
      var _domain=[];


      if(AppUtils.isNotNullOrEmpty(filterField) && filterValue!=null){
        _domain=[
          '&',
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

      }else
      {
        _domain=[
          [
            "name",
            "ilike",
            query??""
          ]
        ];
      }
     

      dynamic response = await _mosqueRepository.getAllMosques(_domain,pageSize,pageIndex);

      contacts.count=0;//response["length"];
      contacts.list=(response as List).map((item) => Mosque.fromJson(item)).toList();
      return contacts;
    }catch(e){
      throw e;
    }

  }

  Future<MosqueData> getAllDoneMosques(int pageSize,int pageIndex,String query) async {
    try {
      MosqueData contacts =MosqueData();
      var _domain=[];
      _domain=[
        "&",
        [
          "name",
          "ilike",
          query
        ],
        [
          "stage_id.state",
          "=",
          "done"
        ],
      ];
    

      dynamic response = await _mosqueRepository.getAllMosques(_domain,pageSize,pageIndex);
   
      contacts.count=0;//response["length"];
      contacts.list=(response as List).map((item) => Mosque.fromJson(item)).toList();
      return contacts;
    }catch(e){
      throw e;
    }

  }


  Future<Mosque> getMosqueDetail(int id) async {
    try {
      Mosque mosque =Mosque(id: 0);
      var _domain=[];

      dynamic response = await _mosqueRepository.getMosqueDetail(id);
      mosque = Mosque.fromJson(response[0]);
      return mosque;
    }on Exception catch(e){
      throw e;
    }

  }
  Future<Mosque> getMosqueCoordinate(int id) async {
    try {
      Mosque mosque =Mosque(id: 0);
      var _domain=[];

      dynamic response = await _mosqueRepository.getMosqueCoordinate(id);
      mosque = Mosque.fromJson(response[0]);
      return mosque;
    }catch(e){
      throw e;
    }

  }
  Future<dynamic> getDisclaimer(int id) async {
    try {
      dynamic response = await _mosqueRepository.getDisclaimer(id);

      return response;
    }on Exception catch (e){
      throw e;
    }

  }
  Future<bool> acceptTerms(int id) async {
    try {

      dynamic response = await _mosqueRepository.acceptTerms(id);
     
  

      return true;
    }catch (e){
      throw e;
    }

  }
  Future<dynamic> sendMosque(int id) async {
    try {
      dynamic response = await _mosqueRepository.sendMosque(id);
     

      return response;
    }on Exception catch (e){
      throw e;
    }

  }
  //
  // Future<bool> acceptMosque(int id) async {
  //   try {
  //     dynamic response = await _mosqueRepository.acceptMosque(id);
  //     return true;
  //   }on Exception catch (e){
  //     throw e;
  //   }
  //
  // }

  Future<bool> refuseMosque(int id,String message) async {
    try {
      dynamic messageId = await _mosqueRepository.refuseMosque(id,message);
      dynamic response = await _mosqueRepository.callRefuseMosque(id,messageId);
      return true;
    }on Exception catch (e){
      throw e;
    }

  }

  Future<Mosque> createMosque(Mosque mosque) async {
    try {
      var _domain=[];

      dynamic response = await _mosqueRepository.createMosque(mosque);
      mosque.id=response;

      return mosque;
    }on Exception catch (e){
      throw e;
    }

  }


  Future<bool> updateObserver(Mosque oldMosque,Mosque mosque) async {
    try {
      var _pram={
        "observer_ids": [
          [
            6,
            false,
            mosque.observerIds
          ]
        ],
      };
      dynamic response = await _mosqueRepository.updateMosque(mosque,_pram);
      return true;
    }on Exception catch (e){
      throw e;
    }

  }

  Future<bool> updateMosqueBasicInfo(Mosque oldMosque,Mosque mosque) async {
    try {
      var _pram={
        "name": mosque.name,
        "classification_id": mosque.classificationId,
        "street": mosque.street,
        // "district": mosque.districtId,
        // "moia_center_id": mosque.moiaCenterId,
        // "city_id": mosque.cityId,
        // "mosque_state": mosque.mosqueState,
        "is_another_neighborhood": mosque.isAnotherNeighborhood,
        "another_neighborhood_char": mosque.anotherNeighborhoodChar,
        "land_owner": mosque.landOwner,
        "mosque_owner_name": mosque.mosqueOwnerName,
        "date_maintenance_last": mosque.dateMaintenanceLast,
        "mosque_opening_date": mosque.mosqueOpeningDate,
        "is_employee": mosque.isEmployee,
        "imam_ids": [
          [
            6,
            false,
            mosque.imamIds
          ]
        ],
        "muezzin_ids": [
          [
            6,
            false,
            mosque.muezzinIds
          ]
        ],
        "khadem_ids": [
          [
            6,
            false,
            mosque.khademIds
          ]
        ],
        "khatib_ids": [
          [
            6,
            false,
            mosque.khatibIds
          ]
        ],
        "observer_ids": [
          [
            6,
            false,
            mosque.observerIds
          ]
        ],
        //"name": mosque.name,
      };
      if(oldMosque.regionId!=mosque.regionId)
        _pram["region_id"] = mosque.regionId;

      if(oldMosque.districtId!=mosque.districtId)
        _pram["district"] = mosque.districtId;

      if(oldMosque.moiaCenterId!=mosque.moiaCenterId)
        _pram["moia_center_id"] = mosque.moiaCenterId;

      if(oldMosque.cityId!=mosque.cityId)
        _pram["city_id"] = mosque.cityId;

      if(oldMosque.mosqueState!=mosque.mosqueState)
        _pram["mosque_state"] = mosque.mosqueState;

      dynamic response = await _mosqueRepository.updateMosque(mosque,_pram);
      return true;
    }on Exception catch (e){
      throw e;
    }

  }

  Future<bool> updateMosqueDetail(Mosque oldMosque,Mosque mosque,
      List<Meter> mosqueElectricMeters,List<Meter> mosqueWaterMeters) async {
    try {
      var _pram={
        "land_area": mosque.landArea,
        "capacity": mosque.capacity,
        // "mosque_land_area": mosque.mosqueLandArea,
        "roofed_area": mosque.roofedArea,
        "urban_condition": mosque.urbanCondition,
        // "carrying_capacity": mosque.carryingCapacity,
        // "has_qr_code_panel": mosque.hasQrCodePanel,
        "is_qr_code_exist": mosque.isQrCodeExist,//
        "qr_code_notes": mosque.qrCodeNotes,//
        "plate_legible": mosque.plateLegible,//
        "is_panel_readable": mosque.isPanelReadable,//
        "code_readable": mosque.codeReadable,//
        "mosque_name_qr": mosque.mosqueNameQr,
        "qr_panel_numbers": mosque.qrPanelNumbers,
        //"qr_image": mosque.qrImage,
         "mosque_data_correct": mosque.mosqueDataCorrect,
        // "capacity": mosque.capacity,
        // "electricity_meter_numero": mosque.electricityMeterNumero,
        // "water_meter_numero": mosque.waterMeterNumero,
        "qr_code_match": mosque.qrCodeMatch,
        //"num_qr_code_panels": mosque.numQrCodePanels,
        //"has_electricity_meter": mosque.hasElectricityMeter,
       // "is_mosque_electric_meter_new": mosque.isMosqueElectricMeterNew,
        //"has_water_meter": mosque.hasWaterMeter,
        // "building_area": mosque.buildingArea,
        "non_building_area": mosque.nonBuildingArea,
        "free_area": mosque.freeArea,
        "is_free_area": mosque.isFreeArea,
        "mosque_rooms": mosque.mosqueRooms,
        "cars_parking": mosque.carsParking,
        "have_washing_room": mosque.haveWashingRoom,
        "lectures_hall": mosque.lecturesHall,
        "library_exist": mosque.libraryExist,
        "stood_on_ground_mosque": mosque.stoodOnGroundMosque,
        "vacancies_spaces": mosque.vacanciesSpaces,
        "other_companions": mosque.otherCompanions,
        "description": mosque.description,

        //"name": mosque.name,
      };

      if(oldMosque.hasElectricityMeter!=mosque.hasElectricityMeter)
        _pram['has_electricity_meter']=mosque.hasElectricityMeter;

      if(oldMosque.hasWaterMeter!=mosque.hasWaterMeter)
        _pram['has_water_meter']=mosque.hasWaterMeter;

      if(oldMosque.isMosqueElectricMeterNew!=mosque.isMosqueElectricMeterNew)
        _pram['is_mosque_electric_meter_new']=mosque.isMosqueElectricMeterNew;

      if(oldMosque.qrImage!=mosque.qrImage)
        _pram['qr_image']=mosque.qrImage;

      _pram['mosque_electricity_meter_ids']=
          mosqueElectricMeters.map((Meter item) {
            if(item.id==0){
              return [0,"virtual_1",{"name":item.name,"attachment_id":item.attachmentId,"mosque_shared":item.mosqueShared}];//Add
            }else if(item.isDelete){
              return [2,item.id,false];//Delete
            }else if(item.isEdit){
              return [1,item.id,{"name":item.name,"attachment_id":item.attachmentId,"mosque_shared":item.mosqueShared}];//Edit
            }else{
              return [4,item.id,false];//Remain same
            }
          }).toList()
      ;

      _pram['mosque_water_meter_ids']=
          mosqueWaterMeters.map((Meter item) {
            if(item.id==0){
              return [0,"virtual_1",{"name":item.name}];//Add
            }else if(item.isDelete){
              return [2,item.id,false];//Delete
            }else if(item.isEdit){
              return [1,item.id,{"name":item.name}];//Edit
            }else{
              return [4,item.id,false];//Remain same
            }
          }).toList()
      ;

      dynamic response = await _mosqueRepository.updateMosque(mosque,_pram);


      return true;
    }on Exception catch (e){
      throw e;
    }

  }

  Future<bool> updateMosqueInfo(Mosque oldMosque,Mosque mosque) async {

    try {
      var _pram={

        "no_planned": mosque.noPlanned,
        "piece_number": mosque.pieceNumber,
        "national_address": mosque.nationalAddress,
        // "mosque_opening_date": "2024-07-02",
        // "mosque_owner_name": mosque.mosqueOwnerName,
        "declaration_note": mosque.declarationNote,
        "observer_supervisor_comment": mosque.observerSupervisorComment,
        //"mosque_qr_attachment_ids": mosque.mosqueQrAttachmentIds,
        // "qr_panel_numbers": mosque.qrPanelNumbers,
        "visit_notes": mosque.visitNotes,
        "observer_commit": mosque.observerCommit,
        "honor_name": mosque.honorName,
        // "image": mosque.image,
        // "outer_image": mosque.outerImage,
        // "qr_image": mosque.qrImage,
        "mosque_edit_request_number": mosque.mosqueEditRequestNumber,
        // "mosque_name_qr": mosque.mosqueNameQr,
      };
      if(oldMosque.image!=mosque.image)
        _pram['image']=mosque.image;

      if(oldMosque.outerImage!=mosque.outerImage)
        _pram['outer_image']=mosque.outerImage;



      dynamic response = await _mosqueRepository.updateMosque(mosque,_pram);

      return true;
    }on Exception catch (e){
      throw e;
    }

  }

  Future<bool> updateMosquePrayerSection(Mosque oldMosque,Mosque mosque) async {
    try {
      var _pram={
        "has_women_prayer_room": mosque.hasWomenPrayerRoom,
        "length_row_women_praying": mosque.lengthRowWomenPraying,
        "row_women_praying_number": mosque.rowWomenPrayingNumber,
        // "number_women_rows": mosque.numberWomenRows,
        "toilet_woman_number": mosque.toiletWomanNumber,
        "is_women_toilets": mosque.isWomenToilets,
        //"mosque_qr_attachment_ids": mosque.mosqueQrAttachmentIds,
        // "num_womens_bathrooms": mosque.numWomensBathrooms,
        "friday_prayer_rows": mosque.fridayPrayerRows,
        "row_men_praying_number": mosque.rowMenPrayingNumber,
        "length_row_men_praying": mosque.lengthRowMenPraying,
        "internal_doors_number": mosque.internalDoorsNumber,
        "toilet_men_number": mosque.toiletMenNumber,
      };

      dynamic response = await _mosqueRepository.updateMosque(mosque,_pram);

      return true;
    }on Exception catch (e){
      throw e;
    }

  }

  Future<bool> updateAccompanying(Mosque oldMosque,Mosque mosque) async {
    try {
      var _pram={
        "cars_parking": mosque.carsParking,
        "have_washing_room": mosque.haveWashingRoom,
        "lectures_hall": mosque.lecturesHall,
        "library_exist": mosque.libraryExist,
        "stood_on_ground_mosque": mosque.stoodOnGroundMosque,
        "vacancies_spaces": mosque.vacanciesSpaces,
        "lectures_hall": mosque.lecturesHall,
        "other_companions": mosque.otherCompanions,
        "row_men_praying_number": mosque.rowMenPrayingNumber ,
        "length_row_men_praying": mosque.lengthRowMenPraying,
        "internal_doors_number": mosque.internalDoorsNumber,
        "toilet_men_number": mosque.toiletMenNumber,
        "internal_speaker_number": mosque.internalSpeakerNumber,
        // "external_speaker_number": mosque.externalSpeakerNumber,
      };

      dynamic response = await _mosqueRepository.updateMosque(mosque,_pram);

      return true;
    }on Exception catch (e){
      throw e;
    }

  }

  Future<bool> updateBuildingDetail(Mosque oldMosque,Mosque mosque) async {
    try {
      var _pram={
        "endowment_on_land": mosque.endowmentOnLand,
        "has_basement": mosque.hasBasement,
        "building_material": mosque.buildingMaterial,
        "building_area": mosque.buildingArea,
        "building_status": mosque.buildingStatus,
        "occupancy_rate": mosque.occupancyRate,
        "buildings_on_land": mosque.buildingsOnLand,
        "recall_notes": mosque.recallNotes,
        "is_there_structure_buildings": mosque.isThereStructureBuildings,
        "building_type_ids":  [[6, false, mosque.buildingTypeIds]],
        "endowment_type": mosque.endowmentType,
        "permitted_from_ministry": mosque.permittedFromMinistry ,
        "is_other_attachment": mosque.isOtherAttachment,
        "other_attachment": mosque.otherAttachment,
        "notes_for_other": mosque.notesForOther,
        "external_headset_number": mosque.externalHeadsetNumber,
        "internal_speaker_number": mosque.internalSpeakerNumber,
        "external_speaker_number": mosque.externalSpeakerNumber,
        "num_lighting_inside": mosque.numLightingInside,
        "num_minarets": mosque.numMinarets,
        "num_floors": mosque.numFloors,
      };

      dynamic response = await _mosqueRepository.updateMosque(mosque,_pram);

      return true;
    }on Exception catch (e){
      throw e;
    }

  }

  Future<bool> updateMaintenanceDetail(Mosque oldMosque,Mosque mosque) async {
    try {
      var _pram={
        "maintainer": mosque.maintainer,
        "company_name": mosque.companyName,
        "contract_number": mosque.contractNumber,
        "has_washing_machine": mosque.hasWashingMachine,
        "has_other_facilities": mosque.hasOtherFacilities,
        "other_facilities_notes": mosque.otherFacilitiesNotes,
        "has_internal_camera": mosque.hasInternalCamera,
        "has_air_conditioners": mosque.hasAirConditioners,
        "num_air_conditioners": mosque.numAirConditioners ,
        "ac_type": mosque.acType,
        "has_fire_extinguishers": mosque.hasFireExtinguishers,
        "has_fire_system_pumps": mosque.hasFireSystemPumps,
        "maintenance_responsible": mosque.maintenanceResponsible,
        "maintenance_person": mosque.maintenancePerson,
        "has_deed": mosque.hasDeed,
        "electronic_instrument_up_to_date": mosque.electronicInstrumentUpToDate,
        "instrument_number": mosque.instrumentNumber,
        "instrument_date": mosque.instrumentDate,
        "instrument_notes": mosque.instrumentNotes,
        // "issuing_entity": mosque.issuingEntity,
        "old_instrument_date": mosque.oldInstrumentDate,
        "is_electronic_instrument": mosque.isElectronicInstrument,
        "instrument_attachment_ids": mosque.instrumentAttachmentIds,
         "instrument_entity_id": mosque.instrumentEntityId,
      };

      dynamic response = await _mosqueRepository.updateMosque(mosque,_pram);

      return true;
    }on Exception catch (e){
      throw e;
    }

  }

  Future<bool> updateMosqueGeneralInfo(Mosque oldMosque,Mosque mosque) async {
    try {
      var _pram={
        "location": mosque.location,
        "phone_number": mosque.phoneNumber,
        "twitter": mosque.twitter,
        "youtube": mosque.youtube,
        "website": mosque.website,
        "street": mosque.street,
        "street2": mosque.street2,
        "city": mosque.city1,
        "zip": mosque.zip,
        "latitude": mosque.latitude,
        "longitude": mosque.longitude,
      };

      dynamic response = await _mosqueRepository.updateMosque(mosque,_pram);

      return true;
    }on Exception catch (e){
      throw e;
    }

  }

  Future<bool> updateMosqueImamDetail(Mosque oldMosque,Mosque mosque,
      List<Meter> imamElecMeters,
      List<Meter> imamWaterMeters,
      List<Meter> muezinElecMeters,
      List<Meter> muezinWaterMeters) async {
    try {
      var _pram={
        "residence_for_imam": mosque.residenceForImam,
        "imam_residence_type": mosque.imamResidenceType,
        "imam_residence_land_area": mosque.imamResidenceLandArea,
        //"is_imam_electric_meter": mosque.isImamElectricMeter,
        "imam_electricity_meter_type": mosque.imamElectricityMeterType,
        "is_imam_electric_meter_new": mosque.isImamElectricMeterNew,
        //"is_imam_water_meter": mosque.isImamWaterMeter,
        "imam_water_meter_type": mosque.imamWaterMeterType,
        "residence_for_mouadhin": mosque.residenceForMouadhin,
        "is_imam_house_private": mosque.isImamHousePrivate,
        "muezzin_residence_type": mosque.muezzinResidenceType,
        "muezzin_residence_land_area": mosque.muezzinResidenceLandArea,
        //"is_muezzin_electric_meter": mosque.isMuezzinElectricMeter,
        "muezzin_electricity_meter_type": mosque.muezzinElectricityMeterType,
        "is_muezzin_electric_meter_new": mosque.isMuezzinElectricMeterNew,
        //"is_muezzin_water_meter": mosque.isMuezzinWaterMeter,
        "muezzin_water_meter_type": mosque.muezzinWaterMeterType,
        "is_muezzin_house_private": mosque.isMuezzinHousePrivate,
      };

      JsonUtils.addField(_pram,"is_imam_electric_meter",mosque.isImamElectricMeter,oldMosque.isImamElectricMeter);
      JsonUtils.addField(_pram,"is_imam_water_meter",mosque.isImamWaterMeter,oldMosque.isImamWaterMeter);
      JsonUtils.addField(_pram,"is_muezzin_electric_meter",mosque.isMuezzinElectricMeter,oldMosque.isMuezzinElectricMeter);
      JsonUtils.addField(_pram,"is_muezzin_water_meter",mosque.isMuezzinWaterMeter,oldMosque.isMuezzinWaterMeter);
      // "imam_electricity_meter_ids": mosque.imamElectricityMeterIds,
      // "imam_water_meter_ids": mosque.imamWaterMeterIds,
      // "muezzin_electricity_meter_ids": mosque.muezzinElectricityMeterIds,
      // "muezzin_water_meter_ids": mosque.muezzinWaterMeterIds,
      // "muezzin_house_type": mosque.muezzinHouseType,



      _pram['imam_electricity_meter_ids']=
        imamElecMeters.map((Meter item) {
          if(item.id==0){
            return [0,"virtual_1",{"name":item.name}];//Add
          }else if(item.isDelete){
            return [2,item.id,false];//Delete
          }else if(item.isEdit){
            return [1,item.id,{"name":item.name}];//Edit
          }else{
            return [4,item.id,false];//Remain same
          }
        }).toList()
      ;

      _pram['muezzin_electricity_meter_ids']=
          muezinElecMeters.map((Meter item) {
            if(item.id==0){
              return [0,"virtual_1",{"name":item.name}];//Add
            }else if(item.isDelete){
              return [2,item.id,false];//Delete
            }else if(item.isEdit){
              return [1,item.id,{"name":item.name}];//Edit
            }else{
              return [4,item.id,false];//Remain same
            }
          }).toList()

      ;

      _pram['imam_water_meter_ids']=
          imamWaterMeters.map((Meter item) {
            if(item.id==0){
              return [0,"virtual_1",{"name":item.name}];//Add
            }else if(item.isDelete){
              return [2,item.id,false];//Delete
            }else if(item.isEdit){
              return [1,item.id,{"name":item.name}];//Edit
            }else{
              return [4,item.id,false];//Remain same
            }
          }).toList()
      ;

      _pram['muezzin_water_meter_ids']=
          muezinWaterMeters.map((Meter item) {
            if(item.id==0){
              return [0,"virtual_1",{"name":item.name}];//Add
            }else if(item.isDelete){
              return [2,item.id,false];//Delete
            }else if(item.isEdit){
              return [1,item.id,{"name":item.name}];//Edit
            }else{
              return [4,item.id,false];//Remain same
            }
          }).toList()
      ;
      dynamic response = await _mosqueRepository.updateMosque(mosque,_pram);

      return true;
    }on Exception catch (e){
      throw e;
    }

  }

  Future<bool> updateMosqueGeoLocation(Mosque oldMosque,Mosque mosque) async {
    try {
      var _pram={
        "latitude": mosque.latitude,
        "longitude": mosque.longitude,
      };

      dynamic response = await _mosqueRepository.updateMosque(mosque,_pram);

      return true;
    }on Exception catch (e){
      throw e;
    }

  }

  Future<Mosque> loadMosque() async {
    try {
      var _domain=[];
      Mosque mosque =Mosque(id: 0);
      dynamic response = await _mosqueRepository.loadMosque();
      mosque = Mosque.fromJson(response['value']);
      return mosque;
    }catch(e){
      throw Response("error", 408);
    }

  }




  Future<List<FieldList>> loadMosqueView() async {
    try {
      var _domain=[];
      List<FieldList> data=[];
      Mosque mosque =Mosque(id: 0);
      dynamic response = await _mosqueRepository.loadMosqueView();
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

  Future<MosqueRegion> createMosqueRegion(MosqueRegion region,int mosqueId) async {
    try {
      var _domain=[];

      dynamic response = await _mosqueRepository.createMosqueRegion(region,mosqueId);
      return region;
    }on Exception catch (e){
      throw e;
    }

  }

  Future<MosqueRegion> updateMosqueRegion(MosqueRegion region,int mosqueId) async {
    try {
      dynamic response = await _mosqueRepository.updateMosqueRegion(region,mosqueId);
      return region;
    }on Exception catch (e){
      throw e;
    }
  }


  Future<int?> getClassificationIdByCode(String code) async {
    try {
      var _domain=[];

      dynamic response = await repository.getClassificationIdByCode(code);
      return response;
    }on Exception catch (e){
      throw e;
    }

  }



  Future<dynamic> validteYakeenApi(Employee mosque) async {
    try {
      var _domain=[];

      String dob='';
      if(mosque.identificationId!.startsWith('1')){

        dynamic selectedDateHijri = new HijriCalendar.fromDate(DateTime.parse(mosque.birthday!));
        dob=selectedDateHijri.hYear.toString()+"-"+AppUtils.addZero(selectedDateHijri.hMonth);
      }else{
        List<String> parts = mosque.birthday!.split("-");
        dob="${parts[0]}-${parts[1]}";;
      }
      dynamic response = await repository.validateYakeenAPI(mosque,dob);
      return response;
    }on Exception catch (e){
      throw e;
    }
  }

  Future<dynamic> validteNationalId(Employee mosque) async {
    try {
      var _domain=[];

      dynamic response = await repository.validateNationalId(mosque);
      return response;
    }on Exception catch (e){
      throw e;
    }

  }


  Future<List<MosqueRegion>> getRegionByIds(List<int> ids) async {
    List<MosqueRegion> list=[];
    try {

      dynamic response = await _mosqueRepository.getRegionsByIds(ids);
      list=(response as List).map((item) => MosqueRegion.fromJson(item)).toList();
      return list;
    }catch(e){
      throw Response("error", 408);
    }

  }

  Future<List<Meter>> getMetersByIds(List<int> ids) async {
    List<Meter> list=[];
    try {

      dynamic response = await _mosqueRepository.getMetersByIds(ids);
      list=(response as List).map((item) => Meter.fromJsonObject(item)).toList();
      return list;
    }catch(e){
    
      throw e;
    }

  }

}