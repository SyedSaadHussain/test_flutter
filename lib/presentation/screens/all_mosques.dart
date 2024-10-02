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
import 'package:mosque_management_system/data/repositories/custom_odoo_client.dart';
import 'package:mosque_management_system/data/services/mosque_service.dart';
import 'package:mosque_management_system/data/services/user_service.dart';
import 'package:mosque_management_system/presentation/screens/mosque_detail.dart';
import 'package:mosque_management_system/providers/user_provider.dart';
import 'package:mosque_management_system/utils/config.dart';
import 'package:mosque_management_system/widgets/ProgressBar.dart';
import 'package:mosque_management_system/widgets/image_data.dart';
import 'package:mosque_management_system/widgets/tag_button.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'package:provider/provider.dart';

class AllMosques extends StatefulWidget {
  final CustomOdooClient client;
  final dynamic? filter;
  AllMosques({required this.client,this.filter});
  @override
  _AllMosquessState createState() => _AllMosquessState();
}
class _AllMosquessState extends BaseState<AllMosques> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late OdooClient client;
  MosqueService? _mosqueService;
  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);
  String convertToDisplayString(String status) {
    List<String> parts = status.split('_'); // Split by underscores
    List<String> capitalizedParts = parts.map((part) => capitalize(part)).toList();
    return capitalizedParts.join(' '); // Join parts with spaces
  }
  dynamic? filterField;
  dynamic? filterValue;
  int activeButtonIndex = 0;
  @override
  void initState(){

    super.initState();
    _mosqueService = MosqueService(this.widget.client!);
 
    filterField=(this.widget.filter?? {})["default_filter"];
    filterValue=(this.widget.filter?? {})["filtervalue"];
    filterValue=filterValue==0?null:filterValue;
    //filterValue=189;
    activeButtonIndex=filterValue??0;

    Future.delayed(Duration.zero, () {
      // This code will run after the current frame
      getStages();
    });
    //getContacts(true);
  }
  List<ComboItem>? stages;
  void getStages(){
    _mosqueService!.getMosqueStages().then((value){
      stages=value;
      setState(() {

      });
    }).catchError((e){

    });
  }
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  MosqueData _mosqueData =MosqueData();
  String query='';
  void filterList() {
    query=_searchController.text;
    getMosques(true);
  }
  void clearSearch(String searchText) {
    if(searchText==''){
      query=searchText;
      getMosques(true);
    }
  }
  void getMosques(bool isReload){
   
    if(isReload){
      _mosqueData.reset();
    }
    _mosqueData.init();
    // setState(() {});

    _mosqueService!.getAllMosques(_mosqueData.pageSize,_mosqueData.pageIndex,query,filterField:filterField,filterValue: filterValue ).then((value){

      _mosqueData.isloading=false;
      if(value.list==null || value.list.isEmpty)
        _mosqueData.hasMore=false;
      else {
        _mosqueData.count=value.count;
        _mosqueData.list!.addAll(value.list!.toList());
      }
      setState((){});
    }).catchError((e){


      _mosqueData.hasMore=false;
      _mosqueData.isloading=false;
      setState((){});
      Flushbar(
        icon: Icon(Icons.warning,color: Colors.white,),
        backgroundColor: AppColors.danger,
        message: e.message,
        duration: Duration(seconds: 3),
      ).show(context);

    });
  }
  Widget buildRoundButton(int index,String title) {
    return GestureDetector(
      onTap: () {
        setState(() {
          activeButtonIndex = index; // Update the active button index
        });
        getMosques(true);
      },
      child: Container(
        // width: 50,
        //height: 50,
        margin: EdgeInsets.symmetric(horizontal: 3),
        padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(15), // Adjust the radius as needed
          color: activeButtonIndex == index ? AppColors.secondly : Colors.transparent,
          border: Border.all(color: AppColors.secondly),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(color: activeButtonIndex == index ? Colors.white : AppColors.secondly),
        ),
      ),
    );
  }
  TextEditingController _searchController = TextEditingController();


  late UserProvider userProvider;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    userProvider = Provider.of<UserProvider>(context);
    _mosqueService!.updateUserProfile(userProvider.userProfile);
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('mosques'.tr()),
        ),
        backgroundColor: Colors.white,
        key: _scaffoldKey,
        body: Container(
          color: Colors.grey.withOpacity(.08),
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
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
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
                            }
                            ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 8),

                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
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
                                getMosques(true);
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
                                  getMosques(true);
                                },
                              );
                            }).toList()],
                        ),
                      ),
                    ),
                  ],
                ),
              ),




              (_mosqueData.isloading==false && _mosqueData.list!.length==0)?Center(child: Text('no_record_found'.tr(),style: TextStyle(color: Colors.grey),)):Container(),

              Expanded(
                child: Container(

                  padding: EdgeInsets.all(5),

                  child: ListView.builder(
                    itemCount: _mosqueData.list!.length+((_mosqueData.hasMore)?1:0),
                    itemBuilder: (context, index) {
                      if(index >= _mosqueData.list!.length)
                      {
                        if(_mosqueData.isloading==false) {
                          _mosqueData.pageIndex = _mosqueData.pageIndex + 1;
                          getMosques(false);
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
                          padding: EdgeInsets.symmetric(horizontal: 5,vertical: 0),
                          margin: EdgeInsets.symmetric(horizontal: 3,vertical: 1),
                          child: ListTile(
                            onTap: (){

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => new MosqueDetail(client: this.widget.client,
                                    mosqueId: _mosqueData.list[index].id,
                                    onCallback: (){
                                      getMosques(true);
                                    },),
                                  //HalqaId: 1
                                ),
                              );
                            },

                            contentPadding: EdgeInsets.all(0),


                            // Container(
                            //   height: 60,
                            //   width: 60,
                            //   child: Image.network('${Config.baseUrl}/web/image?model=mosque.mosque&field=outer_image&id=${_mosqueData.list[index].id}&unique=${_mosqueData.list[index].uniqueId}',headers: _mosqueService!.headersMap,fit: BoxFit.fitHeight,
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
                            title: Container(
                              //color: Colors.lightBlueAccent,

                              child: Row(
                                children: [
                                  ImageData(id: _mosqueData.list[index].id??0, modelName: Model.mosque, fieldId: "outer_image",uniqueId: _mosqueData.list[index].uniqueId,baseUrl: userProvider.baseUrl,headersMap: _mosqueService!.headersMap,height: 70,width: 60,),

                                  Expanded(child:Container(
                                    padding: EdgeInsets.symmetric(horizontal: 5),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text(_mosqueData.list[index].name??'',style: TextStyle(color:Colors.black.withOpacity(.7),fontSize: 15),),
                                        _mosqueData.list[index].city==null?Container():Text(_mosqueData.list[index].city!,style: TextStyle(color:Colors.grey),),
                                        Text(convertToDisplayString(_mosqueData.list[index].stage??""),style: TextStyle(color:Colors.grey),),

                                      ],
                                    ),
                                  )),
                                  // Text(_mosqueData.list[index].state??''),


                                ],
                              ),
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
