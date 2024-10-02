import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:mosque_management_system/constants/app_colors.dart';
import 'package:mosque_management_system/constants/input_decoration_themes.dart';
import 'package:mosque_management_system/data/models/center.dart';
import 'package:mosque_management_system/data/models/combo_list.dart';
import 'package:mosque_management_system/data/models/distract.dart';
import 'package:mosque_management_system/data/models/employee.dart';
import 'package:mosque_management_system/data/models/ir_attachment.dart';
import 'package:mosque_management_system/data/models/meter.dart';
import 'package:mosque_management_system/data/models/mosque.dart';
import 'package:mosque_management_system/data/models/mosque_region.dart';
import 'package:mosque_management_system/data/models/region.dart';
import 'package:mosque_management_system/data/models/res_city.dart';
import 'package:mosque_management_system/data/models/res_partner.dart';
import 'package:mosque_management_system/data/models/userProfile.dart';
import 'package:mosque_management_system/data/repositories/custom_odoo_client.dart';
import 'package:mosque_management_system/data/services/mosque_service.dart';
import 'package:mosque_management_system/data/services/user_service.dart';
import 'package:mosque_management_system/dialogs/disclaimer_dialog.dart';
import 'package:mosque_management_system/list/center_list.dart';
import 'package:mosque_management_system/list/city_list.dart';
import 'package:mosque_management_system/list/combo_list.dart';
import 'package:mosque_management_system/list/district_list.dart';
import 'package:mosque_management_system/list/item_list.dart';
import 'package:mosque_management_system/list/meter_form.dart';
import 'package:mosque_management_system/list/mosque_user_list.dart';
import 'package:mosque_management_system/list/multi_item_list.dart';
import 'package:mosque_management_system/list/partner_list.dart';
import 'package:mosque_management_system/list/region_list.dart';
import 'package:mosque_management_system/presentation/screens/create_employee.dart';
import 'package:mosque_management_system/providers/user_provider.dart';
import 'package:mosque_management_system/styles/text_styles.dart';
import 'package:mosque_management_system/utils/config.dart';
import 'package:mosque_management_system/utils/gps_permission.dart';
import 'package:mosque_management_system/utils/json_utils.dart';
import 'package:mosque_management_system/widgets/FullImageViewer.dart';
import 'package:mosque_management_system/widgets/ProgressBar.dart';
import 'package:mosque_management_system/widgets/app_form_field.dart';
import 'package:mosque_management_system/widgets/app_list_title.dart';
import 'package:mosque_management_system/widgets/app_title.dart';
import 'package:mosque_management_system/widgets/attachment_card.dart';
import 'package:mosque_management_system/widgets/image_data.dart';
import 'package:mosque_management_system/widgets/service_button.dart';
import 'package:mosque_management_system/widgets/state_button.dart';
import 'package:mosque_management_system/widgets/tag_button.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mosque_management_system/data/models/base_state.dart';

class TabForm{
    bool isShowEdit;
    bool isEditMode;
    bool allowEditMode;
    String title='';
    TabForm({
    this.isShowEdit=false,
    this.isEditMode=false,
      this.allowEditMode=true,
    required this.title,
    });
}
class MosqueDetail extends StatefulWidget {
  final CustomOdooClient client;
  final int mosqueId;
  final Function? onCallback;
  MosqueDetail({required this.client,required this.mosqueId,this.onCallback});
  @override
  _MosqueDetailState createState() => _MosqueDetailState();
}

class _MosqueDetailState extends BaseState<MosqueDetail> with SingleTickerProviderStateMixin  {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late OdooClient client;
  late MosqueService _mosqueService;
  UserService? _userService;
  Mosque _mosque =Mosque(id: 0);
  Mosque _mosqueBasicInfo =Mosque(id: 0);
  Mosque _mosqueDetail =Mosque(id: 0);
  Mosque _mosqueMosqueInfo =Mosque(id: 0);
  Mosque _mosqueAccompanying =Mosque(id: 0);
  Mosque _mosqueGeneralInfo =Mosque(id: 0);
  Mosque _mosqueMaintenanceDetail =Mosque(id: 0);
  Mosque _mosqueImamDetail =Mosque(id: 0);
  Mosque _mosqueBuildingDetail =Mosque(id: 0);
  Mosque _mosquePrayerSection =Mosque(id: 0);
  Mosque _mosqueGeoLocation =Mosque(id: 0);

  List<Employee> _allEmployees=[];
  List<Employee> _imams=[];
  List<Employee> _muezzin=[];
  List<Employee> _khadem=[];
  List<Employee> _khatib=[];
  List<Employee> _observers=[];
  List<Employee> _observersTemp=[];



  List<ResPartner> _allpartners=[];
  List<ResPartner> _partners=[];
  List<ResPartner> _humanStaffs=[];
  List<ResPartner> _supervisionPartners=[];
  List<MosqueRegion> _regions=[];

  List<Meter> _mosqueElectricityMeters=[];
  List<Meter> _mosqueWaterMeters=[];
  List<Meter> _imamElectricityMeters=[];
  List<Meter> _imamWaterMeters=[];
  List<Meter> _muezzinElectricityMeters=[];
  List<Meter> _muezzinWaterMeters=[];

  List<Attachment> _instrumentAttachments=[];
  List<Attachment> _tempInstrumentAttachments=[];

  List<Meter> _allMeters=[];
  List<TabForm> _tabs=[];
  bool isLoading=true;
  List<ComboItem> instrumentEntities=[];
  List<ComboItem> buildingTypeIds=[];
  late TabController _tabController = TabController(length: 8, vsync: this);
  @override
  void initState(){
    super.initState();
    _mosqueService = MosqueService(this.widget.client!);
    _userService = UserService(this.widget.client!);
    _tabController.addListener(_handleTabChange); // Add listener for tab changes
    //_tabController = TabController(length: 2, vsync: this);

    renderTabs();
    Future.delayed(Duration.zero, () {

      _mosqueService.loadMosqueView().then((list){
      
        fields.list=list;
        setState(() {

        });
        getMosqueDetail();
        loadInstruments();
        loadBuilding();
      
      }).catchError((e){
        setState((){
          isLoading=false;
        });
        Flushbar(
          icon: Icon(Icons.warning,color: Colors.white,),
          backgroundColor: AppColors.danger,
          message: e.message,
          duration: Duration(seconds: 3),
        ).show(context);
      });
    });
  }
  void loadBuilding(){
    _mosqueService.getBuildingTypes().then((value){
      buildingTypeIds=value;
    
      // categoryData.list.forEach((item){
      //   buildingTypeIds.add(ComboItem(key: item.id,value: item.name));
      //
      // });
      setState(() {

      });

    });
  }
  void loadInstruments(){
    _mosqueService.getInstrumentEntities().then((value){
      instrumentEntities=value;
      setState(() {

      });
      
    });
  }
  FieldListData fields=FieldListData();
  void renderTabs(){
    _tabs.add(TabForm(title: 'basic_info'.tr(),isShowEdit:true));
    _tabs.add(TabForm(title: 'mosque_detail'.tr(),isShowEdit:true));
    _tabs.add(TabForm(title: 'mosque_info'.tr(),isShowEdit:true));
    _tabs.add(TabForm(title: 'maintenance_instrument_details'.tr(),isShowEdit:true));
    _tabs.add(TabForm(title: 'mosque_building_details'.tr(),isShowEdit:true));
    _tabs.add(TabForm(title: 'imams_Muezzins_Details'.tr(),isShowEdit:true));
    _tabs.add(TabForm(title: 'prayer_section'.tr(),isShowEdit:true));
    _tabs.add(TabForm(title: 'geo_location'.tr(),isShowEdit:true));
  }
  void _handleTabChange() {
    setState(() {}); // Trigger setState when tab changes
  }
  bool isVerifyDevice(){
    //return true;//urgent
    if(userProvider.isDeviceVerify) return true;
    else{
      Flushbar(
        icon: Icon(Icons.warning,color: Colors.white,),
        backgroundColor: AppColors.danger,
        message: "device_not_unverified".tr(),
        duration: Duration(seconds: 3),
      ).show(context);
      return false;
    }


  }
  late UserProvider userProvider;
  //#region  Get Methods
  void getAllEmployees(){
    Set<int> uniqueEmployeeIds = {};
    List<int> employeeIds=[];
    uniqueEmployeeIds.addAll(_mosque.imamIds??[]);
    uniqueEmployeeIds.addAll(_mosque.muezzinIds??[]);
    uniqueEmployeeIds.addAll(_mosque.khademIds??[]);
    uniqueEmployeeIds.addAll(_mosque.khatibIds??[]);
    uniqueEmployeeIds.addAll(_mosque.observerIds??[]);
    employeeIds.addAll(uniqueEmployeeIds);
 
    setState((){});
    if(employeeIds.length>0){
      

      _userService!.getEmployeesByIds(employeeIds).then((employees){
        _allEmployees=employees;
        _imams=_allEmployees.where((emp) {
          return  _mosque.imamIds!.contains(emp.id);
        }).toList();
        _muezzin=_allEmployees.where((emp) {
          return  _mosque.muezzinIds!.contains(emp.id);
        }).toList();
        _khadem=_allEmployees.where((emp) {
          return  _mosque.khademIds!.contains(emp.id);
        }).toList();
        _khatib=_allEmployees.where((emp) {
          return  _mosque.khatibIds!.contains(emp.id);
        }).toList();
        _observers=_allEmployees.where((emp) {
          return  _mosque.observerIds!.contains(emp.id);
        }).toList();
      
        setState(() {

        });
      });
    }
  }
  void getAllPartners(){
    Set<int> uniqueUserIds = {};
    List<int> userIds=[];
    uniqueUserIds.addAll(_mosque.humanStaffIds??[]);
    uniqueUserIds.addAll(_mosque.supervisionPartnerIds??[]);
    uniqueUserIds.addAll(_mosque.partnerIds??[]);
    userIds.addAll(uniqueUserIds);

    setState((){});
    if(userIds.length>0){
  
      _userService!.getPartnerByIds(userIds).then((employees){
        _allpartners=employees;
        _partners=_allpartners.where((partner) {
          return  _mosque.partnerIds!.contains(partner.id);
        }).toList();
        _supervisionPartners=_allpartners.where((partner) {
          return  _mosque.supervisionPartnerIds!.contains(partner.id);
        }).toList();
        _humanStaffs=_allpartners.where((partner) {
          return  _mosque.humanStaffIds!.contains(partner.id);
        }).toList();
   
      });
    }
  }
  void getRegions(){

    if(_mosque.regionIds!.length>0){
      _mosqueService!.getMetersByIds(_mosque.regionIds!).then((data){
        setState(() {
        });
      });
    }
  }
  void getAttachments(){
    _tempInstrumentAttachments=[];
    _instrumentAttachments=[];
    if(_mosque.instrumentAttachmentIds!.length>0){
      _userService!.getAllAttachment(_mosque.instrumentAttachmentIds!).then((data){
      
        _instrumentAttachments=data;
        _instrumentAttachments=data;
        _instrumentAttachments.forEach((item) {
          _tempInstrumentAttachments.add(Attachment.shallowCopy(item));
        });
        setState(() {
        });
      });
    }
  }
  void getImamElectricMeters(){
    
    Set<int> uniqueMetersIds = {};
    List<int> meterIds=[];
    uniqueMetersIds.addAll(_mosque.imamElectricityMeterIds??[]);
    uniqueMetersIds.addAll(_mosque.muezzinElectricityMeterIds??[]);
    uniqueMetersIds.addAll(_mosque.imamWaterMeterIds??[]);
    uniqueMetersIds.addAll(_mosque.muezzinWaterMeterIds??[]);
    uniqueMetersIds.addAll(_mosque.mosqueElectricityMeterIds??[]);
    uniqueMetersIds.addAll(_mosque.mosqueWaterMeterIds??[]);
    meterIds.addAll(uniqueMetersIds);

    setState((){});

    _imamElectricityMeters=[];
    _mosqueElectricityMeters=[];
    _muezzinElectricityMeters=[];
    _imamWaterMeters=[];
    _mosqueWaterMeters=[];
    _muezzinWaterMeters=[];


    if(meterIds.length>0){

      _mosqueService!.getMetersByIds(meterIds).then((data){
    

        _allMeters=data;
     

        var tempMeter =_allMeters.where((emp) {
          return  _mosque.imamElectricityMeterIds!.contains(emp.id);
        }).toList();
        tempMeter.forEach((meter) {
          _imamElectricityMeters.add(Meter.shallowCopy(meter));
        });


         tempMeter=_allMeters.where((emp) {
          return  _mosque.mosqueElectricityMeterIds!.contains(emp.id);
        }).toList();

        tempMeter.forEach((meter) {
          _mosqueElectricityMeters.add(Meter.shallowCopy(meter));
        });

        tempMeter=_allMeters.where((emp) {
          return  _mosque.muezzinElectricityMeterIds!.contains(emp.id);
        }).toList();
        tempMeter.forEach((meter) {
          _muezzinElectricityMeters.add(Meter.shallowCopy(meter));
        });



        tempMeter=_allMeters.where((emp) {
          return  _mosque.imamWaterMeterIds!.contains(emp.id);
        }).toList();
        tempMeter.forEach((meter) {
          _imamWaterMeters.add(Meter.shallowCopy(meter));
        });

        tempMeter=_allMeters.where((emp) {
          return  _mosque.muezzinWaterMeterIds!.contains(emp.id);
        }).toList();
        tempMeter.forEach((meter) {
          _muezzinWaterMeters.add(Meter.shallowCopy(meter));
        });



        tempMeter=_allMeters.where((emp) {
          return  _mosque.mosqueWaterMeterIds!.contains(emp.id);
        }).toList();
        tempMeter.forEach((meter) {
          _mosqueWaterMeters.add(Meter.shallowCopy(meter));
        });

      

        setState(() {

        });
      });
    }
  }
  void getMosqueDetail(){
    setState((){
        isLoading=true;
    });
    _mosqueService!.getMosqueDetail(this.widget.mosqueId).then((value){
     
      _mosque=value;
     
      if(_mosque.imamIds==null)
        _mosque.imamIds=[];
      getAllPartners();

      getAllEmployees();
      getRegions();
      getAttachments();
      getImamElectricMeters();
      setState((){
        isLoading=false;
      });

    }).catchError((e){
     
      //isLoading=false;
      setState((){});
      setState((){
        isLoading=false;
      });
      Flushbar(
        icon: Icon(Icons.warning,color: Colors.white,),
        backgroundColor: AppColors.danger,
        message: e.message,
        duration: Duration(seconds: 3),
      ).show(context);
    });
  }

//#endregion  Get Methods

