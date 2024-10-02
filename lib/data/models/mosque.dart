import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:mosque_management_system/utils/extension.dart';
import 'package:mosque_management_system/utils/json_utils.dart';
import 'package:mosque_management_system/utils/paged_data.dart';
import 'package:odoo_rpc/odoo_rpc.dart';

class Mosque {
  String? empty;
  int id;
  String? name;
  String? state;
  int? stageId;
  String? stage;
  String? number;
  String? city;
  int? cityId;
  String? street;
  String? district;
  int? districtId;
  String? moiaCenter;
  int? moiaCenterId;
  String? classification;
  int? classificationId;
  String? region;
  int? regionId;
  String? country;
  int? countryId;
  String? uniqueId;
  String? establishmentDate;
  String? dateMaintenanceLast;
  String? mosqueState;
  String? alImam;
  List<int>? imamIds;
  List<int>? muezzinIds;
  List<int>? khademIds;
  List<int>? khatibIds;
  int? alImamId;
  String? alMudhin;
  int? alMudhinId;
  String? alKhatib;
  int? alKhatibId;

  String? landOwner;
  double? surface;
  int? unitId;
  String? unit;
  String? landArea;
  int? capacity;
  String? electricityMeterNumero;
  String? waterMeterNumero;

  //Mosque Detail  property

  //Mosque info property
  //----Basic Info

  double? noPlanned;
  double? pieceNumber;
  String? nationalAddress;

  String? declarationNote;
  String? observerSupervisorComment;

  int? mosqueOpeningDate;
  String? isEmployee;
  String? mosqueOwnerName;
  int? qrPanelNumbers;
  String? visitNotes;
  bool? observerCommit;
  String? honorName;
  String? image;
  String? outerImage;
  String? qrImage;
  int? mosqueEditRequestNumber;
  String? mosqueNameQr;
  List<int>? mosqueQrAttachmentIds;


  //----Instrument Details
  String? hasDeed;
  String? electronicInstrumentUpToDate;
  double? instrumentNumber;
  String? instrumentDate;
  String? instrumentNotes;
  String? issuingEntity;
  //----Mosque Details
  String? hasWomenPrayerRoom;

  double? lengthRowWomenPraying;
  int? rowWomenPrayingNumber;
  int? numberWomenRows;
  int? toiletWomanNumber;
  String? isWomenToilets;





  double? mosqueLandArea;
  double? roofedArea;
  String? urbanCondition;
  double? carryingCapacity;
  double? fridayPrayerRows;
  String? hasQrCodePanel;
  String? qrCodeNotes;

  String? isQrCodeExist;
  //String? isQrCodeExist;


  String? plateLegible;
  String? isPanelReadable;
  String? codeReadable;
  String? mosqueDataCorrect;
  String? qrCodeMatch;
  double? numQrCodePanels;
  String? hasElectricityMeter;
  String? isMosqueElectricMeterNew;
  List<int>? mosqueElectricityMeterIds;
  String? hasWaterMeter;
  List<int>? mosqueWaterMeterIds;
  //----Maintenance Details
  String? maintainer;
  String? companyName;
  String? contractNumber;
  String? hasWashingMachine;
  String? hasOtherFacilities;
  String? otherFacilitiesNotes;
  String? hasInternalCamera;
  String? hasAirConditioners;
  double? numAirConditioners;
  String? acType;
  String? hasFireExtinguishers;
  String? hasFireSystemPumps;



  String? maintenanceResponsible;
  String? maintenancePerson;
  String? oldInstrumentDate;
  String? isElectronicInstrument;
  List<int>? instrumentAttachmentIds;
  String? instrumentEntity;
  int? instrumentEntityId;


  //----Imam's Residence Details

  String? residenceForImam;
  String? isImamElectricMeter;
  String? isImamWaterMeter;
  String? isImamHousePrivate;

  String? isImamElectricMeterNew;
  List<int>? imamElectricityMeterIds;
  List<int>? imamWaterMeterIds;




  String? imamResidenceType;
  double? imamResidenceLandArea;
  String? imamElectricityMeterType;
  String? imamElectricityMeterNumber;
  String? imamWaterMeterType;
  String? imamWaterMeterNumber;
  //----Muezzin's Residence Details

  String? residenceForMouadhin;
  String? isMuezzinElectricMeter;

  String? isMuezzinElectricMeterNew;
  List<int>? muezzinElectricityMeterIds;
  List<int>? muezzinWaterMeterIds;


  String? isMuezzinWaterMeter;
  String? isMuezzinHousePrivate;
  String? muezzinHouseType;

  String? muezzinResidenceType;



  double? muezzinResidenceLandArea;
  String? muezzinElectricityMeterType;
  String? muezzinElectricityMeterNumber;
  String? muezzinWaterMeterType;
  String? muezzinWaterMeterNumber;
  //----Muezzin's Residence Details
  String? endowmentOnLand;
  String? hasBasement;
  String? buildingMaterial;
  double? occupancyRate;
  String? buildingsOnLand;
  String? recallNotes;
  String? ministryAuthorized;

  String? isThereStructureBuildings;
  List<int>? buildingTypeIds;
  String? endowmentType;
  String? permittedFromMinistry;
  String? isOtherAttachment;
  String? otherAttachment;
  String? notesForOther;
  int? externalHeadsetNumber;



