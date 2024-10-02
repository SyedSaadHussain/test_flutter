import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:mosque_management_system/utils/extension.dart';
import 'package:mosque_management_system/utils/json_utils.dart';
import 'package:mosque_management_system/utils/paged_data.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'package:intl/intl.dart';

class Visit {
  int? id;
  String? name;
  String? state;
  int? stageId;
  String? stage;
  String? prayerName;
  DateTime? dateOfVisit;
  int? mosqueSequenceNoId;
  String? mosqueSequenceNo;
  int? imamEmpId;
  String? imamEmp;
  int? muazzinEmpId;
  String? muazzinEmp;
  List<int>? servantId;

  int? createdById;
  String? createdBy;
  String? imamPresent;
  String? imamOffWork;
  DateTime? imamOffWorkDate;
  String? imamOffPrayersIds;
  String? imamOffPrayersId;
  String? imamNotes;
  String? moazenPresent;
  String? moazenExist;
  String? moazenOffWork;
  String? moazenOffPrayersIds;
  String? moazenOffPrayersId;
  String? moazenNotes;
  String? workerPresent;
  String? workerExist;
  String? workerRate;
  String? workerNotes;

  int? priority;
  String? mosqueClean;
  String? mosqueCleanNotes;
  String? carpetQuality;
  String? carpetQualityNotes;
  String? wcClean;
  String? wcCleanNotes;
  String? airCondition;
  String? airConditionNotes;
  String? soundSystem;
  String? soundSystemNotes;
  String? closeOutsideHorn;
  String? insideHorn;
  String? outsideHorn;
  String? wcMaintenance;
  String? wcMaintenanceNotes;
  String? ablutionWash;
  String? ablutionWashNotes;

  String? observer;
  int? observerId;
  String? visitType;

  String? electricMeterViolation;
  String? electricMeterViolationNote;
  String? electricMeterViolationAttachment;
  String? waterMeterViolation;
  String? waterMeterViolationNote;
  String? waterMeterViolationAttachment;
  String? mosqueViolation;
  String? mosqueViolationNote;
  String? mosqueViolationAttachment;
  String? cleaningMaterial;
  String? holyQuranViolation;
  String? holyQuranViolationNote;
  String? holyQuranViolationAttachment;
  String? description;
  String? uniqueId;

  bool? displayButtonSend;
  bool? displayButtonAccept;
  bool? displayButtonRefuse;
  bool? displayButtonSetToDraft;
  bool? btnStart;

  bool get isActionButton => (this.displayButtonSetToDraft??false) || (this.displayButtonAccept??false) || (this.displayButtonRefuse??false);

  Visit.shallowCopy(Visit other)
      : id = other.id,
        name = other.name,
        state=other.state,
        stage=other.stage,
        stageId=other.stageId,
         prayerName=other.prayerName,
        dateOfVisit=other.dateOfVisit,
        mosqueSequenceNoId = other.mosqueSequenceNoId,
        mosqueSequenceNo = other.mosqueSequenceNo,
        imamEmpId = other.imamEmpId,
        imamEmp = other.imamEmp,
        muazzinEmpId = other.muazzinEmpId,
        muazzinEmp = other.muazzinEmp,
        servantId = other.servantId,
        createdById = other.createdById,
        createdBy = other.createdBy,
        imamPresent = other.imamPresent,
        imamOffWork = other.imamOffWork,
        imamOffWorkDate = other.imamOffWorkDate,
        imamOffPrayersIds = other.imamOffPrayersIds,
        imamOffPrayersId = other.imamOffPrayersId,
        imamNotes = other.imamNotes,
        moazenPresent = other.moazenPresent,
        moazenExist = other.moazenExist,
        moazenOffWork = other.moazenOffWork,
        moazenOffPrayersIds = other.moazenOffPrayersIds,
        moazenOffPrayersId = other.moazenOffPrayersId,
        moazenNotes = other.moazenNotes,
        workerPresent = other.workerPresent,
        workerExist = other.workerExist,
        workerRate = other.workerRate,
        workerNotes = other.workerNotes,
        priority = other.priority,
        mosqueClean = other.mosqueClean,
        mosqueCleanNotes = other.mosqueCleanNotes,
        carpetQuality = other.carpetQuality,
        carpetQualityNotes = other.carpetQualityNotes,
        wcClean = other.wcClean,
        wcCleanNotes = other.wcCleanNotes,
        airCondition = other.airCondition,
        airConditionNotes = other.airConditionNotes,
        soundSystem = other.soundSystem,
        soundSystemNotes = other.soundSystemNotes,
        closeOutsideHorn = other.closeOutsideHorn,
        insideHorn = other.insideHorn,
        outsideHorn = other.outsideHorn,
        wcMaintenance = other.wcMaintenance,
        wcMaintenanceNotes = other.wcMaintenanceNotes,
        ablutionWash = other.ablutionWash,
        ablutionWashNotes = other.ablutionWashNotes,
        observer = other.observer,
        observerId = other.observerId,
        visitType = other.visitType,
        electricMeterViolation = other.electricMeterViolation,
        electricMeterViolationNote = other.electricMeterViolationNote,
        electricMeterViolationAttachment = other.electricMeterViolationAttachment,
        waterMeterViolation = other.waterMeterViolation,
        waterMeterViolationNote = other.waterMeterViolationNote,
        waterMeterViolationAttachment = other.waterMeterViolationAttachment,
        mosqueViolation = other.mosqueViolation,
        mosqueViolationNote = other.mosqueViolationNote,
        mosqueViolationAttachment = other.mosqueViolationAttachment,
        cleaningMaterial = other.cleaningMaterial,
        holyQuranViolation = other.holyQuranViolation,
        holyQuranViolationNote = other.holyQuranViolationNote,
        holyQuranViolationAttachment = other.holyQuranViolationAttachment,
        description = other.description;

