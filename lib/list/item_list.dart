import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:mosque_management_system/constants/app_colors.dart';
import 'package:mosque_management_system/data/models/combo_list.dart';
import 'package:mosque_management_system/data/models/region.dart';
import 'package:mosque_management_system/data/repositories/custom_odoo_client.dart';
import 'package:mosque_management_system/data/services/user_service.dart';
import 'package:mosque_management_system/widgets/ProgressBar.dart';
import 'package:mosque_management_system/widgets/app_title.dart';
import 'package:provider/provider.dart';
import 'dart:io' as io;

class ItemList extends StatefulWidget {
  final CustomOdooClient client;
  final List<ComboItem> items;
  final Function onItemTap;
  final int? selectedValue;
  final String? title;
  ItemList({required this.client,required this.onItemTap,required this.items,this.title,this.selectedValue});
  @override
  _ItemListState createState() => _ItemListState();
}

class _ItemListState extends State<ItemList> {
  RegionData regionData= RegionData();
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
        margin: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ModalTitle(this.widget.title??"",FontAwesomeIcons.users
            ),
            SizedBox(height: 10),
            Expanded(

              child: ListView.builder(
                itemCount: this.widget.items.length,
                itemBuilder: (BuildContext context, int index) {
                  return  Container(
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

                      title: Text(this.widget.items[index].value??"",style: TextStyle(fontWeight: FontWeight.w300,color: AppColors.body),),

                      onTap:() {
                        // Perform actions when an item is tapped
                        this.widget.onItemTap(this.widget.items[index]);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}