  //#region  Modal
  showBuildingModal(){
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return MultiItemList(
          client: this.widget.client,
          selectedValue: _mosqueBuildingDetail.buildingTypeIds,
          title: 'Select Tag',
          items: buildingTypeIds,
          onItemTap: (ComboItem val){

            if(_mosqueBuildingDetail.buildingTypeIds==null)
              _mosqueBuildingDetail.buildingTypeIds=[];
            if (!_mosqueBuildingDetail.buildingTypeIds!.contains(val.key)) {
              _mosqueBuildingDetail.buildingTypeIds!.add(val.key);
            }
            setState(() {

            });

            Navigator.of(context).pop();
          },);
      },
    );
  }
  showRegionModal(){
    showModalBottomSheet(

      context: context,
      builder: (BuildContext context) {
        return RegionList(client: this.widget.client,
          countryId: _mosque.countryId??0,
          onItemTap: (Region val){
      
            _mosqueBasicInfo.region=val.name;
            _mosqueBasicInfo.regionId=val.id;

            _mosqueBasicInfo.city=null;
            _mosqueBasicInfo.cityId=null;

            _mosqueBasicInfo.moiaCenter=null;
            _mosqueBasicInfo.moiaCenterId=null;

            setState(() {

            });
            Navigator.of(context).pop();

          },);
      },
    );
  }
  showCenterModal(){
    showModalBottomSheet(

      context: context,
      builder: (BuildContext context) {
        return CenterList(client: this.widget.client,
          cityId: _mosqueBasicInfo.cityId??0,
          onItemTap: (MoiCenter val){
          
            _mosqueBasicInfo.moiaCenter=val.name;
            _mosqueBasicInfo.moiaCenterId=val.id;


            setState(() {

            });
            Navigator.of(context).pop();

          },);
      },
    );
  }
  showCityModal(){
    showModalBottomSheet(

      context: context,
      builder: (BuildContext context) {
        return CityList(client: this.widget.client,
          regionId: _mosqueBasicInfo.regionId,

          onItemTap: (City val){
           
            _mosqueBasicInfo.city=val.name;
            _mosqueBasicInfo.cityId=val.id;

            _mosqueBasicInfo.moiaCenter=null;
            _mosqueBasicInfo.moiaCenterId=null;
        
            setState(() {

            });
            Navigator.of(context).pop();

          },);
      },
    );
  }
  showDistrictModal(){
    showModalBottomSheet(

      context: context,
      builder: (BuildContext context) {
        return DistrictList(client: this.widget.client,
          onItemTap: (Distract val){
      
            _mosqueBasicInfo.district=val.name;
            _mosqueBasicInfo.districtId=val.id;
          
            setState(() {

            });
            Navigator.of(context).pop();

          },);
      },
    );
  }
  showClassificationModal(){
    showModalBottomSheet(

      context: context,
      builder: (BuildContext context) {
        return ComboBoxList(client: this.widget.client,
          onItemTap: (ComboItem val){
     
            _mosqueBasicInfo.classification=val.value;
            _mosqueBasicInfo.classificationId=val.key;
          
            setState(() {

            });
            Navigator.of(context).pop();

          },);
      },
    );
  }

  showInstrumentModal(){
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ItemList(
          client: this.widget.client,
          title: fields.getField('instrument_entity_id').label,
          items: instrumentEntities,
          onItemTap: (ComboItem val){
            _mosqueMaintenanceDetail.instrumentEntityId=val.key;
            _mosqueMaintenanceDetail.instrumentEntity=val.value;

            setState(() {

            });
            Navigator.of(context).pop();
          },);
      },
    );
  }

  //#endregion  Modal

  //#region  Edit form
  updateObservers(){

    setState((){
      isLoading=true;
    });
    _mosqueBasicInfo.observerIds = _observersTemp.map((item) => item.id!.toInt()).toList();

    _mosqueService!.updateObserver(_mosque,_mosqueBasicInfo).then((value){

      setState((){
        isLoading=false;
        isObserverEditMode=false;
      });
      getMosqueDetail();

    }).catchError((e){


      setState((){
        isLoading=false;
      });
      Flushbar(
        icon: Icon(Icons.warning,color: Colors.white,),
        backgroundColor: AppColors.danger,
        message: e.message,
        duration: Duration(seconds: 3),
      ).show(context);

    });

  }
  updateBasicInfo(index){

    _mosqueBasicInfo.observerIds = _observers.map((item) => item.id!.toInt()).toList();
    _mosqueBasicInfo.imamIds = _imams.map((item) => item.id!.toInt()).toList();
    _mosqueBasicInfo.muezzinIds = _muezzin.map((item) => item.id!.toInt()).toList();
    _mosqueBasicInfo.khademIds = _khadem.map((item) => item.id!.toInt()).toList();
    _mosqueBasicInfo.khatibIds = _khatib.map((item) => item.id!.toInt()).toList();
    
    if (_formBasicInfoKey.currentState!.validate()) {
      _formBasicInfoKey.currentState!.save();
      setState((){
        isLoading=true;
      });

      _mosqueService!.updateMosqueBasicInfo(_mosque,_mosqueBasicInfo).then((value){
     
        setState((){
          _tabs[index].isEditMode=false;
          isLoading=false;
        });
        getMosqueDetail();

      }).catchError((e){
      
        
        setState((){
          isLoading=false;
        });
        Flushbar(
          icon: Icon(Icons.warning,color: Colors.white,),
          backgroundColor: AppColors.danger,
          message: e.message,
          duration: Duration(seconds: 3),
        ).show(context);

      });
    };

  }
  updateMosqueDetail(index){
   
   
    if (_formDetailKey.currentState!.validate()) {
      _formDetailKey.currentState!.save();
      setState((){
        isLoading=true;
      });
      _mosqueService!.updateMosqueDetail(_mosque,_mosqueDetail
          ,_mosqueElectricityMeters,_mosqueWaterMeters).then((value){
     
        setState((){
          _tabs[index].isEditMode=false;
          isLoading=false;
        });
        getMosqueDetail();

      }).catchError((e){
      
        //isLoading=false;
        setState((){
          isLoading=false;
        });
        Flushbar(
          icon: Icon(Icons.warning,color: Colors.white,),
          backgroundColor: AppColors.danger,
          message: e.message,
          duration: Duration(seconds: 3),
        ).show(context);
      });
    };

  }
  updateMosqueInfo(index){
    
    if (_formMosqueInfoKey.currentState!.validate()) {
      _formMosqueInfoKey.currentState!.save();
      setState((){
        isLoading=true;
      });
      _mosqueService!.updateMosqueInfo(_mosque,_mosqueMosqueInfo).then((value){
       
        setState((){
          _tabs[index].isEditMode=false;
          isLoading=false;
        });
        getMosqueDetail();

      }).catchError((e){
        Flushbar(
          icon: Icon(Icons.warning,color: Colors.white,),
          backgroundColor: AppColors.danger,
          message: e.message,
          duration: Duration(seconds: 3),
        ).show(context);
      
        //isLoading=false;
        setState((){
          isLoading=false;
        });
      });
    };

  }
  updateMosquePrayerSection(index){
    
    if (_formPrayerKey.currentState!.validate()) {
      _formPrayerKey.currentState!.save();
      setState((){
        isLoading=true;
      });
      _mosqueService!.updateMosquePrayerSection(_mosque,_mosquePrayerSection).then((value){
    
        setState((){
          _tabs[index].isEditMode=false;
          isLoading=false;
        });
        getMosqueDetail();

      }).catchError((e){
        
        //isLoading=false;
        setState((){
          isLoading=false;
        });
        Flushbar(
          icon: Icon(Icons.warning,color: Colors.white,),
          backgroundColor: AppColors.danger,
          message: e.message,
          duration: Duration(seconds: 3),
        ).show(context);
      });
    };

  }
  updateBuildingDetail(index){
    
    if (_formBuildingKey.currentState!.validate()) {
      _formBuildingKey.currentState!.save();
      setState((){
        isLoading=true;
      });
      _mosqueService!.updateBuildingDetail(_mosque,_mosqueBuildingDetail).then((value){
       
        setState((){
          _tabs[index].isEditMode=false;
          isLoading=false;
        });
        getMosqueDetail();

      }).catchError((e){
      
        //isLoading=false;
        setState((){
          isLoading=false;
        });
        Flushbar(
          icon: Icon(Icons.warning,color: Colors.white,),
          backgroundColor: AppColors.danger,
          message: e.message,
          duration: Duration(seconds: 3),
        ).show(context);
      });
    };

  }
  updateMaintenanceDetail(index){
 
    if (_formMaintenanceKey.currentState!.validate()) {
      _formMaintenanceKey.currentState!.save();

      _mosqueMaintenanceDetail.instrumentAttachmentIds = _tempInstrumentAttachments.map((item) => (item.id!)).toList();
      setState((){
        isLoading=true;
      });
      _mosqueService!.updateMaintenanceDetail(_mosque,_mosqueMaintenanceDetail).then((value){
     
        setState((){
          _tabs[index].isEditMode=false;
          isLoading=false;
        });
        getMosqueDetail();

      }).catchError((e){
       
        //isLoading=false;
        setState((){
          isLoading=false;
        });
        Flushbar(
          icon: Icon(Icons.warning,color: Colors.white,),
          backgroundColor: AppColors.danger,
          message: e.message,
          duration: Duration(seconds: 3),
        ).show(context);
      });
    };

  }
  AddEditRegionModal({MosqueRegion? region=null}){
    MosqueRegion _region=region??MosqueRegion(id:0,number: 0);
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8), // Adjust top radius here
                topRight: Radius.circular(8),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _region.id!>0? ModalTitle('Update Region',Icons.edit):ModalTitle('Add New Region',Icons.add),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Form(
                    key: _formRegionKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [


                        CustomFormField(title: 'Number',value: _region.number,isRequired: true,onChanged:(val) => _region.number = val,type: FieldType.number,),
                        CustomFormField(title: 'Name',value: _region.name,isRequired: true,onChanged:(val) => _region.name = val,),
                        CustomFormField(title: 'Code',value: _region.code,isRequired: true,onChanged:(val) => _region.code = val,),
                        SizedBox(height: 10,),
                        Row(
                          children: [
                            Expanded(
                              child: _region.id! > 0?PrimaryButton(text: "update".tr(),onTab:(){


                                if (_formRegionKey.currentState!.validate()) {
                                  _formRegionKey.currentState!.save();
                                  // getRegions();
                                  // Navigator.pop(context);
                                  setState((){
                                    isLoading=true;
                                  });
                                  _mosqueService!.updateMosqueRegion(_region,_mosque.id).then((value){
                                  
                                    setState((){
                                      isLoading=false;
                                    });
                                    getRegions();
                                    Navigator.pop(context);

                                  }).catchError((e){
                                
                                    //isLoading=false;
                                    setState((){
                                      isLoading=false;
                                    });
                                  });
                                };
                              }):PrimaryButton(text: "create".tr(),onTab:(){


                                if (_formRegionKey.currentState!.validate()) {
                                  _formRegionKey.currentState!.save();
                                  // getRegions();
                                  // Navigator.pop(context);
                                  setState((){
                                    isLoading=true;
                                  });
                                  _mosqueService!.createMosqueRegion(_region,_mosque.id).then((value){
                               
                                    setState((){
                                      isLoading=false;
                                    });
                                    getMosqueDetail();
                                    Navigator.pop(context);

                                  }).catchError((e){
                                 
                                    //isLoading=false;
                                    setState((){
                                      isLoading=false;
                                    });
                                  });
                                };
                              }),
                            ),
                            Expanded(
                              child: SecondaryButton(text: "cancel".tr(),onTab:(){
                                Navigator.pop(context);
                              }),
                            ),
                          ],
                        ),
                        SizedBox(height: 5,),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  updateMosqueImamDetail(index){
    if (_formImamDetailKey.currentState!.validate()) {
      _formImamDetailKey.currentState!.save();
      setState((){
        isLoading=true;
      });
      _mosqueService!.updateMosqueImamDetail(_mosque,_mosqueImamDetail,_imamElectricityMeters,
          _imamWaterMeters,
          _muezzinElectricityMeters,_muezzinWaterMeters).then((value){
     
        setState((){
          _tabs[index].isEditMode=false;
          isLoading=false;
        });
        getMosqueDetail();

      }).catchError((e){
        

        //isLoading=false;
        setState((){
          isLoading=false;
        });
        Flushbar(
          icon: Icon(Icons.warning,color: Colors.white,),
          backgroundColor: AppColors.danger,
          message: e.message,
          duration: Duration(seconds: 3),
        ).show(context);
      });
    };
  }
  updateGeneralInfo(index){
    if (_formGeneralInfoKey.currentState!.validate()) {
      _formGeneralInfoKey.currentState!.save();
      setState((){
        isLoading=true;
      });
      _mosqueService!.updateMosqueGeneralInfo(_mosque,_mosqueGeneralInfo).then((value){
       
        setState((){
          _tabs[index].isEditMode=false;
          isLoading=false;
        });
        getMosqueDetail();

      }).catchError((e){
       
        //isLoading=false;
        setState((){
          isLoading=false;
        });
      });
    };
  }

  updateMosqueGeoLocation(index){
    if (_formGeoLocKey.currentState!.validate()) {
      _formGeoLocKey.currentState!.save();
      setState((){
        isLoading=true;
      });
      _mosqueService!.updateMosqueGeoLocation(_mosque,_mosqueGeoLocation).then((value){
        setState((){
          _tabs[index].isEditMode=false;
          isLoading=false;
        });
        getMosqueDetail();
      }).catchError((e){
        setState((){
          isLoading=false;
        });
        Flushbar(
          icon: Icon(Icons.warning,color: Colors.white,),
          backgroundColor: AppColors.danger,
          message: e.message,
          duration: Duration(seconds: 3),
        ).show(context);
      });
    };
  }

  AddEditMeterModal({Meter? item=null,Function? onSave,String title='',String? labelName,bool isAttachment=false,bool isShared=false}){
    Meter _meter=item??Meter(id: 0);
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return MeterFrom(client: this.widget.client,labelName:labelName,title:title,
          item:item,mosque: _mosque,
          headersMap:  _mosqueService==null?'':_mosqueService!.headersMap,
          onSave: onSave,
          isShared: isShared,
          isAttachment: isAttachment,
        );
      },
    );
   
  }
  //#endregion  Edit form


  final _formDetailKey = GlobalKey<FormState>();
  final _formMaintenanceKey = GlobalKey<FormState>();
  final _formBuildingKey = GlobalKey<FormState>();
  final _formImamDetailKey = GlobalKey<FormState>();
  final _formPrayerKey = GlobalKey<FormState>();
  final _formGeoLocKey = GlobalKey<FormState>();
  final _formBasicInfoKey = GlobalKey<FormState>();
  final _formRegionKey = GlobalKey<FormState>();
  final _formMeterKey = GlobalKey<FormState>();
  final _formRefuseKey = GlobalKey<FormState>();
  final _formMosqueInfoKey = GlobalKey<FormState>();
  final _formGeneralInfoKey = GlobalKey<FormState>();
  bool isVisiablePermission=false;
  late GPSPermission permission;
  List<String> requiredFields=[];
  dynamic disclaimer;
  void acceptTerms(){
    setState(() {
      isLoading=true;
    });
    _mosqueService.acceptTerms(_mosque.id).then((_){
      if(this.widget.onCallback!=null)
        this.widget.onCallback!();
      getMosqueDetail();
      setState(() {
        isLoading=false;
      });
    }).catchError((e){
      setState(() {
        isLoading=false;
      });
      Flushbar(
        icon: Icon(Icons.warning,color: Colors.white,),
        backgroundColor:  AppColors.danger,
        message: e.message,
        duration: Duration(seconds: 3),
      ).show(context);
    });
  }
  void confirmMosque(){
    _mosqueService.getDisclaimer(_mosque.id??0).then((result){
     
      disclaimer=result;
   


      showDisclaimerDialog(context,text:(JsonUtils.toText(disclaimer["value"]["text"])??""),onApproved: (){
        acceptTerms();
      });

    }).catchError((e){
      
    });
    //sendVisit();
  }
  void approveMosque(){
    requiredFields=[];
    setState(() {
      isLoading=true;
    });
    _mosqueService.sendMosque(_mosque.id!).then((response){
     

      setState(() {
        isLoading=false;
      });

      if(response!=null && JsonUtils.toBoolean(response["success"])==false){
     
        var warning = response['warning'] as Map<String, dynamic>;
        if (warning.containsKey('fields') && warning['fields'] is List) {
          var fields = warning['fields'] as List<dynamic>;

          requiredFields=fields.map((item) {
          
            if (item is String) {
              return item;
            } else {
              return '';
            }
          }).toList();
          setState(() {

          });
        }

        Flushbar(
          icon: Icon(Icons.warning,color: Colors.white,),
          backgroundColor:  AppColors.danger,
          message: response["warning"]["message"],
          duration: Duration(seconds: 3),
        ).show(context);
      }else{
        
        confirmMosque();

        //getMosqueDetail();
      }


      //this.widget.onCallback!();
      //Navigator.pop(context);
    }).catchError((e){
      
      setState(() {
        isLoading=false;
      });

      Flushbar(
        icon: Icon(Icons.warning,color: Colors.white,),
        backgroundColor:  AppColors.danger,
        message: e.message,
        duration: Duration(seconds: 3),
      ).show(context);
    });
  }
  bool isObserverEditMode=false;
  // void acceptMosque(){
  //
  //   setState(() {
  //     isLoading=true;
  //   });
  //   _mosqueService.acceptMosque(_mosque.id!).then((_){
  //     getMosqueDetail();
  //     setState(() {
  //       isLoading=false;
  //     });
  //     // this.widget.onCallback!();
  //     // Navigator.pop(context);
  //   }).catchError((e){
  //     setState(() {
  //       isLoading=false;
  //     });
  //
  //
  //     Flushbar(
  //       icon: Icon(Icons.warning,color: Colors.white,),
  //       backgroundColor:  AppColors.danger,
  //       message: e.message,
  //       duration: Duration(seconds: 3),
  //     ).show(context);
  //   });
  // }
  String refuseMessage='';
  showRefuseModal({MosqueRegion? region=null}){
    setState(() {
      refuseMessage='';
    });
    MosqueRegion _region=region??MosqueRegion(id:0,number: 0);
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8), // Adjust top radius here
                topRight: Radius.circular(8),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [

                ModalTitle('Refuse Reason',FontAwesomeIcons.fileEdit),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Form(
                    key: _formRefuseKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CustomFormField(title: '',value: refuseMessage,isRequired: true,onChanged:(val) => refuseMessage = val,type: FieldType.textArea,),
                       SizedBox(height: 10,),
                        Row(
                          children: [
                            Expanded(
                              child: DangerButton(text: "refuse".tr(),onTab:(){


                                if (_formRefuseKey.currentState!.validate()) {
                                  _formRefuseKey.currentState!.save();
                                  refuseMosque();
                                };
                              }),
                            ),
                            Expanded(
                              child: SecondaryButton(text: "cancel".tr(),onTab:(){
                                Navigator.pop(context);
                              }),
                            ),
                          ],
                        ),
                        SizedBox(height: 5,),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  void refuseMosque(){
   
    Navigator.pop(context);
    setState(() {
      isLoading=true;
    });
    _mosqueService.refuseMosque(_mosque.id!,refuseMessage).then((_){

      setState(() {
        isLoading=false;
      });
      getMosqueDetail();
      // this.widget.onCallback!();

    }).catchError((e){
     
      setState(() {
        isLoading=false;
      });
      Flushbar(
        icon: Icon(Icons.warning,color: Colors.white,),
        backgroundColor:  AppColors.danger,
        message: e.message,
        duration: Duration(seconds: 3),
      ).show(context);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    userProvider = Provider.of<UserProvider>(context);
    _userService!.updateUserProfile(userProvider.userProfile);
    _mosqueService.updateUserProfile(userProvider.userProfile);
    _userService!.updateCsrfToken();
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.primary,
        key: _scaffoldKey,
        body: Container(
          color: Colors.grey.withOpacity(.08),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Text((_mosque!.displayButtonRefuse??false).toString()),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5,vertical:5),
                          child: Icon(Icons.arrow_back,color: Theme.of(context).colorScheme.onPrimary.withOpacity(.5),size: 25 , ),
                        ),
                      ),
                      Expanded(child: Container()),
                      (_mosque!.displayButtonSend??false)!?Container(
                        padding: EdgeInsets.symmetric(horizontal: 3,vertical: 0),

                        child: DangerButton(text: "send".tr(),onTab:(){
                          if(isVerifyDevice()) {
                            //confirmMosque();
                            approveMosque();
                          }
                        },icon: FontAwesomeIcons.paperPlane),
                      ):Container(),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10,vertical: 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,

                      children: [
                        GestureDetector(
                          onTap: (){
                           Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FullScreenImagePage(
                                  title :_mosque.name??"",
                                  imageUrl: '${userProvider.baseUrl}/web/image?model=mosque.mosque&field=outer_image&id=${_mosque.id}&unique=${_mosque.uniqueId}',
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: 90,
                            height: 95,
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              color: AppColors.backgroundColor,
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(
                                color:AppColors.backgroundColor,
                                width: 1.0,
                              ),
                            ),
                            // decoration: BoxDecoration(
                            //   borderRadius: BorderRadius.circular(8.0),
                            //   shape: BoxShape.rectangle,
                            //   color: AppColors.backgroundColor,
                            //   border: Border.all(
                            //     color: Colors.grey.shade400,
                            //     width: 1.0,
                            //   ),
                            // ),
                            child:  ClipRRect(
                              child: Image.network('${userProvider.baseUrl}/web/image?model=mosque.mosque&field=outer_image&id=${_mosque.id}&unique=${_mosque.uniqueId}',headers: _mosqueService==null?'':_mosqueService!.headersMap,
                                fit: BoxFit.fitHeight,
                                errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                                  // This function will be called when the image fails to load
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(Icons.person,color: Colors.grey.shade300,size: 65,),
                                  ); // You can replace this with any widget you want to display
                                },
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                            // width:200,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children:[

                                Expanded(
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 10,vertical: 0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Text(_mosque.name??'',style: TextStyle(color: AppColors.onPrimary,fontSize: 20,fontWeight: FontWeight.bold),),
                                          Text(_mosque.number??"",style: TextStyle(color: AppColors.onPrimary,fontSize: 13),  softWrap: true,),
                                          _mosque.stage!=null?AppListTitle2(subTitle: _mosque.stage??'',isTag:true,hasDivider:false,
                                              isSelectionReverse:true,isOnlyValue:true):Container(),
                                          // Text(_mosque.classification??"",style: TextStyle(color: AppColors.onPrimary,fontSize: 13),  softWrap: true,),
                                        ],
                                      ),
                                    )
                                ),
                              ]
                          ),
                        ),

                      ],
                    ),
                  ),
                  SizedBox(height:10),

                  Expanded(
                    child: Container(
                      width: double.infinity,

                      decoration: BoxDecoration(
                        // borderRadius: BorderRadius.only(
                        //   topLeft: Radius.circular(15.0),
                        //   topRight: Radius.circular(15.0),
                        // ),
                        color: Colors.white,
                      ),
                      padding: EdgeInsets.all(0),
                      child: Container(
                        child: Column(
                          children: [
                            // Visibility(
                            //    visible: _tabController.index==0,
                            //   child: Container(
                            //     margin: EdgeInsets.only(bottom: 6),
                            //     decoration: BoxDecoration(
                            //       color: Colors.white,
                            //       boxShadow: [
                            //         BoxShadow(
                            //           color: Colors.black.withOpacity(0.1), // shadow color
                            //           spreadRadius: .05, // spread radius
                            //           blurRadius: 1, // blur radius
                            //           offset: Offset(0, 1), // changes position of shadow
                            //         ),
                            //       ],
                            //     ),
                            //     child: Row(
                            //       children: [
                            //         StateButton(title: 'Spaces',value: '1',icon: Icons.workspaces_outline,hasBorder: true,),
                            //         StateButton(title: 'Components',value: '2',icon: Icons.view_module_outlined,hasBorder: true),
                            //         StateButton(title: 'Programs',value: '3',icon: Icons.featured_play_list_outlined,hasBorder: true),
                            //         StateButton(title: 'Services',value: '10',icon: Icons.miscellaneous_services,)
                            //       ],
                            //     ),
                            //   ),
                            // ),
                            Expanded(
                              child: Container(
                                child: DefaultTabController(

                                  length: 14,
                                  child: Scaffold(

                                    appBar: PreferredSize(
                                      preferredSize: Size.fromHeight(48.0),
                                      child: AppBar(
                                        automaticallyImplyLeading: false,
                                        bottom: PreferredSize(
                                          preferredSize: Size.fromHeight(0.0),
                                          child: Container(
                                            color:   AppColors.secondly,
                                            child: TabBar(
                                              unselectedLabelColor: AppColors.onSecondly,
                                              controller: _tabController,
                                              isScrollable: true,
                                              indicatorSize: TabBarIndicatorSize.label,
                                              tabs:

                                              _tabs.map((TabForm tab) {
                                                // Here you can create the content for each tab
                                                return Tab(text: tab.title);
                                              }).toList(),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    body:  TabBarView(
                                      physics: _tabs[_tabController.index].isEditMode?const NeverScrollableScrollPhysics():null,




                                      controller: _tabController,
                                      children: [
                                        _tabs[_tabController.index].isEditMode?Column(
                                          children: [
                                            Expanded(
                                              child: SingleChildScrollView(
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                                  child: Form(
                                                    key: _formBasicInfoKey,
                                                    child: Column(
                                                      children: [

                                                        CustomListField(title: fields.getField('observer_ids').label,isRequired:requiredFields.contains("observer_ids"),employees: _observers,isEditMode:(_mosqueBasicInfo.isObserverEditable??false),
                                                            onDelete: (id){
                                                         
                                                              _observers.removeWhere((item) => item.id == id);
                                                              setState(() {

                                                              });
                                                            },
                                                            onTab:(){
                                                          
                                                              showModalBottomSheet(
                                                                context: context,
                                                                builder: (BuildContext context) {
                                                                  return MosqueUserList(client: this.widget.client,
                                                                    type: "obs",
                                                                    supervisorId:_mosqueBasicInfo.supervisorId ,
                                                                    title: fields.getField('observer_ids').label,
                                                                    // onAddEmployee: (){
                                                                    //   Navigator.of(context).pop();
                                                                    //   Navigator.push(
                                                                    //     context,
                                                                    //     MaterialPageRoute(
                                                                    //       builder: (context) => new CreateEmployee(client: this.widget.client,),
                                                                    //       //HalqaId: 1
                                                                    //     ),
                                                                    //   );
                                                                    // },
                                                                    onItemTap: (Employee val){
                                                                      
                                                                      if(_observers.where((number) => number.id==val.id).length==0)
                                                                        _observers.add(Employee(id:val.id,name: val.name ));
                                                                      setState(() {

                                                                      });
                                                                      Navigator.of(context).pop();
                                                                    },);
                                                                },
                                                              );
                                                            }),
                                                        CustomFormField(title: fields.getField('name').label,value: _mosqueBasicInfo.name,onChanged:(val) => _mosqueBasicInfo.name = val,
                                                          isRequiredField:requiredFields.contains("name"),
                                                          ),
                                                        // CustomFormField(title: 'Number',value: _mosqueDetail.number,isRequired: true,onChanged:(val) => _mosqueDetail.number = val,),
                                                        CustomFormField(title: fields.getField('region_id').label,onTab: (){
                                                          showRegionModal();
                                                        },isRequiredField:requiredFields.contains("region_id"),value: _mosqueBasicInfo.region,isReadonly:true,isSelection:true),
                                                        CustomFormField(title: fields.getField('city_id').label,onTab: (){
                                                          showCityModal();
                                                        },isRequiredField:requiredFields.contains("city_id"),value: _mosqueBasicInfo.city,isReadonly:true,isDisable: (_mosqueBasicInfo.region==null),isSelection:true),

                                                        CustomFormField(title: fields.getField('moia_center_id').label,onTab: (){
                                                          showCenterModal();
                                                        },isRequiredField:requiredFields.contains("moia_center_id"),value: _mosqueBasicInfo.moiaCenter,isReadonly:true,isSelection:true),


                                                        CustomFormField(title: fields.getField('is_another_neighborhood').label,value: _mosqueBasicInfo.isAnotherNeighborhood,
                                                            onChanged:(val){
                                                              _mosqueBasicInfo.isAnotherNeighborhood= val;
                                                              setState(() {});
                                                             
                                                            },isRequiredField:requiredFields.contains("is_another_neighborhood") ,type:FieldType.boolean),

                                                        _mosqueBasicInfo.isAnotherNeighborhood??false?Container():CustomFormField(title: fields.getField('district').label,onTab: (){
                                                          showDistrictModal();
                                                        },isRequiredField:requiredFields.contains("district"),value: _mosqueBasicInfo.district,isReadonly:true,isSelection:true),

                                                       

                                                        _mosqueBasicInfo.isAnotherNeighborhood??false?
                                                        CustomFormField(title: fields.getField('another_neighborhood_char').label,value: _mosqueBasicInfo.anotherNeighborhoodChar,onChanged:(val) => _mosqueBasicInfo.anotherNeighborhoodChar = val,isRequiredField:requiredFields.contains("another_neighborhood_char"))
                                                        :Container(),


                                                        CustomFormField(title: fields.getField('street').label,isRequiredField:requiredFields.contains("street"),value: _mosqueBasicInfo.street,onChanged:(val) => _mosqueBasicInfo.street = val,),

                                                        CustomFormField(title: fields.getField('classification_id').label,isRequiredField:requiredFields.contains("classification_id"),onTab: (){
                                                          showClassificationModal();
                                                        },value: _mosqueBasicInfo.classification,isReadonly:true,isSelection:true),


                                                        // CustomFormField(title: 'District',value: _mosqueBasicInfo.district,onChanged:(val) => _mosqueBasicInfo.district = val,),



                                                        CustomFormField(title: fields.getField('land_owner').label,isRequiredField:requiredFields.contains("land_owner"),value: _mosqueBasicInfo.landOwner,onChanged:(val){

                                                          _mosqueBasicInfo.landOwner = val;
                                                          setState(() {


                                                          });
                                                        },
                                                            type: FieldType.selection,
                                                            options:fields.getComboList('land_owner')
                                                        ),

                                                        _mosqueBasicInfo.landOwner=="private"?CustomFormField(title: fields.getField('mosque_owner_name').label,value: _mosqueBasicInfo.mosqueOwnerName,
                                                            isRequiredField:requiredFields.contains("mosque_owner_name"),
                                                            onChanged:(val) => _mosqueBasicInfo.mosqueOwnerName = val):Container(),

                                                   
                                                        CustomFormField(title: fields.getField('date_maintenance_last').label,
                                                          value: _mosqueBasicInfo.dateMaintenanceLast,onChanged:(val){
                                                            _mosqueBasicInfo.dateMaintenanceLast = val;
                                                         
                                                            setState((){});
                                                          }
                                                          ,isRequiredField:requiredFields.contains("date_maintenance_last"),type: FieldType.date,
                                                        ),
                                                        CustomFormField(title: fields.getField('mosque_opening_date').label,isRequiredField:requiredFields.contains("mosque_opening_date"),value: _mosqueBasicInfo.mosqueOpeningDate,
                                                            onChanged:(val) {

                                                              _mosqueBasicInfo.mosqueOpeningDate = val;
                                                          
                                                          },type:FieldType.number),

                                                        CustomFormField(title: fields.getField('is_employee').label,isRequiredField:requiredFields.contains("is_employee"),value: _mosqueBasicInfo.isEmployee,onChanged:(val){

                                                          _mosqueBasicInfo.isEmployee = val;
                                                          setState(() {


                                                          });
                                                        },
                                                            type: FieldType.choice,
                                                            options:fields.getComboList('is_employee')
                                                        ),

                                                        _mosqueBasicInfo.isEmployee=='yes'?
                                                        Column(
                                                          children: [
                                                            CustomListField(title: fields.getField('imam_ids').label,isRequired:requiredFields.contains("imam_ids"),employees: _imams,isEditMode:true,
                                                            onDelete: (id){
                                                            
                                                                _imams.removeWhere((item) => item.id == id);
                                                                setState(() {
                                                            
                                                                });
                                                            },
                                                            onTab:(){
                                                                                                                   
                                                              showModalBottomSheet(
                                                                context: context,
                                                                builder: (BuildContext context) {
                                                                  return MosqueUserList(client: this.widget.client,
                                                                    type: "imam",
                                                                    title: fields.getField('imam_ids').label,
                                                                    onAddEmployee: (){
                                                                      Navigator.of(context).pop();
                                                                      Navigator.push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                          builder: (context) => new CreateEmployee(client: this.widget.client,),
                                                                          //HalqaId: 1
                                                                        ),
                                                                      );
                                                                    },
                                                                    onItemTap: (Employee val){
                                                                     
                                                                      if(_imams.where((number) => number.id==val.id).length==0)
                                                                        _imams.add(Employee(id:val.id,name: val.name ));
                                                                      setState(() {
                                                            
                                                                      });
                                                                      Navigator.of(context).pop();
                                                                    },);
                                                                },
                                                              );
                                                            }),
                                                            CustomListField(title: fields.getField('muezzin_ids').label,isRequired:requiredFields.contains("muezzin_ids"),employees: _muezzin,isEditMode:true,
                                                                onDelete: (id){

                                                                  _muezzin.removeWhere((item) => item.id == id);
                                                                  setState(() {

                                                                  });
                                                                },
                                                                onTab:(){
                                                                  showModalBottomSheet(
                                                                    context: context,
                                                                    builder: (BuildContext context) {
                                                                      return MosqueUserList(client: this.widget.client,
                                                                        type: "muezzin",
                                                                        title: fields.getField('muezzin_ids').label,
                                                                        onAddEmployee: (){
                                                                          Navigator.of(context).pop();
                                                                          Navigator.push(
                                                                            context,
                                                                            MaterialPageRoute(
                                                                              builder: (context) => new CreateEmployee(client: this.widget.client,),
                                                                              //HalqaId: 1
                                                                            ),
                                                                          );
                                                                        },
                                                                        onItemTap: (Employee val){

                                                                          if(_muezzin.where((number) => number.id==val.id).length==0)
                                                                            _muezzin.add(Employee(id:val.id,name: val.name ));
                                                                          setState(() {

                                                                          });
                                                                          Navigator.of(context).pop();
                                                                        },);
                                                                    },
                                                                  );
                                                                }),
                                                            CustomListField(title: fields.getField('khadem_ids').label,isRequired:requiredFields.contains("khadem_ids"),employees: _khadem,isEditMode:true,
                                                                onDelete: (id){

                                                                  _khadem.removeWhere((item) => item.id == id);
                                                                  setState(() {

                                                                  });
                                                                },
                                                                onTab:(){
                                                                  showModalBottomSheet(
                                                                    context: context,
                                                                    builder: (BuildContext context) {
                                                                      return MosqueUserList(client: this.widget.client,
                                                                        type: "khadem",
                                                                        onAddEmployee: (){
                                                                          Navigator.of(context).pop();
                                                                          Navigator.push(
                                                                            context,
                                                                            MaterialPageRoute(
                                                                              builder: (context) => new CreateEmployee(client: this.widget.client,),
                                                                              //HalqaId: 1
                                                                            ),
                                                                          );
                                                                        },
                                                                        title: fields.getField('khadem_ids').label,
                                                                        onItemTap: (Employee val){

                                                                          if(_khadem.where((number) => number.id==val.id).length==0)
                                                                            _khadem.add(Employee(id:val.id,name: val.name ));
                                                                          setState(() {

                                                                          });
                                                                          Navigator.of(context).pop();
                                                                        },);
                                                                    },
                                                                  );
                                                                }),
                                                            CustomListField(title: fields.getField('khatib_ids').label,isRequired:requiredFields.contains("khatib_ids"),employees: _khatib,isEditMode:true,
                                                                onDelete: (id){

                                                                  _khatib.removeWhere((item) => item.id == id);
                                                                  setState(() {

                                                                  });
                                                                },
                                                                onTab:(){
                                                                  showModalBottomSheet(
                                                                    context: context,
                                                                    builder: (BuildContext context) {
                                                                      return MosqueUserList(client: this.widget.client,
                                                                        type: "khatib",
                                                                        title: fields.getField('khatib_ids').label,
                                                                        onAddEmployee: (){
                                                                          Navigator.of(context).pop();
                                                                          Navigator.push(
                                                                            context,
                                                                            MaterialPageRoute(
                                                                              builder: (context) => new CreateEmployee(client: this.widget.client,),
                                                                              //HalqaId: 1
                                                                            ),
                                                                          );
                                                                        },
                                                                        onItemTap: (Employee val){

                                                                          if(_khatib.where((number) => number.id==val.id).length==0)
                                                                            _khatib.add(Employee(id:val.id,name: val.name ));
                                                                          setState(() {

                                                                          });
                                                                          Navigator.of(context).pop();
                                                                        },);
                                                                    },
                                                                  );
                                                                }),
                                                          ],
                                                        ):Container(),
                                                        
                                                      

                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),

                                            ),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: PrimaryButton(text: "update".tr(),onTab:(){
                                                    updateBasicInfo(_tabController.index);
                                                

                                                  }),
                                                ),
                                                Expanded(
                                                  child: SecondaryButton(text: "cancel".tr(),onTab:(){
                                                    _tabs[_tabController.index].isEditMode=false;
                                                    setState(() {

                                                    });
                                                 
                                                  }),
                                                ),
                                              ],
                                            )
                                          ],
                                        ):SingleChildScrollView(
                                          child: Container(
                                            padding: EdgeInsets.symmetric(horizontal: 10),
                                            child: Column(
                                              children: [



                                                  
                                                  isObserverEditMode==false?CustomListField(title: fields.getField('observer_ids').label,isRequired:requiredFields.contains("observer_ids"),employees: _observers,
                                                  actions:((_mosque.isObserverEditable??false) && _mosque.state!='draft')?
                                                  DangerButton(onTab: (){
                                                    _mosqueBasicInfo = Mosque.shallowCopy(_mosque);
                                                    _observersTemp=[];
                                                    _observers.forEach((employee) {
                                                      _observersTemp.add(Employee.shallowCopy(employee));
                                                    });
                                                    setState((){
                                                      isObserverEditMode=true;
                                                    });
                                                  },text: 'edit'.tr(),icon:FontAwesomeIcons.edit ):null ,):
                                                  Column(
                                                    children: [
                                                      CustomListField(title: fields.getField('observer_ids').label,isRequired:requiredFields.contains("observer_ids"),employees: _observersTemp,isEditMode:(_mosque.isObserverEditable??false),
                                                                                                      onDelete: (id){
                                                      
                                                      _observersTemp.removeWhere((item) => item.id == id);
                                                      setState(() {
                                                      
                                                      });
                                                                                                      },
                                                                                                      onTab:(){
                                                      
                                                      showModalBottomSheet(
                                                        context: context,
                                                        builder: (BuildContext context) {
                                                          return MosqueUserList(client: this.widget.client,
                                                            type: "obs",
                                                            supervisorId:_mosqueBasicInfo.supervisorId ,
                                                            title: fields.getField('observer_ids').label,
                                                            // onAddEmployee: (){
                                                            //   Navigator.of(context).pop();
                                                            //   Navigator.push(
                                                            //     context,
                                                            //     MaterialPageRoute(
                                                            //       builder: (context) => new CreateEmployee(client: this.widget.client,),
                                                            //       //HalqaId: 1
                                                            //     ),
                                                            //   );
                                                            // },
                                                            onItemTap: (Employee val){
                                                      
                                                              if(_observersTemp.where((number) => number.id==val.id).length==0)
                                                                _observersTemp.add(Employee(id:val.id,name: val.name ));
                                                              setState(() {
                                                      
                                                              });
                                                              Navigator.of(context).pop();
                                                            },);
                                                        },
                                                      );
                                                                                                      }),
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child: PrimaryButton(text: "update".tr(),onTab:(){
                                                              updateObservers();

                                                            }),
                                                          ),
                                                          Expanded(
                                                            child: SecondaryButton(text: "cancel".tr(),onTab:(){
                                                              setState(() {
                                                                isObserverEditMode=false;
                                                              });

                                                            }),
                                                          ),
                                                        ],
                                                      )

                                                    ],
                                                  ),
                                                // AppListTitle2(title:'saad',subTitle: _mosque.supervisor??''),
                                                // AppListTitle2(title: fields.getField('old_sequence').label,subTitle: _mosque.oldSequence??''),
                                                AppListTitle2(title: fields.getField('region_id').label,subTitle: _mosque.region??'',isRequired:requiredFields.contains("region_id")),
                                                AppListTitle2(title: fields.getField('city_id').label,subTitle: _mosque.city??'',isRequired:requiredFields.contains("city")),
                                                AppListTitle2(title: fields.getField('moia_center_id').label,subTitle: _mosque.moiaCenter??'',isRequired:requiredFields.contains("moia_center_id")),


                                                AppListTitle2(title: fields.getField('is_another_neighborhood').label,subTitle: _mosque.isAnotherNeighborhood??'',isBoolean:true,isRequired:requiredFields.contains("is_another_neighborhood")),
                                                 _mosque.isAnotherNeighborhood??false?Container():AppListTitle2(title: fields.getField('district').label,subTitle: _mosque.district??'',isRequired:requiredFields.contains("district")),

                                                 _mosque.isAnotherNeighborhood??false?AppListTitle2(title: fields.getField('another_neighborhood_char').label,subTitle: _mosque.anotherNeighborhoodChar??'',isRequired:requiredFields.contains("another_neighborhood_char")):Container(),
                                                AppListTitle2(title: fields.getField('street').label,subTitle: _mosque.street??'',isRequired:requiredFields.contains("street")),
                                                AppListTitle2(title: fields.getField('classification_id').label,subTitle: _mosque.classification??'',isRequired:requiredFields.contains("classification_id")),
                                                AppListTitle2(title: fields.getField('land_owner').label,subTitle: _mosque.landOwner??'',selection:fields.getComboList('land_owner'),isRequired:requiredFields.contains("land_owner")),

                                                _mosque.landOwner=="private"?AppListTitle2(title: fields.getField('mosque_owner_name').label,isRequired:requiredFields.contains("mosque_owner_name"),subTitle: _mosque.mosqueOwnerName??""):Container(),

                                                // AppListTitle2(title: fields.getField('establishment_date').label,subTitle: _mosque.establishmentDate??''),
                                                AppListTitle2(title: fields.getField('mosque_opening_date').label,subTitle: _mosque.mosqueOpeningDate??"",isRequired:requiredFields.contains("mosque_opening_date")),
                                                AppListTitle2(title: fields.getField('date_maintenance_last').label,subTitle: _mosque.dateMaintenanceLast??'',isDate: true,isRequired:requiredFields.contains("date_maintenance_last")),

                                                AppListTitle2(title: fields.getField('is_employee').label,subTitle: _mosque.isEmployee??'',selection:fields.getComboList('is_employee'),isRequired:requiredFields.contains("is_employee"),isTag:true),


                                                _mosque.isEmployee=='yes'?
                                                Column(
                                                  children: [
                                                    CustomListField(title: fields.getField('imam_ids').label,isRequired:requiredFields.contains("imam_ids"),employees: _imams,),
                                                    CustomListField(title: fields.getField('muezzin_ids').label,isRequired:requiredFields.contains("muezzin_ids"),employees: _muezzin),
                                                    CustomListField(title: fields.getField('khadem_ids').label,isRequired:requiredFields.contains("khadem_ids"),employees: _khadem),
                                                    CustomListField(title: fields.getField('khatib_ids').label,isRequired:requiredFields.contains("khatib_ids"),employees: _khatib),
                                                  ],
                                                ):Container(),

                                               

                                              ],
                                            ),
                                          ),
                                        ),
                                        _tabs[_tabController.index].isEditMode?Column(
                                          children: [
                                            Expanded(
                                              child: SingleChildScrollView(
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                                                  child: Form(
                                                    key: _formDetailKey,
                                                    child: Column(
                                                      children: [
                                                        CustomFormField(title: fields.getField('land_area').label,isRequiredField:requiredFields.contains("land_area"),value: _mosqueDetail.landArea,onChanged:(val) => _mosqueDetail.landArea =val),
                                                        CustomFormField(title: fields.getField('capacity').label,isRequiredField:requiredFields.contains("capacity"),value: _mosqueDetail.capacity.toString(),onChanged:(val) => _mosqueDetail.capacity = val,type: FieldType.number,),
                                                        // CustomFormField(title: fields.getField('mosque_land_area').label,value: _mosqueDetail.mosqueLandArea,onChanged:(val) => _mosqueDetail.mosqueLandArea = val,type: FieldType.double,),
                                                        CustomFormField(title: fields.getField('roofed_area').label,isRequiredField:requiredFields.contains("roofed_area"),value: _mosqueDetail.roofedArea.toString(),onChanged:(val) => _mosqueDetail.roofedArea = val,type: FieldType.double,),

                                                        CustomFormField(title: fields.getField('urban_condition').label,isRequiredField:requiredFields.contains("urban_condition"),value: _mosqueDetail.urbanCondition.toString(),
                                                          onChanged:(val){
                                                            
                                                            _mosqueDetail.urbanCondition = val;
                                                            setState(() {

                                                            });
                                                          },
                                                          type: FieldType.choice,
                                                          isScroll: true,
                                                          options:fields.getComboList('urban_condition').toList(),),
                                                        
                                                        CustomFormField(title: fields.getField('is_qr_code_exist').label,isRequiredField:requiredFields.contains("is_qr_code_exist"),value: _mosqueDetail.isQrCodeExist.toString(),

                                                          onChanged:(val){
                                                          
                                                            _mosqueDetail.isQrCodeExist = val;
                                                            setState(() {

                                                            });
                                                          },
                                                          type: FieldType.choice,
                                                          options:fields.getComboList('is_qr_code_exist').toList(),
                                                        ),
                                                        _mosqueDetail.isQrCodeExist=='yes'?Column(
                                                          children: [
                                                            CustomFormField(title:fields.getField('qr_code_notes').label,isRequiredField:requiredFields.contains("qr_code_notes"),value: _mosqueDetail.qrCodeNotes.toString(),onChanged:(val) => _mosqueDetail.qrCodeNotes = val,


                                                            ),
                                                            CustomFormField(title: fields.getField('is_panel_readable').label,isRequiredField:requiredFields.contains("is_panel_readable"),value: _mosqueDetail.isPanelReadable.toString()

                                                              ,onChanged:(val){
                                                          
                                                                _mosqueDetail.isPanelReadable = val;
                                                                setState(() {

                                                                });
                                                              },
                                                              type: FieldType.choice,
                                                              options:fields.getComboList('is_panel_readable').toList(),
                                                            ),
                                                            _mosqueDetail.isPanelReadable=='yes'?Column(
                                                              children: [
                                                                CustomFormField(title: fields.getField('code_readable').label,value: _mosqueDetail.codeReadable.toString(),



                                                                  onChanged:(val){
                                                                
                                                                    _mosqueDetail.codeReadable = val;
                                                                    setState(() {

                                                                    });
                                                                  },isRequiredField:requiredFields.contains("code_readable"),
                                                                  type: FieldType.choice,
                                                                  options:fields.getComboList('code_readable').toList(),
                                                                ),
                                                                _mosqueDetail.codeReadable=='yes'?CustomFormField(title: fields.getField('mosque_data_correct').label,value: _mosqueDetail.mosqueDataCorrect.toString(),

                                                                  onChanged:(val){
                                                                  
                                                                    _mosqueDetail.mosqueDataCorrect = val;
                                                                    setState(() {

                                                                    });
                                                                  },isRequiredField:requiredFields.contains("mosque_data_correct"),
                                                                  type: FieldType.choice,
                                                                  options:fields.getComboList('mosque_data_correct').toList(),
                                                                ):Container(),
                                                              ],
                                                            ):Container(),
                                                            CustomFormField(title: fields.getField('qr_code_match').label,value: _mosqueDetail.qrCodeMatch.toString(),

                                                              onChanged:(val){
                                                             
                                                                _mosqueDetail.qrCodeMatch = val;
                                                                setState(() {

                                                                });
                                                              },isRequiredField:requiredFields.contains("qr_code_match"),
                                                              type: FieldType.choice,
                                                              options:fields.getComboList('qr_code_match').toList(),
                                                            ),
                                                            _mosqueDetail.qrCodeMatch=='no'?CustomFormField(title: fields.getField('mosque_name_qr').label,value: _mosqueDetail.mosqueNameQr,
                                                                onChanged:(val) => _mosqueDetail.mosqueNameQr = val,isRequiredField:requiredFields.contains("mosque_name_qr")):Container(),
                                                            CustomFormField(title: fields.getField('qr_panel_numbers').label,value: _mosqueDetail.qrPanelNumbers,
                                                                onChanged:(val) => _mosqueDetail.qrPanelNumbers = val,
                                                                type:FieldType.number,isRequiredField:requiredFields.contains("qr_panel_numbers")),

                                                            CustomFormField(title: fields.getField('qr_image').label,isRequiredField:requiredFields.contains("qr_image"),
                                                                value: _mosqueDetail.qrImage==null?'':'${userProvider.baseUrl}/web/image?model=mosque.mosque&id=${_mosque.id}&field=qr_image&unique=${_mosque.uniqueId}',
                                                                onChanged:(val) {
                                                                  _mosqueDetail
                                                                      .qrImage =
                                                                      val;
                                                                  setState(() {


                                                                  });
                                                                },type: FieldType.image
                                                                ,headersMap: _mosqueService==null?'':_mosqueService!.headersMap),


                                                            //
                                                            // CustomFormField(title: fields.getField('num_qr_code_panels').label,value: _mosqueDetail.numQrCodePanels.toString(),onChanged:(val) => _mosqueDetail.numQrCodePanels = val,
                                                            //   type: FieldType.double,
                                                            // ),
                                                          ],
                                                        ):Container(),

                                                        CustomFormField(title: fields.getField('has_electricity_meter').label,value: _mosqueDetail.hasElectricityMeter.toString(),

                                                          onChanged:(val){
                                                      
                                                            _mosqueDetail.hasElectricityMeter = val;
                                                            setState(() {

                                                            });
                                                          },isRequiredField:requiredFields.contains("has_electricity_meter"),
                                                          type: FieldType.choice,
                                                          options:fields.getComboList('has_electricity_meter').toList(),
                                                        ),

                                                        _mosqueDetail.hasElectricityMeter=='yes'?Column(
                                                          children: [
                                                            CustomFormField(title: fields.getField('is_mosque_electric_meter_new').label,value: _mosqueDetail.isMosqueElectricMeterNew.toString(),

                                                              onChanged:(val){
                                                            
                                                                _mosqueDetail.isMosqueElectricMeterNew = val;
                                                                setState(() {

                                                                });
                                                              },
                                                              type: FieldType.choice,isRequiredField:requiredFields.contains("is_mosque_electric_meter_new"),
                                                              options:fields.getComboList('is_mosque_electric_meter_new').toList(),
                                                            ),
                                                            CustomListField(title: fields.getField('mosque_electricity_meter_ids').label,isRequired:requiredFields.contains("mosque_electricity_meter_ids"),


                                                                buttonIcon : FontAwesomeIcons.plusCircle,

                                                                employees:  _mosqueElectricityMeters.where((item) => item.isDelete==false).toList(),isEditMode:true,
                                                                builder: (Meter item){
                                                                  return  Row(
                                                                    children: [
                                                                      ImageData(id: item.id,modelName: Model.meter,width: 50,height: 50,uniqueId: item.uniqueId,baseUrl: userProvider.baseUrl,headersMap:_mosqueService==null?'':_mosqueService!.headersMap ,fieldId: "attachment_id",),
                                                                     
                                                                      Column(
                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                        children: [
                                                                          // Text(item.attachmentId.toString()),
                                                                          Text(item.name!,style: TextStyle(color: AppColors.defaultColor),),
                                                                          Row(
                                                                            children: [
                                                                              AppBoolean(value: (item.mosqueShared??false),),
                                                                              // SizedBox(width: 5,),
                                                                              Text("shared".tr(),style: AppTextStyles.formLabel,),
                                                                            ],
                                                                          )
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  );
                                                                },
                                                                onEdit: (Meter item){
                                                                  Meter copyItem=Meter(id: item.id,attachmentId: item.attachmentId,mosqueShared: item.mosqueShared,name: item.name,uniqueId: item.uniqueId);
                                                                  AddEditMeterModal(item: copyItem,
                                                                      title: fields.getField('mosque_electricity_meter_ids').label,
                                                                      labelName: "electric_meter_number".tr(),
                                                                      isAttachment: true,
                                                                      isShared: true,
                                                                      onSave:(Meter item){
                                                                        Meter itemToUpdate = _mosqueElectricityMeters.firstWhere((record) => record.id == item.id);

                                                                        itemToUpdate.isEdit = true;
                                                                        itemToUpdate.name = item.name;
                                                                        itemToUpdate.attachmentId = item.attachmentId;
                                                                        itemToUpdate.mosqueShared = item.mosqueShared;

                                                                        setState(() {

                                                                        });
                                                                        Navigator.of(context).pop();
                                                                      }
                                                                  );
                                                                },
                                                                onDelete: (Meter item){
                                                                  Meter itemToUpdate = _mosqueElectricityMeters.firstWhere((record) => record.id == item.id);
                                                                  itemToUpdate.isDelete = true;
                                                                  setState(() {

                                                                  });
                                                                 
                                                                
                                                                },

                                                                onTab:(){
                                                                  AddEditMeterModal(
                                                                      title: fields.getField('mosque_electricity_meter_ids').label,
                                                                      labelName: "electric_meter_number".tr(),
                                                                      isAttachment: true,
                                                                      isShared: true,
                                                                      onSave:(Meter item){
                                                                        _mosqueElectricityMeters.add(item);
                                                                        setState(() {

                                                                        });
                                                                        Navigator.of(context).pop();
                                                                      }
                                                                  );
                                                                }),
                                                          ],
                                                        ):Container(),
                                                        CustomFormField(title: fields.getField('has_water_meter').label,value: _mosqueDetail.hasWaterMeter.toString(),

                                                          isRequiredField:requiredFields.contains("has_water_meter"),
                                                          onChanged:(val){
                                                     
                                                            _mosqueDetail.hasWaterMeter = val;
                                                            setState(() {

                                                            });
                                                          },
                                                          type: FieldType.choice,
                                                          options:fields.getComboList('has_water_meter').toList(),
                                                        ),

                                                        _mosqueDetail.hasWaterMeter=='yes'?
                                                        CustomListField(title: fields.getField('mosque_water_meter_ids').label,isRequired:requiredFields.contains("mosque_water_meter_ids"),employees:  _mosqueWaterMeters.where((item) => item.isDelete==false).toList(),isEditMode:true,
                                                            buttonIcon: FontAwesomeIcons.plusCircle,
                                                            builder: (Meter item){
                                                              return  Text(item.name!,style: TextStyle(color: AppColors.defaultColor),);
                                                            },
                                                            onEdit: (Meter item){
                                                              AddEditMeterModal(item: item,
                                                                  title: fields.getField('mosque_water_meter_ids').label,
                                                                  labelName: "water_meter_number".tr(),
                                                                  onSave:(Meter item){
                                                                    Meter itemToUpdate = _mosqueWaterMeters.firstWhere((record) => record.id == item.id);

                                                                    itemToUpdate.isEdit = true;
                                                                    itemToUpdate.name = item.name;

                                                                    setState(() {

                                                                    });
                                                                    Navigator.of(context).pop();
                                                                  }
                                                              );
                                                            },
                                                            onDelete: (Meter item){
                                                              Meter itemToUpdate = _mosqueWaterMeters.firstWhere((record) => record.id == item.id);
                                                              itemToUpdate.isDelete = true;
                                                              setState(() {

                                                              });
                                                            },
                                                            onTab:(){
                                                              AddEditMeterModal(
                                                                  title: fields.getField('mosque_water_meter_ids').label,
                                                                  labelName: "water_meter_number".tr(),
                                                                  onSave:(Meter item){
                                                                    _mosqueWaterMeters.add(item);
                                                                    setState(() {

                                                                    });
                                                                    Navigator.of(context).pop();
                                                                  }
                                                              );
                                                            }):Container(),

                                                        CustomFormField(title: fields.getField('non_building_area').label,value: _mosqueDetail.nonBuildingArea.toString(),onChanged:(val) => _mosqueDetail.nonBuildingArea = val,
                                                          isRequiredField:requiredFields.contains("non_building_area"),
                                                          type: FieldType.double,
                                                        ),
                                                        CustomFormField(title: fields.getField('is_free_area').label,value: _mosqueDetail.isFreeArea.toString(),
                                                          isRequiredField:requiredFields.contains("is_free_area"),
                                                          onChanged:(val){

                                                            _mosqueDetail.isFreeArea = val;
                                                            setState(() {

                                                            });
                                                          },
                                                          type: FieldType.choice,
                                                          options:fields.getComboList('is_free_area').toList(),
                                                        ),
                                                        _mosqueDetail.isFreeArea=='yes'?CustomFormField(title: fields.getField('free_area').label,value: _mosqueDetail.freeArea.toString(),onChanged:(val) => _mosqueDetail.freeArea = val,
                                                          isRequiredField:requiredFields.contains("free_area"),
                                                          type: FieldType.double,
                                                        ):Container(),

                                                        CustomFormField(title: fields.getField('mosque_rooms').label,value: _mosqueDetail.mosqueRooms.toString(),onChanged:(val) => _mosqueDetail.mosqueRooms = val,
                                                          isRequiredField:requiredFields.contains("mosque_rooms"),
                                                          type: FieldType.number,
                                                        ),
                                                        CustomFormField(title: fields.getField('cars_parking').label,value: _mosqueDetail.carsParking,
                                                            isRequiredField:requiredFields.contains("cars_parking"),
                                                            onChanged:(val){
                                                              _mosqueDetail.carsParking= val;
                                                              setState(() {});
                                                            } ,type:FieldType.boolean),
                                                        CustomFormField(title: fields.getField('have_washing_room').label,value: _mosqueDetail.haveWashingRoom,
                                                            isRequiredField:requiredFields.contains("have_washing_room"),
                                                            onChanged:(val){
                                                              _mosqueDetail.haveWashingRoom = val;
                                                              setState(() {});
                                                            },type:FieldType.boolean),
                                                        CustomFormField(title: fields.getField('lectures_hall').label,value: _mosqueDetail.lecturesHall,
                                                            isRequiredField:requiredFields.contains("lectures_hall"),
                                                            onChanged:(val){
                                                              _mosqueDetail.lecturesHall = val;
                                                              setState(() {});
                                                            } ,type:FieldType.boolean),
                                                        CustomFormField(title: fields.getField('library_exist').label,value: _mosqueDetail.libraryExist,
                                                            isRequiredField:requiredFields.contains("library_exist"),
                                                            onChanged:(val){
                                                              _mosqueDetail.libraryExist = val;
                                                              setState(() {});
                                                            } ,type:FieldType.boolean),
                                                        CustomFormField(title: fields.getField('stood_on_ground_mosque').label,value: _mosqueDetail.stoodOnGroundMosque,
                                                            isRequiredField:requiredFields.contains("stood_on_ground_mosque"),
                                                            onChanged:(val){
                                                              _mosqueDetail.stoodOnGroundMosque = val;
                                                              setState(() {});
                                                            } ,type:FieldType.boolean),
                                                        CustomFormField(title: fields.getField('vacancies_spaces').label,value: _mosqueDetail.vacanciesSpaces,
                                                            isRequiredField:requiredFields.contains("vacancies_spaces"),
                                                            onChanged:(val){
                                                              _mosqueDetail.vacanciesSpaces = val;
                                                              setState(() {});
                                                            } ,type:FieldType.boolean),
                                                        CustomFormField(title: fields.getField('other_companions').label,value: _mosqueDetail.otherCompanions,
                                                            isRequiredField:requiredFields.contains("other_companions"),
                                                            onChanged:(val){
                                                              _mosqueDetail.otherCompanions = val;
                                                              setState(() {});
                                                            } ,type:FieldType.boolean),

                                                        (_mosqueDetail.otherCompanions??false)? CustomFormField(title: '',value: _mosqueDetail.description.toString(),onChanged:(val) => _mosqueDetail.description = val,
                                                          type: FieldType.textArea,):Container()



                                                        // CustomFormField(title: 'No. Planned11',value: _mosqueMosqueInfo.noPlanned,
                                                        //     onChanged:(val) => _mosqueMosqueInfo.noPlanned = val,
                                                        //     type:FieldType.double),
                                                        // CustomFormField(title: 'Piece Number',value: _mosqueMosqueInfo.pieceNumber,
                                                        //     onChanged:(val) => _mosqueMosqueInfo.pieceNumber = val,
                                                        //     type:FieldType.double),
                                                        // CustomFormField(title: 'National Address',value: _mosqueMosqueInfo.nationalAddress,
                                                        //     onChanged:(val) => _mosqueMosqueInfo.nationalAddress = val),
                                                        //
                                                        // AppTitle1('Facilities Details',Icons.info),
                                                        // CustomFormField(title: 'Number of men\'s bathrooms',value: _mosqueMosqueInfo.numMensBathrooms,
                                                        //     onChanged:(val) => _mosqueMosqueInfo.numMensBathrooms = val,
                                                        //     type:FieldType.double),
                                                        // CustomFormField(title: 'Number of internal speakers',value: _mosqueMosqueInfo.numInternalSpeakers,
                                                        //     onChanged:(val) => _mosqueMosqueInfo.numInternalSpeakers = val,
                                                        //     type:FieldType.double),
                                                        // CustomFormField(title: 'Number of external speakers',value: _mosqueMosqueInfo.numExternalSpeakers,
                                                        //     onChanged:(val) => _mosqueMosqueInfo.numExternalSpeakers = val,
                                                        //     type:FieldType.double),
                                                        // CustomFormField(title: 'Number of lighting inside the mosque',value: _mosqueMosqueInfo.numLightingInside,
                                                        //     onChanged:(val) => _mosqueMosqueInfo.numLightingInside = val,
                                                        //     type:FieldType.double),
                                                        // CustomFormField(title: 'Number of minarets in the mosque',value: _mosqueMosqueInfo.numMinarets,
                                                        //     onChanged:(val) => _mosqueMosqueInfo.numMinarets = val,
                                                        //     type:FieldType.double),
                                                        // CustomFormField(title: 'The number of floors',value: _mosqueMosqueInfo.numFloors,
                                                        //     onChanged:(val) => _mosqueMosqueInfo.numFloors = val,
                                                        //     type:FieldType.double),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),

                                            ),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: PrimaryButton(text: "update".tr(),onTab:(){
                                                    updateMosqueDetail(_tabController.index);
                                                 

                                                  }),
                                                ),
                                                Expanded(
                                                  child: SecondaryButton(text: "cancel".tr(),onTab:(){
                                                    _tabs[_tabController.index].isEditMode=false;
                                                    setState(() {

                                                    });
                                                 
                                                  }),
                                                ),
                                              ],
                                            )
                                          ],
                                        ):Column(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                child: SingleChildScrollView(
                                                  child: Container(
                                                    padding: EdgeInsets.symmetric(horizontal: 15,vertical: 5),
                                                    child: Column(
                                                      children: [
                                                        AppListTitle2(title: fields.getField('land_area').label,subTitle: _mosque.landArea??'',isRequired:requiredFields.contains("land_area")),
                                                        AppListTitle2(title: fields.getField('capacity').label,subTitle: _mosque.capacity.toString()??'',isRequired:requiredFields.contains("capacity")),
                                                        // AppListTitle2(title: fields.getField('mosque_land_area').label,subTitle: (_mosque.mosqueLandArea??'').toString()),

                                                        AppListTitle2(title: fields.getField('roofed_area').label,subTitle: (_mosque.roofedArea??'').toString(),isRequired:requiredFields.contains("roofed_area")),
                                                        AppListTitle2(title: fields.getField('urban_condition').label,subTitle: _mosque.urbanCondition??'',isTag: true,
                                                          selection:fields.getComboList('urban_condition'),isRequired:requiredFields.contains("urban_condition")),

                                                        // AppListTitle2(title: fields.getField('carrying_capacity').label,subTitle: (_mosque.carryingCapacity??'').toString()),

                                                        // AppListTitle2(title: fields.getField('has_qr_code_panel').label,subTitle: _mosque.hasQrCodePanel??'',isTag: true,
                                                        //     selection:fields.getComboList('has_qr_code_panel')),

                                                        AppListTitle2(title: fields.getField('is_qr_code_exist').label,subTitle: _mosque.isQrCodeExist??'',isTag: true,
                                                            selection:fields.getComboList('is_qr_code_exist'),isRequired:requiredFields.contains("is_qr_code_exist")),

                                                        _mosque.isQrCodeExist=='yes'?Column(
                                                          children: [
                                                            AppListTitle2(title: fields.getField('qr_code_notes').label,subTitle: _mosque.qrCodeNotes??'',isRequired:requiredFields.contains("qr_code_notes")),
                                                            AppListTitle2(title: fields.getField('is_panel_readable').label,subTitle: _mosque.isPanelReadable??'',isTag: true,
                                                                selection:fields.getComboList('is_panel_readable'),isRequired:requiredFields.contains("is_panel_readable")),
                                                            _mosque.isPanelReadable=='yes'?Column(
                                                              children: [
                                                                AppListTitle2(title: fields.getField('code_readable').label,subTitle: _mosque.codeReadable??'',isTag: true,
                                                                    selection:fields.getComboList('code_readable'),isRequired:requiredFields.contains("code_readable")),
                                                                _mosque.codeReadable=='yes'?AppListTitle2(title: fields.getField('mosque_data_correct').label,subTitle: _mosque.mosqueDataCorrect??'',isTag: true,
                                                                    selection:fields.getComboList('mosque_data_correct'),isRequired:requiredFields.contains("mosque_data_correct")):Container(),
                                                              ],
                                                            ):Container(),

                                                            AppListTitle2(title: fields.getField('qr_code_match').label,subTitle: _mosque.qrCodeMatch??'',isTag: true,
                                                                selection:fields.getComboList('qr_code_match'),isRequired:requiredFields.contains("qr_code_match")),
                                                            _mosque.qrCodeMatch=='no'?AppListTitle2(title: fields.getField('mosque_name_qr').label,subTitle: _mosque.mosqueNameQr??"",isRequired:requiredFields.contains("mosque_name_qr")):Container(),
                                                            AppListTitle2(title: fields.getField('qr_panel_numbers').label,subTitle: _mosque.qrPanelNumbers??"",isRequired:requiredFields.contains("qr_panel_numbers")),
                                                            // AppListTitle2(title: fields.getField('qr_image').label,subTitle: _mosque.qrImage??""),
                                                            AppListTitle2(title: fields.getField('qr_image').label,isRequired:requiredFields.contains("qr_image"),
                                                                subTitle: '${userProvider.baseUrl}/web/image?model=mosque.mosque&field=qr_image&id=${_mosque.id}&unique=${_mosque.uniqueId}'
                                                                ,type:ListType.image,headersMap: _mosqueService==null?'':_mosqueService!.headersMap,
                                                                onTab:(){
                                                                  Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      builder: (context) => FullScreenImagePage(
                                                                        title :fields.getField('qr_image').label,
                                                                        imageUrl: '${userProvider.baseUrl}/web/image?model=mosque.mosque&field=qr_image&id=${_mosque.id}&unique=${_mosque.uniqueId}',
                                                                      ),
                                                                    ),
                                                                  );
                                                                }
                                                            ),
                                                          ],
                                                        ):Container(),

                                                        // AppListTitle2(title: fields.getField('num_qr_code_panels').label,subTitle: (_mosque.numQrCodePanels??'').toString()),
                                                        AppListTitle2(title: fields.getField('has_electricity_meter').label,subTitle: _mosque.hasElectricityMeter??'',isTag: true,
                                                            selection:fields.getComboList('has_electricity_meter'),isRequired:requiredFields.contains("has_electricity_meter")),
                                                        _mosque.hasElectricityMeter=='yes'?Column(
                                                          children: [

                                                            AppListTitle2(title: fields.getField('is_mosque_electric_meter_new').label,subTitle: _mosque.isMosqueElectricMeterNew??'',isTag: true,
                                                                selection:fields.getComboList('is_mosque_electric_meter_new'),isRequired:requiredFields.contains("is_mosque_electric_meter_new")),
                                                            CustomListField(title: fields.getField('mosque_electricity_meter_ids').label,isRequired:requiredFields.contains("mosque_electricity_meter_ids"),employees: _mosqueElectricityMeters,isEditMode:false,
                                                              builder: (Meter item){
                                                                return  Row(
                                                                  children: [
                                                                    ImageData(id: item.id,modelName: Model.meter,width: 50,height: 50,uniqueId: item.uniqueId,
                                                                        baseUrl: userProvider.baseUrl,headersMap:_mosqueService==null?'':_mosqueService!.headersMap ,
                                                                      title:item.name,fieldId: "attachment_id" ),
                                                                    // Container(
                                                                    //
                                                                    //   height: 50,
                                                                    //   width: 50,
                                                                    //   child: Image.network('${Config.baseUrl}/web/image?model=meter.meter&id=${item.id}&field=attachment_id&unique=${item.uniqueId}',headers: _mosqueService==null?'':_mosqueService!.headersMap,fit: BoxFit.fitHeight,
                                                                    //     errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                                                                    //       // This function will be called when the image fails to load
                                                                    //       return Padding(
                                                                    //         padding: const EdgeInsets.all(8.0),
                                                                    //         child: Icon(Icons.person,color: Colors.grey.shade300,size: 30,),
                                                                    //       ); // You can replace this with any widget you want to display
                                                                    //     },
                                                                    //   ),
                                                                    //   //backgroundImage: NetworkImage('${AppConfig.baseURL}/web/image?model=res.partner&field=image_128&id=${employees[index]!.id}&unique=1202212040830551',headers: headersMap)),
                                                                    // ),
                                                                    Column(
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                                      children: [
                                                                        Text(item.name!,style: TextStyle(color: AppColors.defaultColor),),
                                                                        Row(
                                                                          children: [
                                                                            AppBoolean(value: (item.mosqueShared??false),),
                                                                            // SizedBox(width: 5,),
                                                                            Text("shared".tr(),style: AppTextStyles.formLabel,),
                                                                          ],
                                                                        )
                                                                      ],
                                                                    ),
                                                                  ],
                                                                );
                                                              },)
                                                          ],
                                                        ):Container(),
                                                        AppListTitle2(title: fields.getField('has_water_meter').label,subTitle: _mosque.hasWaterMeter??'',isTag: true,
                                                            selection:fields.getComboList('has_water_meter'),isRequired:requiredFields.contains("has_water_meter")),


                                                        _mosque.hasWaterMeter=='yes'?Column(
                                                          children: [

                                                            // AppListTitle2(title: fields.getField('imam_electricity_meter_ids').label,subTitle: (_mosque.imamElectricityMeterIds??'').toString(),
                                                            //   ),
                                                            CustomListField(title: fields.getField('mosque_water_meter_ids').label,isRequired:requiredFields.contains("mosque_water_meter_ids"),employees: _mosqueWaterMeters,isEditMode:false,
                                                              builder: (Meter item){
                                                                return  Text(item.name!,style: TextStyle(color: AppColors.defaultColor),);
                                                              },)
                                                          ],
                                                        ):Container(),

                                                        // CustomListField(title: fields.getField('imam_electricity_meter_ids').label,employees:  _imamElectricityMeters.where((item) => item.isDelete==false).toList(),isEditMode:true,
                                                        //     builder: (ComboItem item){
                                                        //       return  Text(item.value!,style: TextStyle(color: AppColors.defaultColor),);
                                                        //     },
                                                        //
                                                        //     ),

                                                        //sdf
                                                        AppListTitle2(title: fields.getField('non_building_area').label,subTitle: _mosque.nonBuildingArea??'',isRequired:requiredFields.contains("non_building_area")),
                                                        AppListTitle2(title: fields.getField('is_free_area').label,subTitle: _mosque.isFreeArea??'',
                                                            selection:fields.getComboList('is_free_area'),isTag:true,isRequired:requiredFields.contains("is_free_area")),
                                                        _mosque.isFreeArea=='yes'?AppListTitle2(title: fields.getField('free_area').label,subTitle: _mosque.freeArea??'',isRequired:requiredFields.contains("free_area")):Container(),
                                                        AppListTitle2(title: fields.getField('mosque_rooms').label,subTitle: _mosque.mosqueRooms??'',isRequired:requiredFields.contains("mosque_rooms")),

                                                        AppListTitle2(title: fields.getField('cars_parking').label,subTitle: _mosque.carsParking,isBoolean: true,isRequired:requiredFields.contains("cars_parking")),
                                                        AppListTitle2(title: fields.getField('have_washing_room').label,subTitle: _mosque.haveWashingRoom,isBoolean: true,isRequired:requiredFields.contains("have_washing_room")),
                                                        AppListTitle2(title: fields.getField('lectures_hall').label,subTitle: _mosque.lecturesHall,isBoolean: true,isRequired:requiredFields.contains("lectures_hall")),
                                                        AppListTitle2(title: fields.getField('library_exist').label,subTitle: _mosque.libraryExist,isBoolean: true,isRequired:requiredFields.contains("library_exist")),
                                                        AppListTitle2(title: fields.getField('stood_on_ground_mosque').label,subTitle: _mosque.stoodOnGroundMosque,isBoolean: true,isRequired:requiredFields.contains("stood_on_ground_mosque")),
                                                        AppListTitle2(title: fields.getField('vacancies_spaces').label,subTitle: _mosque.vacanciesSpaces??'',isBoolean: true,isRequired:requiredFields.contains("vacancies_spaces")),
                                                        AppListTitle2(title: fields.getField('other_companions').label,subTitle: _mosque.otherCompanions??'',isBoolean: true,isRequired:requiredFields.contains("other_companions")),
                                                        (_mosque.otherCompanions??false)?AppListTitle2(title: '',subTitle: _mosque.description??''):Container(),


                                                        //
                                                        // AppListTitle2(title: 'Piece Number',subTitle: _mosque.pieceNumber.toString()),
                                                        // AppListTitle2(title: 'National Address',subTitle: _mosque.nationalAddress??""),
                                                        // AppTitle1('Instrument Details',Icons.perm_device_information),
                                                        // AppListTitle2(title: 'Is there a deed?',subTitle: _mosque.hasDeed??'',isBoolean: true),
                                                        // AppListTitle2(title: 'Is the electronic instrument up to date?',subTitle: _mosque.electronicInstrumentUpToDate??'',isBoolean: true),
                                                        // AppListTitle2(title: 'Instrument Number',subTitle: (_mosque.instrumentNumber??'').toString()),
                                                        // AppListTitle2(title: 'Date of Instrument',subTitle: _mosque.instrumentDate??''),
                                                        // AppListTitle2(title: 'General notes about the instrument',subTitle: _mosque.instrumentNotes??''),
                                                        // AppListTitle2(title: 'The entity issuing the instrument',subTitle: _mosque.issuingEntity??''),
                                                        // AppTitle1('Mosque Details',Icons.mosque_outlined),
                                                        // AppListTitle2(title: 'Is there a prayer room for women?',subTitle: _mosque.hasWomenPrayerRoom??'',isBoolean: true),
                                                        //
                                                        //
                                                        //
                                                        //
                                                        //
                                                        //
                                                        //
                                                        // AppTitle1('Maintenance Details',Icons.build),
                                                        // AppListTitle2(title: 'Maintainer',subTitle: _mosque.maintainer??''),
                                                        // AppListTitle2(title: 'Company Name',subTitle: _mosque.companyName??''),
                                                        // AppListTitle2(title: 'Contract Number',subTitle: _mosque.contractNumber??''),
                                                        // AppListTitle2(title: 'Is there a washing machine for the dead?',subTitle: _mosque.hasWashingMachine??'',isBoolean: true),
                                                        // AppListTitle2(title: 'Does the mosque have other facilities?',subTitle: _mosque.hasOtherFacilities??'',isBoolean: true),
                                                        // AppListTitle2(title: 'Mention it',subTitle: _mosque.otherFacilitiesNotes??''),
                                                        // AppListTitle2(title: 'Is there an internal camera?',subTitle: _mosque.hasInternalCamera??'',isBoolean: true),
                                                        // AppListTitle2(title: 'Are there air conditioners?',subTitle: _mosque.hasAirConditioners??'',isBoolean: true),
                                                        // AppListTitle2(title: 'Number of air conditioners in the mosque *',subTitle: (_mosque.numAirConditioners??'').toString()),
                                                        // AppListTitle2(title: 'Air conditioning type *',subTitle: _mosque.acType??''),
                                                        // AppListTitle2(title: 'Are there fire extinguishers?',subTitle: _mosque.hasFireExtinguishers??'',isBoolean: true),
                                                        // AppListTitle2(title: 'Are there pumps for fire systems?',subTitle: _mosque.hasFireSystemPumps??'',isBoolean: true),
                                                        // AppTitle1('Imam Residence Details',Icons.person),
                                                        // AppListTitle2(title: 'Type of residence of the imam',subTitle: _mosque.imamResidenceType??''),
                                                        // AppListTitle2(title: 'The land area for the imam’s residence',subTitle: (_mosque.imamResidenceLandArea??'').toString()),
                                                        // AppListTitle2(title: 'Type of electricity meter for the front residence',subTitle: _mosque.imamElectricityMeterType??''),
                                                        // AppListTitle2(title: 'Electricity meter number for the Imam’s residence',subTitle: _mosque.imamElectricityMeterNumber??''),
                                                        // AppListTitle2(title: 'Type of water meter for the front residence',subTitle: _mosque.imamWaterMeterType??''),
                                                        // AppListTitle2(title: 'Water meter number for the Imam’s residence',subTitle: _mosque.imamWaterMeterNumber??''),
                                                        // AppTitle1('Muezzins Residence Details',Icons.person),
                                                        // AppListTitle2(title: 'Type of residence of the muezzin',subTitle: _mosque.muezzinResidenceType??''),
                                                        // AppListTitle2(title: 'The land area for the muezzin’s residence',subTitle: (_mosque.muezzinResidenceLandArea??'').toString()),
                                                        // AppListTitle2(title: 'Type of electricity meter for the muezzin’s residence',subTitle: _mosque.muezzinElectricityMeterType??''),
                                                        // AppListTitle2(title: 'The electricity meter number for the muezzin’s residence',subTitle: _mosque.muezzinElectricityMeterNumber??''),
                                                        // AppListTitle2(title: 'Type of water meter for the muezzin’s residence',subTitle: _mosque.muezzinWaterMeterType??''),
                                                        // AppListTitle2(title: 'Water meter number for the muezzin’s residence',subTitle: _mosque.muezzinWaterMeterNumber??''),
                                                        // AppTitle1('Mosque Building Details',Icons.build),

                                                        // AppListTitle2(title: 'Authorized by the Ministry?',subTitle: _mosque.ministryAuthorized??'',isBoolean: true),
                                                        // AppTitle1('Facilities Details',Icons.info),
                                                        // AppListTitle2(title: 'Number of men\'s bathrooms',subTitle: (_mosque.numMensBathrooms??'').toString()),
                                                        // AppListTitle2(title: 'Number of bathrooms for women',subTitle: (_mosque.numWomensBathrooms??'').toString()),
                                                        // AppListTitle2(title: 'Number of internal speakers',subTitle: (_mosque.numInternalSpeakers??'').toString()),
                                                        // AppListTitle2(title: 'Number of external speakers',subTitle: (_mosque.numExternalSpeakers??'').toString()),
                                                        // AppListTitle2(title: 'Number of lighting inside the mosque',subTitle: (_mosque.numLightingInside??'').toString()),
                                                        // AppListTitle2(title: 'Number of minarets in the mosque',subTitle: (_mosque.numMinarets??'').toString()),
                                                        // AppListTitle2(title: 'The number of floors',subTitle: (_mosque.numFloors??'').toString()),
                                                        // AppListTitle2(title: 'How big is it?',subTitle: (_mosque.mosqueSize??'').toString()),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        _tabs[_tabController.index].isEditMode?Column(
                                          children: [
                                            Expanded(
                                              child: SingleChildScrollView(
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                                                  child: Form(
                                                    key: _formMosqueInfoKey,
                                                    child: Column(
                                                      children: [
                                                        CustomFormField(title: fields.getField('no_planned').label,value: _mosqueMosqueInfo.noPlanned,
                                                            isRequiredField:requiredFields.contains("no_planned"),
                                                            onChanged:(val) => _mosqueMosqueInfo.noPlanned = val,
                                                            type:FieldType.double),
                                                        CustomFormField(title: fields.getField('piece_number').label,value: _mosqueMosqueInfo.pieceNumber,
                                                            isRequiredField:requiredFields.contains("piece_number"),
                                                            onChanged:(val) => _mosqueMosqueInfo.pieceNumber = val,
                                                            type:FieldType.double),
                                                        CustomFormField(title: fields.getField('national_address').label,value: _mosqueMosqueInfo.nationalAddress,
                                                            isRequiredField:requiredFields.contains("national_address"),
                                                            onChanged:(val) => _mosqueMosqueInfo.nationalAddress = val),

                                                       
                                                        
                                                        
                                                        // CustomFormField(title: fields.getField('mosque_qr_attachment_ids').label,value: _mosqueMosqueInfo.mosqueQrAttachmentIds,
                                                        //     onChanged:(val) => _mosqueMosqueInfo.mosqueQrAttachmentIds = val),

                                                        CustomFormField(title: fields.getField('declaration_note').label,value: _mosqueMosqueInfo.declarationNote,
                                                            isRequiredField:requiredFields.contains("declaration_note"),
                                                            onChanged:(val) => _mosqueMosqueInfo.declarationNote = val,
                                                            type:FieldType.textArea),
                                                        CustomFormField(title: fields.getField('observer_supervisor_comment').label,value: _mosqueMosqueInfo.observerSupervisorComment,
                                                            isRequiredField:requiredFields.contains("observer_supervisor_comment"),
                                                            onChanged:(val) => _mosqueMosqueInfo.observerSupervisorComment = val,
                                                            type:FieldType.textArea),


                                                        // CustomFormField(title: fields.getField('visit_notes').label,value: _mosqueMosqueInfo.visitNotes,
                                                        //     onChanged:(val) => _mosqueMosqueInfo.visitNotes = val,
                                                        //     ),
                                                        CustomFormField(title: fields.getField('observer_commit').label,value: _mosqueMosqueInfo.observerCommit,
                                                            isRequiredField:requiredFields.contains("observer_commit"),
                                                            onChanged:(val) {
                                                              _mosqueMosqueInfo.observerCommit = val;
                                                                  //setState({});
                                                              setState(() {

                                                              });
                                                              },
                                                            type:FieldType.boolean),
                                                        CustomFormField(title: fields.getField('honor_name').label,value: _mosqueMosqueInfo.honorName,
                                                            isRequiredField:requiredFields.contains("honor_name"),
                                                            onChanged:(val) => _mosqueMosqueInfo.honorName = val),
                                                        


                                                        CustomFormField(title: fields.getField('image').label,
                                                            isRequiredField:requiredFields.contains("image"),
                                                            value: _mosqueMosqueInfo.image==null?'':'${userProvider.baseUrl}/web/image?model=mosque.mosque&id=${_mosque.id}&field=image&unique=${_mosque.uniqueId}',
                                                            onChanged:(val) {
                                                              _mosqueMosqueInfo.image = val;
                                                              setState(() {

                                                              });
                                                              },type: FieldType.image,
                                                            headersMap: _mosqueService!.headersMap
                                                            ),


                                                        CustomFormField(title: fields.getField('outer_image').label,
                                                            isRequiredField:requiredFields.contains("outer_image"),
                                                            value: _mosqueMosqueInfo.outerImage==null?'':'${userProvider.baseUrl}/web/image?model=mosque.mosque&id=${_mosque.id}&field=outer_image&unique=${_mosque.uniqueId}',
                                                          onChanged:(val) {
                                                            _mosqueMosqueInfo
                                                                .outerImage =
                                                                val;
                                                            setState(() {

                                                            });
                                                          },type: FieldType.image
                                                            ,headersMap: _mosqueService==null?'':_mosqueService!.headersMap),


                                                        // AppListTitle2(title: fields.getField('image').label,
                                                        //     subTitle: '${Config.baseUrl}/web/image?model=mosque.mosque&id=${_mosque.id}&field=image&unique=${_mosque.uniqueId}'
                                                        //     ,type:ListType.image,headersMap: _mosqueService==null?'':_mosqueService!.headersMap),

                                                        // CustomFormField(title: fields.getField('mosque_edit_request_number').label,value: _mosqueMosqueInfo.mosqueEditRequestNumber,
                                                        //     isRequiredField:requiredFields.contains("mosque_edit_request_number"),
                                                        //     onChanged:(val) => _mosqueMosqueInfo.mosqueEditRequestNumber = val,
                                                        //     type:FieldType.number),





                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),

                                            ),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: PrimaryButton(text: "update".tr(),onTab:(){
                                                    updateMosqueInfo(_tabController.index);
                                                   

                                                  }),
                                                ),
                                                Expanded(
                                                  child: SecondaryButton(text: "cancel".tr(),onTab:(){
                                                    _tabs[_tabController.index].isEditMode=false;
                                                    setState(() {

                                                    });
                                                 
                                                  }),
                                                ),
                                              ],
                                            )
                                          ],
                                        ):Column(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                child: SingleChildScrollView(
                                                  child: Container(
                                                    padding: EdgeInsets.symmetric(horizontal: 15,vertical: 5),
                                                    child: Column(
                                                      children: [
                                                        AppListTitle2(title: fields.getField('no_planned').label,isRequired:requiredFields.contains("no_planned"),subTitle: (_mosque.noPlanned??"").toString()),
                                                        AppListTitle2(title: fields.getField('piece_number').label,isRequired:requiredFields.contains("piece_number"),subTitle: _mosque.pieceNumber.toString()),
                                                        AppListTitle2(title: fields.getField('national_address').label,isRequired:requiredFields.contains("national_address"),subTitle: _mosque.nationalAddress??""),
                                                        // ,
                                                        //
                                                        AppListTitle2(title: fields.getField('declaration_note').label,isRequired:requiredFields.contains("declaration_note"),subTitle: _mosque.declarationNote??""),
                                                        AppListTitle2(title: fields.getField('observer_supervisor_comment').label,isRequired:requiredFields.contains("observer_supervisor_comment"),subTitle: _mosque.observerSupervisorComment??""),

                                                        // AppListTitle2(title: fields.getField('mosque_qr_attachment_ids').label,subTitle: _mosque.mosqueQrAttachmentIds??""),
                                                        // AppListTitle2(title: fields.getField('qr_panel_numbers').label,subTitle: _mosque.qrPanelNumbers??""),
                                                        // AppListTitle2(title: fields.getField('visit_notes').label,subTitle: _mosque.visitNotes??""),
                                                        AppListTitle2(title: fields.getField('observer_commit').label,isRequired:requiredFields.contains("observer_commit"),subTitle: _mosque.observerCommit,isBoolean: true),

                                                        AppListTitle2(title: fields.getField('honor_name').label,isRequired:requiredFields.contains("honor_name"),subTitle: _mosque.honorName??""),


                                                        AppListTitle2(title: fields.getField('image').label,isRequired:requiredFields.contains("image"),
                                                            subTitle: '${userProvider.baseUrl}/web/image?model=mosque.mosque&id=${_mosque.id}&field=image&unique=${_mosque.uniqueId}'
                                                            ,type:ListType.image,headersMap: _mosqueService==null?'':_mosqueService!.headersMap,
                                                             onTab:(){
                                                            
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder: (context) => FullScreenImagePage(
                                                                      title :fields.getField('image').label,
                                                                      imageUrl: '${userProvider.baseUrl}/web/image?model=mosque.mosque&id=${_mosque.id}&field=image&unique=${_mosque.uniqueId}',
                                                                    ),
                                                                  ),
                                                                );
                                                            }
                                                        ),
                                                        AppListTitle2(title: fields.getField('outer_image').label,isRequired:requiredFields.contains("outer_image"),
                                                            subTitle: '${userProvider.baseUrl}/web/image?model=mosque.mosque&field=outer_image&id=${_mosque.id}&unique=${_mosque.uniqueId}'
                                                            ,type:ListType.image,headersMap: _mosqueService==null?'':_mosqueService!.headersMap,
                                                            onTab:(){
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder: (context) => FullScreenImagePage(
                                                                    title :fields.getField('outer_image').label,
                                                                    imageUrl: '${userProvider.baseUrl}/web/image?model=mosque.mosque&field=outer_image&id=${_mosque.id}&unique=${_mosque.uniqueId}',
                                                                  ),
                                                                ),
                                                              );
                                                            }
                                                            ),


                                                        // AppListTitle2(title: fields.getField('mosque_edit_request_number').label,isRequired:requiredFields.contains("mosque_edit_request_number"),subTitle: _mosque.mosqueEditRequestNumber??""),


                                                        // AppTitle1('Instrument Details',Icons.perm_device_information),

                                                        // AppTitle1('Mosque Details',Icons.mosque_outlined),
                                                        // AppListTitle2(title: 'Is there a prayer room for women?',subTitle: _mosque.hasWomenPrayerRoom??'',isBoolean: true),
                                                        // AppListTitle2(title: 'Mosque Land Area',subTitle: (_mosque.mosqueLandArea??'').toString()),
                                                        // AppListTitle2(title: 'Roofed Area',subTitle: (_mosque.roofedArea??'').toString()),
                                                        // AppListTitle2(title: 'Urban condition of the mosque',subTitle: _mosque.urbanCondition??''),
                                                        // AppListTitle2(title: 'The mosque\'s carrying capacity of worshippers',subTitle: (_mosque.carryingCapacity??'').toString()),
                                                        // AppListTitle2(title: 'Number of rows of worshipers during Friday prayers',subTitle: (_mosque.fridayPrayerRows??'').toString()),
                                                        // AppListTitle2(title: 'Is there a QR Code panel?',subTitle: _mosque.hasQrCodePanel??'',isBoolean: true),
                                                        // AppListTitle2(title: 'Notes on QR code',subTitle: _mosque.qrCodeNotes??''),
                                                        // AppListTitle2(title: 'Is the plate legible?',subTitle: _mosque.plateLegible??'',isBoolean: true),
                                                        // AppListTitle2(title: 'Is the code readable?',subTitle: _mosque.codeReadable??'',isBoolean: true),
                                                        // AppListTitle2(title: 'Is the mosque data correct?',subTitle: _mosque.mosqueDataCorrect??'',isBoolean: true),
                                                        // AppListTitle2(title: 'Does the name of the mosque match the QR Code sign?',subTitle: _mosque.qrCodeMatch??'',isBoolean: true),
                                                        // AppListTitle2(title: 'Number of QR Code panels',subTitle: (_mosque.numQrCodePanels??'').toString()),
                                                        // AppListTitle2(title: 'Is there an electricity meter *',subTitle: _mosque.hasElectricityMeter??'',isBoolean: true),
                                                        // AppListTitle2(title: 'Is there a water meter *',subTitle: _mosque.hasWaterMeter??'',isBoolean: true),
                                                        // AppTitle1('Maintenance Details',Icons.build),
                                                        // AppListTitle2(title: 'Maintainer',subTitle: _mosque.maintainer??''),
                                                        // AppListTitle2(title: 'Company Name',subTitle: _mosque.companyName??''),
                                                        // AppListTitle2(title: 'Contract Number',subTitle: _mosque.contractNumber??''),
                                                        // AppListTitle2(title: 'Is there a washing machine for the dead?',subTitle: _mosque.hasWashingMachine??'',isBoolean: true),
                                                        // AppListTitle2(title: 'Does the mosque have other facilities?',subTitle: _mosque.hasOtherFacilities??'',isBoolean: true),
                                                        // AppListTitle2(title: 'Mention it',subTitle: _mosque.otherFacilitiesNotes??''),
                                                        // AppListTitle2(title: 'Is there an internal camera?',subTitle: _mosque.hasInternalCamera??'',isBoolean: true),
                                                        // AppListTitle2(title: 'Are there air conditioners?',subTitle: _mosque.hasAirConditioners??'',isBoolean: true),
                                                        // AppListTitle2(title: 'Number of air conditioners in the mosque *',subTitle: (_mosque.numAirConditioners??'').toString()),
                                                        // AppListTitle2(title: 'Air conditioning type *',subTitle: _mosque.acType??''),
                                                        // AppListTitle2(title: 'Are there fire extinguishers?',subTitle: _mosque.hasFireExtinguishers??'',isBoolean: true),
                                                        // AppListTitle2(title: 'Are there pumps for fire systems?',subTitle: _mosque.hasFireSystemPumps??'',isBoolean: true),
                                                        // AppTitle1('Imam Residence Details',Icons.person),
                                                        // AppListTitle2(title: 'Type of residence of the imam',subTitle: _mosque.imamResidenceType??''),
                                                        // AppListTitle2(title: 'The land area for the imam’s residence',subTitle: (_mosque.imamResidenceLandArea??'').toString()),
                                                        // AppListTitle2(title: 'Type of electricity meter for the front residence',subTitle: _mosque.imamElectricityMeterType??''),
                                                        // AppListTitle2(title: 'Electricity meter number for the Imam’s residence',subTitle: _mosque.imamElectricityMeterNumber??''),
                                                        // AppListTitle2(title: 'Type of water meter for the front residence',subTitle: _mosque.imamWaterMeterType??''),
                                                        // AppListTitle2(title: 'Water meter number for the Imam’s residence',subTitle: _mosque.imamWaterMeterNumber??''),
                                                        // AppTitle1('Muezzins Residence Details',Icons.person),
                                                        // AppListTitle2(title: 'Type of residence of the muezzin',subTitle: _mosque.muezzinResidenceType??''),
                                                        // AppListTitle2(title: 'The land area for the muezzin’s residence',subTitle: (_mosque.muezzinResidenceLandArea??'').toString()),
                                                        // AppListTitle2(title: 'Type of electricity meter for the muezzin’s residence',subTitle: _mosque.muezzinElectricityMeterType??''),
                                                        // AppListTitle2(title: 'The electricity meter number for the muezzin’s residence',subTitle: _mosque.muezzinElectricityMeterNumber??''),
                                                        // AppListTitle2(title: 'Type of water meter for the muezzin’s residence',subTitle: _mosque.muezzinWaterMeterType??''),
                                                        // AppListTitle2(title: 'Water meter number for the muezzin’s residence',subTitle: _mosque.muezzinWaterMeterNumber??''),
                                                        // AppTitle1('Mosque Building Details',Icons.build),
                                                        // AppListTitle2(title: 'Is the endowment on the mosque’s land?',subTitle: _mosque.endowmentOnLand??'',isBoolean: true),
                                                        // AppListTitle2(title: 'Is there a basement?',subTitle: _mosque.hasBasement??'',isBoolean: true),
                                                        // AppListTitle2(title: 'Building material',subTitle: _mosque.buildingMaterial??''),
                                                        // AppListTitle2(title: 'Building occupancy rate',subTitle: (_mosque.occupancyRate??'').toString()),
                                                        // AppListTitle2(title: 'Are there buildings built on the mosque land?',subTitle: _mosque.buildingsOnLand??'',isBoolean: true),
                                                        // AppListTitle2(title: 'Recall notes',subTitle: _mosque.recallNotes??''),
                                                        // AppListTitle2(title: 'Authorized by the Ministry?',subTitle: _mosque.ministryAuthorized??'',isBoolean: true),
                                                        // AppTitle1('Facilities Details',Icons.info),
                                                        // AppListTitle2(title: 'Number of men\'s bathrooms',subTitle: (_mosque.numMensBathrooms??'').toString()),
                                                        // AppListTitle2(title: 'Number of bathrooms for women',subTitle: (_mosque.numWomensBathrooms??'').toString()),
                                                        // AppListTitle2(title: 'Number of internal speakers',subTitle: (_mosque.numInternalSpeakers??'').toString()),
                                                        // AppListTitle2(title: 'Number of external speakers',subTitle: (_mosque.numExternalSpeakers??'').toString()),
                                                        // AppListTitle2(title: 'Number of lighting inside the mosque',subTitle: (_mosque.numLightingInside??'').toString()),
                                                        // AppListTitle2(title: 'Number of minarets in the mosque',subTitle: (_mosque.numMinarets??'').toString()),
                                                        // AppListTitle2(title: 'The number of floors',subTitle: (_mosque.numFloors??'').toString()),
                                                        // AppListTitle2(title: 'How big is it?',subTitle: (_mosque.mosqueSize??'').toString()),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            _tabs[_tabController.index].isEditMode?Row(
                                              children: [
                                                Expanded(
                                                  child: PrimaryButton(text: "save".tr(),onTab:(){
                                               

                                                  }),
                                                ),
                                                Expanded(
                                                  child: SecondaryButton(text: "cancel".tr(),onTab:(){
                                                    _tabs[_tabController.index].isEditMode=false;
                                                    setState(() {

                                                    });
                                                  
                                                  }),
                                                ),
                                              ],
                                            ):Container()
                                          ],
                                        ),
                                        //#region Mosque Maintainanace Details
                                        _tabs[_tabController.index].isEditMode?Column(
                                          children: [
                                            Expanded(
                                              child: SingleChildScrollView(
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                                                  child: Form(
                                                    key: _formMaintenanceKey,
                                                    child: Column(
                                                      children: [
                                                        AppTitle1('maintenance_details'.tr(),Icons.info),

                                                        CustomFormField(title:  fields.getField('maintainer').label,value: _mosqueMaintenanceDetail.maintainer,
                                                            isRequiredField:requiredFields.contains("maintainer"),
                                                            onChanged:(val){
                                                              _mosqueMaintenanceDetail.maintainer = val;
                                                         
                                                              setState(() {});
                                                            }),
                                                        CustomFormField(title:  fields.getField('company_name').label,value: _mosqueMaintenanceDetail.companyName,
                                                            isRequiredField:requiredFields.contains("company_name"),
                                                            onChanged:(val){
                                                              _mosqueMaintenanceDetail.companyName = val;
                                                      
                                                              setState(() {});
                                                            }),
                                                        CustomFormField(title:  fields.getField('contract_number').label,value: _mosqueMaintenanceDetail.contractNumber,
                                                            isRequiredField:requiredFields.contains("contract_number"),
                                                            onChanged:(val){
                                                              _mosqueMaintenanceDetail.contractNumber = val;
                                                          
                                                              setState(() {});
                                                            }),
                                                        CustomFormField(title:  fields.getField('has_washing_machine').label,value: _mosqueMaintenanceDetail.hasWashingMachine,
                                                            isRequiredField:requiredFields.contains("has_washing_machine"),
                                                            onChanged:(val){
                                                              _mosqueMaintenanceDetail.hasWashingMachine = val;
                                                        
                                                              setState(() {});
                                                            },type:FieldType.choice,options:fields.getComboList('has_washing_machine')),
                                                        CustomFormField(title:  fields.getField('has_other_facilities').label,value: _mosqueMaintenanceDetail.hasOtherFacilities,
                                                            isRequiredField:requiredFields.contains("has_other_facilities"),
                                                            onChanged:(val){
                                                              _mosqueMaintenanceDetail.hasOtherFacilities = val;
                                                            
                                                              setState(() {});
                                                            },type:FieldType.choice,options:fields.getComboList('has_other_facilities')),
                                                        CustomFormField(title:  fields.getField('other_facilities_notes').label,value: _mosqueMaintenanceDetail.otherFacilitiesNotes,
                                                            isRequiredField:requiredFields.contains("other_facilities_notes"),
                                                            onChanged:(val){
                                                              _mosqueMaintenanceDetail.otherFacilitiesNotes = val;
                                                           
                                                              setState(() {});
                                                            },type:FieldType.textArea),
                                                        CustomFormField(title:  fields.getField('has_internal_camera').label,value: _mosqueMaintenanceDetail.hasInternalCamera,
                                                            isRequiredField:requiredFields.contains("has_internal_camera"),
                                                            onChanged:(val){
                                                              _mosqueMaintenanceDetail.hasInternalCamera = val;
                                                         
                                                              setState(() {});
                                                            },type:FieldType.choice,options:fields.getComboList('has_internal_camera')),
                                                        CustomFormField(title:  fields.getField('has_air_conditioners').label,value: _mosqueMaintenanceDetail.hasAirConditioners,
                                                            isRequiredField:requiredFields.contains("has_air_conditioners"),
                                                            onChanged:(val){
                                                              _mosqueMaintenanceDetail.hasAirConditioners = val;
                                                       
                                                              setState(() {});
                                                            },type:FieldType.choice,options:fields.getComboList('has_air_conditioners')),
                                                        _mosqueMaintenanceDetail.hasAirConditioners=='yes'?Column(
                                                          children: [

                                                            CustomFormField(title:  fields.getField('num_air_conditioners').label,value: _mosqueMaintenanceDetail.numAirConditioners,
                                                                isRequiredField:requiredFields.contains("num_air_conditioners"),
                                                                onChanged:(val){
                                                                  _mosqueMaintenanceDetail.numAirConditioners = val;
                                                               
                                                                },type:FieldType.double),

                                                            CustomFormField(title:  fields.getField('ac_type').label,value: _mosqueMaintenanceDetail.acType,
                                                                isRequiredField:requiredFields.contains("ac_type"),
                                                                onChanged:(val){
                                                                  _mosqueMaintenanceDetail.acType = val;
                                                                
                                                                  setState(() {});
                                                                },type:FieldType.selection,options:fields.getComboList('ac_type')),


                                                          ],
                                                        ):Container(),

                                                        CustomFormField(title:  fields.getField('has_fire_extinguishers').label,value: _mosqueMaintenanceDetail.hasFireExtinguishers,
                                                            isRequiredField:requiredFields.contains("has_fire_extinguishers"),
                                                            onChanged:(val){
                                                              _mosqueMaintenanceDetail.hasFireExtinguishers = val;
                                                           
                                                              setState(() {});
                                                            },type:FieldType.choice,options:fields.getComboList('has_fire_extinguishers')),
                                                        CustomFormField(title:  fields.getField('has_fire_system_pumps').label,value: _mosqueMaintenanceDetail.hasFireSystemPumps,
                                                            isRequiredField:requiredFields.contains("has_fire_system_pumps"),
                                                            onChanged:(val){
                                                              _mosqueMaintenanceDetail.hasFireSystemPumps = val;
                                                        
                                                              setState(() {});
                                                            },type:FieldType.choice,options:fields.getComboList('has_fire_system_pumps')),
                                                        CustomFormField(title:  fields.getField('maintenance_responsible').label,value: _mosqueMaintenanceDetail.maintenanceResponsible,
                                                            isRequiredField:requiredFields.contains("maintenance_responsible"),
                                                            onChanged:(val){
                                                              _mosqueMaintenanceDetail.maintenanceResponsible = val;
                                                           
                                                              setState(() {});
                                                            },type:FieldType.selection,options:fields.getComboList('maintenance_responsible')),

                                                        _mosqueMaintenanceDetail.maintenanceResponsible!='Ministry'?
                                                        CustomFormField(title:  fields.getField('maintenance_person').label,value: _mosqueMaintenanceDetail.maintenancePerson,
                                                            isRequiredField:requiredFields.contains("maintenance_person"),
                                                            onChanged:(val){
                                                              _mosqueMaintenanceDetail.maintenancePerson = val;
                                                          
                                                              setState(() {});
                                                            }):Container(),
                                                        // AppTitle1('instrument_details'.tr(),Icons.info),
                                                        //
                                                        // CustomFormField(title:  fields.getField('has_deed').label,value: _mosqueMaintenanceDetail.hasDeed,
                                                        //     isRequiredField:requiredFields.contains("has_deed"),
                                                        //     onChanged:(val){
                                                        //       _mosqueMaintenanceDetail.hasDeed = val;
                                                        // 
                                                        //       setState(() {});
                                                        //     },type:FieldType.choice,options:fields.getComboList('has_deed')),
                                                        // CustomFormField(title:  fields.getField('is_electronic_instrument').label,value: _mosqueMaintenanceDetail.isElectronicInstrument,
                                                        //     isRequiredField:requiredFields.contains("is_electronic_instrument"),
                                                        //     onChanged:(val){
                                                        //       _mosqueMaintenanceDetail.isElectronicInstrument = val;
                                                        //  
                                                        //       setState(() {});
                                                        //     },type:FieldType.choice,options:fields.getComboList('is_electronic_instrument')),
                                                        //
                                                        // _mosqueMaintenanceDetail.isElectronicInstrument=='yes'?Column(
                                                        //
                                                        //   children: [
                                                        //     CustomFormField(title:  fields.getField('electronic_instrument_up_to_date').label,value: _mosqueMaintenanceDetail.electronicInstrumentUpToDate,
                                                        //         isRequiredField:requiredFields.contains("electronic_instrument_up_to_date"),
                                                        //         onChanged:(val){
                                                        //           _mosqueMaintenanceDetail.electronicInstrumentUpToDate = val;
                                                        //       
                                                        //           setState(() {});
                                                        //         },type:FieldType.choice,options:fields.getComboList('electronic_instrument_up_to_date')),
                                                        //
                                                        // CustomFormField(title:  fields.getField('instrument_number').label,value: _mosqueMaintenanceDetail.instrumentNumber,
                                                        //     isRequiredField:requiredFields.contains("instrument_number"),
                                                        //     onChanged:(val){
                                                        //       _mosqueMaintenanceDetail.instrumentNumber = val;
                                                        //    
                                                        //     },type:FieldType.double),
                                                        // CustomFormField(title:  fields.getField('instrument_date').label,value: _mosqueMaintenanceDetail.instrumentDate,
                                                        //     isRequiredField:requiredFields.contains("instrument_date"),
                                                        //     onChanged:(val){
                                                        //       _mosqueMaintenanceDetail.instrumentDate = val;
                                                        //    
                                                        //       setState(() {});
                                                        //     },type:FieldType.date),
                                                        // CustomFormField(title:  fields.getField('instrument_notes').label,value: _mosqueMaintenanceDetail.instrumentNotes,
                                                        //     isRequiredField:requiredFields.contains("instrument_notes"),
                                                        //     onChanged:(val){
                                                        //       _mosqueMaintenanceDetail.instrumentNotes = val;
                                                        //   
                                                        //       setState(() {});
                                                        //     },type:FieldType.textArea),
                                                        // // CustomFormField(title:  fields.getField('issuing_entity').label,value: _mosqueMaintenanceDetail.issuingEntity,
                                                        // //     isRequiredField:requiredFields.contains("issuing_entity"),
                                                        // //     onChanged:(val){
                                                        // //       _mosqueMaintenanceDetail.issuingEntity = val;
                                                        // //
                                                        // //       setState(() {});
                                                        // //     }),
                                                        // CustomFormField(title:  fields.getField('old_instrument_date').label,value: _mosqueMaintenanceDetail.oldInstrumentDate,
                                                        //     isRequiredField:requiredFields.contains("old_instrument_date"),
                                                        //     onChanged:(val){
                                                        //       _mosqueMaintenanceDetail.oldInstrumentDate = val;
                                                        //
                                                        //       setState(() {});
                                                        //     },type:FieldType.date),
                                                        //
                                                        //     MultipleAttachmentField(title: fields.getField('instrument_attachment_ids').label,isRequired:requiredFields.contains("instrument_attachment_ids"),data: _tempInstrumentAttachments,
                                                        //       headerMap: _mosqueService==null?'':_mosqueService!.headersMap,isEditMode: true,userService: _userService,
                                                        //       onTab: (Attachment value){
                                                        //         _tempInstrumentAttachments.add(value);
                                                       
                                                        //         setState((){});
                                                        //       },
                                                        //       onDelete:(Attachment value){
                                                        //         setState(() {
                                                        //           _tempInstrumentAttachments.remove(value);
                                                        //         });
                                                        //         setState((){});
                                                        //       },
                                                        //     ),
                                                        //     CustomFormField(title: fields.getField('instrument_entity_id').label,onTab: (){
                                                        //       showInstrumentModal();
                                                        //     },
                                                        //         isRequiredField:requiredFields.contains("instrument_entity_id"),
                                                        //         value: _mosqueMaintenanceDetail.instrumentEntity,isReadonly:true,isSelection:true),
                                                        //    
                                                        //   ],
                                                        // ):Container(),
                                                        //
                                                        //





                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),

                                            ),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: PrimaryButton(text: "update".tr(),onTab:(){
                                                    updateMaintenanceDetail(_tabController.index);
                                              

                                                  }),
                                                ),
                                                Expanded(
                                                  child: SecondaryButton(text: "cancel".tr(),onTab:(){
                                                    _tabs[_tabController.index].isEditMode=false;
                                                    setState(() {

                                                    });
                                                  
                                                  }),
                                                ),
                                              ],
                                            )
                                          ],
                                        ):SingleChildScrollView(
                                            child: Container(

                                                padding: EdgeInsets.symmetric(horizontal: 15,vertical: 5),
                                                child: Column(
                                                  children: [
                                                    AppTitle1('maintenance_details'.tr(),Icons.info),
                                                    // AppListTitle2(title: fields.getField('endowment_on_land').label,subTitle: _mosque.endowmentOnLand??'',
                                                    //     isTag: true,selection:fields.getComboList('endowment_on_land')),
                                                      AppListTitle2(title: fields.getField('maintainer').label,isRequired:requiredFields.contains("maintainer"),subTitle: _mosque.maintainer??''),
                                                    AppListTitle2(title: fields.getField('company_name').label,isRequired:requiredFields.contains("company_name"),subTitle: _mosque.companyName??''),
                                                    AppListTitle2(title: fields.getField('contract_number').label,isRequired:requiredFields.contains("contract_number"),subTitle: _mosque.contractNumber??''),
                                                    AppListTitle2(title: fields.getField('has_washing_machine').label,isRequired:requiredFields.contains("has_washing_machine"),subTitle: _mosque.hasWashingMachine??'',
                                                        isTag: true,selection:fields.getComboList('has_washing_machine')),
                                                    AppListTitle2(title: fields.getField('has_other_facilities').label,isRequired:requiredFields.contains("has_other_facilities"),subTitle: _mosque.hasOtherFacilities??'',
                                                        isTag: true,selection:fields.getComboList('has_other_facilities')),
                                                    AppListTitle2(title: fields.getField('other_facilities_notes').label,isRequired:requiredFields.contains("other_facilities_notes"),subTitle: _mosque.otherFacilitiesNotes??''),
                                                    AppListTitle2(title: fields.getField('has_internal_camera').label,isRequired:requiredFields.contains("has_internal_camera"),subTitle: _mosque.hasInternalCamera??'',
                                                        isTag: true,selection:fields.getComboList('has_internal_camera')),
                                                    AppListTitle2(title: fields.getField('has_air_conditioners').label,isRequired:requiredFields.contains("has_air_conditioners"),subTitle: _mosque.hasAirConditioners??'',
                                                        isTag: true,selection:fields.getComboList('has_air_conditioners')),

                                                    _mosque.hasAirConditioners=='yes'?Column(
                                                      children: [
                                                        AppListTitle2(title: fields.getField('num_air_conditioners').label,isRequired:requiredFields.contains("num_air_conditioners"),subTitle: (_mosque.numAirConditioners??'').toString()),
                                                        AppListTitle2(title: fields.getField('ac_type').label,isRequired:requiredFields.contains("ac_type"),subTitle: _mosque.acType??'',
                                                            selection:fields.getComboList('ac_type')),
                                                      ],
                                                    ):Container(),


                                                    AppListTitle2(title: fields.getField('has_fire_extinguishers').label,isRequired:requiredFields.contains("has_fire_extinguishers"),subTitle: _mosque.hasFireExtinguishers??'',
                                                        isTag: true,selection:fields.getComboList('has_fire_extinguishers')),
                                                    AppListTitle2(title: fields.getField('has_fire_system_pumps').label,isRequired:requiredFields.contains("has_fire_system_pumps"),subTitle: _mosque.hasFireSystemPumps??'',
                                                        isTag: true,selection:fields.getComboList('has_fire_system_pumps')),
                                                    AppListTitle2(title: fields.getField('maintenance_responsible').label,isRequired:requiredFields.contains("maintenance_responsible"),subTitle: _mosque.maintenanceResponsible??'',
                                                       selection:fields.getComboList('maintenance_responsible')),
                                                    _mosqueMaintenanceDetail.maintenanceResponsible!='Ministry'?AppListTitle2(title: fields.getField('maintenance_person').label,isRequired:requiredFields.contains("maintenance_person"),subTitle: _mosque.maintenancePerson??''):Container(),
                                                    // AppTitle1('instrument_details'.tr(),Icons.info),
                                                    //  AppListTitle2(title: fields.getField('has_deed').label,isRequired:requiredFields.contains("has_deed"),subTitle: _mosque.hasDeed??'',
                                                    //      isTag: true,selection:fields.getComboList('has_deed')),
                                                    // AppListTitle2(title: fields.getField('is_electronic_instrument').label,isRequired:requiredFields.contains("is_electronic_instrument"),subTitle: _mosque.isElectronicInstrument??'',
                                                    //     isTag: true,selection:fields.getComboList('is_electronic_instrument')),
                                                    //
                                                    // _mosque.isElectronicInstrument=='yes'?Column(
                                                    //   children: [
                                                    //     AppListTitle2(title: fields.getField('electronic_instrument_up_to_date').label,isRequired:requiredFields.contains("electronic_instrument_up_to_date"),subTitle: _mosque.electronicInstrumentUpToDate??'',
                                                    //         isTag: true,selection:fields.getComboList('electronic_instrument_up_to_date')),
                                                    //     AppListTitle2(title: fields.getField('instrument_number').label,isRequired:requiredFields.contains("instrument_number"),subTitle: (_mosque.instrumentNumber??'').toString()),
                                                    //     AppListTitle2(title: fields.getField('instrument_date').label,isRequired:requiredFields.contains("instrument_date"),subTitle: _mosque.instrumentDate??'',isDate:true),
                                                    //     AppListTitle2(title: fields.getField('instrument_notes').label,isRequired:requiredFields.contains("instrument_notes"),subTitle: _mosque.instrumentNotes??''),
                                                    //    // AppListTitle2(title: fields.getField('issuing_entity').label,isRequired:requiredFields.contains("issuing_entity"),subTitle: _mosque.issuingEntity??''),
                                                    //
                                                    //     AppListTitle2(title: fields.getField('old_instrument_date').label,isRequired:requiredFields.contains("old_instrument_date"),subTitle: _mosque.oldInstrumentDate??'',isDate:true),
                                                    //
                                                    //     MultipleAttachmentField(title: fields.getField('instrument_attachment_ids').label,isRequired:requiredFields.contains("instrument_attachment_ids"),data: _instrumentAttachments,
                                                    //       headerMap: _mosqueService==null?'':_mosqueService!.headersMap,
                                                    //     ),
                                                    //     // AppListTitle2(title: fields.getField('instrument_attachment_ids').label,isRequired:requiredFields.contains("instrument_attachment_ids"),subTitle: _mosque.instrumentAttachmentIds??''),
                                                    //     AppListTitle2(title: fields.getField('instrument_entity_id').label,isRequired:requiredFields.contains("instrument_entity_id"),subTitle: _mosque.instrumentEntity??''),
                                                    //   ],
                                                    // ):Container(),
                                                    //
                                                    //
                                                  ],
                                                )
                                            )),
                                        //#region Mosque Building Details
                                        _tabs[_tabController.index].isEditMode?Column(
                                          children: [
                                            Expanded(
                                              child: SingleChildScrollView(
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                                                  child: Form(
                                                    key: _formBuildingKey,
                                                    child: Column(
                                                      children: [



                                                        CustomFormField(title:  fields.getField('has_basement').label,value: _mosqueBuildingDetail.hasBasement,
                                                            isRequiredField:requiredFields.contains("has_basement"),
                                                            onChanged:(val){
                                                              _mosqueBuildingDetail.hasBasement = val;
                                                       
                                                              setState(() {});
                                                            },type:FieldType.choice,options:fields.getComboList('has_basement')),


                                                        CustomFormField(title:  fields.getField('building_material').label,value: _mosqueBuildingDetail.buildingMaterial,
                                                            isRequiredField:requiredFields.contains("building_material"),
                                                            onChanged:(val){
                                                              _mosqueBuildingDetail.buildingMaterial = val;
                                                          
                                                              setState(() {});
                                                            },type:FieldType.selection,options:fields.getComboList('building_material')),

                                                        CustomFormField(title: fields.getField('building_area').label,value: _mosqueBuildingDetail.buildingArea,onChanged:(val) => _mosqueBuildingDetail.buildingArea = val,
                                                          isRequiredField:requiredFields.contains("building_area"),
                                                          type: FieldType.double,
                                                        ),

                                                        CustomFormField(title:  fields.getField('building_status').label,value: _mosqueBuildingDetail.buildingStatus,
                                                            isRequiredField:requiredFields.contains("building_status"),
                                                            onChanged:(val){
                                                              _mosqueBuildingDetail.buildingStatus = val;
                                                      
                                                              setState(() {});
                                                            },type:FieldType.choice,options:fields.getComboList('building_status'),isScroll:true),

                                                        CustomFormField(title:  fields.getField('occupancy_rate').label,value: _mosqueBuildingDetail.occupancyRate,
                                                          isRequiredField:requiredFields.contains("occupancy_rate"),
                                                            onChanged:(val){
                                                              _mosqueBuildingDetail.occupancyRate = val;
                                                         
                                                            },type:FieldType.double,),

                                                        CustomFormField(title:  fields.getField('buildings_on_land').label,value: _mosqueBuildingDetail.buildingsOnLand,
                                                            isRequiredField:requiredFields.contains("buildings_on_land"),
                                                            onChanged:(val){
                                                              _mosqueBuildingDetail.buildingsOnLand = val;
                                                      
                                                              setState(() {});
                                                            },type:FieldType.choice,options:fields.getComboList('buildings_on_land')),

                                                        CustomFormField(title:  fields.getField('recall_notes').label,value: _mosqueBuildingDetail.recallNotes,
                                                            isRequiredField:requiredFields.contains("recall_notes"),
                                                            onChanged:(val){
                                                              _mosqueBuildingDetail.recallNotes = val;
                                                   
                                                              setState(() {});
                                                            },type:FieldType.textArea),

                                                        CustomFormField(title:  fields.getField('endowment_on_land').label,value: _mosqueBuildingDetail.endowmentOnLand,
                                                            isRequiredField:requiredFields.contains("endowment_on_land"),
                                                            onChanged:(val){
                                                              _mosqueBuildingDetail.endowmentOnLand = val;

                                                              setState(() {});
                                                            },type:FieldType.choice,options:fields.getComboList('endowment_on_land')),

                                                            _mosqueBuildingDetail.endowmentOnLand=='yes'?CustomFormField(title:  fields.getField('endowment_type').label,value: _mosqueBuildingDetail.endowmentType,
                                                            isRequiredField:requiredFields.contains("endowment_type"),
                                                            onChanged:(val){
                                                              _mosqueBuildingDetail.endowmentType = val;

                                                              setState(() {});
                                                            },type:FieldType.choice,options:fields.getComboList('endowment_type')):Container(),
                                                        
CustomFormField(title:  fields.getField('is_there_structure_buildings').label,value: _mosqueBuildingDetail.isThereStructureBuildings,
                                                            isRequiredField:requiredFields.contains("is_there_structure_buildings"),
                                                            onChanged:(val){
                                                              _mosqueBuildingDetail.isThereStructureBuildings = val;

                                                              setState(() {});
                                                            },type:FieldType.choice,options:fields.getComboList('is_there_structure_buildings')),

                                                        _mosqueBuildingDetail.isThereStructureBuildings=='yes'?Column(
                                                          children: [
                                                            CustomFormField(title: fields.getField('building_type_ids').label,
                                                              onTab: (){

                                                                showBuildingModal();

                                                              },value: _mosqueBuildingDetail.buildingTypeIds??[],
                                                              options: this.buildingTypeIds,isReadonly:true,isSelection:true,type: FieldType.multiSelect,
                                                              builder:(ComboItem value){
                                                                return MultiTag(title:value.value??"",onTab: (){
                                                                  _mosqueBuildingDetail.buildingTypeIds!.removeWhere((categoryId) => categoryId == value.key);
                                                                  setState(() {

                                                                  });

                                                                });
                                                              },
                                                            ),


                                                            (_mosqueBuildingDetail.buildingTypeIds??[]).where((x)=>x==5).length>0?CustomFormField(title:  fields.getField('notes_for_other').label,value: _mosqueBuildingDetail.notesForOther,
                                                              isRequiredField:requiredFields.contains("notes_for_other"),
                                                              onChanged:(val){
                                                                _mosqueBuildingDetail.notesForOther = val;

                                                                setState(() {});
                                                              },type:FieldType.textArea,):Container(),
                                                            

                                                            (_mosqueBuildingDetail.buildingTypeIds??[]).length>0?CustomFormField(title:  fields.getField('permitted_from_ministry').label,value: _mosqueBuildingDetail.permittedFromMinistry,
                                                                isRequiredField:requiredFields.contains("permitted_from_ministry"),
                                                                onChanged:(val){
                                                                  _mosqueBuildingDetail.permittedFromMinistry = val;

                                                                  setState(() {});
                                                                },type:FieldType.choice,options:fields.getComboList('permitted_from_ministry')):Container(),
                                                                
                                                            
                                                          ],
                                                        ):Container(),

                                                       
                                                        
                                                        CustomFormField(title:  fields.getField('is_other_attachment').label,value: _mosqueBuildingDetail.isOtherAttachment,
                                                            isRequiredField:requiredFields.contains("is_other_attachment"),
                                                            onChanged:(val){
                                                              _mosqueBuildingDetail.isOtherAttachment = val;
                                                          
                                                              setState(() {});
                                                            },type:FieldType.choice,options:fields.getComboList('is_other_attachment')),
                                                        CustomFormField(title:  fields.getField('other_attachment').label,value: _mosqueBuildingDetail.otherAttachment,
                                                            isRequiredField:requiredFields.contains("other_attachment"),
                                                            onChanged:(val){
                                                              _mosqueBuildingDetail.otherAttachment = val;
                                                     
                                                              setState(() {});
                                                            }),
                                                        
                                                        CustomFormField(title:  fields.getField('external_headset_number').label,value: _mosqueBuildingDetail.externalHeadsetNumber,
                                                          isRequiredField:requiredFields.contains("external_headset_number"),
                                                            onChanged:(val){
                                                              _mosqueBuildingDetail.externalHeadsetNumber = val;
                                                        
                                                              setState(() {});
                                                            },type:FieldType.number,),
                                                        CustomFormField(title:  fields.getField('internal_speaker_number').label,value: _mosqueBuildingDetail.internalSpeakerNumber,
                                                          isRequiredField:requiredFields.contains("internal_speaker_number"),
                                                            onChanged:(val){
                                                              _mosqueBuildingDetail.internalSpeakerNumber = val;
                                                         
                                                              setState(() {});
                                                            },type:FieldType.number,),
                                                     
                                                        CustomFormField(title:  fields.getField('num_lighting_inside').label,value: _mosqueBuildingDetail.numLightingInside,
                                                          isRequiredField:requiredFields.contains("num_lighting_inside"),
                                                            onChanged:(val){
                                                              _mosqueBuildingDetail.numLightingInside = val;
                                                         
                                                              setState(() {});
                                                            },type:FieldType.number,),
                                                        CustomFormField(title:  fields.getField('num_minarets').label,value: _mosqueBuildingDetail.numMinarets,
                                                          isRequiredField:requiredFields.contains("num_minarets"),
                                                            onChanged:(val){
                                                              _mosqueBuildingDetail.numMinarets = val;
                                                           
                                                              setState(() {});
                                                            },type:FieldType.number,),
                                                        CustomFormField(title:  fields.getField('num_floors').label,value: _mosqueBuildingDetail.numFloors,
                                                          isRequiredField:requiredFields.contains("num_floors"),
                                                            onChanged:(val){
                                                              _mosqueBuildingDetail.numFloors = val;
                                                           
                                                              setState(() {});
                                                            },type:FieldType.number,),


                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),

                                            ),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: PrimaryButton(text: "update".tr(),onTab:(){
                                                    updateBuildingDetail(_tabController.index);
                                               

                                                  }),
                                                ),
                                                Expanded(
                                                  child: SecondaryButton(text: "cancel".tr(),onTab:(){
                                                    _tabs[_tabController.index].isEditMode=false;
                                                    setState(() {

                                                    });
                                                
                                                  }),
                                                ),
                                              ],
                                            )
                                          ],
                                        ):SingleChildScrollView(
                                              child: Container(

                                                  padding: EdgeInsets.symmetric(horizontal: 15,vertical: 5),
                                                  child: Column(
                                                    children: [

                                                      AppListTitle2(title: fields.getField('has_basement').label,isRequired:requiredFields.contains("has_basement"),subTitle: _mosque.hasBasement??'',
                                                          isTag: true,selection:fields.getComboList('has_basement')),
                                                      AppListTitle2(title: fields.getField('building_material').label,isRequired:requiredFields.contains("building_material"),subTitle: _mosque.buildingMaterial??'',
                                                          selection:fields.getComboList('building_material')),
                                                      AppListTitle2(title: fields.getField('building_area').label,isRequired:requiredFields.contains("building_area"),subTitle: _mosque.buildingArea??''),
                                                      AppListTitle2(title: fields.getField('building_status').label,isRequired:requiredFields.contains("building_status"),subTitle: _mosque.buildingStatus??'',
                                                          isBar: true,selection:fields.getComboList('building_status'),context: context),
                                                      //
                                                      AppListTitle2(title: fields.getField('occupancy_rate').label,isRequired:requiredFields.contains("occupancy_rate"),subTitle: (_mosque.occupancyRate??'').toString()),
                                                      AppListTitle2(title: fields.getField('buildings_on_land').label,isRequired:requiredFields.contains("buildings_on_land"),subTitle: _mosque.buildingsOnLand??'',
                                                          isTag: true,selection:fields.getComboList('buildings_on_land')),
                                                      AppListTitle2(title: fields.getField('recall_notes').label,isRequired:requiredFields.contains("recall_notes"),subTitle: _mosque.recallNotes??''),

                                                      AppListTitle2(title: fields.getField('endowment_on_land').label,isRequired:requiredFields.contains("endowment_on_land"),subTitle: _mosque.endowmentOnLand??'',
                                                          isTag: true,selection:fields.getComboList('endowment_on_land')),

                                                      _mosque.endowmentOnLand=='yes'?AppListTitle2(title: fields.getField('endowment_type').label,isRequired:requiredFields.contains("endowment_type"),subTitle: _mosque.endowmentType??'',
                                                          isTag: true,selection:fields.getComboList('endowment_type')):Container(),

                                                      AppListTitle2(title: fields.getField('is_there_structure_buildings').label,isRequired:requiredFields.contains("is_there_structure_buildings"),subTitle: _mosque.isThereStructureBuildings??'',
                                                          isTag: true,selection:fields.getComboList('is_there_structure_buildings')),
                                                      
                                                      _mosque.isThereStructureBuildings=='yes'?Column(
                                                        children: [
                                                          AppListTitle2(title: fields.getField('building_type_ids').label,isRequired:requiredFields.contains("is_there_structure_buildings"),subTitle: _mosque.buildingTypeIds??'',
                                                            selection:buildingTypeIds,type: ListType.multiSelect),
                                                          
                                                          (_mosque.buildingTypeIds??[]).where((x)=>x==5).length>0?AppListTitle2(title: fields.getField('notes_for_other').label,isRequired:requiredFields.contains("notes_for_other"),subTitle: _mosque.notesForOther??''):Container(),

                                                          (_mosque.buildingTypeIds??[]).length>0?AppListTitle2(title: fields.getField('permitted_from_ministry').label,isRequired:requiredFields.contains("permitted_from_ministry"),subTitle: _mosque.permittedFromMinistry??'',
                                                              isTag: true,selection:fields.getComboList('permitted_from_ministry')):Container(),
                                                        ],
                                                      ):Container(),




                                                      AppListTitle2(title: fields.getField('is_other_attachment').label,isRequired:requiredFields.contains("is_other_attachment"),subTitle: _mosque.isOtherAttachment??'',
                                                          isTag: true,selection:fields.getComboList('is_other_attachment')),
                                                      AppListTitle2(title: fields.getField('other_attachment').label,isRequired:requiredFields.contains("other_attachment"),subTitle: _mosque.otherAttachment??''),

                                                      AppListTitle2(title: fields.getField('external_headset_number').label,isRequired:requiredFields.contains("external_headset_number"),subTitle: _mosque.externalHeadsetNumber??'',),
                                                      AppListTitle2(title: fields.getField('internal_speaker_number').label,isRequired:requiredFields.contains("internal_speaker_number"),subTitle: (_mosque.internalSpeakerNumber??'').toString()),
                                                      // AppListTitle2(title: fields.getField('external_speaker_number').label,subTitle: (_mosque.externalSpeakerNumber??'').toString()),
                                                      AppListTitle2(title: fields.getField('num_lighting_inside').label,isRequired:requiredFields.contains("num_lighting_inside"),subTitle: (_mosque.numLightingInside??'').toString()),
                                                      AppListTitle2(title: fields.getField('num_minarets').label,isRequired:requiredFields.contains("num_minarets"),subTitle: (_mosque.numMinarets??'').toString()),
                                                      AppListTitle2(title: fields.getField('num_floors').label,isRequired:requiredFields.contains("num_floors"),subTitle: (_mosque.numFloors??'').toString()),
                                                      // AppListTitle2(title: 'Residence For Imam',subTitle: _mosque.ministryAuthorized??'',isBoolean: true),
                                                      // AppListTitle2(title: 'Residence For Mouadhin',subTitle: _mosque.ministryAuthorized??'',isBoolean: true),

                                                      // AppListTitle2(title: 'Length Row Women Praying',subTitle: (_mosque.lengthRowWomenPraying??'').toString()),
                                                      
                                                     
                                                      // AppListTitle2(title: 'Toilet Woman Number',subTitle: (_mosque.toiletWomenNumber??'').toString()),

                                                    ],
                                                  )
                                              )),
                                        //#endregion
                                        //#region Imam's & Muezzin's Details
                                        _tabs[_tabController.index].isEditMode?Column(
                                          children: [
                                            Expanded(
                                              child: SingleChildScrollView(
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                                                  child: Form(
                                                    key: _formImamDetailKey,
                                                    child: Column(
                                                      children: [
                                                        AppTitle1('imam_residence_details'.tr(),Icons.info),
                                                        CustomFormField(title:  fields.getField('residence_for_imam').label,value: _mosqueImamDetail.residenceForImam,
                                                            isRequiredField :requiredFields.contains("residence_for_imam"),
                                                            onChanged:(val){

                                                              _mosqueImamDetail.residenceForImam = val;
                                                            
                                                              setState(() {});
                                                            },type:FieldType.selection,options:fields.getComboList('residence_for_imam')),
                                                        _mosqueImamDetail.residenceForImam=='yes'?Column(

                                                          children: [
                                                            CustomFormField(title:  fields.getField('imam_residence_type').label,value: _mosqueImamDetail.imamResidenceType,
                                                                isRequiredField:requiredFields.contains("imam_residence_type"),
                                                                onChanged:(val){
                                                                  _mosqueImamDetail.imamResidenceType = val;
                                                               
                                                                  setState(() {});
                                                                },type:FieldType.selection,options:fields.getComboList('imam_residence_type')),

                                                        CustomFormField(title:  fields.getField('imam_residence_land_area').label,value: _mosqueImamDetail.imamResidenceLandArea,
                                                            isRequiredField:requiredFields.contains("imam_residence_land_area"),
                                                            onChanged:(val){
                                                              _mosqueImamDetail.imamResidenceLandArea = val;
                                                        
                                                            },type:FieldType.double),
                                                        CustomFormField(title:  fields.getField('is_imam_electric_meter').label,value: _mosqueImamDetail.isImamElectricMeter,
                                                            isRequiredField:requiredFields.contains("is_imam_electric_meter"),
                                                            onChanged:(val){
                                                              _mosqueImamDetail.isImamElectricMeter = val;

                                                          
                                                              setState(() {});
                                                            },type:FieldType.choice,options:fields.getComboList('is_imam_electric_meter')),
                                                        _mosqueImamDetail.isImamElectricMeter=='yes'?Column(
                                                          children: [

                                                            CustomFormField(title:  fields.getField('is_imam_electric_meter_new').label,value: _mosqueImamDetail.isImamElectricMeterNew,
                                                                isRequiredField:requiredFields.contains("is_imam_electric_meter_new"),
                                                                onChanged:(val){
                                                                  _mosqueImamDetail.isImamElectricMeterNew = val;
                                                           
                                                                  setState(() {});
                                                                },type:FieldType.choice,options:fields.getComboList('is_imam_electric_meter_new')),

                                                            CustomFormField(title:  fields.getField('imam_electricity_meter_type').label,value: _mosqueImamDetail.imamElectricityMeterType,
                                                                isRequiredField:requiredFields.contains("imam_electricity_meter_type"),
                                                                onChanged:(val){
                                                           
                                                            
                                                                  if((val=="separate" || val=="shared_with_mosque") && (_mosqueImamDetail.muezzinElectricityMeterType=="shared_with_imam" || _mosqueImamDetail.muezzinElectricityMeterType=="shared_with_mosque_imam")){
                                                                    Flushbar(
                                                                      icon: Icon(Icons.warning,color: Colors.white,),
                                                                      backgroundColor: AppColors.flushColor,
                                                                      title: 'warning'.tr(),
                                                                      message: "Muezzin meter not shared with Imam",
                                                                      duration: Duration(seconds: 3),
                                                                    ).show(context);
                                                                    _mosqueImamDetail.imamElectricityMeterType='';

                                                                    setState(() {

                                                                    });
                                                                    return;
                                                                  }
                                                                  _mosqueImamDetail.imamElectricityMeterType = val;

                                                                  _imamElectricityMeters.removeWhere((item) => item.isNew);

                                                                  _imamElectricityMeters.forEach((item) {
                                                                  
                                                                    item.isDelete=true;
                                                                  });

                                                                  if(val=='shared_with_mosque' || val=='shared'){
                                                               
                                                               
                                                                    _mosqueElectricityMeters.where((item) => item.mosqueShared==true).forEach((item) {
                                                                  
                                                                      if(_imamElectricityMeters.where((rec) => rec.name==item.name).length==0)
                                                                        {
                                                                          var newMeter=Meter(id: item.id,name: item.name);
                                                                          newMeter.isNew=true;
                                                                          _imamElectricityMeters.add(newMeter);
                                                                        }
                                                                      else{
                                                                        Meter itemToUpdate = _imamElectricityMeters.firstWhere((record) => record.id == item.id);
                                                                        itemToUpdate.isDelete = false;
                                                                      }

                                                                    });

                                                                  }else{

                                                                    //_imamElectricityMeters=[];
                                                                  }
                                                            
                                                                  setState(() {});
                                                                },type:FieldType.selection,options:fields.getComboList('imam_electricity_meter_type')),

                                                          
                                                            CustomListField(title: fields.getField('imam_electricity_meter_ids').label,isRequired:requiredFields.contains("imam_electricity_meter_ids"),employees:  _imamElectricityMeters.where((item) => item.isDelete==false).toList(),isEditMode:true,

                                                                builder: (Meter item){
                                                                      return  Text(item.name!,style: TextStyle(color: AppColors.defaultColor),);
                                                                },
                                                                onEdit: (Meter item){
                                                                  AddEditMeterModal(item: item,
                                                                      title: fields.getField('imam_electricity_meter_ids').label,
                                                                      labelName: "electric_meter_number".tr(),
                                                                      onSave:(Meter item){
                                                                        Meter itemToUpdate = _imamElectricityMeters.firstWhere((record) => record.id == item.id);

                                                                        itemToUpdate.isEdit = true;
                                                                        itemToUpdate.name = item.name;

                                                                        setState(() {

                                                                        });
                                                                        Navigator.of(context).pop();
                                                                      }
                                                                  );
                                                                },
                                                                onDelete: (Meter item){
                                                                  if(item.isNew){
                                                                    _imamElectricityMeters.removeWhere((rec) => rec.name==item.name);
                                                                  }else{
                                                                    Meter itemToUpdate = _imamElectricityMeters.firstWhere((record) => record.id == item.id);
                                                                    itemToUpdate.isDelete = true;
                                                                  }
                                                                  setState(() {
                                                                    
                                                                  });
                                                                },
                                                                onTab:(){
                                                                  AddEditMeterModal(
                                                                      title: fields.getField('imam_electricity_meter_ids').label,
                                                                      labelName: "electric_meter_number".tr(),
                                                                      onSave:(Meter item){
                                                                        _imamElectricityMeters.add(item);
                                                                        setState(() {

                                                                        });
                                                                        Navigator.of(context).pop();
                                                                    }
                                                                  );
                                                                })

                                                          ],
                                                        ):Container(),

                                                        CustomFormField(title:  fields.getField('is_imam_water_meter').label,value: _mosqueImamDetail.isImamWaterMeter,
                                                            isRequiredField:requiredFields.contains("is_imam_water_meter"),
                                                            onChanged:(val){
                                                              _mosqueImamDetail.isImamWaterMeter = val;
                                                           
                                                              setState(() {});
                                                            },type:FieldType.choice,options:fields.getComboList('is_imam_water_meter')),

                                                        _mosqueImamDetail.isImamWaterMeter=='yes'?Column(
                                                          children: [
                                                            CustomFormField(title:  fields.getField('imam_water_meter_type').label,value: _mosqueImamDetail.imamWaterMeterType,
                                                                isRequiredField:requiredFields.contains("imam_water_meter_type"),
                                                                onChanged:(val){
                                                                  _mosqueImamDetail.imamWaterMeterType = val;
                                                                  
                                                                  setState(() {});
                                                                },type:FieldType.selection,options:fields.getComboList('imam_water_meter_type')),
                                                          
                                                            CustomListField(title: fields.getField('imam_water_meter_ids').label,isRequired:requiredFields.contains("imam_water_meter_ids"),employees:  _imamWaterMeters.where((item) => item.isDelete==false).toList(),isEditMode:true,

                                                                builder: (Meter item){
                                                                  return  Text(item.name!,style: TextStyle(color: AppColors.defaultColor),);
                                                                },
                                                                onEdit: (Meter item){
                                                                  AddEditMeterModal(item: item,
                                                                      title: fields.getField('imam_water_meter_ids').label,
                                                                      labelName: "water_meter_number".tr(),
                                                                      onSave:(Meter item){
                                                                        Meter itemToUpdate = _imamWaterMeters.firstWhere((record) => record.id == item.id);

                                                                        itemToUpdate.isEdit = true;
                                                                        itemToUpdate.name = item.name;

                                                                        setState(() {

                                                                        });
                                                                        Navigator.of(context).pop();
                                                                      }
                                                                  );
                                                                },
                                                                onDelete: (Meter item){
                                                                  Meter itemToUpdate = _imamWaterMeters.firstWhere((record) => record.id == item.id);
                                                                  itemToUpdate.isDelete = true;
                                                                  setState(() {

                                                                  });
                                                                },
                                                                onTab:(){
                                                                  AddEditMeterModal(
                                                                      title: fields.getField('imam_water_meter_ids').label,
                                                                      labelName: "water_meter_number".tr(),
                                                                      onSave:(Meter item){
                                                                        _imamWaterMeters.add(item);
                                                                        setState(() {

                                                                        });
                                                                        Navigator.of(context).pop();
                                                                      }
                                                                  );
                                                                })
                                                          ],
                                                        ):Container(),

                                                        CustomFormField(title:  fields.getField('is_imam_house_private').label,value: _mosqueImamDetail.isImamHousePrivate,
                                                            isRequiredField:requiredFields.contains("is_imam_house_private"),
                                                            onChanged:(val){
                                                              _mosqueImamDetail.isImamHousePrivate = val;
                                                         
                                                              setState(() {});
                                                            },type:FieldType.choice,options:fields.getComboList('is_imam_house_private')),
                                                          ],
                                                        ):Container(),

                                                        AppTitle1('muezzin_residence_details'.tr(),Icons.info),
                                                        CustomFormField(title:  fields.getField('residence_for_mouadhin').label,value: _mosqueImamDetail.residenceForMouadhin,
                                                            isRequiredField:requiredFields.contains("residence_for_mouadhin"),
                                                            onChanged:(val){

                                                              _mosqueImamDetail.residenceForMouadhin = val;
                                                          
                                                              setState(() {});
                                                            },type:FieldType.selection,options:fields.getComboList('residence_for_mouadhin')),
                                                        
                                                        _mosqueImamDetail.residenceForMouadhin=='yes'?Column(
                                                          children: [
                                                            CustomFormField(title:  fields.getField('muezzin_residence_type').label,value: _mosqueImamDetail.muezzinResidenceType,
                                                                isRequiredField:requiredFields.contains("muezzin_residence_type"),
                                                                onChanged:(val){
                                                                  _mosqueImamDetail.muezzinResidenceType = val;
                                                                
                                                                  setState(() {});
                                                                },type:FieldType.selection,options:fields.getComboList('muezzin_residence_type')),


                                                        CustomFormField(title:  fields.getField('muezzin_residence_land_area').label,value: _mosqueImamDetail.muezzinResidenceLandArea,
                                                            isRequiredField:requiredFields.contains("muezzin_residence_land_area"),
                                                            onChanged:(val){
                                                              _mosqueImamDetail.muezzinResidenceLandArea = val;
                                                              
                                                            },type:FieldType.double),

                                                        CustomFormField(title:  fields.getField('is_muezzin_electric_meter').label,value: _mosqueImamDetail.isMuezzinElectricMeter,
                                                            isRequiredField:requiredFields.contains("is_muezzin_electric_meter"),
                                                            onChanged:(val){
                                                              _mosqueImamDetail.isMuezzinElectricMeter = val;
                                                        
                                                              setState(() {});
                                                            },type:FieldType.choice,options:fields.getComboList('is_muezzin_electric_meter')),



                                                        _mosqueImamDetail.isMuezzinElectricMeter=='yes'?Column(
                                                          children: [
                                                            CustomFormField(title:  fields.getField('is_muezzin_electric_meter_new').label,value: _mosqueImamDetail.isMuezzinElectricMeterNew,
                                                                isRequiredField:requiredFields.contains("is_muezzin_electric_meter_new"),
                                                                onChanged:(val){
                                                                  _mosqueImamDetail.isMuezzinElectricMeterNew = val;
                                                           
                                                                  setState(() {});
                                                                },type:FieldType.choice,options:fields.getComboList('is_muezzin_electric_meter_new')),
                                                            CustomFormField(title:  fields.getField('muezzin_electricity_meter_type').label,value: _mosqueImamDetail.muezzinElectricityMeterType,
                                                                isRequiredField:requiredFields.contains("muezzin_electricity_meter_type"),
                                                                onChanged:(val){
                                                                  // Future.delayed(Duration(seconds: 1),(){
                                                                  //   _mosqueImamDetail.muezzinElectricityMeterType='';
                                                                  //   setState(() {
                                                                  //
                                                                  //   });
                                                                  // });
                                                                  //
                                                                  // return;
                                                                   if((val=="shared_with_imam" || val=="shared_with_mosque_imam") && (_mosqueImamDetail.imamElectricityMeterType!="shared" && _mosqueImamDetail.imamElectricityMeterType!="shared_with_muezzin")){
                                                                     Flushbar(
                                                                       icon: Icon(Icons.warning,color: Colors.white,),
                                                                       backgroundColor: AppColors.flushColor,
                                                                       title: 'warning'.tr(),
                                                                       message: "Imam meter not shared with muezzin",
                                                                       duration: Duration(seconds: 3),
                                                                     ).show(context);
                                                                     _mosqueImamDetail.muezzinElectricityMeterType='';

                                                                     setState(() {

                                                                     });
                                                                     return;
                                                                   }
                                                                
                                                                  _mosqueImamDetail.muezzinElectricityMeterType = val;
                                                               
                                                                  _muezzinElectricityMeters.removeWhere((item) => item.isNew);
                                                                  _muezzinElectricityMeters.forEach((item) {
                                                                 
                                                                    item.isDelete=true;
                                                                    // if(_imamElectricityMeters.where((rec) => rec.name==item.name).length==0)
                                                                    //   _imamElectricityMeters.add(item);
                                                                  });
                                                                  //_muezzinElectricityMeters=[];
                                                                  if(val=='shared_with_mosque' || val=='shared_with_mosque_imam'){
                                                                    _mosqueElectricityMeters.where((item) => item.mosqueShared==true).forEach((item) {
                                                                   
                                                                      if(_muezzinElectricityMeters.where((rec) => rec.name==item.name).length==0){
                                                                          var newMeter=Meter(id: item.id,name: item.name);
                                                                          newMeter.isNew=true;
                                                                          _muezzinElectricityMeters.add(newMeter);
                                                                      }
                                                                      else{
                                                                        Meter itemToUpdate = _muezzinElectricityMeters.firstWhere((record) => record.id == item.id);
                                                                        itemToUpdate.isDelete = false;
                                                                      }
                                                                    });
                                                                  }
                                                                  if(val=='shared_with_imam' || val=='shared_with_mosque_imam' ){
                                                                    _imamElectricityMeters.forEach((item) {
                                                                     
                                                                      if(_muezzinElectricityMeters.where((rec) => rec.name==item.name).length==0){
                                                                        var newMeter=Meter(id: item.id,name: item.name);
                                                                        newMeter.isNew=true;
                                                                        _muezzinElectricityMeters.add(newMeter);
                                                                      }
                                                                      else{
                                                                        Meter itemToUpdate = _muezzinElectricityMeters.firstWhere((record) => record.id == item.id);
                                                                        itemToUpdate.isDelete = false;
                                                                      }
                                                                    });
                                                                  }

                                                               
                                                                  setState(() {});
                                                                },type:FieldType.selection,options:fields.getComboList('muezzin_electricity_meter_type')),

                                                          

                                                            CustomListField(title: fields.getField('muezzin_electricity_meter_ids').label,isRequired:requiredFields.contains("muezzin_electricity_meter_ids"),employees:  _muezzinElectricityMeters.where((item) => item.isDelete==false).toList(),isEditMode:true,
                                                                builder: (Meter item){
                                                                  return  Text(item.name!,style: TextStyle(color: AppColors.defaultColor),);
                                                                },
                                                                onEdit: (Meter item){
                                                                  AddEditMeterModal(item: item,
                                                                      title: fields.getField('muezzin_electricity_meter_ids').label,
                                                                      labelName: "electric_meter_number".tr(),
                                                                      onSave:(Meter item){
                                                                    
                                                                        Meter itemToUpdate = _muezzinElectricityMeters.firstWhere((record) => record.id == item.id);

                                                                        itemToUpdate.isEdit = true;
                                                                        itemToUpdate.name = item.name;

                                                                        setState(() {

                                                                        });
                                                                        Navigator.of(context).pop();
                                                                      }
                                                                  );
                                                                },
                                                                onDelete: (Meter item){
                                                                  if(item.isNew){
                                                                    _muezzinElectricityMeters.removeWhere((rec) => rec.name==item.name);
                                                                  }else{
                                                                    Meter itemToUpdate = _muezzinElectricityMeters.firstWhere((record) => record.id == item.id);
                                                                    itemToUpdate.isDelete = true;
                                                                  }

                                                                  setState(() {

                                                                  });
                                                                },
                                                                onTab:(){
                                                                  AddEditMeterModal(
                                                                      title: fields.getField('muezzin_electricity_meter_ids').label,
                                                                      labelName: "electric_meter_number".tr(),
                                                                      onSave:(Meter item){
                                                                        _muezzinElectricityMeters.add(item);
                                                                        setState(() {

                                                                        });
                                                                        Navigator.of(context).pop();
                                                                      }
                                                                  );
                                                                })


                                                          ],
                                                        ):Container(),

                                                        CustomFormField(title:  fields.getField('is_muezzin_water_meter').label,value: _mosqueImamDetail.isMuezzinWaterMeter,
                                                            isRequiredField:requiredFields.contains("is_muezzin_water_meter"),
                                                            onChanged:(val){
                                                              _mosqueImamDetail.isMuezzinWaterMeter = val;
                                                           
                                                              setState(() {});
                                                            },type:FieldType.choice,options:fields.getComboList('is_muezzin_water_meter')),

                                                        _mosqueImamDetail.isMuezzinWaterMeter=='yes'?Column(
                                                          children: [
                                                            CustomFormField(title:  fields.getField('muezzin_water_meter_type').label,value: _mosqueImamDetail.muezzinWaterMeterType,
                                                                isRequiredField:requiredFields.contains("muezzin_water_meter_type"),
                                                                onChanged:(val){
                                                                  _mosqueImamDetail.muezzinWaterMeterType = val;
                                                                
                                                                  setState(() {});
                                                                },type:FieldType.selection,options:fields.getComboList('muezzin_water_meter_type')),
                                                          
                                                              CustomListField(title: fields.getField('muezzin_water_meter_ids').label,isRequired:requiredFields.contains("muezzin_water_meter_ids"),employees:  _muezzinWaterMeters.where((item) => item.isDelete==false).toList(),isEditMode:true,

                                                                builder: (Meter item){
                                                                  return  Text(item.name!,style: TextStyle(color: AppColors.defaultColor),);
                                                                },
                                                                onEdit: (Meter item){
                                                                  AddEditMeterModal(item: item,
                                                                      title: fields.getField('muezzin_water_meter_ids').label,
                                                                      labelName: "water_meter_number".tr(),
                                                                      onSave:(Meter item){
                                                                       
                                                                        Meter itemToUpdate = _muezzinWaterMeters.firstWhere((record) => record.id == item.id);

                                                                        itemToUpdate.isEdit = true;
                                                                        itemToUpdate.name = item.name;

                                                                        setState(() {

                                                                        });
                                                                        Navigator.of(context).pop();
                                                                      }
                                                                  );
                                                                },
                                                                onDelete: (Meter item){
                                                                  Meter itemToUpdate = _muezzinWaterMeters.firstWhere((record) => record.id == item.id);
                                                                  itemToUpdate.isDelete = true;
                                                                  setState(() {

                                                                  });
                                                                },
                                                                onTab:(){
                                                                  AddEditMeterModal(
                                                                      title: fields.getField('muezzin_water_meter_ids').label,
                                                                      labelName: "water_meter_number".tr(),
                                                                      onSave:(Meter item){
                                                                        _muezzinWaterMeters.add(item);
                                                                        setState(() {

                                                                        });
                                                                        Navigator.of(context).pop();
                                                                      }
                                                                  );
                                                                })
                                                          ],
                                                        ):Container(),
                                                     
                                                        CustomFormField(title:  fields.getField('is_muezzin_house_private').label,value: _mosqueImamDetail.isMuezzinHousePrivate,
                                                            isRequiredField:requiredFields.contains("is_muezzin_house_private"),
                                                            onChanged:(val){
                                                              _mosqueImamDetail.isMuezzinHousePrivate = val;
                                                        
                                                              setState(() {});
                                                            },type:FieldType.choice,options:fields.getComboList('is_muezzin_house_private')),
                                                          ],
                                                        ):Container(),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),

                                            ),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: PrimaryButton(text: "update".tr(),onTab:(){
                                                    updateMosqueImamDetail(_tabController.index);
                                                 

                                                  }),
                                                ),
                                                Expanded(
                                                  child: SecondaryButton(text: "cancel".tr(),onTab:(){
                                                    _tabs[_tabController.index].isEditMode=false;
                                                    setState(() {

                                                    });
                                                 
                                                  }),
                                                ),
                                              ],
                                            )
                                          ],
                                        ):
                                        SingleChildScrollView(
                                            child: Container(
                                                padding: EdgeInsets.symmetric(horizontal: 15,vertical: 5),
                                                child: Column(
                                                  children: [
                                                    AppTitle1('imam_residence_details'.tr(),Icons.info),
                                                    AppListTitle2(title: fields.getField('residence_for_imam').label,isRequired:requiredFields.contains("residence_for_imam"),subTitle: _mosque.residenceForImam??'',
                                                        selection:fields.getComboList('residence_for_imam')),
                                                    _mosque.residenceForImam=='yes'?Column(
                                                      children: [
                                                        AppListTitle2(title: fields.getField('imam_residence_type').label,isRequired:requiredFields.contains("imam_residence_type"),subTitle: _mosque.imamResidenceType??'',
                                                            selection:fields.getComboList('imam_residence_type')),
                                                        AppListTitle2(title: fields.getField('imam_residence_land_area').label,isRequired:requiredFields.contains("imam_residence_land_area"),subTitle: (_mosque.imamResidenceLandArea??'').toString()),
                                                        AppListTitle2(title: fields.getField('is_imam_electric_meter').label,isRequired:requiredFields.contains("is_imam_electric_meter"),subTitle: (_mosque.isImamElectricMeter??'').toString(),
                                                            isTag: true,selection:fields.getComboList('is_imam_electric_meter')),
                                                        _mosque.isImamElectricMeter=='yes'?Column(
                                                          children: [

                                                            AppListTitle2(title: fields.getField('is_imam_electric_meter_new').label,isRequired:requiredFields.contains("is_imam_electric_meter_new"),subTitle: (_mosque.isImamElectricMeterNew??'').toString(),
                                                                isTag: true,selection:fields.getComboList('is_imam_electric_meter_new')),
                                                            AppListTitle2(title: fields.getField('imam_electricity_meter_type').label,isRequired:requiredFields.contains("imam_electricity_meter_type"),subTitle: _mosque.imamElectricityMeterType??'',
                                                                selection:fields.getComboList('imam_electricity_meter_type')),
                                                         
                                                          ],
                                                        ):Container(),

                                                        
                                                        _mosque.isImamElectricMeter=='yes'?Column(
                                                          children: [

                                                          // AppListTitle2(title: fields.getField('imam_electricity_meter_ids').label,subTitle: (_mosque.imamElectricityMeterIds??'').toString(),
                                                          //   ),
                                                            CustomListField(title: fields.getField('imam_electricity_meter_ids').label,isRequired:requiredFields.contains("imam_electricity_meter_ids"),employees: _imamElectricityMeters,isEditMode:false,
                                                                builder: (Meter item){
                                                                  return  Text(item.name!,style: TextStyle(color: AppColors.defaultColor),);
                                                                },),

                                                          ],
                                                        ):Container(),








                                                        AppListTitle2(title: fields.getField('is_imam_water_meter').label,isRequired:requiredFields.contains("is_imam_water_meter"),subTitle: _mosque.isImamWaterMeter??'',
                                                            isTag: true,selection:fields.getComboList('is_imam_water_meter')),
                                                        _mosque.isImamWaterMeter=='yes'?Column(
                                                          children: [
                                                            AppListTitle2(title: fields.getField('imam_water_meter_type').label,isRequired:requiredFields.contains("imam_water_meter_type"),subTitle: _mosque.imamWaterMeterType??'',
                                                                selection:fields.getComboList('imam_water_meter_type')),

                                                            // AppListTitle2(title: fields.getField('imam_water_meter_ids').label,subTitle: (_mosque.imamWaterMeterIds??'').toString(),
                                                            // ),
                                                            CustomListField(title: fields.getField('imam_water_meter_ids').label,isRequired:requiredFields.contains("imam_water_meter_ids"),employees: _imamWaterMeters,isEditMode:false,
                                                              builder: (Meter item){
                                                                return  Text(item.name!,style: TextStyle(color: AppColors.defaultColor),);
                                                              },)
                                                          ],
                                                        ):Container(),



                                                        AppListTitle2(title: fields.getField('is_imam_house_private').label,isRequired:requiredFields.contains("is_imam_house_private"),subTitle: _mosque.isImamHousePrivate??'',
                                                            isTag: true,selection:fields.getComboList('is_imam_house_private')),
                                                      ],
                                                    ):Container(),


                                                    AppTitle1('muezzin_residence_details'.tr(),Icons.info),

                                                    AppListTitle2(title: fields.getField('residence_for_mouadhin').label,isRequired:requiredFields.contains("residence_for_mouadhin"),subTitle: _mosque.residenceForMouadhin??'',
                                                        selection:fields.getComboList('residence_for_imam')),

                                                    _mosque.residenceForMouadhin=='yes'?Column(
                                                      children: [


                                                    AppListTitle2(title: fields.getField('muezzin_residence_type').label,isRequired:requiredFields.contains("muezzin_residence_type"),subTitle: _mosque.muezzinResidenceType??'',
                                                        selection:fields.getComboList('muezzin_residence_type')),
                                                    AppListTitle2(title: fields.getField('muezzin_residence_land_area').label,isRequired:requiredFields.contains("muezzin_residence_land_area"),subTitle: (_mosque.muezzinResidenceLandArea??'').toString()),
                                                    AppListTitle2(title: fields.getField('is_muezzin_electric_meter').label,isRequired:requiredFields.contains("is_muezzin_electric_meter"),subTitle: (_mosque.isMuezzinElectricMeter??'').toString(),
                                                        isTag: true,selection:fields.getComboList('is_muezzin_electric_meter')),

                                                    _mosque.isMuezzinElectricMeter=='yes'?Column(
                                                      children: [
                                                        AppListTitle2(title: fields.getField('is_muezzin_electric_meter_new').label,isRequired:requiredFields.contains("is_muezzin_electric_meter_new"),subTitle: (_mosque.isMuezzinElectricMeterNew??'').toString(),
                                                            isTag: true,selection:fields.getComboList('is_muezzin_electric_meter_new')),

                                                        AppListTitle2(title: fields.getField('muezzin_electricity_meter_type').label,isRequired:requiredFields.contains("muezzin_electricity_meter_type"),subTitle: _mosque.muezzinElectricityMeterType??'',
                                                            selection:fields.getComboList('muezzin_electricity_meter_type')),

                                                        // AppListTitle2(title: fields.getField('muezzin_electricity_meter_ids').label,subTitle: (_mosque.muezzinElectricityMeterIds??'').toString(),
                                                        // ),

                                                        CustomListField(title: fields.getField('muezzin_electricity_meter_ids').label,isRequired:requiredFields.contains("muezzin_electricity_meter_ids"),employees: _muezzinElectricityMeters,isEditMode:false,
                                                          builder: (Meter item){
                                                            return  Text(item.name!,style: TextStyle(color: AppColors.defaultColor),);
                                                          },)
                                                      ],
                                                    ):Container(),


                                                    AppListTitle2(title: fields.getField('is_muezzin_water_meter').label,isRequired:requiredFields.contains("is_muezzin_water_meter"),subTitle: _mosque.isMuezzinWaterMeter??'',
                                                        isTag: true,selection:fields.getComboList('is_imam_water_meter')),

                                                    _mosque.isMuezzinWaterMeter=='yes'?Column(
                                                      children: [
                                                        AppListTitle2(title: fields.getField('muezzin_water_meter_type').label,isRequired:requiredFields.contains("muezzin_water_meter_type"),subTitle: _mosque.muezzinWaterMeterType??'',
                                                            selection:fields.getComboList('muezzin_water_meter_type')
                                                        ),

                                                        CustomListField(title: fields.getField('muezzin_water_meter_ids').label,isRequired:requiredFields.contains("muezzin_water_meter_ids"),employees: _muezzinWaterMeters,isEditMode:false,
                                                          builder: (Meter item){
                                                            return  Text(item.name!,style: TextStyle(color: AppColors.defaultColor),);
                                                          },)
                                                        // AppListTitle2(title: fields.getField('muezzin_water_meter_ids').label,subTitle: _mosque.muezzinWaterMeterIds??''),
                                                      ],
                                                    ):Container(),


                                                    // AppListTitle2(title: fields.getField('muezzin_house_type').label,subTitle: _mosque.muezzinHouseType??'',
                                                    //     selection:fields.getComboList('muezzin_house_type')),
                                                    AppListTitle2(title: fields.getField('is_muezzin_house_private').label,isRequired:requiredFields.contains("is_muezzin_house_private"),subTitle: _mosque.isMuezzinHousePrivate??'',
                                                        isTag: true,selection:fields.getComboList('is_muezzin_house_private')),

                                                      ],
                                                    ):Container(),

                                                    // AppListTitle2(title: 'Electricity meter number for the Imam’s residence',subTitle: _mosque.imamElectricityMeterNumber??''),
                                                    //
                                                    // AppListTitle2(title: 'Water meter number for the Imam’s residence',subTitle: _mosque.imamWaterMeterNumber??''),
                                                    //AppListTitle2(title: 'Notes',subTitle: _mosque.note),

                                                  ],
                                                )
                                            )),
                                        //#endregion
                                        //#region Prayer Section
                                        _tabs[_tabController.index].isEditMode?Column(
                                          children: [
                                            Expanded(
                                              child: SingleChildScrollView(
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                                                  child: Form(
                                                    key: _formPrayerKey,
                                                    child: Column(
                                                      children: [
                                                        CustomFormField(title:  fields.getField('has_women_prayer_room').label,value: _mosquePrayerSection.hasWomenPrayerRoom,
                                                            isRequiredField:requiredFields.contains("has_women_prayer_room"),
                                                            onChanged:(val){
                                                              _mosquePrayerSection.hasWomenPrayerRoom = val;
                                                          
                                                              setState(() {});
                                                            },type:FieldType.choice,options:fields.getComboList('has_women_prayer_room')),
                                                        _mosquePrayerSection.hasWomenPrayerRoom=='yes'? Column(
                                                          children: [
                                                            CustomFormField(title: fields.getField('row_women_praying_number').label,value: _mosquePrayerSection.rowWomenPrayingNumber,
                                                                isRequiredField:requiredFields.contains("row_women_praying_number"),
                                                                onChanged:(val){
                                                                  _mosquePrayerSection.rowWomenPrayingNumber = val;
                                                              
                                                                  setState(() {});
                                                                },type:FieldType.number),
                                                            CustomFormField(title: fields.getField('length_row_women_praying').label,value: _mosquePrayerSection.lengthRowWomenPraying,
                                                                isRequiredField:requiredFields.contains("length_row_women_praying"),
                                                                onChanged:(val){
                                                                  _mosquePrayerSection.lengthRowWomenPraying = val;
                                                                 
                                                                },type:FieldType.double),

                                                            CustomFormField(title: fields.getField('is_women_toilets').label,value: _mosquePrayerSection.isWomenToilets,
                                                                isRequiredField:requiredFields.contains("is_women_toilets"),
                                                                onChanged:(val){
                                                                  _mosquePrayerSection.isWomenToilets = val;
                                                                 
                                                                  setState(() {});
                                                                },type: FieldType.choice,options:fields.getComboList('is_women_toilets')),

                                                            _mosquePrayerSection.isWomenToilets=='yes'?CustomFormField(title: fields.getField('toilet_woman_number').label,value: _mosquePrayerSection.toiletWomanNumber,
                                                                isRequiredField:requiredFields.contains("toilet_woman_number"),
                                                                onChanged:(val){
                                                                  _mosquePrayerSection.toiletWomanNumber = val;
                                                              
                                                                  setState(() {});
                                                                },type:FieldType.number):Container(),



                                                          ],
                                                        ):Container(),

                                                        _mosquePrayerSection.classificationId==1?Container():CustomFormField(title: fields.getField('friday_prayer_rows').label,value: _mosquePrayerSection.fridayPrayerRows,
                                                            isRequiredField:requiredFields.contains("friday_prayer_rows"),
                                                            onChanged:(val){
                                                              _mosquePrayerSection.fridayPrayerRows = val;
                                                        
                                                            } ,type:FieldType.double),
                                                        CustomFormField(title:fields.getField('row_men_praying_number').label,value: _mosquePrayerSection.rowMenPrayingNumber,
                                                            isRequiredField:requiredFields.contains("row_men_praying_number"),
                                                            onChanged:(val){
                                                              _mosquePrayerSection.rowMenPrayingNumber = val;
                                                           
                                                            } ,type:FieldType.number),
                                                        CustomFormField(title: fields.getField('length_row_men_praying').label,value: _mosquePrayerSection.lengthRowMenPraying,
                                                            isRequiredField:requiredFields.contains("length_row_men_praying"),
                                                            onChanged:(val){
                                                              _mosquePrayerSection.lengthRowMenPraying = val;

                                                            } ,type:FieldType.double),
                                                        CustomFormField(title: fields.getField('internal_doors_number').label,value: _mosquePrayerSection.internalDoorsNumber,
                                                            isRequiredField:requiredFields.contains("internal_doors_number"),
                                                            onChanged:(val){
                                                              _mosquePrayerSection.internalDoorsNumber = val;

                                                            } ,type:FieldType.number),
                                                        CustomFormField(title:  fields.getField('toilet_men_number').label,value: _mosquePrayerSection.toiletMenNumber,
                                                            isRequiredField:requiredFields.contains("toilet_men_number"),
                                                            onChanged:(val){
                                                              _mosquePrayerSection.toiletMenNumber = val;

                                                            } ,type:FieldType.number),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),

                                            ),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: PrimaryButton(text: "update".tr(),onTab:(){
                                                    updateMosquePrayerSection(_tabController.index);
                                                   

                                                  }),
                                                ),
                                                Expanded(
                                                  child: SecondaryButton(text: "cancel".tr(),onTab:(){
                                                    _tabs[_tabController.index].isEditMode=false;
                                                    setState(() {

                                                    });
                                                 
                                                  }),
                                                ),
                                              ],
                                            )
                                          ],
                                        ):
                                        SingleChildScrollView(
                                          child: Container(
                                            padding: EdgeInsets.symmetric(horizontal: 15,vertical: 5),
                                            child: Column(
                                              children: [
                                                AppListTitle2(title: fields.getField('has_women_prayer_room').label,isRequired:requiredFields.contains("has_women_prayer_room"),subTitle: _mosque.hasWomenPrayerRoom??'',isTag: true,selection:fields.getComboList('has_women_prayer_room') ),
                                                _mosque.hasWomenPrayerRoom=='yes'?Column(
                                                  children: [
                                                    AppListTitle2(title: fields.getField('row_women_praying_number').label,isRequired:requiredFields.contains("row_women_praying_number"),subTitle: _mosque.rowWomenPrayingNumber??""),

                                                    AppListTitle2(title: fields.getField('length_row_women_praying').label,isRequired:requiredFields.contains("length_row_women_praying"),subTitle: _mosque.lengthRowWomenPraying.toString()),
                                                    // AppListTitle2(title: fields.getField('number_women_rows').label,subTitle: _mosque.numberWomenRows??""),

                                                    AppListTitle2(title: fields.getField('is_women_toilets').label,isRequired:requiredFields.contains("is_women_toilets"),subTitle: _mosque.isWomenToilets??"",isTag: true,selection:fields.getComboList('is_women_toilets')),
                                                    _mosque.isWomenToilets=='yes'?AppListTitle2(title: fields.getField('toilet_woman_number').label,isRequired:requiredFields.contains("toilet_woman_number"),subTitle: _mosque.toiletWomanNumber??""):Container(),
                                                    // _mosque.isWomenToilets=='yes'?AppListTitle2(title: fields.getField('num_womens_bathrooms').label,subTitle: (_mosque.numWomensBathrooms??'').toString()):Container(),
                                                  ],
                                                ):Container(),
                                                _mosque.classificationId==1?Container():AppListTitle2(title: fields.getField('friday_prayer_rows').label,isRequired:requiredFields.contains("friday_prayer_rows"),subTitle: (_mosque.fridayPrayerRows??'').toString()),
                                                AppListTitle2(title: fields.getField('row_men_praying_number').label,isRequired:requiredFields.contains("row_men_praying_number"),subTitle: (_mosque.rowMenPrayingNumber).toString()),
                                                AppListTitle2(title: fields.getField('length_row_men_praying').label,isRequired:requiredFields.contains("length_row_men_praying"),subTitle: (_mosque.lengthRowMenPraying).toString()),
                                                AppListTitle2(title: fields.getField('internal_doors_number').label,isRequired:requiredFields.contains("internal_doors_number"),subTitle: (_mosque.internalDoorsNumber??'').toString()),
                                                AppListTitle2(title: fields.getField('toilet_men_number').label,isRequired:requiredFields.contains("toilet_men_number"),subTitle: (_mosque.toiletMenNumber??'').toString()),

                                              ],
                                            ),
                                          ),
                                        ),
                                        //#endregion
                                        //#region Geo Location
                                        _tabs[_tabController.index].isEditMode?Column(
                                          children: [
                                            Expanded(
                                              child: SingleChildScrollView(
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                                                  child: Form(
                                                    key: _formGeoLocKey,
                                                    child: Column(
                                                      children: [


                                                        Column(
                                                           crossAxisAlignment: CrossAxisAlignment.end,
                                                          // mainAxisAlignment: MainAxisAlignment.end,
                                                          children: [
                                                            CustomFormField(title:  fields.getField('latitude').label,value: _mosqueGeoLocation.latitude,
                                                                isRequiredField:requiredFields.contains("latitude"),
                                                                onChanged:(val){
                                                                    _mosqueGeoLocation.latitude= val;
                                                                  },isReadonly:true ),
                                                            CustomFormField(title:  fields.getField('longitude').label,value: _mosqueGeoLocation.longitude,
                                                                isRequiredField:requiredFields.contains("longitude"),
                                                                  onChanged:(val){
                                                                    _mosqueGeoLocation.longitude= val;
                                                                  },isReadonly:true ),
                                                            isVisiablePermission? Visibility(
                                                              visible:  isVisiablePermission,
                                                              child: Container(
                                                                  margin: EdgeInsets.only(bottom: 5),
                                                                  padding: EdgeInsets.all(10),
                                                                  //height: 30,
                                                                  decoration: BoxDecoration(
                                                                    borderRadius: BorderRadius.circular(7),
                                                                    border: Border.all(
                                                                      color: Colors.grey.shade200,  // Set this to the desired color when not authorized
                                                                      width: 1.0,       // Adjust the width as needed
                                                                    ),
                                                                    color: permission.status==GPSPermissionStatus.authorize?AppColors.backgroundColor :AppColors.backgroundColor,
                                                                  ),
                                                                  child: Row(
                                                                    children: [
                                                                      permission.status==GPSPermissionStatus.authorize?Icon(Icons.check_circle,color: Colors.grey.shade400,):Icon(Icons.warning_amber,color: Colors.grey.shade400,),
                                                                      SizedBox(width: 5,),
                                                                      Expanded(
                                                                          child: Text(permission.statusDesc,style: TextStyle(fontSize: 13 ,color: Colors.grey.shade400),)
                                                                      ),
                                                                      !permission.isCompleted?SizedBox(
                                                                          height: 25.0,
                                                                          width: 25.0,
                                                                          child: CircularProgressIndicator(color: Colors.grey.shade400,)):permission.showTryAgainButton?
                                                                      TextButton(
                                                                          style: TextButton.styleFrom(
                                                                              padding: EdgeInsets.zero,
                                                                              minimumSize: Size(50, 25),
                                                                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                                              alignment: Alignment.centerLeft),
                                                                          onPressed: () {
                                                                            if(permission.status==GPSPermissionStatus.locationDisabled){
                                                                              permission.enableMobileLocation();
                                                                            }else if(permission.status==GPSPermissionStatus.permissionDenied){
                                                                              permission.allowPermission();
                                                                            }else if(permission.status==GPSPermissionStatus.failFetchCoordinate || permission.status==GPSPermissionStatus.unAuthorizeLocation){
                                                                              permission.getCurrentLocation();
                                                                            }
                                                                          },child: Text('try_again'.tr(),style: TextStyle(color: Colors.grey.shade400,decoration: TextDecoration.underline,),)):Container() ,
                                                                    ],
                                                                  )
                                                              ),
                                                            ):Container(),
                                                            Container(
                                                              // width:250,
                                                              margin: EdgeInsets.symmetric(
                                                                  horizontal: 2,vertical: 10),
                                                              // Set margin here
                                                              child:
                                                              SecondaryOutlineButton(text: "fetch_current_coordinates".tr(),
                                                                  icon:Icons.gps_fixed,
                                                                    onTab:(){
                                                                    permission=new GPSPermission(
                                                                        allowDistance: 0,
                                                                        latitude:0,
                                                                        longitude:0,
                                                                        isOnlyGPS: true
                                                                    );
                                                                    setState((){
                                                                      isVisiablePermission=true;
                                                                    });
                                                                    permission.checkPermission();
                                                                    permission.listner.listen((value){
                                                            

                                                                      if(value){
                                                                   
                                                                        _mosqueGeoLocation.latitude=double.parse(permission.currentPosition!.latitude.toStringAsFixed(6));
                                                                        _mosqueGeoLocation.longitude= double.parse(permission.currentPosition!.longitude.toStringAsFixed(6));
                                                                        setState((){
                                                                          isVisiablePermission=false;
                                                                        });

                                                                      }
                                                                      setState((){

                                                                      });
                                                                    });
                                                                    
                                                              })
                                                             
                                                            ),


                                                          ],
                                                        ),


                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),

                                            ),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: PrimaryButton(text: "update".tr(),onTab:(){
                                                    updateMosqueGeoLocation(_tabController.index);
                                                  

                                                  }),
                                                ),
                                                Expanded(
                                                  child: SecondaryButton(text: "cancel".tr(),onTab:(){
                                                    _tabs[_tabController.index].isEditMode=false;
                                                    setState(() {

                                                    });
                                            
                                                  }),
                                                ),
                                              ],
                                            )
                                          ],
                                        ):
                                        SingleChildScrollView(
                                            child: Container(
                                                padding: EdgeInsets.symmetric(horizontal: 15,vertical: 5),
                                                child: Column(
                                                  children: [

                                                    AppListTitle2(title: 'gps_coordinate'.tr(),isRequired:(requiredFields.contains("longitude") || requiredFields.contains("latitude")),subTitle: _mosque.latitude.toString()+','+_mosque.longitude.toString(),hasDivider:true),



                                                  ],
                                                )
                                            )),
                                        //#endregion
                                        // gleChildScrollView(
                                        //     child: Container(
                                        //       padding: EdgeInsets.symmetric(horizontal: 15,vertical: 5),
                                        //       child: Table(
                                        //         //border: TableBorder.all(color: Colors.grey.shade200),
                                        //         columnWidths: {
                                        //           0: FixedColumnWidth(80),
                                        //           2: FixedColumnWidth(100),
                                        //           3: FixedColumnWidth(50),
                                        //         },
                                        //         children: [
                                        //           TableRow(
                                        //
                                        //             decoration: BoxDecoration(
                                        //               border: Border.all(width: 0),
                                        //               borderRadius: BorderRadius.only(topLeft:  Radius.circular(10),topRight:  Radius.circular(10) ),
                                        //               color: AppColors.flushColor,
                                        //             ),
                                        //             children: [
                                        //               TableCell(
                                        //
                                        //                 child: Container(
                                        //                   // decoration: BoxDecoration(
                                        //                   //   border: Border.all(width: 0),
                                        //                   //   borderRadius: BorderRadius.only(topLeft:Radius.circular(10) ),
                                        //                   //   color: AppColors.flushColor,
                                        //                   // ),
                                        //
                                        //                   padding: EdgeInsets.all(8),
                                        //
                                        //                   child: Center(
                                        //                     child: Text(
                                        //                       'Number',
                                        //                       style: TextStyle(fontSize: 13, color: Colors.white),
                                        //                     ),
                                        //                   ),
                                        //                 ),
                                        //               ),
                                        //               TableCell(
                                        //                 child: Container(
                                        //
                                        //                   padding: EdgeInsets.all(8),
                                        //                   // decoration: BoxDecoration(
                                        //                   //   border: Border.all(width: 0),
                                        //                   //   color: AppColors.flushColor,// Adjust the value to change the corner radius
                                        //                   // ),
                                        //                   child: Center(
                                        //                     child: Text(
                                        //                       'Name',
                                        //                       style: TextStyle(fontSize: 13, color: Colors.white),
                                        //                     ),
                                        //                   ),
                                        //                 ),
                                        //               ),
                                        //               TableCell(
                                        //                 child: Container(
                                        //                   padding: EdgeInsets.all(8),
                                        //                   // decoration: BoxDecoration(
                                        //                   //   border: Border.all(width: 0),
                                        //                   //   borderRadius: BorderRadius.only(topRight:Radius.circular(10) ),
                                        //                   //   color: AppColors.flushColor,// Adjust the value to change the corner radius
                                        //                   // ),
                                        //                   child: Center(
                                        //                     child: Text(
                                        //                       'Code',
                                        //                       style: TextStyle(fontSize: 13, color: Colors.white),
                                        //                     ),
                                        //                   ),
                                        //                 ),
                                        //               ),
                                        //               TableCell(
                                        //                 child: Container(
                                        //                   padding: EdgeInsets.all(8),
                                        //
                                        //                 ),
                                        //               ),
                                        //             ],
                                        //           ),
                                        //           for (int i = 0; i < _regions.length; i++) // Generate 10 rows
                                        //             TableRow(
                                        //               decoration: BoxDecoration(
                                        //                 border: Border(
                                        //                   bottom: BorderSide(width: 1.0, color: Colors.grey.shade200), // Bottom border only
                                        //                 ),
                                        //                 color: i % 2 == 0 ? Colors.grey[100] : Colors.white,
                                        //               ),
                                        //               children: [
                                        //                 TableCell(
                                        //                   child: Container(
                                        //                     padding: EdgeInsets.all(12),
                                        //                     child: Center(
                                        //                       child: Text(_regions[i].number.toString()),
                                        //                     ),
                                        //                   ),
                                        //                 ),
                                        //                 TableCell(
                                        //                   child: Container(
                                        //                     padding: EdgeInsets.all(12),
                                        //                     child: Text(_regions[i].name.toString()),
                                        //                   ),
                                        //                 ),
                                        //                 TableCell(
                                        //                   child: Container(
                                        //                     padding: EdgeInsets.all(12),
                                        //                     child: Center(
                                        //                       child: Text(_regions[i].code.toString()),
                                        //                     ),
                                        //                   ),
                                        //                 ),
                                        //                 TableCell(
                                        //                   child: Container(
                                        //                       padding: EdgeInsets.all(5),
                                        //                       child: IconButton(
                                        //                         icon: Icon(Icons.edit,color: AppColors.primary,size: 25,),
                                        //                         onPressed: () {
                                        //                           AddEditRegionModal(region: _regions[i]);
                                        //                           // Add your onPressed function here
                                        //                         },
                                        //                       )
                                        //                   ),
                                        //                 ),
                                        //               ],
                                        //             ),
                                        //         ],
                                        //       ),
                                        //     )),


                                      ],
                                    ),

                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  ),
                  _mosque.isActionButton?Row(
                    children: [
                      _mosque.displayButtonAccept!?Expanded(
                        child: Container(
                          color: Colors.white,
                          child: PrimaryButton(text: "accept".tr(),onTab:(){
                            if(isVerifyDevice()) {
                              confirmMosque();
                              //acceptMosque();
                            }
                          }),
                        ),
                      ):Container(),
                      _mosque.displayButtonRefuse!?Expanded(
                        child: Container(
                          color: Colors.white,
                          child: DangerButton(text: "refuse".tr(),onTab:(){
                            if(isVerifyDevice()) {
                              showRefuseModal();
                            }
                          }),
                        ),
                      ):Container(),

                    ],
                  ):Container(),
                ],
              ),

              isLoading
                  ? ProgressBar()
                  : SizedBox.shrink(),

            ],
          ),
        ),
        floatingActionButton: (_tabs[_tabController.index].isEditMode==false &&
            _tabs[_tabController.index].isShowEdit==true && _mosque.state=='draft'
        )?FloatingActionButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50), // Adjust this value if needed
          ),
          onPressed: (){
            if(isVerifyDevice()) {
              if (_tabs[_tabController.index].allowEditMode)
                _tabs[_tabController.index].isEditMode = true;
              if (_tabController.index == 0)
                _mosqueBasicInfo = Mosque.shallowCopy(_mosque);
              else if (_tabController.index == 1)
                _mosqueDetail = Mosque.shallowCopy(_mosque);
              else if (_tabController.index == 2)
                _mosqueMosqueInfo = Mosque.shallowCopy(_mosque);
              else if (_tabController.index == 3)
                _mosqueMaintenanceDetail = Mosque.shallowCopy(_mosque);
              else if (_tabController.index == 4)
                _mosqueBuildingDetail = Mosque.shallowCopy(_mosque);
              else if (_tabController.index == 5)
                _mosqueImamDetail = Mosque.shallowCopy(_mosque);
              else if (_tabController.index == 6)
                _mosquePrayerSection = Mosque.shallowCopy(_mosque);
              else if (_tabController.index == 7)
                _mosqueGeoLocation = Mosque.shallowCopy(_mosque);

              setState(() {

              });
            }

          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.edit,size: 14),
              Text('edit'.tr()),
              

            ],
          ),
        ):Container(),
      ),
    );
  }
}
