import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:mosque_management_system/constants/app_colors.dart';
import 'package:mosque_management_system/constants/input_decoration_themes.dart';
import 'package:mosque_management_system/data/models/combo_list.dart';
import 'package:mosque_management_system/data/models/employee.dart';
import 'package:mosque_management_system/data/models/mosque.dart';
import 'package:mosque_management_system/data/models/mosque_region.dart';
import 'package:mosque_management_system/data/models/region.dart';
import 'package:mosque_management_system/data/models/res_city.dart';
import 'package:mosque_management_system/data/models/res_partner.dart';
import 'package:mosque_management_system/data/models/userProfile.dart';
import 'package:mosque_management_system/data/models/visit.dart';
import 'package:mosque_management_system/data/repositories/custom_odoo_client.dart';
import 'package:mosque_management_system/data/services/mosque_service.dart';
import 'package:mosque_management_system/data/services/user_service.dart';
import 'package:mosque_management_system/data/services/visit_service.dart';
import 'package:mosque_management_system/dialogs/disclaimer_dialog.dart';
import 'package:mosque_management_system/list/city_list.dart';
import 'package:mosque_management_system/list/combo_list.dart';
import 'package:mosque_management_system/list/mosque_user_list.dart';
import 'package:mosque_management_system/list/region_list.dart';
import 'package:mosque_management_system/presentation/screens/mosque_detail.dart';
import 'package:mosque_management_system/providers/user_provider.dart';
import 'package:mosque_management_system/utils/config.dart';
import 'package:mosque_management_system/utils/gps_permission.dart';
import 'package:mosque_management_system/widgets/ProgressBar.dart';
import 'package:mosque_management_system/widgets/app_form_field.dart';
import 'package:mosque_management_system/widgets/app_list_title.dart';
import 'package:mosque_management_system/widgets/app_title.dart';
import 'package:mosque_management_system/widgets/image_data.dart';
import 'package:mosque_management_system/widgets/service_button.dart';
import 'package:mosque_management_system/widgets/state_button.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'package:provider/provider.dart';
import 'package:mosque_management_system/data/models/base_state.dart';
import 'package:url_launcher/url_launcher.dart';

class VisitDetail extends StatefulWidget {
  final CustomOdooClient client;
  final int visitIdId;
  final Function? onCallback;
  VisitDetail({required this.client,required this.visitIdId,this.onCallback});
  @override
  _VisitDetailState createState() => _VisitDetailState();
}

class _VisitDetailState extends BaseState<VisitDetail> with SingleTickerProviderStateMixin  {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late OdooClient client;
  late VisitService _visitService;
  late MosqueService _mosqueService;
  UserService? _userService;
  Visit _visit =Visit(id: 0);
  Visit _visitDetail =Visit(id: 0);
  Visit _visitAssessment =Visit(id: 0);

  List<Employee> _allEmployees=[];
  List<Employee> _imams=[];
  List<Employee> _muezzin=[];
  List<Employee> _servants=[];
  List<Employee> _khatib=[];



