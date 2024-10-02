import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:mosque_management_system/constants/app_colors.dart';
import 'package:mosque_management_system/data/models/combo_list.dart';
import 'package:mosque_management_system/data/models/region.dart';
import 'package:mosque_management_system/data/models/res_city.dart';
import 'package:mosque_management_system/data/repositories/custom_odoo_client.dart';
import 'package:mosque_management_system/data/services/user_service.dart';
import 'package:mosque_management_system/widgets/ProgressBar.dart';
import 'package:mosque_management_system/widgets/app_title.dart';
import 'package:provider/provider.dart';
import 'dart:io' as io;

class ComboBoxList extends StatefulWidget {
  final CustomOdooClient client;
  final String? label;
  final Function onItemTap;
  ComboBoxList({required this.client,required this.onItemTap,this.label});
  @override
  _ComboBoxListState createState() => _ComboBoxListState();
}

class _ComboBoxListState extends State<ComboBoxList> {
  ComboItemData data= ComboItemData();
  List<Region> filteredUsers= [];
  UserService? _userService;

  TextEditingController _controller = TextEditingController();
  List<String> items = [];
  List<String> filteredItems = [];

  @override
  void initState() {
    filteredItems.addAll(items);
    _userService = UserService(this.widget.client!);
    searchRecords();
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
  void searchRecords(){
    data.reset();
    data.init();
   
    _userService!.getClassification().then((value){

      setState((){
        data.list=value;
        data.isloading=false;
      });

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
        child: Column(
          children: [
            ModalTitle(this.widget.label??"",Icons.category),
            Expanded(
              child: Container(
                margin: EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    Expanded(
              
                      child: ListView.builder(
                        itemCount: data.list?.length ?? 0,
                        itemBuilder: (BuildContext context, int index) {
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
              
                              title: Text(data.list[index].value??"",style: TextStyle(fontWeight: FontWeight.w300,color: AppColors.body),),
              
                              onTap: () {
                            
                                this.widget.onItemTap(data.list[index]);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}