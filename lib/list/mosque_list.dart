import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:mosque_management_system/constants/app_colors.dart';
import 'package:mosque_management_system/data/models/distract.dart';
import 'package:mosque_management_system/data/models/mosque.dart';
import 'package:mosque_management_system/data/models/region.dart';
import 'package:mosque_management_system/data/models/res_city.dart';
import 'package:mosque_management_system/data/repositories/custom_odoo_client.dart';
import 'package:mosque_management_system/data/services/mosque_service.dart';
import 'package:mosque_management_system/data/services/user_service.dart';
import 'package:mosque_management_system/widgets/ProgressBar.dart';
import 'package:mosque_management_system/widgets/app_title.dart';
import 'package:provider/provider.dart';
import 'dart:io' as io;

class MosqueList extends StatefulWidget {
  final CustomOdooClient client;
  final Function onItemTap;
  final String? title;
  MosqueList({required this.client,required this.onItemTap,this.title});
  @override
  _MosqueListState createState() => _MosqueListState();
}

class _MosqueListState extends State<MosqueList> {
  MosqueData data= MosqueData();
  List<Region> filteredUsers= [];
  UserService? _userService;
  MosqueService? _mosqueService;


  TextEditingController _controller = TextEditingController();
  List<String> items = [];
  List<String> filteredItems = [];

  @override
  void initState() {
    filteredItems.addAll(items);
    _userService = UserService(this.widget.client!);
    _mosqueService = MosqueService(this.widget.client!);
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
      data.reset();
    }
    data.init();
   
    _mosqueService!.getAllDoneMosques(10,data.pageIndex,_controller.text).then((value){

      // data.hasMore=true;
      // data.isloading=true;

      if(data.pageIndex>1){
        if(value.list==null || value.list.isEmpty){
          setState((){
            data.isloading=false;
            data.hasMore=false;
          });
        }else{
          setState((){
            data.list!.addAll(value.list!.toList());
            data.isloading=false;
          });
        }

      }else{
        setState((){
          data.list=value.list;
          data.isloading=false;
        });
      }

    });

  }

  @override
  Widget build(BuildContext context) {
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
        margin: EdgeInsets.symmetric(horizontal: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ModalTitle(this.widget.title??"",FontAwesomeIcons.mosque
            ),
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
                itemCount: data.list!.length+((data.hasMore)?1:0),
                itemBuilder: (BuildContext context, int index) {
                  if(index >= data.list!.length)
                  {
                    data.pageIndex=data.pageIndex+1;
                    searchRecords(false);
                    return Container(
                        height: 100,
                        child: ProgressBar(opacity: 0));
                  }
                  else {
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

                        title: Text(data.list[index].name??"",style: TextStyle(fontWeight: FontWeight.w300,color: AppColors.body),),

                        onTap: () {
                          this.widget.onItemTap(data.list[index]);
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