  //----Facilities Details
  double? numMensBathrooms;
  double? numWomensBathrooms;
  double? numInternalSpeakers;
  double? numExternalSpeakers;
  int? numLightingInside;
  int? numMinarets;
  int? numFloors;
  double? mosqueSize;
  //Accompanying

  double? buildingArea;
  String? buildingStatus;
  double? nonBuildingArea;
  double? freeArea;
  String? isFreeArea;
  int? mosqueRooms;


  bool? carsParking;
  bool? haveWashingRoom;
  bool? lecturesHall;
  bool? libraryExist;
  bool? stoodOnGroundMosque;
  bool? vacanciesSpaces;
  bool? otherCompanions;
  String? description;
  int? rowMenPrayingNumber;
  double? lengthRowMenPraying;
  int? internalDoorsNumber;
  int? toiletMenNumber;
  int? internalSpeakerNumber;
  int? externalSpeakerNumber;
  //General Info
  String? location;
  String? phoneNumber;
  String? twitter;
  String? youtube;
  String? website;
  String? note;
  String? street2;
  String? city1;
  String? zip;
  double? latitude;
  double? longitude;
  //grids
  List<int>? humanStaffIds;
  List<int>? supervisionPartnerIds;
  List<int>? partnerIds;
  List<int>? regionIds;
  List<int>? spaceIds;
  List<int>? componentIds;
  List<int>? mosqueContractorIds;
  List<int>? maintenanceStaffIds;
  List<int>? hygieneStaffIds;
  List<int>? programIds;
  List<int>? serviceIds;
  List<int>? systemIds;
  List<int>? mosqueDeviceIds;
  List<int>? attachmentIds;

  //New field  property
  int? supervisorId;
  String? supervisor;
  List<int>? observerIds;
  String? oldSequence;
  bool? isAnotherNeighborhood;
  String? anotherNeighborhoodChar;

  bool? displayButtonSend;
  bool? displayButtonAccept;
  bool? displayButtonRefuse;
  bool? isObserverEditable;

  bool get isActionButton => (this.displayButtonAccept??false) || (this.displayButtonRefuse??false);


  // Shallow copy constructor
  // Shallow copy constructor
  Mosque.shallowCopy(Mosque other)
      : id = other.id,
        name = other.name,
        state = other.state,
        stage=other.stage,
        stageId=other.stageId,
        oldSequence=other.oldSequence,
        isAnotherNeighborhood=other.isAnotherNeighborhood,
        anotherNeighborhoodChar=other.anotherNeighborhoodChar,
        number =other.number,
        city = other.city,
        street = other.street,
        district = other.district,
        districtId = other.districtId,
        moiaCenter = other.moiaCenter,
        moiaCenterId = other.moiaCenterId,
        classification = other.classification,
        classificationId = other.classificationId,
        country = other.country,
        countryId = other.countryId,
        region = other.region,
        regionId = other.regionId,
        uniqueId = other.uniqueId,
        establishmentDate = other.establishmentDate,
        dateMaintenanceLast = other.dateMaintenanceLast,
        mosqueState = other.mosqueState,
        imamIds = other.imamIds,
        muezzinIds = other.muezzinIds,
        khademIds = other.khademIds,
        khatibIds = other.khatibIds,
        alImam = other.alImam,
        alMudhin = other.alMudhin,
        alKhatib = other.alKhatib,
        cityId = other.cityId,
        landOwner = other.landOwner,
        surface = other.surface,
        unitId = other.unitId,
        unit = other.unit,
        landArea = other.landArea,
        capacity = other.capacity,
        electricityMeterNumero = other.electricityMeterNumero,
        waterMeterNumero = other.waterMeterNumero,
        observerIds = other.observerIds,
        supervisorId = other.supervisorId,
        supervisor = other.supervisor,
        noPlanned = other.noPlanned,
        pieceNumber = other.pieceNumber,
        nationalAddress = other.nationalAddress,

        declarationNote = other.declarationNote,
        observerSupervisorComment = other.observerSupervisorComment,

        mosqueOpeningDate = other.mosqueOpeningDate,
        isEmployee = other.isEmployee,
        mosqueOwnerName = other.mosqueOwnerName,
        qrPanelNumbers = other.qrPanelNumbers,
        visitNotes = other.visitNotes,
        observerCommit = other.observerCommit,
        honorName = other.honorName,
        image = other.image,
        outerImage = other.outerImage,
        qrImage = other.qrImage,
        mosqueEditRequestNumber = other.mosqueEditRequestNumber,
        mosqueNameQr = other.mosqueNameQr,
        mosqueQrAttachmentIds = other.mosqueQrAttachmentIds,


        hasDeed = other.hasDeed,
        electronicInstrumentUpToDate = other.electronicInstrumentUpToDate,
        instrumentNumber = other.instrumentNumber,
        instrumentDate = other.instrumentDate,
        instrumentNotes = other.instrumentNotes,
        issuingEntity = other.issuingEntity,
        hasWomenPrayerRoom = other.hasWomenPrayerRoom,