  // Default constructor
  Visit({
    this.id,
    this.name,
    this.state,
    this.stageId,
    this.stage,
    this.prayerName,
    this.dateOfVisit,
    this.mosqueSequenceNo,
    this.mosqueSequenceNoId,
    this.imamEmpId,
    this.imamEmp,
    this.muazzinEmpId,
    this.muazzinEmp,
    this.servantId,
    this.createdById,
    this.createdBy,
    this.imamPresent,
    this.imamOffWork,
    this.imamOffWorkDate,
    this.imamOffPrayersIds,
    this.imamOffPrayersId,
    this.imamNotes,
    this.moazenPresent,
    this.moazenExist,
    this.moazenOffWork,
    this.moazenOffPrayersIds,
    this.moazenOffPrayersId,
    this.moazenNotes,
    this.workerPresent,
    this.workerExist,
    this.workerRate,
    this.workerNotes,
    this.priority,
    this.mosqueClean,
    this.mosqueCleanNotes,
    this.carpetQuality,
    this.carpetQualityNotes,
    this.wcClean,
    this.wcCleanNotes,
    this.airCondition,
    this.airConditionNotes,
    this.soundSystem,
    this.soundSystemNotes,
    this.closeOutsideHorn,
    this.insideHorn,
    this.outsideHorn,
    this.wcMaintenance,
    this.wcMaintenanceNotes,
    this.ablutionWash,
    this.ablutionWashNotes,
    this.observer,
    this.observerId,
    this.visitType,
    this.electricMeterViolation,
    this.electricMeterViolationAttachment,
    this.electricMeterViolationNote,
    this.waterMeterViolation,
    this.waterMeterViolationAttachment,
    this.waterMeterViolationNote,
    this.mosqueViolation,
    this.mosqueViolationAttachment,
    this.mosqueViolationNote,
    this.cleaningMaterial,
    this.holyQuranViolation,
    this.holyQuranViolationAttachment,
    this.holyQuranViolationNote,
    this.description,
    this.uniqueId,
    this.btnStart,
    this.displayButtonAccept=false,
    this.displayButtonSetToDraft=false,
    this.displayButtonRefuse=false,
    this.displayButtonSend=false
  });
  String get dateOfVisitGreg {
    DateFormat dateFormat = DateFormat('yyyy-MM-dd');
    return this.dateOfVisit==null?"":dateFormat.format(this.dateOfVisit!);
  }
  factory Visit.fromJson(Map<String, dynamic> json) {
    
    return Visit(
      id: JsonUtils.toInt(json['id']),
      name: JsonUtils.toText(json['name']),
      state: JsonUtils.toText(json['state']),
      stage: JsonUtils.getName(json['stage_id']),
      stageId: JsonUtils.getId(json['stage_id']),
      prayerName: JsonUtils.toText(json['prayer_name']),
      dateOfVisit: JsonUtils.toDateTime(json['date_of_visit']),
      mosqueSequenceNoId: JsonUtils.getId(json['mosque_seq_no']),
      mosqueSequenceNo: JsonUtils.getName(json['mosque_seq_no']),
      imamEmpId: JsonUtils.getId(json['imam_emp_id']),
      imamEmp: JsonUtils.getName(json['imam_emp_id']),
      muazzinEmpId: JsonUtils.getId(json['muazzin_emp_id']),
      muazzinEmp: JsonUtils.getName(json['muazzin_emp_id']),
      servantId: JsonUtils.toList(json['servant_id']),
      createdById: JsonUtils.getId(json['created_by']),
      createdBy: JsonUtils.getName(json['created_by']),
      imamPresent: JsonUtils.toText(json['imam_present']),
      imamOffWork: JsonUtils.toText(json['imam_off_work']),
//imamOffWorkDate: JsonUtils.toDateTime(json['imam_off_work_date']),
      imamOffPrayersIds: JsonUtils.toText(json['imam_off_prayers_ids']),
      imamOffPrayersId: JsonUtils.toText(json['imam_off_prayers_id']),
      imamNotes: JsonUtils.toText(json['imam_notes']),
      moazenPresent: JsonUtils.toText(json['moazen_present']),
      moazenExist: JsonUtils.toText(json['moazen_exist']),
      moazenOffWork: JsonUtils.toText(json['moazen_off_work']),
      moazenOffPrayersIds: JsonUtils.toText(json['moazen_off_prayers_ids']),
      moazenOffPrayersId: JsonUtils.toText(json['moazen_off_prayers_id']),
      moazenNotes: JsonUtils.toText(json['moazen_notes']),
      workerPresent: JsonUtils.toText(json['worker_present']),
      workerExist: JsonUtils.toText(json['worker_exist']),
      workerRate: JsonUtils.toText(json['worker_rate']),
      workerNotes: JsonUtils.toText(json['worker_notes']),
      priority: JsonUtils.toInt(json['priority']),
      mosqueClean: JsonUtils.toText(json['mosque_clean']),
      mosqueCleanNotes: JsonUtils.toText(json['mosque_clean_notes']),
      carpetQuality: JsonUtils.toText(json['carpet_quality']),
      carpetQualityNotes: JsonUtils.toText(json['carpet_quality_notes']),
      wcClean: JsonUtils.toText(json['wc_clean']),
      wcCleanNotes: JsonUtils.toText(json['wc_clean_notes']),
      airCondition: JsonUtils.toText(json['air_condition']),
      airConditionNotes: JsonUtils.toText(json['air_condition_notes']),
      soundSystem: JsonUtils.toText(json['sound_system']),
      soundSystemNotes: JsonUtils.toText(json['sound_system_notes']),
      closeOutsideHorn: JsonUtils.toText(json['close_outside_horn']),
      insideHorn: JsonUtils.toText(json['inside_horn']),
      outsideHorn: JsonUtils.toText(json['outside_horn']),
      wcMaintenance: JsonUtils.toText(json['wc_maintenance']),
      wcMaintenanceNotes: JsonUtils.toText(json['wc_maintenance_notes']),
      ablutionWash: JsonUtils.toText(json['ablution_wash']),
      ablutionWashNotes: JsonUtils.toText(json['ablution_wash_notes']),
      observer: JsonUtils.getName(json['observer']),
      observerId: JsonUtils.getId(json['observer']),
      visitType: JsonUtils.toText(json['visit_type']),
      electricMeterViolation: JsonUtils.toText(json['electric_meter_violation']),
      electricMeterViolationAttachment: JsonUtils.toText(json['electric_meter_violation_attachment']),
      electricMeterViolationNote: JsonUtils.toText(json['electric_meter_violation_note']),
      waterMeterViolation: JsonUtils.toText(json['water_meter_violation']),
      waterMeterViolationAttachment: JsonUtils.toText(json['water_meter_violation_attachment']),
      waterMeterViolationNote: JsonUtils.toText(json['water_meter_violation_note']),
      mosqueViolation: JsonUtils.toText(json['mosque_violation']),
      mosqueViolationAttachment: JsonUtils.toText(json['mosque_violation_attachment']),
      mosqueViolationNote: JsonUtils.toText(json['mosque_violation_note']),
      cleaningMaterial: JsonUtils.toText(json['cleaning_material']),
      holyQuranViolation: JsonUtils.toText(json['holy_quran_violation']),
      holyQuranViolationAttachment: JsonUtils.toText(json['holy_quran_violation_attachment']),
      holyQuranViolationNote: JsonUtils.toText(json['holy_quran_violation_note']),
      description: JsonUtils.toText(json['description']),
      uniqueId:(json['__last_update']??false)==false?"":json['__last_update'].replaceAll(RegExp(r'[^0-9]'), ''),
      displayButtonSend: JsonUtils.toBoolean(json['display_button_send']),
      displayButtonRefuse: JsonUtils.toBoolean(json['display_button_refuse']),
      displayButtonAccept: JsonUtils.toBoolean(json['display_button_accept']),
      displayButtonSetToDraft: JsonUtils.toBoolean(json['display_button_set_to_draft']),
      btnStart: JsonUtils.toBoolean(json['btn_start']),
    );
  }
}
//
class VisitData extends PagedData<Visit>{

}

