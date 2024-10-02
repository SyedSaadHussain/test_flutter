import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mosque_management_system/constants/app_colors.dart';
import 'package:mosque_management_system/data/models/base_state.dart';
import 'package:mosque_management_system/data/models/combo_list.dart';
import 'package:mosque_management_system/data/models/employee_category.dart';
import 'package:mosque_management_system/data/models/userProfile.dart';
import 'package:mosque_management_system/data/repositories/custom_odoo_client.dart';
import 'package:mosque_management_system/data/repositories/common_repository.dart';
import 'package:mosque_management_system/data/services/mosque_service.dart';
import 'package:mosque_management_system/data/services/user_service.dart';
import 'package:mosque_management_system/providers/user_provider.dart';
import 'package:mosque_management_system/utils/config.dart';
import 'package:mosque_management_system/utils/extension.dart';
import 'package:mosque_management_system/utils/json_utils.dart';
import 'package:mosque_management_system/widgets/ProgressBar.dart';
import 'package:mosque_management_system/widgets/app_form_field.dart';
import 'package:mosque_management_system/widgets/app_list_title.dart';
import 'package:mosque_management_system/widgets/app_title.dart';
import 'package:mosque_management_system/widgets/bottom_navigation.dart';
import 'package:mosque_management_system/widgets/image_data.dart';
import 'package:mosque_management_system/widgets/tag_button.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'package:provider/provider.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class Profile extends StatefulWidget {
  final CustomOdooClient client;
  Profile({required this.client});
  @override
  _ProfileViewState createState() => _ProfileViewState();
}
class _ProfileViewState extends BaseState<Profile> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


  late UserService _userService;
  UserProfile _userProfile =UserProfile(userId: 0);
  dynamic userInfo= {};
  FieldListData fields=FieldListData();
  @override
  void initState(){
    super.initState();
  
    _userService = UserService(this.widget.client);
    Future.delayed(Duration.zero, () {
      getUserProfile();
       loadTranslation();
    });

  }
  bool isSaving=true;
  void loadTranslation(){
    _userService.loadEmployeeView().then((list){

      fields.list=list;
      setState(() {
        isSaving=false;
      });

    }).catchError((e){
      setState(() {
        isSaving=false;
      });
    });
  }
  void getUserProfile(){
   

    _userService!.getEmployeeDetail().then((value){
      userInfo=value[0];

      setState((){});

      
      loadEmployeeCategory(JsonUtils.toList(userInfo["category_ids"]));

  

    }).catchError((e){
      //isLoading=false;
      setState((){});
    });
  }
  EmployeeCategoryData categoryData=EmployeeCategoryData();
  void loadEmployeeCategory(List<int>? ids){

    _userService.getEmployeeCategoryIds(ids: ids).then((value){
    
      categoryData.list=value;
      setState(() {

      });

    }).catchError((e){

    });
  }

  bool notificationsEnabled = true;
  int notificationInterval = 15;
  late UserProvider userProvider;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    userProvider = Provider.of<UserProvider>(context);
    _userService!.updateUserProfile(userProvider.userProfile);
  }
  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<UserProvider>(context);
    _userService.repository.userProfile=userProvider.userProfile;
    return SafeArea(

      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: Container(
          color: Colors.grey.withOpacity(.08),
          child: Stack(
            children: [
              Column(
                children: [
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.start,
                  //   crossAxisAlignment: CrossAxisAlignment.center,
                  //   children: [
                  //     GestureDetector(
                  //       onTap: () {
                  //         Navigator.pop(context);
                  //       },
                  //       child: Padding(
                  //         padding: const EdgeInsets.symmetric(horizontal: 5),
                  //         child: Icon(Icons.arrow_back,color: Theme.of(context).colorScheme.onPrimary.withOpacity(.5),size: 25 , ),
                  //       ),
                  //     ),
                  //
                  //   ],
                  // ),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 15,vertical: 5),
                    //height: 170,
                    child:
                    Column(
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children:[
                              ImageData(id: JsonUtils.toInt(userInfo["id"])??0, modelName: Model.employee, fieldId: "avatar_128",baseUrl: userProvider.baseUrl, headersMap: _userService.headersMap,width: 70,height: 80,),
                              SizedBox(width: 8,),
                              Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                     Text(JsonUtils.toText(userInfo["display_name"])??"",style: TextStyle(color: AppColors.onPrimary,fontSize: 18),),

                                      Text(JsonUtils.toText(userInfo["job_title"])??"",style: TextStyle(color: AppColors.onPrimary,fontSize: 13),  softWrap: true,),
                                      Row(
                                        children: categoryData.list.map((rec){
                                          return CustomTag(title:rec.name.toString(),colorId:rec.color,isActive: true );
                                        }).toList(),
                                      )
                                    ],
                                  )
                              ),
                            ]


                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10.0),
                          topRight: Radius.circular(10.0),
                        ),
                        color: Colors.white

                      ),
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      //decoration: BodyBoxDecoration4(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [

                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  SizedBox(height: 5,),
                                  AppTitle2("User Info", Icons.person),
                                  Container(
                                    padding: EdgeInsets.all(5),
                                    margin: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: Colors.grey.shade200, // You can change this color to match your design
                                        width: 1, // Width of the border in pixels
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        AppListTitle2(title: fields.getField('birthday').label,subTitle: JsonUtils.toText(userInfo["birthday"])??"",isDate: true),
                                        AppListTitle2(title: fields.getField('identification_id').label,subTitle: JsonUtils.toText(userInfo["identification_id"])??""),
                                        AppListTitle2(title: fields.getField('staff_relation_type').label,subTitle: JsonUtils.toText(userInfo["staff_relation_type"])??"", selection:fields.getComboList('staff_relation_type')),
                                        AppListTitle2(title: fields.getField('classification_id').label,subTitle: JsonUtils.getName(userInfo["classification_id"])??"",hasDivider:false),


                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 10,),
                                  AppTitle2("Work Information", Icons.shopping_bag),
                                  Container(
                                    padding: EdgeInsets.all(5),
                                    margin: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: Colors.grey.shade200, // You can change this color to match your design
                                        width: 1, // Width of the border in pixels
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        AppListTitle2(title: fields.getField('mobile_phone').label,subTitle: JsonUtils.toText(userInfo["mobile_phone"])??""),
                                        AppListTitle2(title: fields.getField('work_phone').label,subTitle: JsonUtils.toText(userInfo["work_phone"])??""),
                                        AppListTitle2(title: fields.getField('work_email').label,subTitle: JsonUtils.toText(userInfo["work_email"])??""),
                                        AppListTitle2(title: fields.getField('address_id').label,subTitle: JsonUtils.getName(userInfo["address_id"])??""),
                                        AppListTitle2(title: fields.getField('new_city_id').label,subTitle: JsonUtils.getName(userInfo["new_city_id"])??""),
                                        AppListTitle2(title: fields.getField('moi_center').label,subTitle: JsonUtils.getName(userInfo["moi_center"])??""),
                                        AppListTitle2(title: fields.getField('district_id').label,subTitle: JsonUtils.getName(userInfo["district_id"])??""),
                                        AppListTitle2(title: fields.getField('parent_id').label,subTitle: JsonUtils.getName(userInfo["parent_id"])??"",hasDivider: false),


                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

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
        bottomNavigationBar:this.widget.client==null?null:BottomNavigation(client: this.widget.client!,selectedIndex: 2),
      ),
    );
  }
}