        lengthRowWomenPraying = other.lengthRowWomenPraying,
        rowWomenPrayingNumber = other.rowWomenPrayingNumber,
        numberWomenRows = other.numberWomenRows,
        toiletWomanNumber = other.toiletWomanNumber,
        isWomenToilets = other.isWomenToilets,

        mosqueLandArea = other.mosqueLandArea,
        roofedArea = other.roofedArea,
        urbanCondition = other.urbanCondition,
        carryingCapacity = other.carryingCapacity,
        fridayPrayerRows = other.fridayPrayerRows,
        hasQrCodePanel = other.hasQrCodePanel,
        qrCodeNotes = other.qrCodeNotes,
        isQrCodeExist = other.isQrCodeExist,
        plateLegible = other.plateLegible,
        isPanelReadable = other.isPanelReadable,
        codeReadable = other.codeReadable,
        mosqueDataCorrect = other.mosqueDataCorrect,
        qrCodeMatch = other.qrCodeMatch,
        numQrCodePanels = other.numQrCodePanels,
        hasElectricityMeter = other.hasElectricityMeter,
        isMosqueElectricMeterNew = other.isMosqueElectricMeterNew,
        mosqueElectricityMeterIds = other.mosqueElectricityMeterIds,
        hasWaterMeter = other.hasWaterMeter,
        mosqueWaterMeterIds = other.mosqueWaterMeterIds,
        maintainer = other.maintainer,
        companyName = other.companyName,
        contractNumber = other.contractNumber,
        hasWashingMachine = other.hasWashingMachine,
        hasOtherFacilities = other.hasOtherFacilities,
        otherFacilitiesNotes = other.otherFacilitiesNotes,
        hasInternalCamera = other.hasInternalCamera,
        hasAirConditioners = other.hasAirConditioners,
        numAirConditioners = other.numAirConditioners,
        acType = other.acType,
        hasFireExtinguishers = other.hasFireExtinguishers,
        hasFireSystemPumps = other.hasFireSystemPumps,


        maintenanceResponsible = other.maintenanceResponsible,
        maintenancePerson = other.maintenancePerson,
        oldInstrumentDate = other.oldInstrumentDate,
        isElectronicInstrument = other.isElectronicInstrument,
        instrumentAttachmentIds = other.instrumentAttachmentIds,
        instrumentEntity = other.instrumentEntity,
        instrumentEntityId = other.instrumentEntityId,

        imamResidenceType = other.imamResidenceType,

        residenceForImam = other.residenceForImam,
        isImamElectricMeter = other.isImamElectricMeter,
        isImamWaterMeter = other.isImamWaterMeter,
        isImamHousePrivate = other.isImamHousePrivate,


        isImamElectricMeterNew = other.isImamElectricMeterNew,
        imamElectricityMeterIds = other.imamElectricityMeterIds,
        imamWaterMeterIds = other.imamWaterMeterIds,

        imamResidenceLandArea = other.imamResidenceLandArea,
        imamElectricityMeterType = other.imamElectricityMeterType,
        imamElectricityMeterNumber = other.imamElectricityMeterNumber,
        imamWaterMeterType = other.imamWaterMeterType,
        imamWaterMeterNumber = other.imamWaterMeterNumber,
        muezzinResidenceType = other.muezzinResidenceType,

        residenceForMouadhin= other.residenceForMouadhin,

        isMuezzinElectricMeter= other.isMuezzinElectricMeter,
        isMuezzinWaterMeter= other.isMuezzinWaterMeter,
        isMuezzinHousePrivate= other.isMuezzinHousePrivate,

        muezzinHouseType= other.muezzinHouseType,

        isMuezzinElectricMeterNew= other.isMuezzinElectricMeterNew,
        muezzinElectricityMeterIds= other.muezzinElectricityMeterIds,
        muezzinWaterMeterIds= other.muezzinWaterMeterIds,

        muezzinResidenceLandArea = other.muezzinResidenceLandArea,
        muezzinElectricityMeterType = other.muezzinElectricityMeterType,
        muezzinElectricityMeterNumber = other.muezzinElectricityMeterNumber,
        muezzinWaterMeterType = other.muezzinWaterMeterType,
        muezzinWaterMeterNumber = other.muezzinWaterMeterNumber,
        endowmentOnLand = other.endowmentOnLand,
        hasBasement = other.hasBasement,
        buildingMaterial = other.buildingMaterial,
        occupancyRate = other.occupancyRate,
        buildingsOnLand = other.buildingsOnLand,
        recallNotes = other.recallNotes,
        ministryAuthorized = other.ministryAuthorized,

        isThereStructureBuildings = other.isThereStructureBuildings,
        buildingTypeIds = other.buildingTypeIds,
        endowmentType = other.endowmentType,
        permittedFromMinistry = other.permittedFromMinistry,
        isOtherAttachment = other.isOtherAttachment,
        otherAttachment = other.otherAttachment,
        notesForOther = other.notesForOther,
        externalHeadsetNumber = other.externalHeadsetNumber,

