import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:mosque_management_system/constants/app_colors.dart';
import 'package:mosque_management_system/constants/input_decoration_themes.dart';
import 'package:mosque_management_system/data/models/base_state.dart';
import 'package:mosque_management_system/data/models/combo_list.dart';
import 'package:mosque_management_system/data/models/mosque.dart';
import 'package:mosque_management_system/data/models/visit.dart';
import 'package:mosque_management_system/data/repositories/custom_odoo_client.dart';
import 'package:mosque_management_system/data/services/mosque_service.dart';
import 'package:mosque_management_system/data/services/user_service.dart';
import 'package:mosque_management_system/data/services/visit_service.dart';
import 'package:mosque_management_system/presentation/screens/mosque_detail.dart';
import 'package:mosque_management_system/presentation/screens/visit_detail.dart';
import 'package:mosque_management_system/providers/user_provider.dart';
import 'package:mosque_management_system/utils/config.dart';
import 'package:mosque_management_system/utils/gps_permission.dart';
import 'package:mosque_management_system/utils/json_utils.dart';
import 'package:mosque_management_system/widgets/ProgressBar.dart';
import 'package:mosque_management_system/widgets/image_data.dart';
import 'package:mosque_management_system/widgets/tag_button.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'package:provider/provider.dart';

class TodayVisits extends StatefulWidget {
  final CustomOdooClient client;
  final dynamic? filter;
  TodayVisits({required this.client,this.filter});
  @override
  _TodayVisitsState createState() => _TodayVisitsState();
}
class _TodayVisitsState extends BaseState<TodayVisits> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late OdooClient client;
  VisitService? _visitService;
  String query='';
  dynamic? filterField;
  dynamic filterValue;
  int activeButtonIndex = 0;
  @override
  void initState(){
    super.initState();

    _visitService = VisitService(this.widget.client!);
    filterField=(this.widget.filter?? {})["default_filter"];
    filterValue=(this.widget.filter?? {})["filtervalue"];
    filterValue=filterValue==0?null:filterValue;
    //filterValue=193;
    activeButtonIndex=filterValue??0;


    Future.delayed(Duration.zero, () {
      // This code will run after the current frame
      getVisitStages();
    });
    //getContacts(true);
  }
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  VisitData _visitData =VisitData();
  void filterList() {
    FocusScope.of(context).unfocus();
    query=_searchController.text;
    getVisits(true);
  }
  List<ComboItem>? stages;
  void getVisitStages(){

    _visitService!.getVisitStages().then((value){
      stages=value;
      setState(() {

      });
    }).catchError((e){

    });
  }
  void clearSearch(String searchText) {
    if(searchText==''){
      query=searchText;
      getVisits(true);
    }
  }
  void getVisits(bool isReload){
    if(isReload){
      _visitData.reset();
      setState(() {

      });
      
      // return;
    }
    _visitData.init();



    _visitService!.getVisits(_visitData.pageSize,_visitData.pageIndex,query,filterField:filterField,filterValue: filterValue ).then((value){
      _visitData.isloading=false;
      if(value.list==null || value.list.isEmpty)
        _visitData.hasMore=false;
      else {
        _visitData.count=value.count;
        _visitData.list!.addAll(value.list!.toList());
      }
      setState((){});
    }).catchError((e){

    });
  }

  TextEditingController _searchController = TextEditingController();
  bool isVisiablePermission=false;
  late GPSPermission permission;

  late UserProvider userProvider;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    userProvider = Provider.of<UserProvider>(context);
    _visitService!.updateUserProfile(userProvider.userProfile);
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('search_visits'.tr()),
        ),

        key: _scaffoldKey,
        body: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Container(
              //   padding: EdgeInsets.symmetric(horizontal: 10,vertical: 0),
              //   child: TextField(
              //     onSubmitted: filterList,
              //     onChanged: clearSearch,
              //     decoration: InputDecoration(
              //       contentPadding: EdgeInsets.all(15),
              //       prefixIcon: Icon(Icons.search, color: Colors.grey),
              //       filled: true,
              //       fillColor: Colors.grey[200], // Background color
              //       border: OutlineInputBorder(
              //         borderRadius: BorderRadius.circular(20.0), // Rounded corners
              //         borderSide: BorderSide.none, // Remove border
              //       ),
              //       enabledBorder: OutlineInputBorder(
              //         borderRadius: BorderRadius.circular(20.0), // Rounded corners
              //         borderSide: BorderSide.none, //
              //       ),
              //       focusedBorder: OutlineInputBorder(
              //         borderRadius: BorderRadius.circular(20.0), // Rounded corners
              //         borderSide: BorderSide.none, //
              //       ),
              //       hintText: 'search_here'.tr(),
              //       hintStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),
              //     ),
              //   ),
              // )
              isVisiablePermission? Visibility(
                visible:  isVisiablePermission,
                child: Container(
                    margin: EdgeInsets.only(bottom: 5),
                    padding: EdgeInsets.all(10),
                    //height: 30,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7),
                      color: permission.status==GPSPermissionStatus.authorize?AppColors.primaryText :AppColors.primaryText,
                    ),
                    child: Row(
                      children: [
                        permission.status==GPSPermissionStatus.authorize?Icon(Icons.check_circle,color: AppColors.success,):Icon(Icons.warning_amber,color: AppColors.warning,),
                        SizedBox(width: 5,),
                        Expanded(
                            child: Text(permission.statusDesc,style: TextStyle(fontSize: 13 ,color: permission.status==GPSPermissionStatus.authorize?AppColors.success: AppColors.warning),)
                        ),
                        !permission.isCompleted?SizedBox(
                            height: 25.0,
                            width: 25.0,
                            child: CircularProgressIndicator(color: AppColors.warning,)):permission.showTryAgainButton?
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
                            },child: Text('tryAgain',style: TextStyle(color: AppColors.warning,decoration: TextDecoration.underline,),)):Container() ,
                      ],
                    )
                ),
              ):Container(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10,vertical: 0),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: Offset(0, 2), // changes position of shadow
                          ),
                        ],
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 0,vertical: 5),
                      child: TextField(
                        controller:_searchController ,
                        onEditingComplete: () {
                          // Your code here, triggered when the user submits the input
                          filterList();
                        },
                        onChanged: (val){
                          if(val.isEmpty)
                            filterList();
                        },
                        style: TextStyle(color: AppColors.gray),
                        decoration: MyInputDecorationThemes.secondInputDecoration(context,label: "search".tr(),icon: Icons.search,
                        onTab: (){
                          filterList();
                        },control: _searchController
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 8),

                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child:  Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children:  [
                            TagButton(
                              index: 0,
                              activeButtonIndex: activeButtonIndex,
                              title: "All",
                              onChange: () {
                                setState(() {
                                  filterValue=null;
                                  activeButtonIndex = 0;
                                });
                                // Call your function here
                                getVisits(true);
                              },
                            ),

                            ...(stages??[])!.map((stage) {
                              return TagButton(
                                index: stage.key,
                                activeButtonIndex: activeButtonIndex,
                                title: (stage.value??""),
                                onChange: () {
                                  setState(() {
                                    filterValue=stage.key;
                                    activeButtonIndex = stage.key;
                                  });
                                  // Call your function here
                                  getVisits(true);
                                },
                              );
                            }).toList()],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              (_visitData.isloading==false && _visitData.list!.length==0)?Center(child: Text('no_record_found'.tr(),style: TextStyle(color: Colors.grey),)):Container(),
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15.0),
                      topRight: Radius.circular(15.0),
                      bottomLeft: Radius.circular(15.0),
                      bottomRight: Radius.circular(15.0),
                    ),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child: ListView.builder(
                    itemCount: _visitData.list!.length+((_visitData.hasMore)?1:0),
                    itemBuilder: (context, index) {
                      if(index >= _visitData.list!.length)
                      {
                        if(_visitData.isloading==false){
                          _visitData.pageIndex=_visitData.pageIndex+1;
                          getVisits(false);
                        }
                        return Container(
                            height: 100,
                            child: ProgressBar(opacity: 0));
                      }else{
                        return Container(

                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.grey.shade200, // Change this to your desired border color
                              width: 1.0, // Adjust the width as needed
                            ),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                          margin: EdgeInsets.symmetric(horizontal: 3,vertical: 1),
                          child: ListTile(
                            onTap: (){

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => new VisitDetail(
                                    client: this.widget.client,
                                    visitIdId: _visitData.list[index].id!,
                                    onCallback: (){
                                      getVisits(true);
                                    },
                                  ),
                                  //HalqaId: 1
                                ),
                              );
                            },

                            contentPadding: EdgeInsets.all(0),

                            // leading:

                            title: Row(
                              children: [
                                ImageData(id: _visitData.list[index].mosqueSequenceNoId??0, modelName: Model.mosque, fieldId: "outer_image",uniqueId: _visitData.list[index].uniqueId,baseUrl: userProvider.baseUrl,headersMap: _visitService!.headersMap,height: 80,width: 70,),

                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.all(5),
                                    //color: Colors.lightBlueAccent,

                                    child:
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Expanded(child:Text(_visitData.list[index].mosqueSequenceNo??'',style: TextStyle(color:Colors.black.withOpacity(.7),fontSize: 12),)),


                                            ],
                                          ),
                                          // Text(_visitData.list[index].priority.toString()),
                                          Text(_visitData.list[index].name.toString(),style: TextStyle(color:Colors.grey,fontSize: 12),),
                                          Text(_visitData.list[index].stage??"" ,style: TextStyle(color:Colors.grey,fontSize: 12),),
                                          _visitData.list[index].dateOfVisitGreg==null?Container():Text(_visitData.list[index].dateOfVisitGreg.toString()!,style: TextStyle(color:Colors.grey,fontSize: 12),),
                                        ],
                                      )
                                  ),
                                ),
                              ],
                            ),

                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
