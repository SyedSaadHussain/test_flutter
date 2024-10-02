import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget AppLargeContainer(Function fun,{ String value="",String text="",IconData icon=Icons.add,
  Color color= const Color(0xfff223b51), Color onColor= const Color(0xfff223b51),Widget? child}) {

  return GestureDetector(
    onTap: (){
      fun();
    },
    child: Container(
      width: double.infinity,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal:10,vertical: 5),
            margin: EdgeInsets.symmetric(horizontal:5,vertical: 5),
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    colors: <Color>[color, color.withOpacity(.9)]),
                // color: ,
                borderRadius: BorderRadius.all(Radius.circular(10))
            ),
            width: double.infinity,
            child:Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(text,style: TextStyle(color: onColor.withOpacity(.8),fontSize: 15,fontWeight: FontWeight.bold),),
                      child!=null?child:

                      Text(value,style: TextStyle(color: onColor.withOpacity(1),fontSize: 35))

                    ],
                  ),
                ),
                SizedBox(width: 10,),
                Icon(icon,color: onColor.withOpacity(.8),size: 50,)
              ],
            ) ,
          ),
        ],
      ),
    ),
  );
}