        numMensBathrooms = other.numMensBathrooms,
        numWomensBathrooms = other.numWomensBathrooms,
        numInternalSpeakers = other.numInternalSpeakers,
        numExternalSpeakers = other.numExternalSpeakers,
        numLightingInside = other.numLightingInside,
        numMinarets = other.numMinarets,
        numFloors = other.numFloors,
        mosqueSize = other.mosqueSize,
        humanStaffIds = other.humanStaffIds,
        supervisionPartnerIds = other.supervisionPartnerIds,
        partnerIds = other.partnerIds,
        regionIds = other.regionIds,
        spaceIds = other.spaceIds,
        componentIds = other.componentIds,
        mosqueContractorIds = other.mosqueContractorIds,
        maintenanceStaffIds = other.maintenanceStaffIds,
        hygieneStaffIds = other.hygieneStaffIds,
        programIds = other.programIds,
        serviceIds = other.serviceIds,
        systemIds = other.systemIds,
        mosqueDeviceIds = other.mosqueDeviceIds,
        attachmentIds = other.attachmentIds,
        carsParking = other.carsParking,
        buildingArea = other.buildingArea,
        buildingStatus = other.buildingStatus,
        nonBuildingArea = other.nonBuildingArea,
        freeArea = other.freeArea,
        isFreeArea = other.isFreeArea,
        mosqueRooms = other.mosqueRooms,
        haveWashingRoom = other.haveWashingRoom,
        lecturesHall = other.lecturesHall,
        libraryExist = other.libraryExist,
        stoodOnGroundMosque = other.stoodOnGroundMosque,
        vacanciesSpaces = other.vacanciesSpaces,
        otherCompanions = other.otherCompanions,
        description = other.description,
        rowMenPrayingNumber = other.rowMenPrayingNumber,
        lengthRowMenPraying = other.lengthRowMenPraying,
        internalDoorsNumber = other.internalDoorsNumber,
        toiletMenNumber = other.toiletMenNumber,
        internalSpeakerNumber = other.internalSpeakerNumber,
        externalSpeakerNumber = other.externalSpeakerNumber,
        location = other.location,
        phoneNumber = other.phoneNumber,
        twitter = other.twitter,
        youtube = other.youtube,
        website = other.website,
        note = other.note,
        street2 = other.street2,
        city1 = other.city1,
        zip = other.zip,
        latitude = other.latitude,
        longitude = other.longitude,
        displayButtonSend = other.displayButtonSend,
        displayButtonAccept = other.displayButtonAccept,
        displayButtonRefuse = other.displayButtonRefuse,
        isObserverEditable = other.isObserverEditable
  ;


