import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:mosque_management_system/constants/app_colors.dart';
import 'package:mosque_management_system/data/repositories/custom_odoo_client.dart';
import 'package:mosque_management_system/presentation/screens/profile.dart';
import 'package:mosque_management_system/presentation/screens/services.dart';
import 'package:provider/provider.dart';
import 'dart:io' as io;

class TagButton extends StatefulWidget {
  int activeButtonIndex;
  final int index;
  final String title;
  final Function? onChange;
  TagButton({required this.activeButtonIndex,required this.index,required this.title,
  this.onChange
  });
  @override
  State<TagButton> createState() => _TagButtonState();
}

class _TagButtonState extends State<TagButton> {

  @override
  void initState() {

  }
  //int _selectedIndex = 4;
  //UserPreferences
  @override
  Widget build(BuildContext context) {
    //HalqaProvider auth = Provider.of<HalqaProvider>(context);
    return GestureDetector(
      onTap: () {
        setState(() {
          this.widget.activeButtonIndex = this.widget.index; // Update the active button index
        });
        if(this.widget.onChange!=null)
          this.widget.onChange!();
        //getMosques(true);
      },
      child: Container(
        // width: 50,
        //height: 50,
        margin: EdgeInsets.symmetric(horizontal: 3),
        padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(8), // Adjust the radius as needed
          color: this.widget.activeButtonIndex == this.widget.index ? AppColors.secondly : Colors.transparent,
          border: Border.all(color: AppColors.secondly),
        ),
        alignment: Alignment.center,
        child: Text(
          this.widget.title,
          style: TextStyle(color: this.widget.activeButtonIndex == this.widget.index ? Colors.white : AppColors.secondly,fontSize: 12),
        ),
      ),
    );
  }
}

Widget CustomTag({String? title,bool? isActive,int? colorId}){
  Color color=AppColors.secondly;
  if(colorId!=null)
    color=OdooColor[colorId]??AppColors.secondly;
  return Container(
    // width: 50,
    //height: 50,
    margin: EdgeInsets.symmetric(horizontal: 2),
    padding: EdgeInsets.symmetric(horizontal: 5,vertical: 3),
    decoration: BoxDecoration(
      shape: BoxShape.rectangle,
      borderRadius: BorderRadius.circular(5), // Adjust the radius as needed
      color: (isActive??false) ? color : Colors.transparent,
      border: Border.all(color: color),
    ),
    alignment: Alignment.center,
    child: Text(
      title??"",
      style: TextStyle(color: (isActive??false) ? Colors.white : AppColors.secondly,fontSize: 11),
    ),
  );
}

Widget MultiTag({String? title,bool? isActive,int? colorId,Function? onTab}){

  return Container(
    // width: 150,
    padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey),
      borderRadius: BorderRadius.circular(20.0),
    ),
    child: Container(
      child: Wrap(
        children: [
          Text(
            title??"",
            style: TextStyle(fontSize: 12.0),
          ),

          onTab==null?SizedBox(width: 1,):GestureDetector(
            onTap: (){
              if(onTab!=null)
                onTab!();

            },
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: Icon(Icons.close, color: Colors.grey,size: 15,)),
          ),
        ],
      ),
    ),
  );
}