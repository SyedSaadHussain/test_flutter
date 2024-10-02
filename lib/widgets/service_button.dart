import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mosque_management_system/constants/app_colors.dart';
import 'package:mosque_management_system/widgets/wave_loader.dart';

Widget ServiceButton({Function? onTab,String value="",String text="",IconData icon=Icons.add,
  Color color= const Color(0xFF245896), Color onColor= const Color(0xff429477)}) {

  return GestureDetector(
    onTap: (){
      if(onTab!=null)
        onTab();
    },

    child: Container(
      padding: EdgeInsets.all(10),

      decoration: BoxDecoration(

          shape: BoxShape.rectangle,
          color: AppColors.secondly.withOpacity(.1),
          borderRadius: new BorderRadius.all(Radius.circular(8.0)),
          border: Border.all(
            color: AppColors.secondly.withOpacity(.3), // Change this to the color you want for the border
            width: 0.0, // You can adjust the width of the border as needed
          ),
      ),
      width: double.infinity,
      //width: 100,

      // width: double.infinity,
      margin: EdgeInsets.all(3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              // width: double.infinity,
              child:Icon(icon,size: 40,color:AppColors.secondly.withOpacity(.8),),
            ),
          ),
          Text(text,style: TextStyle(color: AppColors.primary,fontSize: 12), textAlign: TextAlign.center,)
        ],
      ),
    ),
  );
}


Widget PrimaryButton({Function? onTab,String value="",String text="",IconData icon=Icons.add,
  Color color= const Color(0xFF245896), Color onColor= const Color(0xff429477)}) {

  return  Padding(
    padding: const EdgeInsets.symmetric(horizontal: 2),
    child: TextButton(
      onPressed:  onTab==null?null:(){
          onTab();
      },
      child:  Text(text??"",style: TextStyle(color: AppColors.onPrimary),),
      style: TextButton.styleFrom(
        backgroundColor:onTab==null? AppColors.primary.withOpacity(.5):AppColors.primary, // Background color
        padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0), // Padding
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0), // Rounded corners
        ),
      ),
    ),
  );
}

Widget SecondaryButton({Function? onTab,String value="",String text="",IconData icon=Icons.add,
  Color color= const Color(0xFF245896), Color onColor= const Color(0xff429477)}) {

  return  Padding(
    padding: const EdgeInsets.symmetric(horizontal: 2),
    child: TextButton(
      onPressed:  (){
        if(onTab!=null)
          onTab();
      },
      child:  Text(text??"",style: TextStyle(color: AppColors.primary),),
      style: TextButton.styleFrom(
        backgroundColor: AppColors.secondly, // Background color
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0), // Padding
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0), // Rounded corners
        ),
      ),
    ),
  );
}

Widget SecondaryOutlineButton({Function? onTab,String value="",String text="",IconData? icon,
  Color color= const Color(0xFF245896), Color onColor= const Color(0xff429477),bool? isLoading=false}) {

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 2),
    child: TextButton(
      onPressed: isLoading==true?null: (){
        if(onTab!=null)
          onTab();
      },
      child:   Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              icon==null?Container():Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Icon(icon,color:AppColors.secondly ,size: 13,),
              ),
              isLoading==true?Center(child: WaveLoader(color: AppColors.secondly,size: 25)):
              Text(text??"",style: TextStyle(color: AppColors.secondly),),
            ],
          )
      ),
      style: TextButton.styleFrom(
        backgroundColor: Colors.transparent, // Transparent background color
        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0), // Padding
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0), // Rounded corners
          side: BorderSide(color: AppColors.secondly, width: 1), // Outline color and width
        ),
      ),
    ),
  );
  return  Padding(
    padding: const EdgeInsets.symmetric(horizontal: 2),
    child: TextButton(
      onPressed:  (){
        if(onTab!=null)
          onTab();
      },
      child:   Row(
        children: [
          icon==null?Container():Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Icon(icon,color:AppColors.secondly ,size: 13,),
          ),
          Text(text??"",style: TextStyle(color: AppColors.secondly),),
        ],
      ),
      style: TextButton.styleFrom(
        backgroundColor: Colors.transparent, // Transparent background color
        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0), // Padding
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0), // Rounded corners
          side: BorderSide(color: AppColors.secondly, width: 1), // Outline color and width
        ),
      ),
    ),
  );
}

Widget DefaultButton({Function? onTab,String value="",String text="",IconData icon=Icons.add,
  Color color= const Color(0xFF245896), Color onColor= const Color(0xff429477)}) {

  return  Padding(
    padding: const EdgeInsets.symmetric(horizontal: 2),
    child: TextButton(
      onPressed:  (){
        if(onTab!=null)
          onTab();
      },
      child:  Row(
        children: [
          Icon(icon,color:AppColors.gray.withOpacity(.6) ,size: 14,),
          SizedBox(width: 8,),
          Text(text??"",style: TextStyle(color: AppColors.gray.withOpacity(.6)),),
        ],
      ),
      style: TextButton.styleFrom(

        backgroundColor: AppColors.gray.withOpacity(.01), // Background color
        // padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0), // Padding
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0), // Rounded corners
        ),
        side: BorderSide(color: AppColors.gray.withOpacity(.1), width: 1),
      ),
    ),
  );
}

Widget DangerButton({Function? onTab,String value="",String text="",IconData? icon,
  Color color= const Color(0xFF245896), Color onColor= const Color(0xff429477)}) {

  return  Container(
    // color: Colors.amberAccent,
    // height: 40,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: TextButton(
        onPressed:  (){
          if(onTab!=null)
            onTab();
        },
        child:  Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon==null?Container():Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Icon(icon,color:Colors.white.withOpacity(.8) ,size: 13,),
            ),
            Text(text??"",style: TextStyle(color: Colors.white.withOpacity(.8)),),
          ],
        ),
        style: TextButton.styleFrom(
          backgroundColor: AppColors.danger, // Background color
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0), // Padding
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0), // Rounded corners
          ),
        ),
      ),
    ),
  );
}


Widget AppButton({Function? onTab,String value="",String text="",IconData? icon,
  Color color= AppColors.defaultColor, Color onColor= AppColors.defaultColor,bool isFullWidth=true,bool isOutline=false}) {

  return  TextButton(
    onPressed:  (){
      if(onTab!=null)
        onTab();
    },
    child:  Row(
      mainAxisSize:isFullWidth?MainAxisSize.max:MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        icon==null?Container():Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Icon(icon,color:Colors.white.withOpacity(.8) ,size: 13,),
        ),
        Text(text??"",style: TextStyle(color: isOutline?color:Colors.white.withOpacity(.8)),),
      ],
    ),
    style:isOutline==false?TextButton.styleFrom(
      backgroundColor: color, // Background color
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0), // Padding
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0), // Rounded corners
      ),
    ):TextButton.styleFrom(
     backgroundColor: Colors.transparent, // Transparent background color
    padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0), // Padding
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(5.0), // Rounded corners
      side: BorderSide(color: color, width: 1), // Outline color and width
    ),
  ),
  );
}