  List<ResPartner> _allpartners=[];
  List<TabForm> _tabs=[];
  bool isLoading=true;
  void _changeTab(int index) {
    _tabController.animateTo(index);
  }
  late TabController _tabController = TabController(length: 5, vsync: this);
  @override
  void initState(){

    super.initState();

    _visitService = VisitService(this.widget.client!);
    _mosqueService = MosqueService(this.widget.client!);
    _userService = UserService(this.widget.client!);
    _tabController.addListener(_handleTabChange); // Add listener for tab changes
    //_tabController = TabController(length: 2, vsync: this);

    renderTabs();
    Future.delayed(Duration.zero, () {
      _visitService.loadVisitView().then((list){
        fields.list=list;
        setState(() {

        });
        getVisitDetail();
      });
    });
  }
  bool isVerifyDevice(){
    ///return true;
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
  FieldListData fields=FieldListData();
  void renderTabs(){
    _tabs.add(TabForm(title: 'visitor'.tr(),isShowEdit:true));
    _tabs.add(TabForm(title: 'imam'.tr(),isShowEdit:true));
    _tabs.add(TabForm(title: 'muazzin'.tr(),isShowEdit:true));
    _tabs.add(TabForm(title: 'servant'.tr(),isShowEdit:true));
    _tabs.add(TabForm(title: 'mosque'.tr(),isShowEdit:true));
  }
  void _handleTabChange() {
    setState(() {}); // Trigger setState when tab changes
  }

  late UserProvider userProvider;
  Mosque _mosqueDetail=Mosque(id: 0);
  void getVisitDetail(){
    setState((){
        isLoading=true;
    });
    _visitService!.getVisitDetail(this.widget.visitIdId).then((value){

      _visit=value;
      setState((){
        isLoading=false;
      });
      getAllEmployees();
      _mosqueService.getMosqueCoordinate(_visit.mosqueSequenceNoId!).then((_mosque){
          _mosqueDetail=_mosque;
      }).catchError((e){

      });


    }).catchError((e){
      setState((){});
      setState((){
        isLoading=false;
      });
    });
  }

  void getAllEmployees(){
    Set<int> uniqueEmployeeIds = {};
    List<int> employeeIds=[];
    uniqueEmployeeIds.addAll(_visit.servantId??[]);
    employeeIds.addAll(uniqueEmployeeIds);
    setState((){});
    if(employeeIds.length>0){
      _userService!.getEmployeesByIds(employeeIds).then((employees){
        _allEmployees=employees;
        _servants=_allEmployees.where((emp) {
          return  _visit.servantId!.contains(emp.id);
        }).toList();
        setState(() {

        });
      });
    }
  }



  final _formDetailKey = GlobalKey<FormState>();
  final _formRegionKey = GlobalKey<FormState>();
  final _formVisitInfoKey = GlobalKey<FormState>();
  final _formGeneralInfoKey = GlobalKey<FormState>();
  updateDetail(index){

    if (_formDetailKey.currentState!.validate()) {
      _formDetailKey.currentState!.save();
      setState((){
        isLoading=true;
      });

      _visitService!.updateVisit(_visit,_visitDetail).then((value){

        setState((){
          isEditMode=false;
          isLoading=false;
        });
        getVisitDetail();

      }).catchError((e){
        Flushbar(
          icon: Icon(Icons.warning,color: Colors.white,),
          backgroundColor: AppColors.flushColor,
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

  List<ComboItem> getComboList(dynamic field){
    return fields.getComboList(field);
 
  }
  FieldList? getField(dynamic key){
    return fields.getField(key);


  }
  bool isEditMode=false;
  bool isVisiablePermission=false;
  late GPSPermission permission;

  void refuseVisit(){

    setState(() {
      isLoading=true;
    });
    _visitService.refuseVisit(_visit.id!).then((_){
      getVisitDetail();
      setState(() {
        isLoading=false;
      });
      // this.widget.onCallback!();
      // Navigator.pop(context);
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
  void setDraftVisit(){

    setState(() {
      isLoading=true;
    });
    _visitService.setDraftVisit(_visit.id!).then((_){
      getVisitDetail();
      setState(() {
        isLoading=false;
      });
      // this.widget.onCallback!();
      // Navigator.pop(context);
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
  dynamic disclaimer;
  void confirmSendVisit(){
    _visitService.getVisitDisclaimer(_visit.id??0).then((result){
      
        disclaimer=result;
    

        showDisclaimerDialog(context,text:disclaimer["value"]["text"],onApproved: (){
          acceptTermsVisit();
        });

    }).catchError((e){
       
    });
    //sendVisit();
  }

  void acceptTermsVisit(){
   
      setState(() {
        isLoading=true;
      });
      _visitService.acceptTermsVisit(_visit.id!).then((_){
    
        // getVisitDetail();
        setState(() {
          isLoading=false;
        });
        this.widget.onCallback!();
        Navigator.pop(context);
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

  void acceptVisit(){

    setState(() {
      isLoading=true;
    });
    _visitService.acceptVisit(_visit.id!).then((_){

      setState(() {
        isLoading=false;
      });
      confirmSendVisit();
      // this.widget.onCallback!();
      // Navigator.pop(context);
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

  void sendVisit(){

    setState(() {
      isLoading=true;
    });
    _visitService.sendVisit(_visit.id!).then((_){

      // getVisitDetail();
      setState(() {
        isLoading=false;
      });
      confirmSendVisit();
      // this.widget.onCallback!();
      // Navigator.pop(context);
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
  // void confirmAcceptVisit(){
  //   _visitService.getVisitDisclaimer(_visit.id??0).then((result){
  
  //     disclaimer=result;

  //     showDisclaimerDialog(context,text:disclaimer["value"]["text"],onApproved: (){
  //       acceptVisit();
  //     });
  //   }).catchError((e){

  //   });
  //   //sendVisit();
  // }
  // void acceptVisit(){
  //   setState(() {
  //     isLoading=true;
  //   });
  //   _visitService.acceptVisit(_visit.id!).then((_){
  //     getVisitDetail();
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
  //     Flushbar(
  //       icon: Icon(Icons.warning,color: Colors.white,),
  //       backgroundColor:  AppColors.danger,
  //       message: e.message,
  //       duration: Duration(seconds: 3),
  //     ).show(context);
  //   });
  // }
  void startEdit(){
    permission=new GPSPermission(
      allowDistance: 100,
      latitude:(_mosqueDetail!.latitude??0),
      longitude:(_mosqueDetail!.longitude??0),
    );
    setState((){
      isVisiablePermission=true;
    });
    permission.checkPermission();
    permission.listner.listen((value){

      if(value){
        isEditMode=true;
        _visitDetail=Visit.shallowCopy(_visit);
        setState((){
          isVisiablePermission=false;
        });

      }
      setState((){

      });
    });
    setState(() {

    });

  }

  void startVisit(){
    setState(() {
      isLoading=true;
    });
    //First Update Prayer time
    _visitService!.updatePrayerTime(_visit).then((value){
      //Now start button base on prayer time
      _visitService.startVisit(_visit.id!).then((_){
        getVisitDetail();
        setState(() {
          isLoading=false;
        });
        this.widget.onCallback!();
      }).catchError((e){
        Flushbar(
          icon: Icon(Icons.warning,color: Colors.white,),
          backgroundColor: AppColors.danger,
          message: e.message,
          duration: Duration(seconds: 3),
        ).show(context);
        setState(() {
          isLoading=false;
        });
      });

    }).catchError((e){
      Flushbar(
        icon: Icon(Icons.warning,color: Colors.white,),
        backgroundColor: AppColors.flushColor,
        message: e.message,
        duration: Duration(seconds: 3),
      ).show(context);
      //isLoading=false;
      setState((){
        isLoading=false;
      });
    });

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    userProvider = Provider.of<UserProvider>(context);
    _visitService.updateUserProfile(userProvider.userProfile);
    _userService!.updateUserProfile(userProvider.userProfile);
    _mosqueService.updateUserProfile(userProvider.userProfile);
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



                  Container(
                    padding: EdgeInsets.only(top: 45,left: 20,bottom: 10,right: 10),
                    
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [

                        Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children:[
                              // Container(
                              //   width: 90,
                              //   height: 90,
                              //   decoration: BoxDecoration(
                              //     shape: BoxShape.circle,
                              //     color: AppColors.backgroundColor,
                              //     border: Border.all(
                              //       color: Color(0xff288056),
                              //       width: 5.0,
                              //     ),
                              //   ),
                              //   // child:  ClipOval(
                              //   //   child: Image.network('${Config.baseUrl}/web/image?model=mosque.mosque&id=${_visit.mosqueSequenceNoId}&field=image_128&unique=${_visit.uniqueId}',headers: _visitService==null?'':_visitService!.headersMap,fit: BoxFit.fitHeight,
                              //   //     errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                              //   //       // This function will be called when the image fails to load
                              //   //       return Padding(
                              //   //         padding: const EdgeInsets.all(8.0),
                              //   //         child: Icon(Icons.person,color: Colors.grey.shade300,size: 65,),
                              //   //       ); // You can replace this with any widget you want to display
                              //   //     },
                              //   //   ),
                              //   // ),
                              // ),
                              ImageData(id: _visit.mosqueSequenceNoId??0, modelName: Model.mosque, fieldId: "outer_image",uniqueId: _visit.uniqueId,baseUrl: userProvider.baseUrl,headersMap: _visitService!.headersMap,height: 90,width: 80,),

                              SizedBox(width: 8,),
                              Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text((_visit.name??''),style: TextStyle(color: AppColors.onPrimary,fontSize: 20,fontWeight: FontWeight.bold),),
                                      Text(_visit.mosqueSequenceNo??"",style: TextStyle(color: AppColors.onPrimary,fontSize: 13),  softWrap: true,),
                                      _visit.stage!=null?AppListTitle2(subTitle: _visit.stage??'',isTag:true,hasDivider:false,
                                          isSelectionReverse:true,isOnlyValue:true):Container(),
                                        ],
                                  )
                              ),
                            ]
                        ),

                      ],
                    ),
                  ),

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
                                    body:  Form(
                                      key: _formDetailKey,
                                      child: TabBarView(

                                        controller: _tabController,
                                        children: [
                                          isEditMode?Column(
                                            children: [
                                              Expanded(
                                                child: SingleChildScrollView(
                                                  child: Container(
                                                    padding: EdgeInsets.symmetric(horizontal: 10),
                                                    child: Column(
                                                      children: [
                                                      
                                                        CustomFormField(title:getField('prayer_name')!.label,
                                                          value: _visitDetail.prayerName,onChanged:(val){
                                                            _visitDetail.prayerName = val;
                                                           
                                                            setState((){});
                                                          }
                                                          ,type: FieldType.selection,
                                                          options:fields.getComboList('prayer_name'),
                                                        ),

                                                      ],
                                                    ),

                                                  ),
                                                ),

                                              ),
                                              Column(
                                                children: [
                                                  Row(
                                                    children: [
                                                  
                                                      Expanded(
                                                        child: SecondaryButton(text: "close".tr(),onTab:(){
                                                          isEditMode=false;
                                                          setState(() {

                                                          });
                                                        }),
                                                      ),
                                                      Expanded(
                                                        child: SecondaryButton(text: "next".tr(),onTab:(){
                                                         
                                                          _tabController.animateTo(1);
                                                  
                                                        }),
                                                      ),
                                                      Expanded(
                                                        child: PrimaryButton(text: "save".tr(),onTab:(){
                                                          isEditMode=false;

                                                          updateDetail(_tabController.index);

                                                          setState(() {

                                                          });

                                                        }),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              )
                                            ],
                                          ):Column(
                                            children: [
                                              Expanded(
                                                child: SingleChildScrollView(
                                                  child: Container(
                                                    padding: EdgeInsets.symmetric(horizontal: 10),
                                                    child: Column(
                                                      children: [
                                                        // (_visit.id!=0 && _visit.btnStart!=true)?CustomFormField(title:getField('prayer_name')!.label,
                                                        //   value: _visit.prayerName,onChanged:(val){
                                                        //
                                                        //     _visit.prayerName = val;
                                                        //
                                                        //     setState((){});
                                                        //   }
                                                        //   ,type: FieldType.selection,
                                                        //   options:fields.getComboList('prayer_name'),
                                                        // ):
                                                        AppListTitle2(title: getField('prayer_name')!.label,subTitle: _visit.prayerName??'',selection:fields.getComboList('prayer_name')),

                                                        AppListTitle2(title: getField('date_of_visit')!.label,subTitle: _visit.dateOfVisitGreg??'',isDate: true),
                                                        _visit.visitType=='regular'?Container():AppListTitle2(title: getField('created_by')!.label,subTitle: _visit.createdBy??''),


                                                        AppListTitle2(title: getField('visit_type')!.label,subTitle: _visit.visitType??'',selection:fields.getComboList('visit_type')),
                                                        AppListTitle2(title: getField('observer')!.label,hasDivider:false,child:
                                                           EmployeeListTitle(Employee(id:_visit.observerId,name:_visit.observer  ),null,userProvider.baseUrl),
                                                        ),

                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              // (isVisiablePermission  || _visit.btnStart==false)?Container():Column(
                                              //   children: [
                                              //     Row(
                                              //       children: [
                                              //         Expanded(
                                              //           child: SecondaryButton(text: "Edit",onTab:(){
                                              //             startEdit();
                                              //           }),
                                              //         ),
                                              //         Expanded(
                                              //           child: PrimaryButton(text: "Send",onTab:(){
                                              //             sendVisit();
                                              //           }),
                                              //         ),
                                              //       ],
                                              //     ),
                                              //   ],
                                              // )
                                            ],
                                          ),
                                          isEditMode?Column(
                                            children: [
                                              Expanded(
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                                                  child: SingleChildScrollView(
                                                    child: Column(
                                                      children: [
                                                        AppListTitle2(title: getField('imam_emp_id')!.label,hasDivider:false,child:
                                                          _visit.imamEmpId==null?Container():EmployeeListTitle(Employee(id:_visit.imamEmpId,name:_visit.imamEmp  ),null,userProvider.baseUrl),
                                                        ),
                                                        CustomFormField(title: getField('imam_present')!.label,
                                                          value: _visitDetail.imamPresent,onChanged:(val){
                                                            _visitDetail.imamPresent = val;
                                                            setState((){});
                                                          }
                                                          ,type: FieldType.choice,
                                                          options:getComboList('imam_present').toList(),
                                                        ),
                                                        CustomFormField(title: getField('imam_off_work')!.label,
                                                          value: _visitDetail.imamOffWork,onChanged:(val){
                                                            _visitDetail.imamOffWork = val;
                                                            setState((){});
                                                          }
                                                          ,type: FieldType.choice,
                                                          options:getComboList('imam_off_work').toList(),
                                                        ),
                                                        AppListTitle2(title: getField('imam_off_prayers_id')!.label,subTitle: _visit.imamOffPrayersId??"",
                                                            selection:fields.getComboList('imam_off_prayers_id')),
                                                        CustomFormField(title: getField('imam_notes')!.label,
                                                          value: _visitDetail.imamNotes,onChanged:(val){
                                                            _visitDetail.imamNotes = val;
                                                            setState((){});
                                                          }
                                                          ,type: FieldType.textArea,

                                                        ),

                                                      ],
                                                    ),

                                                  ),
                                                ),

                                              ),
                                              Row(
                                                children: [

                                                  Expanded(
                                                    child: SecondaryButton(text: "back".tr(),onTab:(){
                                                      _tabController.animateTo(0);
                                                    }),
                                                  ),
                                                  Expanded(
                                                    child: SecondaryButton(text: "next".tr(),onTab:(){
                                               
                                                      _tabController.animateTo(2);

                                                    }),
                                                  ),
                                                  Expanded(
                                                    child: PrimaryButton(text: "save".tr(),onTab:(){
                                                      isEditMode=false;

                                                      updateDetail(_tabController.index);
                                               

                                                      setState(() {

                                                      });

                                                    }),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ):Column(
                                            children: [
                                              Expanded(
                                                child: SingleChildScrollView(
                                                  child: Container(
                                                    padding: EdgeInsets.symmetric(horizontal: 15,vertical: 5),
                                                    child: Column(
                                                      children: [
                                                        AppListTitle2(title: getField('imam_emp_id')!.label ,hasDivider:false,child:
                                                        _visit.imamEmpId==null?Container():EmployeeListTitle(Employee(id:_visit.imamEmpId,name:_visit.imamEmp  ),null,userProvider.baseUrl),
                                                        ),
                                                        AppListTitle2(title:getField('imam_present')!.label,subTitle: _visit.imamPresent??"",
                                                            selection:getComboList('imam_present'),isTag:true),
                                                        AppListTitle2(title: getField('imam_off_work')!.label,subTitle: _visit.imamOffWork??"",
                                                            selection:getComboList('imam_off_work'),isTag:true),
                                                        AppListTitle2(title: getField('imam_off_work_date')!.label,subTitle: _visit.imamOffWorkDate??""),
                                                        AppListTitle2(title: getField('imam_off_prayers_id')!.label,subTitle: _visit.imamOffPrayersId??"",selection:fields.getComboList('imam_off_prayers_id')),
                                                        AppListTitle2(title: getField('imam_notes')!.label,subTitle: _visit.imamNotes??""),

                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              // (isVisiablePermission  || _visit.dateOfVisit==null)?Container():Column(
                                              //   children: [
                                              //     Row(
                                              //       children: [
                                              //         Expanded(
                                              //           child: SecondaryButton(text: "Edit",onTab:(){
                                              //             startEdit();
                                              //           }),
                                              //         ),
                                              //         Expanded(
                                              //           child: PrimaryButton(text: "Send",onTab:(){
                                              //             sendVisit();
                                              //           }),
                                              //         ),
                                              //       ],
                                              //     ),
                                              //   ],
                                              // )
                                            ],
                                          ),
                                          isEditMode?Column(
                                            children: [
                                              Expanded(
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                                                  child: SingleChildScrollView(
                                                    child: Column(
                                                      children: [
                                                        AppListTitle2(title: getField('muazzin_emp_id')!.label,hasDivider:false,child:
                                                        _visit.muazzinEmpId==null?Container():EmployeeListTitle(Employee(id:_visit.muazzinEmpId,name:_visit.muazzinEmp  ),null,userProvider.baseUrl),
                                                        ),
                                                        CustomFormField(title: getField('moazen_present')!.label,
                                                          value: _visitDetail.moazenPresent,onChanged:(val){
                                                            _visitDetail.moazenPresent = val;
                                                            setState((){});
                                                          }
                                                          ,type: FieldType.choice,
                                                          options:getComboList('moazen_present').toList(),
                                                        ),
                                                        CustomFormField(title: getField('moazen_exist')!.label,
                                                          value: _visitDetail.moazenExist,onChanged:(val){
                                                            _visitDetail.moazenExist = val;
                                                            setState((){});
                                                          }
                                                          ,type: FieldType.choice,
                                                          options:getComboList('moazen_exist').toList(),
                                                        ),
                                                        CustomFormField(title: getField('moazen_off_work')!.label,
                                                          value: _visitDetail.moazenOffWork,onChanged:(val){
                                                            _visitDetail.moazenOffWork = val;
                                                            setState((){});
                                                          }
                                                          ,type: FieldType.choice,
                                                          options:getComboList('moazen_off_work').toList(),
                                                        ),


                                                        AppListTitle2(title: getField('moazen_off_prayers_id')!.label,subTitle: _visit.moazenOffPrayersId??"",
                                                            selection:fields.getComboList('moazen_off_prayers_id')),
                                                        CustomFormField(title: getField('moazen_notes')!.label,
                                                          value: _visitDetail.moazenNotes,onChanged:(val){
                                                            _visitDetail.moazenNotes = val;
                                                            setState((){});
                                                          }
                                                          ,type: FieldType.textArea,
                                                        ),

                                                      ],
                                                    ),

                                                  ),
                                                ),

                                              ),
                                              Row(
                                                children: [

                                                  Expanded(
                                                    child: SecondaryButton(text: "back".tr(),onTab:(){
                                                      _tabController.animateTo(1);
                                                    }),
                                                  ),
                                                  Expanded(
                                                    child: SecondaryButton(text: "next".tr(),onTab:(){
                                                     
                                                      _tabController.animateTo(3);

                                                    }),
                                                  ),
                                                  Expanded(
                                                    child: PrimaryButton(text: "save".tr(),onTab:(){
                                                      isEditMode=false;

                                                      updateDetail(_tabController.index);
                                                 

                                                      setState(() {

                                                      });

                                                    }),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ):Column(
                                            children: [
                                              Expanded(
                                                child: SingleChildScrollView(
                                                  child: Container(
                                                    padding: EdgeInsets.symmetric(horizontal: 15,vertical: 5),
                                                    child: Column(
                                                      children: [
                                                        AppListTitle2(title: getField('muazzin_emp_id')!.label,hasDivider:false,child:
                                                        _visit.muazzinEmpId==null?Container():EmployeeListTitle(Employee(id:_visit.muazzinEmpId,name:_visit.muazzinEmp  ),null,userProvider.baseUrl),
                                                        ),
                                                        AppListTitle2(title: getField('moazen_present')!.label,subTitle: _visit.moazenPresent??'',
                                                            selection:getComboList('moazen_present'),isTag:true),
                                                        AppListTitle2(title: getField('moazen_exist')!.label,subTitle: _visit.moazenExist??'',
                                                            selection:getComboList('moazen_exist'),isTag:true
                                                        ),
                                                        AppListTitle2(title: getField('moazen_off_work')!.label,subTitle: _visit.moazenOffWork??'',
                                                            selection:getComboList('moazen_off_work'),isTag:true
                                                        ),
                                                        AppListTitle2(title: getField('moazen_off_prayers_id')!.label,subTitle: _visit.moazenOffPrayersId??'',
                                                            selection:fields.getComboList('moazen_off_prayers_id')),
                                                        AppListTitle2(title: getField('moazen_notes')!.label,subTitle: _visit.moazenNotes??''),

                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              // (isVisiablePermission  || _visit.dateOfVisit==null)?Container():Column(
                                              //   children: [
                                              //     Row(
                                              //       children: [
                                              //         Expanded(
                                              //           child: SecondaryButton(text: "Edit",onTab:(){
                                              //             startEdit();
                                              //           }),
                                              //         ),
                                              //         Expanded(
                                              //           child: PrimaryButton(text: "Send",onTab:(){
                                              //             sendVisit();
                                              //           }),
                                              //         ),
                                              //       ],
                                              //     ),
                                              //   ],
                                              // )
                                            ],
                                          ),
                                          isEditMode?Column(
                                            children: [
                                              Expanded(
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                                                  child: SingleChildScrollView(
                                                    child: Column(
                                                      children: [
                                                        CustomListField(title: fields.getField('servant_id').label,employees: _servants),
                                                        // AppListTitle2(title: getField('observer')!.label,subTitle: _visit.observer??''),
                                                        CustomFormField(title: getField('worker_present')!.label,
                                                          value: _visitDetail.workerPresent,onChanged:(val){
                                                            _visitDetail.workerPresent = val;
                                                            setState((){});
                                                          }
                                                          ,type: FieldType.choice,
                                                          options:getComboList('worker_present').toList(),
                                                        ),
                                                        CustomFormField(title: getField('worker_exist')!.label,
                                                          value: _visitDetail.workerExist,onChanged:(val){
                                                            _visitDetail.workerExist = val;
                                                            setState((){});
                                                          }
                                                          ,type: FieldType.choice,
                                                          options:getComboList('worker_exist').toList(),
                                                        )
                                                       ,CustomFormField(title: getField('worker_rate')!.label,
                                                          value: _visitDetail.workerRate,onChanged:(val){
                                                            _visitDetail.workerRate = val;
                                                            setState((){});
                                                          }
                                                          ,type: FieldType.choice,isSelectionReverse:true,
                                                          options:getComboList('worker_rate').toList(),
                                                        ),
                                                        CustomFormField(title: getField('worker_notes')!.label,
                                                          value: _visitDetail.workerNotes,onChanged:(val){
                                                            _visitDetail.workerNotes = val;
                                                            setState((){});
                                                          }
                                                          ,type: FieldType.textArea,
                                                        ),

                                                      ],
                                                    ),

                                                  ),
                                                ),

                                              ),
                                              Row(
                                                children: [

                                                  Expanded(
                                                    child: SecondaryButton(text: "back".tr(),onTab:(){
                                                      _tabController.animateTo(2);
                                                    }),
                                                  ),
                                                  Expanded(
                                                    child: SecondaryButton(text: "next".tr(),onTab:(){
                                                     
                                                      _tabController.animateTo(4);

                                                    }),
                                                  ),
                                                  Expanded(
                                                    child: PrimaryButton(text: "save".tr(),onTab:(){
                                                      isEditMode=false;

                                                      updateDetail(_tabController.index);
                                            

                                                      setState(() {

                                                      });

                                                    }),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ):Column(
                                            children: [
                                              Expanded(
                                                child: SingleChildScrollView(
                                                  child: Container(
                                                    padding: EdgeInsets.symmetric(horizontal: 15,vertical: 5),
                                                    child: Column(
                                                      children: [
                                                        CustomListField(title: fields.getField('servant_id').label,employees: _servants),
                                                        // AppListTitle2(title: getField('servant_id')!.label,subTitle: _visit.servantId??''),
                                                        AppListTitle2(title: getField('worker_present')!.label,subTitle: _visit.workerPresent??'',
                                                            selection:getComboList('worker_present'),isTag:true),
                                                        AppListTitle2(title: getField('worker_exist')!.label,subTitle: _visit.workerExist??'',
                                                            selection:getComboList('worker_exist'),isTag:true),
                                                        AppListTitle2(title: getField('worker_rate')!.label,subTitle: _visit.workerRate??'',
                                                            selection:getComboList('worker_rate'),isBar:true,isSelectionReverse: true,context: context),
                                                        AppListTitle2(title: getField('worker_notes')!.label,subTitle: (_visit.workerNotes??'').toString()),

                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              // (isVisiablePermission  || _visit.dateOfVisit==null)?Container():Column(
                                              //   children: [
                                              //     Row(
                                              //       children: [
                                              //         Expanded(
                                              //           child: SecondaryButton(text: "Edit",onTab:(){
                                              //             startEdit();
                                              //           }),
                                              //         ),
                                              //         Expanded(
                                              //           child: PrimaryButton(text: "Send",onTab:(){
                                              //             sendVisit();
                                              //           }),
                                              //         ),
                                              //       ],
                                              //     ),
                                              //   ],
                                              // )
                                            ],
                                          ),
                                          isEditMode?Column(
                                            children: [
                                              Expanded(
                                                child: SingleChildScrollView(
                                                  child: Container(
                                                    padding: EdgeInsets.symmetric(horizontal: 15,vertical: 5),
                                                    child: Column(
                                                      children: [
                                                        CustomFormField(title: getField('mosque_clean')!.label,
                                                          value: _visitDetail.mosqueClean,onChanged:(val){
                                                            _visitDetail.mosqueClean = val;
                                                            setState((){});
                                                          }
                                                          ,type: FieldType.choice,
                                                          options:getComboList('mosque_clean').toList(),
                                                        ),
                                                        (_visitDetail.mosqueClean=='good' || _visitDetail.mosqueClean=='')?Container():
                                                        CustomFormField(title: getField('mosque_clean_notes')!.label,
                                                          value: _visitDetail.mosqueCleanNotes,onChanged:(val){
                                                            _visitDetail.mosqueCleanNotes = val;
                                                            setState((){});
                                                          }
                                                          ,type: FieldType.textArea,
                                                        ),
                                                        CustomFormField(title: getField('carpet_quality')!.label,
                                                          value: _visitDetail.carpetQuality,onChanged:(val){
                                                            _visitDetail.carpetQuality = val;
                                                            setState((){});
                                                          }
                                                          ,type: FieldType.choice,
                                                          options:getComboList('carpet_quality').toList(),
                                                        ),
                                                        (_visitDetail.carpetQuality=='good' || _visitDetail.carpetQuality=='')?Container():
                                                        CustomFormField(title: getField('carpet_quality_notes')!.label,
                                                          value: _visitDetail.carpetQualityNotes,onChanged:(val){
                                                            _visitDetail.carpetQualityNotes = val;
                                                            setState((){});
                                                          }
                                                          ,type: FieldType.textArea,
                                                        ),
                                                        CustomFormField(title: getField('wc_clean')!.label,
                                                          value: _visitDetail.wcClean,onChanged:(val){
                                                            _visitDetail.wcClean = val;
                                                            setState((){});
                                                          }
                                                          ,type: FieldType.choice,
                                                          options:getComboList('wc_clean').toList(),
                                                        ),
                                                        (_visitDetail.wcClean=='good' || _visitDetail.wcClean=='')?Container():
                                                        CustomFormField(title: getField('wc_clean_notes')!.label,
                                                          value: _visitDetail.wcCleanNotes,onChanged:(val){
                                                            _visitDetail.wcCleanNotes = val;
                                                            setState((){});
                                                          }
                                                          ,type: FieldType.textArea,
                                                        ),
                                                        CustomFormField(title:getField('air_condition')!.label,
                                                          value: _visitDetail.airCondition,onChanged:(val){
                                                            _visitDetail.airCondition = val;
                                                            setState((){});
                                                          }
                                                          ,type: FieldType.choice,
                                                          options:getComboList('air_condition').toList(),
                                                        ),

                                                        (_visitDetail.airCondition=='good' || _visitDetail.airCondition=='')?Container():
                                                        CustomFormField(title: getField('air_condition_notes')!.label,
                                                          value: _visitDetail.airConditionNotes,onChanged:(val){
                                                            _visitDetail.airConditionNotes = val;
                                                            setState((){});
                                                          }
                                                          ,type: FieldType.textArea,
                                                        ),
                                                        CustomFormField(title: getField('sound_system')!.label,
                                                          value: _visitDetail.soundSystem,onChanged:(val){
                                                            _visitDetail.soundSystem = val;
                                                            setState((){});
                                                          }
                                                          ,type: FieldType.choice,
                                                          options:getComboList('sound_system').toList(),
                                                        ),
                                                        (_visitDetail.soundSystem=='good' || _visitDetail.soundSystem=='')?Container():
                                                        CustomFormField(title: getField('sound_system_notes')!.label,
                                                          value: _visitDetail.soundSystemNotes,onChanged:(val){
                                                            _visitDetail.soundSystemNotes = val;
                                                            setState((){});
                                                          }
                                                          ,type: FieldType.textArea,
                                                        ),
                                                        CustomFormField(title: getField('close_outside_horn')!.label,
                                                          value: _visitDetail.closeOutsideHorn,onChanged:(val){
                                                            _visitDetail.closeOutsideHorn = val;
                                                            setState((){});
                                                          }
                                                          ,type: FieldType.choice,
                                                          options:getComboList('close_outside_horn').toList(),
                                                        ),
                                                        CustomFormField(title: getField('inside_horn')!.label,
                                                          value: _visitDetail.insideHorn,onChanged:(val){
                                                            _visitDetail.insideHorn = val;
                                                            setState((){});
                                                          }
                                                          ,type: FieldType.choice,
                                                          options:getComboList('inside_horn').toList(),
                                                        ),
                                                        CustomFormField(title: getField('outside_horn')!.label,
                                                          value: _visitDetail.outsideHorn,onChanged:(val){
                                                            _visitDetail.outsideHorn = val;
                                                            setState((){});
                                                          }
                                                          ,type: FieldType.choice,
                                                          options:getComboList('outside_horn').toList(),
                                                        ),
                                                        CustomFormField(title: getField('wc_maintenance')!.label,
                                                          value: _visitDetail.wcMaintenance,onChanged:(val){
                                                            _visitDetail.wcMaintenance = val;
                                                            setState((){});
                                                          }
                                                          ,type: FieldType.choice,
                                                          options:getComboList('wc_maintenance').toList(),
                                                        ),
                                                        (_visitDetail.wcMaintenance=='good' || _visitDetail.wcMaintenance=='')?Container():
                                                        CustomFormField(title: getField('sound_system_notes')!.label,
                                                          value: _visitDetail.wcMaintenanceNotes,onChanged:(val){
                                                            _visitDetail.wcMaintenanceNotes = val;
                                                            setState((){});
                                                          }
                                                          ,type: FieldType.textArea,
                                                        ),
                                                        CustomFormField(title: getField('ablution_wash')!.label,
                                                          value: _visitDetail.ablutionWash,onChanged:(val){
                                                            _visitDetail.ablutionWash = val;
                                                            setState((){});
                                                          }
                                                          ,type: FieldType.choice,
                                                          options:getComboList('ablution_wash').toList(),
                                                        ),
                                                        (_visitDetail.ablutionWash=='good' || _visitDetail.ablutionWash=='')?Container():
                                                        CustomFormField(title: getField('ablution_wash_notes')!.label,
                                                          value: _visitDetail.ablutionWashNotes,onChanged:(val){
                                                            _visitDetail.ablutionWashNotes = val;
                                                            setState((){});
                                                          }
                                                          ,type: FieldType.textArea,
                                                        ),
                                                        CustomFormField(title: getField('electric_meter_violation')!.label,
                                                          value: _visitDetail.electricMeterViolation,onChanged:(val){
                                                            _visitDetail.electricMeterViolation = val;
                                                            setState((){});
                                                          }
                                                          ,type: FieldType.choice,
                                                          options:getComboList('electric_meter_violation').toList(),
                                                        ),
                                                        _visitDetail.electricMeterViolation=='yes'?
                                                        CustomFormField(title: getField('electric_meter_violation_note')!.label,
                                                          value: _visitDetail.electricMeterViolationNote,onChanged:(val){
                                                            _visitDetail.electricMeterViolationNote = val;
                                                            setState((){});
                                                          }
                                                          ,type: FieldType.textArea,
                                                        ):Container(),


                                                        CustomFormField(title: getField('water_meter_violation')!.label,
                                                          value: _visitDetail.waterMeterViolation,onChanged:(val){
                                                            _visitDetail.waterMeterViolation = val;
                                                            setState((){});
                                                          }
                                                          ,type: FieldType.choice,
                                                          options:getComboList('water_meter_violation').toList(),
                                                        ),

                                                        _visitDetail.waterMeterViolation=='yes'?
                                                        CustomFormField(title: getField('water_meter_violation_note')!.label,
                                                          value: _visitDetail.waterMeterViolationNote,onChanged:(val){
                                                            _visitDetail.waterMeterViolationNote = val;
                                                            setState((){});
                                                          }
                                                          ,type: FieldType.textArea,
                                                        ):Container(),

                                                        CustomFormField(title: getField('mosque_violation')!.label,
                                                          value: _visitDetail.mosqueViolation,onChanged:(val){
                                                            _visitDetail.mosqueViolation = val;
                                                            setState((){});
                                                          }
                                                          ,type: FieldType.choice,
                                                          options:getComboList('mosque_violation').toList(),
                                                        ),
                                                        _visitDetail.mosqueViolation=='yes' ?
                                                        CustomFormField(title: getField('water_meter_violation_note')!.label,
                                                          value: _visitDetail.mosqueViolationNote,onChanged:(val){
                                                            _visitDetail.mosqueViolationNote = val;
                                                            setState((){});
                                                          }
                                                          ,type: FieldType.textArea,
                                                        ):Container(),

                                                        CustomFormField(title:getField('cleaning_material')!.label,
                                                          value: _visitDetail.cleaningMaterial,onChanged:(val){
                                                            _visitDetail.cleaningMaterial = val;
                                                            setState((){});
                                                          }
                                                          ,type: FieldType.choice,
                                                          options:getComboList('cleaning_material').toList(),
                                                        ),
                                                        CustomFormField(title: getField('holy_quran_violation')!.label,
                                                          value: _visitDetail.holyQuranViolation,onChanged:(val){
                                                            _visitDetail.holyQuranViolation = val;
                                                            setState((){});
                                                          }
                                                          ,type: FieldType.choice,
                                                          options:getComboList('holy_quran_violation').toList(),
                                                        ),
                                                        _visitDetail.holyQuranViolation=='yes'?
                                                        CustomFormField(title: getField('holy_quran_violation_note')!.label,
                                                          value: _visitDetail.holyQuranViolationNote,onChanged:(val){
                                                            _visitDetail.holyQuranViolationNote = val;
                                                            setState((){});
                                                          }
                                                          ,type: FieldType.textArea,
                                                        ):Container(),

                                                        CustomFormField(title: getField('description')!.label,
                                                          value: _visitDetail.description,onChanged:(val){
                                                            _visitDetail.description = val;
                                                            setState((){});
                                                          }
                                                          ,type: FieldType.textArea,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: SecondaryButton(text: "back".tr(),onTab:(){
                                                      _tabController.animateTo(3);
                                                    }),
                                                  ),
                                                  Expanded(
                                                    child: SecondaryButton(text: "close".tr(),onTab:(){
                                                      isEditMode=false;
                                                      setState(() {

                                                      });
                                                    }),
                                                  ),
                                                  Expanded(
                                                    child: PrimaryButton(text: "save".tr(),onTab:(){
                                                      isEditMode=false;

                                                      updateDetail(_tabController.index);
                                                      

                                                      setState(() {

                                                      });

                                                    }),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ):Column(
                                            children: [
                                              Expanded(
                                                child: SingleChildScrollView(
                                                  child: Container(
                                                    padding: EdgeInsets.symmetric(horizontal: 15,vertical: 5),
                                                    child: Column(
                                                      children: [
                                                         AppListTitle2(title: getField('mosque_clean')!.label,subTitle: (_visit.mosqueClean??''),
                                                             selection:getComboList('mosque_clean'),isBar:true,context: context),
                                                        getComboList('mosque_clean').length==0 || getComboList('mosque_clean')[0].key==_visit.mosqueClean?Container():
                                                        AppListTitle2(title: getField('mosque_clean_notes')!.label,subTitle: _visit.mosqueCleanNotes),

                                                        AppListTitle2(title: getField('carpet_quality')!.label,subTitle: (_visit.carpetQuality??''),
                                                            selection:getComboList('carpet_quality'),isBar:true,context: context
                                                        ),
                                                        getComboList('carpet_quality').length==0 || getComboList('carpet_quality')[0].key==_visit.carpetQuality?Container():
                                                        AppListTitle2(title: getField('carpet_quality_notes')!.label,subTitle: _visit.carpetQualityNotes),

                                                        AppListTitle2(title: getField('wc_clean')!.label,subTitle: (_visit.wcClean??''),
                                                            selection:getComboList('wc_clean'),isBar:true,context: context
                                                        ),
                                                        getComboList('wc_clean').length==0 || getComboList('wc_clean')[0].key==_visit.wcClean?Container():
                                                        AppListTitle2(title: getField('wc_clean_notes')!.label,subTitle: _visit.wcCleanNotes),

                                                        AppListTitle2(title: getField('air_condition')!.label,subTitle: (_visit.airCondition??''),
                                                            selection:getComboList('air_condition'),isBar:true,context: context),
                                                        getComboList('air_condition').length==0 || getComboList('air_condition')[0].key==_visit.airCondition?Container():
                                                        AppListTitle2(title: getField('air_condition_notes')!.label,subTitle: _visit.airConditionNotes),

                                                        AppListTitle2(title: getField('sound_system')!.label,subTitle: _visit.soundSystem??'',
                                                            selection:getComboList('sound_system'),isBar:true,context: context
                                                        ),
                                                        getComboList('sound_system').length==0 || getComboList('sound_system')[0].key==_visit.soundSystem?Container():
                                                        AppListTitle2(title: getField('sound_system_notes')!.label,subTitle: _visit.soundSystemNotes),

                                                        AppListTitle2(title: getField('close_outside_horn')!.label??"",subTitle: _visit.closeOutsideHorn??'',
                                                            selection:getComboList('close_outside_horn'),isTag:true
                                                        ),

                                                        AppListTitle2(title: getField('inside_horn')!.label,subTitle: _visit.insideHorn??'',
                                                            selection:getComboList('inside_horn'),isBar:true,context: context),
                                                        AppListTitle2(title: getField('outside_horn')!.label,subTitle: _visit.outsideHorn??'',
                                                            selection:getComboList('outside_horn'),isBar:true,context: context),

                                                        AppListTitle2(title: getField('wc_maintenance')!.label,subTitle: _visit.wcMaintenance??'',
                                                            selection:getComboList('wc_maintenance'),isBar:true,context: context),
                                                        getComboList('wc_maintenance').length==0 ||  getComboList('wc_maintenance')[0].key==_visit.wcMaintenance?Container():
                                                        AppListTitle2(title: getField('wc_maintenance_notes')!.label,subTitle: _visit.wcMaintenanceNotes),

                                                        AppListTitle2(title: getField('ablution_wash')!.label,subTitle: _visit.ablutionWash??'',
                                                            selection:getComboList('ablution_wash'),isBar:true,context: context),
                                                        getComboList('ablution_wash').length==0 ||  getComboList('ablution_wash')[0].key==_visit.ablutionWash?Container():
                                                        AppListTitle2(title: getField('ablution_wash_notes')!.label,subTitle: _visit.ablutionWashNotes),

                                                        AppListTitle2(title: getField('electric_meter_violation')!.label,subTitle: _visit.electricMeterViolation??'',
                                                            selection:getComboList('electric_meter_violation'),isTag:true),
                                                        getComboList('electric_meter_violation').length==0 ||  getComboList('electric_meter_violation')[1].key==_visit.electricMeterViolation?Container():
                                                        AppListTitle2(title: getField('electric_meter_violation_note')!.label,subTitle: _visit.electricMeterViolationNote),

                                                        AppListTitle2(title: getField('water_meter_violation')!.label,subTitle: _visit.waterMeterViolation??'',
                                                            selection:getComboList('water_meter_violation'),isTag:true),
                                                        getComboList('water_meter_violation').length==0 ||  getComboList('water_meter_violation')[1].key==_visit.waterMeterViolation?Container():
                                                        AppListTitle2(title: getField('water_meter_violation_note')!.label,subTitle: _visit.waterMeterViolationNote),

                                                        AppListTitle2(title: getField('mosque_violation')!.label,subTitle: _visit.mosqueViolation??'',
                                                            selection:getComboList('mosque_violation'),isTag:true),
                                                        getComboList('mosque_violation').length==0 ||  getComboList('mosque_violation')[1].key==_visit.mosqueViolation?Container():
                                                        AppListTitle2(title: getField('mosque_violation_note')!.label,subTitle: _visit.mosqueViolationNote),

                                                        AppListTitle2(title: getField('cleaning_material')!.label,subTitle: _visit.cleaningMaterial??'',
                                                            selection:getComboList('cleaning_material'),isTag:true),

                                                        AppListTitle2(title: getField('holy_quran_violation')!.label,
                                                            subTitle: _visit.holyQuranViolation??'',
                                                            selection:getComboList('holy_quran_violation'),isTag:true),
                                                        getComboList('holy_quran_violation').length==0 ||  getComboList('holy_quran_violation')[1].key==_visit.holyQuranViolation?Container():
                                                        AppListTitle2(title: getField('holy_quran_violation_note')!.label,subTitle: _visit.holyQuranViolationNote),

                                                        AppListTitle2(title: getField('description')!.label,child: HtmlWidget(_visit.description??"")),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              // (isVisiablePermission  || _visit.dateOfVisit==null)?Container():Column(
                                              //   children: [
                                              //     Row(
                                              //       children: [
                                              //         Expanded(
                                              //           child: SecondaryButton(text: "Edit",onTab:(){
                                              //             startEdit();
                                              //           }),
                                              //         ),
                                              //         Expanded(
                                              //           child: PrimaryButton(text: "Send",onTab:(){
                                              //             sendVisit();
                                              //           }),
                                              //         ),
                                              //       ],
                                              //     ),
                                              //   ],
                                              // )
                                            ],
                                          ),
                                        ],
                                      ),
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
                  _visit.id==0?Container():_visit.btnStart!=true?Row(
                    children: [
                      Expanded(
                        child: Container(
                          color: Colors.white,
                          child: PrimaryButton(text: "start".tr(),onTab:(){
                            if(isVerifyDevice()){
                              startVisit();
                            }

                          }),
                        ),
                      ),
                    ],
                  ):Container(),
                  isVisiablePermission? Visibility(
                    visible:  isVisiablePermission,
                    child: Container(
                        margin: EdgeInsets.only(bottom: 0),
                        padding: EdgeInsets.all(10),
                        //height: 30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(0),
                          border: Border.all(
                            color: Colors.grey.shade200,  // Set this to the desired color when not authorized
                            width: 1.0,       // Adjust the width as needed
                          ),
                          color: permission.status==GPSPermissionStatus.authorize?AppColors.backgroundColor :AppColors.backgroundColor,
                        ),
                        child: Row(
                          children: [
                            permission.status==GPSPermissionStatus.authorize?Icon(Icons.check_circle,color: Colors.grey.shade500,):Icon(Icons.warning_amber,color: Colors.grey.shade400,),
                            SizedBox(width: 5,),
                            Expanded(
                                child: Text(permission.statusDesc,style: TextStyle(fontSize: 13 ,color: Colors.grey.shade500),)
                            ),
                            !permission.isCompleted?SizedBox(
                                height: 25.0,
                                width: 25.0,
                                child: CircularProgressIndicator(color: Colors.grey.shade500,)):permission.showTryAgainButton?
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
                                },child: Text('try_again'.tr(),style: TextStyle(color: Colors.grey.shade500,decoration: TextDecoration.underline,),)):Container() ,
                          ],
                        )
                    ),
                  ):Container(),
                  _visit.isActionButton?Row(
                    children: [
                      _visit.displayButtonAccept!?Expanded(
                        child: Container(
                          color: Colors.white,
                          child: PrimaryButton(text: "Accept",onTab:(){
                              if(isVerifyDevice()) {
                                //confirmSendVisit();
                                acceptVisit();
                              }
                          }),
                        ),
                      ):Container(),
                      _visit.displayButtonRefuse!?Expanded(
                        child: Container(
                          color: Colors.white,
                          child: DangerButton(text: "Refuse",onTab:(){
                              if(isVerifyDevice()) {
                                refuseVisit();
                              }

                          }),
                        ),
                      ):Container(),
                      _visit.displayButtonSetToDraft!?Expanded(
                        child: Container(
                          color: Colors.white,
                          child: SecondaryButton(text: "Draft State",onTab:(){
                              if(isVerifyDevice()) {
                                setDraftVisit();
                              }
                          }),
                        ),
                      ):Container(),
                    ],
                  ):Container(),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  (_visit!.displayButtonSend??false)!?Container(
                    padding: EdgeInsets.symmetric(horizontal: 3,vertical: 3),
                    child: DangerButton(text: "Send",onTab:(){
                          if(isVerifyDevice()) {
                            sendVisit();
                          }
                    },icon: FontAwesomeIcons.paperPlane),
                  ):Container(),
                ],
              ),
              isLoading
                  ? ProgressBar()
                  : SizedBox.shrink(),
            ],
          ),
        ),
        floatingActionButton: (!isEditMode && isVisiablePermission==false && _visit.btnStart==true && _visit.state=='draft' && (_visit.observerId==userProvider.userProfile.employeeId))?FloatingActionButton(
          onPressed: (){
             // isEditMode=true;
             // _visitDetail=Visit.shallowCopy(_visit);

          if(isVerifyDevice()) {
            permission = new GPSPermission(
              allowDistance: 100,
              latitude: (_mosqueDetail!.latitude??0),
              longitude: (_mosqueDetail!.longitude??0),
            );
            setState(() {
              isVisiablePermission = true;
            });
            permission.checkPermission();
            permission.listner.listen((value) {
              if (value) {
                isEditMode = true;
                _visitDetail = Visit.shallowCopy(_visit);
                setState(() {
                  isVisiablePermission = false;
                });
              }
              setState(() {

              });
            });
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
