import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:enhance_stepper/enhance_stepper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:mosque_management_system/constants/app_colors.dart';
import 'package:mosque_management_system/data/models/User.dart';
import 'package:mosque_management_system/data/models/base_state.dart';
import 'package:mosque_management_system/data/models/center.dart';
import 'package:mosque_management_system/data/models/combo_list.dart';
import 'package:mosque_management_system/data/models/distract.dart';
import 'package:mosque_management_system/data/models/employee.dart';
import 'package:mosque_management_system/data/models/employee_category.dart';
import 'package:mosque_management_system/data/models/mosque.dart';
import 'package:mosque_management_system/data/models/region.dart';
import 'package:mosque_management_system/data/models/res_city.dart';
import 'package:mosque_management_system/data/models/userProfile.dart';
import 'package:mosque_management_system/data/models/visit.dart';
import 'package:mosque_management_system/data/repositories/custom_odoo_client.dart';
import 'package:mosque_management_system/data/repositories/common_repository.dart';
import 'package:mosque_management_system/data/services/mosque_service.dart';
import 'package:mosque_management_system/data/services/user_service.dart';
import 'package:mosque_management_system/data/services/visit_service.dart';
import 'package:mosque_management_system/list/center_list.dart';
import 'package:mosque_management_system/list/city_list.dart';
import 'package:mosque_management_system/list/combo_list.dart';
import 'package:mosque_management_system/list/district_list.dart';
import 'package:mosque_management_system/list/mosque_list.dart';
import 'package:mosque_management_system/list/mosque_user_list.dart';
import 'package:mosque_management_system/list/multi_item_list.dart';
import 'package:mosque_management_system/list/region_list.dart';
import 'package:mosque_management_system/presentation/screens/all_mosques.dart';
import 'package:mosque_management_system/presentation/screens/create_employee.dart';
import 'package:mosque_management_system/presentation/screens/mosque_detail.dart';
import 'package:mosque_management_system/presentation/screens/visit_detail.dart';
import 'package:mosque_management_system/providers/user_provider.dart';
import 'package:mosque_management_system/utils/config.dart';
import 'package:mosque_management_system/utils/gps_permission.dart';
import 'package:mosque_management_system/utils/json_utils.dart';
import 'package:mosque_management_system/widgets/ProgressBar.dart';
import 'package:mosque_management_system/widgets/app_form_field.dart';
import 'package:mosque_management_system/widgets/app_list_title.dart';
import 'package:mosque_management_system/widgets/bottom_navigation.dart';
import 'package:mosque_management_system/widgets/custom_enhance_stepper.dart';
import 'package:mosque_management_system/widgets/service_button.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'package:provider/provider.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class CreateVisit extends StatefulWidget {
  final CustomOdooClient client;
  CreateVisit({required this.client});
  @override
  _CreateVisitViewState createState() => _CreateVisitViewState();
}
class _CreateVisitViewState extends BaseState<CreateVisit> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late VisitService _visitService;

  List<Employee> _imams=[];
  List<Employee> _muezzin=[];
  List<Employee> _khadem=[];
  List<Employee> _khatib=[];
  bool isSaving=true;
  UserProfile _userProfile =UserProfile(userId: 0);
  EmployeeCategoryData categoryData=EmployeeCategoryData();
  Employee newEmployee=Employee(id: 0);
  Visit newVisit=Visit(id: 0);

  @override
  void initState(){
    super.initState();
    _visitService = VisitService(this.widget.client!);

    Future.delayed(Duration.zero, () {
      _visitService.loadVisitView().then((list){
        fields.list=list;
        setState(() {
          isSaving=false;
        });
      }).catchError((e){
        setState(() {
          isSaving=false;
        });
      });
    });
  }
  late UserProvider userProvider;


  final _formKey = GlobalKey<FormState>();
  FieldListData fields=FieldListData();
  createVisit(){
    setState(() {
      isSaving=true;
    });
    newVisit.createdById=userProvider.userProfile.userId;
    _visitService!.createOnDemandVisit(newVisit).then((value){

      
      setState(() {
        isSaving=false;
      });

      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
          new VisitDetail(client: this.widget.client,visitIdId: value,),
        ),
      );

      // Navigator.of(context).pop();
    }).catchError((e){

      setState(() {
        isSaving=false;
      });
      Flushbar(
        icon: Icon(Icons.warning,color: Colors.white,),
        backgroundColor: AppColors.danger,
        message: e.message.toString(),
        duration: Duration(seconds: 3),
      ).show(context);
    });

    // await Future.delayed(Duration(seconds: 2));
    // setState(() {
    //   _index = 2;
    //   isSaving=false;
    // });
  }
  showMosqueModal(){
    showModalBottomSheet(

      context: context,
      builder: (BuildContext context) {
        return MosqueList(client: this.widget.client,
          title: fields.getField('mosque_seq_no').label,
          onItemTap: (Mosque val){
            newVisit.mosqueSequenceNoId=val.id;
            newVisit.mosqueSequenceNo=val.name;
         
            setState(() {

            });
            Navigator.of(context).pop();

          },);
      },
    );
  }
  showObserverModal(){

    showModalBottomSheet(

      context: context,
      builder: (BuildContext context) {
        return MosqueUserList(client: this.widget.client,
          type: "obs",
          title: fields.getField('observer').label,

          supervisorId: userProvider.userProfile.employeeId,

          onItemTap: (Employee val){

            newVisit.observer=val.name;
            newVisit.observerId=val.id;
            setState(() {

            });
            Navigator.of(context).pop();
          },);
      },
    );
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    userProvider = Provider.of<UserProvider>(context);
    _visitService.updateUserProfile(userProvider.userProfile);
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(

      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: Container(

          child: Stack(
            children: [
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 15,vertical: 5),
                    //height: 170,
                    child:
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 5,vertical: 5),
                                child: Row(
                                  children: [
                                    Icon(Icons.arrow_back,color: Theme.of(context).colorScheme.onPrimary.withOpacity(.5),size: 25 , ),
                                    Text('create_new_visit'.tr(),style: TextStyle(color: AppColors.onPrimary,fontSize: 20),)
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: Container(

                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15.0),
                            topRight: Radius.circular(15.0),
                          ),
                          color: Colors.white

                      ),
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      //decoration: BodyBoxDecoration4(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Expanded(
                            child: SingleChildScrollView(
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    SizedBox(height: 10,),
                                    CustomFormField(title: fields.getField('mosque_seq_no').label,onTab: (){
                                      showMosqueModal();
                                    },value: newVisit.mosqueSequenceNo,isReadonly:true,isSelection:true,isRequired: true,),

                                    CustomFormField(title: fields.getField('observer').label,onTab: (){
                                      showObserverModal();
                                    },value: newVisit.observer,isReadonly:true,isSelection:true,isRequired: true,),

                                    AppListTitle2(title: fields.getField('visit_type')!.label,subTitle: 'ondemand',selection:fields.getComboList('visit_type'),hasDivider: false),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: PrimaryButton(text: "create".tr(),onTab: ()async{
                                  if (_formKey.currentState!.validate()) {
                                    _formKey.currentState!.save();
                                    createVisit();
                                  }

                                }),
                              ),
                            ],
                          )

                        ],
                      ),
                    ),
                  ),
                ],
              ),
              isSaving
                  ? ProgressBar()
                  : SizedBox.shrink(),
            ],
          ),
        ),
        //bottomNavigationBar:this.widget.client==null?null:BottomNavigation(client: this.widget.client!,selectedIndex: 2),
      ),
    );
  }
}