  Mosque({
    required this.id,
    this.name,
    this.state,
    this.stageId,
    this.stage,
    this.oldSequence,
    this.isAnotherNeighborhood,
    this.anotherNeighborhoodChar,
    this.number,
    this.city,
    this.street,
    this.district,
    this.districtId,
    this.moiaCenter,
    this.moiaCenterId,
    this.classification,
    this.classificationId,
    this.country,
    this.countryId,
    this.region,
    this.regionId,
    this.uniqueId,
    this.establishmentDate,
    this.dateMaintenanceLast,
    this.mosqueState,
    this.alImam,
    this.imamIds,
    this.muezzinIds,
    this.khademIds,
    this.khatibIds,
    this.alMudhin,
    this.alKhatib,
    this.cityId,
    this.landOwner,
    this.surface,
    this.unitId,
    this.unit,
    this.landArea,
    this.capacity,
    this.electricityMeterNumero,
    this.waterMeterNumero,
    //Mosque info property
    this.observerIds,
    this.supervisorId,
    this.supervisor,
    this.noPlanned,
    this.pieceNumber,
    this.nationalAddress,

    this.declarationNote,
    this.observerSupervisorComment,



    this.mosqueOpeningDate,
    this.isEmployee,
    this.mosqueOwnerName,
    this.qrPanelNumbers,
    this.visitNotes,
    this.observerCommit,
    this.honorName,
    this.image,
    this.outerImage,
    this.qrImage,
    this.mosqueEditRequestNumber,
    this.mosqueNameQr,
    this.mosqueQrAttachmentIds,
    this.hasDeed,
    this.electronicInstrumentUpToDate,
    this.instrumentNumber,
    this.instrumentDate,
    this.instrumentNotes,
    this.issuingEntity,
    this.hasWomenPrayerRoom,
    this.lengthRowWomenPraying,
    this.rowWomenPrayingNumber,
    this.numberWomenRows,
    this.toiletWomanNumber,
    this.isWomenToilets,
    this.mosqueLandArea,
    this.roofedArea,
    this.urbanCondition,
    this.carryingCapacity,
    this.fridayPrayerRows,
    this.hasQrCodePanel,
    this.qrCodeNotes,
    this.isQrCodeExist,
    this.plateLegible,
    this.isPanelReadable,
    this.codeReadable,
    this.mosqueDataCorrect,
    this.qrCodeMatch,
    this.numQrCodePanels,
    this.hasElectricityMeter,
    this.isMosqueElectricMeterNew,
    this.mosqueElectricityMeterIds,
    this.hasWaterMeter,
    this.mosqueWaterMeterIds,
    this.maintainer,
    this.companyName,
    this.contractNumber,
    this.hasWashingMachine,
    this.hasOtherFacilities,
    this.otherFacilitiesNotes,
    this.hasInternalCamera,
    this.hasAirConditioners,
    this.numAirConditioners,
    this.acType,
    this.hasFireExtinguishers,
    this.hasFireSystemPumps,

    this.maintenanceResponsible,
    this.maintenancePerson,
    this.oldInstrumentDate,
    this.isElectronicInstrument,
    this.instrumentAttachmentIds,
    this.instrumentEntity,
    this.instrumentEntityId,


    this.imamResidenceType,
    this.residenceForImam,
    this.isImamElectricMeter,
    this.isImamWaterMeter,
    this.isImamHousePrivate,

    this.isImamElectricMeterNew,
    this.imamElectricityMeterIds,
    this.imamWaterMeterIds,

    this.imamResidenceLandArea,
    this.imamElectricityMeterType,
    this.imamElectricityMeterNumber,
    this.imamWaterMeterType,
    this.imamWaterMeterNumber,
    this.muezzinResidenceType,

    this.residenceForMouadhin,
    this.isMuezzinElectricMeter,
    this.isMuezzinWaterMeter,
    this.isMuezzinHousePrivate,
    this.muezzinHouseType,

    this.isMuezzinElectricMeterNew,
    this.muezzinElectricityMeterIds,
    this.muezzinWaterMeterIds,

    this.muezzinResidenceLandArea,
    this.muezzinElectricityMeterType,
    this.muezzinElectricityMeterNumber,
    this.muezzinWaterMeterType,
    this.muezzinWaterMeterNumber,
    this.endowmentOnLand,
    this.hasBasement,
    this.buildingMaterial,
    this.occupancyRate,
    this.buildingsOnLand,
    this.recallNotes,
    this.ministryAuthorized,


    this.isThereStructureBuildings,
    this.buildingTypeIds,
    this.endowmentType,
    this.permittedFromMinistry,
    this.isOtherAttachment,
    this.otherAttachment,
    this.notesForOther,
    this.externalHeadsetNumber,

    this.numMensBathrooms,
    this.numWomensBathrooms,
    this.numInternalSpeakers,
    this.numExternalSpeakers,
    this.numLightingInside,
    this.numMinarets,
    this.numFloors,
    this.mosqueSize,
    //List
    this.humanStaffIds,
    this.supervisionPartnerIds,
    this.partnerIds,
    this.regionIds,
    this.spaceIds,
    this.componentIds,
    this.mosqueContractorIds,
    this.maintenanceStaffIds,
    this.hygieneStaffIds,
    this.programIds,
    this.serviceIds,
    this.systemIds,
    this.mosqueDeviceIds,
    this.attachmentIds,
    //Accompanying
    this.carsParking,
    this.buildingArea,
    this.buildingStatus,
    this.nonBuildingArea,
    this.freeArea,
    this.isFreeArea,
    this.mosqueRooms,
    this.haveWashingRoom,
    this.lecturesHall,
    this.libraryExist,
    this.stoodOnGroundMosque,
    this.vacanciesSpaces,
    this.otherCompanions,
    this.description,
    this.rowMenPrayingNumber,
    this.lengthRowMenPraying,
    this.internalDoorsNumber,
    this.toiletMenNumber,
    this.internalSpeakerNumber,
    this.externalSpeakerNumber,
    //General Info
    this.location,
    this.phoneNumber,
    this.twitter,
    this.youtube,
    this.website,
    this.note,
    this.street2,
    this.city1,
    this.zip,
    this.latitude,
    this.longitude=0,
    this.displayButtonSend,
    this.displayButtonAccept,
    this.isObserverEditable,
    this.displayButtonRefuse

  });
  factory Mosque.fromJson(Map<String, dynamic> json) {
    //json['no_planned']=false;
    return Mosque(
      id: JsonUtils.toInt(json['id'])??0,
      name: JsonUtils.toText(json['name']),
      state: JsonUtils.toText(json['state']),
      stage: JsonUtils.getName(json['stage_id']),
      stageId: JsonUtils.getId(json['stage_id']),
      oldSequence: JsonUtils.toText(json['old_sequence']),
      isAnotherNeighborhood: JsonUtils.toBoolean(json['is_another_neighborhood']),
      anotherNeighborhoodChar: JsonUtils.toText(json['another_neighborhood_char']),
      number: JsonUtils.toText(json['number']),
      city: JsonUtils.getName(json['city_id']),
      cityId:JsonUtils.getId(json['city_id']) ,
      street: JsonUtils.toText(json['street']),
      district: JsonUtils.getName(json['district']),
      districtId: JsonUtils.getId(json['district']),
      moiaCenter: JsonUtils.getName(json['moia_center_id']),
      moiaCenterId: JsonUtils.getId(json['moia_center_id']),
      classification: (((json['classification_id']??false)==false?[]:json['classification_id']) as List<dynamic>).getName(),
      classificationId: (((json['classification_id']??false)==false?[]:json['classification_id']) as List<dynamic>).getId(),
      country: JsonUtils.getName(json['country_id']),
      countryId: JsonUtils.getId(json['country_id']),
      region: JsonUtils.getName(json['region_id']),
      regionId: JsonUtils.getId(json['region_id']),
      uniqueId:(json['__last_update']??false)==false?"":json['__last_update'].replaceAll(RegExp(r'[^0-9]'), ''),
      establishmentDate: JsonUtils.toText(json['establishment_date']),
      dateMaintenanceLast: (json['date_maintenance_last']??false)==false?'':json['date_maintenance_last'],
      mosqueState: JsonUtils.toText(json['mosque_state']),
      alImam: (json['alimam']??false)==false?'':json['alimam'],
      imamIds:JsonUtils.toList(json['imam_ids']),
      muezzinIds:JsonUtils.toList(json['muezzin_ids']),
      khademIds:JsonUtils.toList(json['khadem_ids']),
      khatibIds:JsonUtils.toList(json['khatib_ids']),
      alMudhin: (json['almudhin']??false)==false?'':json['almudhin'],
      alKhatib: (json['alkhatib']??false)==false?'':json['alkhatib'],

      landOwner: JsonUtils.toText(json['land_owner']),
      surface: (json['surface']??false)==false?null:json['surface'],
      unitId: (((json['unit_id']??false)==false?[]:json['unit_id']) as List<dynamic>).getId(),
      unit: (((json['unit_id']??false)==false?[]:json['unit_id']) as List<dynamic>).getName(),
      landArea: JsonUtils.toText(json['land_area']),
      capacity: JsonUtils.toInt(json['capacity']),
      electricityMeterNumero: (json['electricity_meter_numero']??false)==false?'':json['electricity_meter_numero'],
      waterMeterNumero: (json['water_meter_numero']??false)==false?'':json['water_meter_numero'],
      // //Mosque info property
      observerIds: JsonUtils.toList(json['observer_ids']),
      supervisorId: JsonUtils.getId(json['supervisor_id']),
      supervisor: JsonUtils.getName(json['supervisor_id']),
      noPlanned: JsonUtils.toDouble(json['no_planned']),
       pieceNumber: JsonUtils.toDouble(json['piece_number']),
       nationalAddress: JsonUtils.toText(json['national_address']),

      declarationNote: JsonUtils.toText(json['declaration_note']),
      observerSupervisorComment: JsonUtils.toText(json['observer_supervisor_comment']),


      mosqueOpeningDate: JsonUtils.toInt(json['mosque_opening_date']),
      isEmployee: JsonUtils.toText(json['is_employee']),
      mosqueOwnerName: JsonUtils.toText(json['mosque_owner_name']),
      qrPanelNumbers: JsonUtils.toInt(json['qr_panel_numbers']),
      visitNotes: JsonUtils.toText(json['visit_notes']),
      observerCommit: JsonUtils.toBoolean(json['observer_commit']),
      honorName: JsonUtils.toText(json['honor_name']),
      image: JsonUtils.toText(json['image']),
      outerImage: JsonUtils.toText(json['outer_image']),
      qrImage: JsonUtils.toText(json['qr_image']),
      mosqueEditRequestNumber: JsonUtils.toInt(json['mosque_edit_request_number']),
      mosqueNameQr: JsonUtils.toText(json['mosque_name_qr']),
      mosqueQrAttachmentIds: JsonUtils.toList(json['mosque_qr_attachment_ids']),

      hasDeed: JsonUtils.toText(json['has_deed']),
      electronicInstrumentUpToDate: JsonUtils.toText(json['electronic_instrument_up_to_date']),
      instrumentNumber: JsonUtils.toDouble(json['instrument_number']),
      instrumentDate: JsonUtils.toText(json['instrument_date']),
      instrumentNotes: JsonUtils.toText(json['instrument_notes']),
      issuingEntity: JsonUtils.toText(json['issuing_entity']),
      hasWomenPrayerRoom: JsonUtils.toText(json['has_women_prayer_room']),
      lengthRowWomenPraying: JsonUtils.toDouble(json['length_row_women_praying']),
      rowWomenPrayingNumber: JsonUtils.toInt(json['row_women_praying_number']),
      numberWomenRows: JsonUtils.toInt(json['number_women_rows']),
      toiletWomanNumber: JsonUtils.toInt(json['toilet_woman_number']),
      isWomenToilets: JsonUtils.toText(json['is_women_toilets']),
      mosqueLandArea: JsonUtils.toDouble(json['mosque_land_area']),
       roofedArea: JsonUtils.toDouble(json['roofed_area']),
       urbanCondition: JsonUtils.toText(json['urban_condition']),
       carryingCapacity: JsonUtils.toDouble(json['carrying_capacity']),
       fridayPrayerRows: JsonUtils.toDouble(json['friday_prayer_rows']),
      hasQrCodePanel: JsonUtils.toText(json['has_qr_code_panel']),
      qrCodeNotes: JsonUtils.toText(json['qr_code_notes']),
      isQrCodeExist: JsonUtils.toText(json['is_qr_code_exist']),
      plateLegible: JsonUtils.toText(json['plate_legible']),
      isPanelReadable: JsonUtils.toText(json['is_panel_readable']),
      codeReadable: JsonUtils.toText(json['code_readable']),
      mosqueDataCorrect: JsonUtils.toText(json['mosque_data_correct']),
      qrCodeMatch: JsonUtils.toText(json['qr_code_match']),
      numQrCodePanels: JsonUtils.toDouble(json['num_qr_code_panels']),
      hasElectricityMeter: JsonUtils.toText(json['has_electricity_meter']),
      isMosqueElectricMeterNew: JsonUtils.toText(json['is_mosque_electric_meter_new']),
      mosqueElectricityMeterIds: JsonUtils.toList(json['mosque_electricity_meter_ids']),
      hasWaterMeter: JsonUtils.toText(json['has_water_meter']),
      mosqueWaterMeterIds: JsonUtils.toList(json['mosque_water_meter_ids']),
      maintainer: JsonUtils.toText(json['maintainer']),
      companyName: JsonUtils.toText(json['company_name']),
      contractNumber: JsonUtils.toText(json['contract_number']),
      hasWashingMachine: JsonUtils.toText(json['has_washing_machine']),
      hasOtherFacilities: JsonUtils.toText(json['has_other_facilities']),
      otherFacilitiesNotes: JsonUtils.toText(json['other_facilities_notes']),
      hasInternalCamera: JsonUtils.toText(json['has_internal_camera']),
      hasAirConditioners: JsonUtils.toText(json['has_air_conditioners']),
      numAirConditioners: JsonUtils.toDouble(json['num_air_conditioners']),
      acType: JsonUtils.toText(json['ac_type']),
      hasFireExtinguishers: JsonUtils.toText(json['has_fire_extinguishers']),
       hasFireSystemPumps: JsonUtils.toText(json['has_fire_system_pumps']),



      maintenanceResponsible: JsonUtils.toText(json['maintenance_responsible']),
      maintenancePerson: JsonUtils.toText(json['maintenance_person']),
      oldInstrumentDate: JsonUtils.toText(json['old_instrument_date']),
      isElectronicInstrument: JsonUtils.toText(json['is_electronic_instrument']),
      instrumentAttachmentIds: JsonUtils.toList(json['instrument_attachment_ids']),
      instrumentEntity: JsonUtils.getName(json['instrument_entity_id']),
      instrumentEntityId: JsonUtils.getId(json['instrument_entity_id']),




      imamResidenceType: JsonUtils.toText(json['imam_residence_type']),
      residenceForImam: JsonUtils.toText(json['residence_for_imam']),
      isImamElectricMeter: JsonUtils.toText(json['is_imam_electric_meter']),
      isImamWaterMeter: JsonUtils.toText(json['is_imam_water_meter']),
      isImamHousePrivate: JsonUtils.toText(json['is_imam_house_private']),

      isImamElectricMeterNew: JsonUtils.toText(json['is_imam_electric_meter_new']),
      imamElectricityMeterIds: JsonUtils.toList(json['imam_electricity_meter_ids']),
      imamWaterMeterIds: JsonUtils.toList(json['imam_water_meter_ids']),

      imamResidenceLandArea: JsonUtils.toDouble(json['imam_residence_land_area']),
      imamElectricityMeterType: JsonUtils.toText(json['imam_electricity_meter_type']),
      imamElectricityMeterNumber: JsonUtils.toText(json['imam_electricity_meter_number']),
      imamWaterMeterType: JsonUtils.toText(json['imam_water_meter_type']),
      imamWaterMeterNumber: JsonUtils.toText(json['imam_water_meter_number']),
      muezzinResidenceType: JsonUtils.toText(json['muezzin_residence_type']),

      residenceForMouadhin: JsonUtils.toText(json['residence_for_mouadhin']),
      isMuezzinElectricMeter: JsonUtils.toText(json['is_muezzin_electric_meter']),
      isMuezzinWaterMeter: JsonUtils.toText(json['is_muezzin_water_meter']),
      isMuezzinHousePrivate: JsonUtils.toText(json['is_muezzin_house_private']),
      muezzinHouseType: JsonUtils.toText(json['muezzin_house_type']),

      isMuezzinElectricMeterNew: JsonUtils.toText(json['is_muezzin_electric_meter_new']),
      muezzinElectricityMeterIds: JsonUtils.toList(json['muezzin_electricity_meter_ids']),
      muezzinWaterMeterIds: JsonUtils.toList(json['muezzin_water_meter_ids']),

      muezzinResidenceLandArea: JsonUtils.toDouble(json['muezzin_residence_land_area']),
      muezzinElectricityMeterType: JsonUtils.toText(json['muezzin_electricity_meter_type']),
      muezzinElectricityMeterNumber: JsonUtils.toText(json['muezzin_electricity_meter_number']),
      muezzinWaterMeterType: JsonUtils.toText(json['muezzin_water_meter_type']),
      muezzinWaterMeterNumber: JsonUtils.toText(json['muezzin_water_meter_number']),
      endowmentOnLand: JsonUtils.toText(json['endowment_on_land']),
      hasBasement: JsonUtils.toText(json['has_basement']),
      buildingMaterial: JsonUtils.toText(json['building_material']),
      occupancyRate: JsonUtils.toDouble(json['occupancy_rate']),
      buildingsOnLand: JsonUtils.toText(json['buildings_on_land']),
      recallNotes: JsonUtils.toText(json['recall_notes']),
      ministryAuthorized: JsonUtils.toText(json['ministry_authorized']),

      isThereStructureBuildings: JsonUtils.toText(json['is_there_structure_buildings']),
      buildingTypeIds: JsonUtils.toList(json['building_type_ids']),
      endowmentType: JsonUtils.toText(json['endowment_type']),
      permittedFromMinistry: JsonUtils.toText(json['permitted_from_ministry']),
      isOtherAttachment: JsonUtils.toText(json['is_other_attachment']),
      otherAttachment: JsonUtils.toText(json['other_attachment']),
      notesForOther: JsonUtils.toText(json['notes_for_other']),
      externalHeadsetNumber: JsonUtils.toInt(json['external_headset_number']),


      numMensBathrooms: JsonUtils.toDouble(json['num_mens_bathrooms']),
      numWomensBathrooms: JsonUtils.toDouble(json['num_womens_bathrooms']),
      numInternalSpeakers: JsonUtils.toDouble(json['num_internal_speakers']),
      numExternalSpeakers: JsonUtils.toDouble(json['num_external_speakers']),
      numLightingInside: JsonUtils.toInt(json['num_lighting_inside']),
      numMinarets: JsonUtils.toInt(json['num_minarets']),
      numFloors: JsonUtils.toInt(json['num_floors']),
      mosqueSize: JsonUtils.toDouble(json['mosque_size']),
      ////Accompanying  property
      carsParking: JsonUtils.toBoolean(json['cars_parking']),

      buildingArea: JsonUtils.toDouble(json['building_area']),
      buildingStatus: JsonUtils.toText(json['building_status']),
      nonBuildingArea: JsonUtils.toDouble(json['non_building_area']),
      freeArea: JsonUtils.toDouble(json['free_area']),
      isFreeArea: JsonUtils.toText(json['is_free_area']),
      mosqueRooms: JsonUtils.toInt(json['mosque_rooms']),

      haveWashingRoom: JsonUtils.toBoolean(json['have_washing_room']),
      lecturesHall: JsonUtils.toBoolean(json['lectures_hall']),
      libraryExist: JsonUtils.toBoolean(json['library_exist']),
      stoodOnGroundMosque: JsonUtils.toBoolean(json['stood_on_ground_mosque']),
      vacanciesSpaces: JsonUtils.toBoolean(json['vacancies_spaces']),
      otherCompanions: JsonUtils.toBoolean(json['other_companions']),
      description: JsonUtils.toText(json['description']),
      rowMenPrayingNumber: JsonUtils.toInt(json['row_men_praying_number']),
      lengthRowMenPraying: JsonUtils.toDouble(json['length_row_men_praying']),
      internalDoorsNumber: JsonUtils.toInt(json['internal_doors_number']),
      toiletMenNumber: JsonUtils.toInt(json['toilet_men_number']),
      internalSpeakerNumber: JsonUtils.toInt(json['internal_speaker_number']),
      externalSpeakerNumber: JsonUtils.toInt(json['external_speaker_number']),
      ////General Info
      location: JsonUtils.toText(json['location']),
      phoneNumber: JsonUtils.toText(json['phone_number']),
      twitter: JsonUtils.toText(json['twitter']),
      youtube: JsonUtils.toText(json['youtube']),
      website: JsonUtils.toText(json['website']),
      note: JsonUtils.toText(json['note']),
      street2: JsonUtils.toText(json['street2']),
      city1: JsonUtils.toText(json['city']),
      zip: JsonUtils.toText(json['zip']),
      latitude: JsonUtils.toDouble(json['latitude']),
      longitude: JsonUtils.toDouble(json['longitude']),


      displayButtonSend: JsonUtils.toBoolean(json['display_button_send']),
      displayButtonAccept: JsonUtils.toBoolean(json['display_button_accept']),
      displayButtonRefuse: JsonUtils.toBoolean(json['display_button_refuse']),
      isObserverEditable: JsonUtils.toBoolean(json['is_observer_editable']),

      //List  property
      // humanStaffIds: JsonUtils.toList(json['human_staff_ids']),
      // supervisionPartnerIds: JsonUtils.toList(json['supervision_partner_ids']),
      // partnerIds: JsonUtils.toList(json['partner_ids']),
       regionIds: JsonUtils.toList(json['region_ids']),
      // spaceIds: JsonUtils.toList(json['space_ids']),
      // componentIds: JsonUtils.toList(json['component_ids']),
      // mosqueContractorIds: JsonUtils.toList(json['mosque_contractor_ids']),
      // maintenanceStaffIds: JsonUtils.toList(json['maintenance_staff_ids']),
      // hygieneStaffIds: JsonUtils.toList(json['hygiene_staff_ids']),
      // programIds: JsonUtils.toList(json['program_ids']),
      // serviceIds: JsonUtils.toList(json['service_ids']),
      // systemIds: JsonUtils.toList(json['system_ids']),
      // mosqueDeviceIds: JsonUtils.toList(json['mosque_device_ids']),
      //  attachmentIds: JsonUtils.toList(json['attachment_ids']),


    );
  }

  String get truncatedLocation {
    if (location == null || location!.length <= 20) {
      return location ?? '';
    } else {
      return '${location!.substring(0, 20)}...';
    }
  }

  String? getNullableId(dynamic json,String value){
    return (json[value]??false)==false?null:json[value][0];
  }
  String? getNullableString(dynamic json,String value){
    return (json[value]??false)==false?null:json[value][1];
  }
}

class MosqueData extends PagedData<Mosque>{

}

