
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mosque_management_system/constants/app_colors.dart';

class  StateButton extends StatelessWidget{
  final VoidCallback? onRetry;
  final String title;
  final String value;
  final IconData icon;
  final bool hasBorder;

  StateButton({this.onRetry,required this.title,required this.value,required this.icon, this.hasBorder = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          border: hasBorder ? Border(right: BorderSide(color: Colors.grey.shade100)) : null, // Add border if hasBorder is true
        ),
        child: Column(
          children: [
            Text(this.title,style: TextStyle(color: Colors.grey),),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 5,vertical: 10),
              child: Row(
                children: [
                  Icon(this.icon,size: 25,color: Colors.black.withOpacity(.5),),
                  Expanded(child:Container()),
                  Text(this.value,style: TextStyle(fontSize: 20,color: Colors.black.withOpacity(.5)),)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}