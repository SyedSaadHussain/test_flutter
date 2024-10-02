import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:mosque_management_system/constants/app_colors.dart';
import 'package:mosque_management_system/data/models/center.dart';
import 'package:mosque_management_system/data/models/region.dart';
import 'package:mosque_management_system/data/repositories/custom_odoo_client.dart';
import 'package:mosque_management_system/data/services/user_service.dart';
import 'package:mosque_management_system/providers/user_provider.dart';
import 'package:mosque_management_system/widgets/ProgressBar.dart';
import 'package:provider/provider.dart';
import 'dart:io' as io;

class CenterList extends StatefulWidget {
  final CustomOdooClient client;
  final Function onItemTap;
  final int cityId;
  CenterList({required this.client,required this.onItemTap,required this.cityId});
  @override
  _CenterListState createState() => _CenterListState();
}

class _CenterListState extends State<CenterList> {
  MoiCenterData regionData= MoiCenterData();
  List<Region> filteredUsers= [];
  UserService? _userService;

  TextEditingController _controller = TextEditingController();
  List<String> items = [
    'Apple',
    'Banana',
    'Cherry',
    'Date',
    'Elderberry',
    'Fig',
    'Grape',
    'Honeydew'
  ];
  List<String> filteredItems = [];

  @override
  void initState() {
    
    filteredItems.addAll(items);
    _userService = UserService(this.widget.client!);
    super.initState();
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void filterSearchResults(String query) {
    List<String> searchList = items.where((item) => item.toLowerCase().contains(query.toLowerCase())).toList();
    setState(() {
      filteredItems.clear();
      filteredItems.addAll(searchList);
    });
  }
  void searchRecords(bool isReload){
    
    if(isReload){
      regionData.list=[];
      regionData.pageIndex=1;
    }

    _userService!.getCenter(10,regionData.pageIndex,this.widget.cityId,_controller.text).then((value){
      regionData.hasMore=true;
      regionData.isloading=true;
      if(regionData.pageIndex>1){
        if(value==null || value.isEmpty){
          setState((){
            regionData.isloading=false;
            regionData.hasMore=false;
          });
        }else{
          setState((){
            regionData.list!.addAll(value!.toList());
            regionData.isloading=false;
          });
        }
      }else{
        setState((){
          regionData.list=value;
          regionData.isloading=false;
        });
      }
    });
  }
  late UserProvider userProvider;
  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<UserProvider>(context);
    _userService!.repository.userProfile=userProvider.userProfile;
    return Container(
      // margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8), // Adjust top radius here
          topRight: Radius.circular(8),
        ),
      ),

      child: Container(
        margin: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _controller,
              onChanged: (val){
                setState(() {

                });
              },

              onSubmitted: (value) {
                searchRecords(true);
              },
              decoration: InputDecoration(
                hintText: 'search'.tr(),
                suffixIcon: Container(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _controller.text.isEmpty
                          ?Container(): IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {

                          _controller.clear();
                          searchRecords(true);
                          FocusScope.of(context).unfocus();
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {
                          searchRecords(true);
                          FocusScope.of(context).unfocus();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Expanded(

              child: ListView.builder(
                itemCount: regionData.list!.length+((regionData.hasMore)?1:0),
                itemBuilder: (BuildContext context, int index) {
                  if(index >= regionData.list!.length)
                  {
                    regionData.pageIndex=regionData.pageIndex+1;
                    searchRecords(false);
                    return Container(
                        height: 100,
                        child: ProgressBar(opacity: 0));
                  }else {
                    return Container(
                      padding: EdgeInsets.symmetric(vertical: 0),

                      decoration: BoxDecoration(
                        color:  index % 2 == 0 ? Colors.grey[100] : Colors.white,
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey.shade100, // Change color as needed
                            width: 1.0, // Change thickness as needed
                          ),
                        ),
                      ),
                      child: ListTile(
                        title: Text(regionData.list[index].name??"",style: TextStyle(fontWeight: FontWeight.w300,color: AppColors.body),),
                        onTap: () {
                          
                          this.widget.onItemTap(regionData.list[index]);
                        },
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}