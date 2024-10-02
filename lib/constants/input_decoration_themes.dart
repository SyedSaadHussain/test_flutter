import 'package:flutter/material.dart';
import 'package:mosque_management_system/constants/app_colors.dart';

class MyInputDecorationThemes {
  // First InputDecorationTheme
  static InputDecoration firstInputDecoration(BuildContext context,{String? label,IconData? icon,Function? onTab}) {

    final OutlineInputBorder outlineInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(
        color: Colors.white.withOpacity(.2), // Set your desired border color here
      ),
    );

    return InputDecoration(
      contentPadding: EdgeInsets.symmetric(vertical: 10.0,horizontal: 10),
      suffixIcon: icon==null?null:GestureDetector(
          onTap: (){
            onTab!();
          },
          child: Icon(icon,color: Colors.white.withOpacity(.5),)),
      labelStyle: TextStyle(color: Colors.blue), // Set label text color
      hintStyle: TextStyle(color: Colors.blue),
      label: Text(label??"",style: TextStyle(color: Colors.white.withOpacity(.4)),),
      fillColor: Colors.white.withOpacity(.2),

      // Customize the appearance of the input fields for the first theme
      focusedBorder: outlineInputBorder,
      enabledBorder: outlineInputBorder,
      border: outlineInputBorder,
      // Add more customizations as needed
    );
  }

  static InputDecoration secondInputDecoration(BuildContext context,{String? label,IconData? icon,Function? onTab,
    TextEditingController? control
  }) {

    final OutlineInputBorder outlineInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(
        color: Colors.white.withOpacity(.2), // Set your desired border color here
      ),

    );

    return InputDecoration(
      contentPadding: EdgeInsets.symmetric(vertical: 10.0,horizontal: 10),
      suffixIcon: icon==null?null:Container(
        width: 100,
        child: Row(
          children: [
            Expanded(child: Container()),

            (control!=null && control.text.isNotEmpty)?IconButton(
              icon: Icon(Icons.close, color: Colors.grey.withOpacity(0.5)),
              onPressed: () {
                control.text='';
                if(onTab!=null)
                  onTab();
              },
            ):Container(),
            IconButton(
              icon: Icon(icon, color: Colors.grey.withOpacity(0.5)),
              onPressed: () {
                if(onTab!=null)
                  onTab();
              },
            ),
          ],
        ),
      ),
      labelStyle: TextStyle(color: Colors.blue), // Set label text color
      hintStyle: TextStyle(color: Colors.blue),
      label: Text(label??"",style: TextStyle(color: AppColors.hint),),
      //fillColor: Colors.white.withOpacity(.2),

      // Customize the appearance of the input fields for the first theme
      focusedBorder: outlineInputBorder,
      enabledBorder: outlineInputBorder,
      border: outlineInputBorder,
      // Add more customizations as needed
    );
  }
}