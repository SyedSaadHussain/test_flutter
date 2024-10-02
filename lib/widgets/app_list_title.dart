import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:mosque_management_system/constants/app_colors.dart';
import 'package:mosque_management_system/constants/input_decoration_themes.dart';
import 'package:mosque_management_system/data/models/combo_list.dart';
import 'package:mosque_management_system/data/models/employee.dart';
import 'package:mosque_management_system/data/models/res_partner.dart';
import 'package:mosque_management_system/utils/config.dart';
import 'package:mosque_management_system/widgets/tag_button.dart';

Widget AppListTitle({Function? onTab,String title="",String subTitle="",IconData? icon,
  Color iconColor= AppColors.primary}) {

  return ListTile(
    contentPadding: EdgeInsets.symmetric(horizontal: 5),
    onTap:(){
      onTab!();
    },
    title: Text(title,style: TextStyle(color: Colors.black.withOpacity(.6),fontSize: 15),),
    subtitle: Text(subTitle,style: TextStyle(color: Colors.grey,fontSize: 13)),
    trailing: onTab==null?null:Icon(
      Icons.arrow_forward_ios,
      color: Colors.grey,
      size: 15,// Set the color to gray
    ),
    leading:icon==null?null:Container(

      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor, // Background color
        borderRadius: BorderRadius.circular(10), // Border radius
      ),
      child: Icon(
        icon,
        color: Colors.white.withOpacity(.9), // Set the color to gray
        size: 25,
      ),
    ),
  );
}

String add_zero(your_number) {
  // return your_number.toString();
  var num = '' + your_number.toString();
  if (your_number < 10) {
    num = '0' + num;
  }
  return num;
}
enum ListType {
  tag,
  date,
  text,
  image,
  multiSelect
}
Widget AppListTitle2({Function? onTab,String title="",dynamic? subTitle="",IconData? icon,bool isDate=false,
  Color iconColor= AppColors.primary,bool hasDivider=true,
  bool isBoolean=false,List<ComboItem>? selection,
  bool isTag=false,bool isBar=false,bool isSelectionReverse=false,
  BuildContext? context,Widget? child,bool isOnlyValue=false,ListType type=ListType.text,dynamic headersMap,bool? isRequired}) {
  Color tagColor=Colors.grey;
  String value=subTitle.toString();
  int index=0;
  int width_per=0;
  double width=double.infinity;
  if(isDate){
    if(value!=''){
    
      var selectedDateHijri = new HijriCalendar.now();
      DateTime? _selectedDate=DateTime.tryParse(value);
      if(_selectedDate!=null){
        selectedDateHijri = new HijriCalendar.fromDate(_selectedDate!);
        value += ' / '+(selectedDateHijri.hYear.toString() +
            '-' +
            add_zero(selectedDateHijri.hMonth) +
            '-' +
            add_zero(selectedDateHijri.hDay).toString());
      }
    }
  }
  else if(selection!=null && selection.length>0){
    width=context==null?double.infinity:MediaQuery.of(context!).size.width/selection!.length;

    var filteredList = selection!.where((rec) => rec.key == subTitle);
    if (filteredList.isNotEmpty) {
      value = filteredList.first.value.toString();
    }
 
    index=selection.indexWhere((rec)=>rec.key==subTitle);

    if(index>-1){
      List<int> ascendingList = List<int>.generate(selection.length, (index) => index).reversed.toList();

      if(isSelectionReverse){
        width_per=index;
      }else{
        width_per=ascendingList[index];
      }

    }
    List<Color> listColor=[AppColors.success,AppColors.warning,AppColors.danger];
    if(selection.length==3){
      listColor=[AppColors.success,AppColors.warning,AppColors.danger];
    }else if(selection.length==2){
      listColor=[AppColors.success,AppColors.danger];
    }else if(selection.length==4){
      listColor=[AppColors.success,Colors.amber,AppColors.warning,AppColors.danger];
    }
    else if(selection.length==5){
      listColor=[AppColors.success,AppColors.success.withOpacity(.6),Colors.amber,AppColors.warning,AppColors.danger];
    }else if(selection.length==6){
      listColor=[AppColors.success,AppColors.success.withOpacity(.6),Colors.amber,Colors.amber.withOpacity(.6),AppColors.warning,AppColors.danger];
    }else if(selection.length==7){
      listColor=[AppColors.success,AppColors.success.withOpacity(.6),Colors.amber,Colors.amber.withOpacity(.6),AppColors.warning,AppColors.warning.withOpacity(.6),AppColors.danger];
    }else if(selection.length==8){
      listColor=[AppColors.success,AppColors.success.withOpacity(.6),Colors.amber,Colors.amber.withOpacity(.6),AppColors.warning,AppColors.warning.withOpacity(.6),AppColors.danger,AppColors.danger.withOpacity(.6)];
    }
   
    if(isSelectionReverse)
      listColor = listColor.reversed.toList();
    if(index>-1)
      tagColor=listColor[index];
  
  }
  Widget tagWidget=IntrinsicWidth (
    child:
    Container(
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(5), // Adjust the radius as needed
        color: Colors.white,
        border: Border.all(color: tagColor.withOpacity(.1)),
      ),

      child: Container(

        constraints: BoxConstraints(
          minWidth: 50.0, // Minimum width
        ),
        height: 30,
        //width: 50,
        // margin: EdgeInsets.symmetric(horizontal: 3),
        padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(5), // Adjust the radius as needed
          color: tagColor.withOpacity(.1) ,
          border: Border.all(color: tagColor.withOpacity(.1)),
        ),
        alignment: Alignment.center,
        child: Text(
          value,
          style: TextStyle(color: tagColor,fontSize: 12),
        ),
      ),
    ),

  );

  return  Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(0.0),
          child: Container(

            // color: Colors.green,
            child: ListTile(
              contentPadding: EdgeInsets.all(0),
              onTap:(){
                if(onTab!=null)
                  onTab!();
              },
               title: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   title.isEmpty?Container():Row(
                     children: [
                       Expanded(child: Text(title??"",style: TextStyle(color: (isRequired??false)?Colors.red:Colors.grey,fontSize: 13,fontWeight: (isRequired??false)?FontWeight.normal:FontWeight.w300),)),
                       // Container(child: Container()),
                       // (isRequired??false)?Container(
                       //     padding: EdgeInsets.symmetric(horizontal: 5),
                       //     child: Icon(Icons.warning,color: Colors.red,size: 15,)):Container(),

                     ],
                   ),
                   isOnlyValue?tagWidget:child!=null?child:isBar?Stack(
                     children: [
                       Container(
                         margin: EdgeInsets.only(top: 5),
                         width: double.infinity,
                         height: 25,
                         decoration: BoxDecoration(
                           shape: BoxShape.rectangle,
                           borderRadius: BorderRadius.circular(5), // Adjust the radius as needed
                           color: Colors.grey.shade100 ,
                           border: Border.all(color: tagColor.withOpacity(.0)),

                         ),

                       ),
                       Container(
                         margin: EdgeInsets.only(top: 5),
                         width: width*(width_per+1),
                         height: 25,
                         decoration: BoxDecoration(
                           shape: BoxShape.rectangle,
                           borderRadius: BorderRadius.circular(5), // Adjust the radius as needed
                           color: tagColor.withOpacity(.2),
                           border: Border.all(color: tagColor.withOpacity(.1)),
                         ),

                         child: Text(
                           //value+'-'+index.toString()+'#'+selection!.length.toString()
                           value
                           ,style: TextStyle(color:tagColor,fontWeight:FontWeight.w300),textAlign: TextAlign.center),
                       )
                     ],
                   ):
                   (isBoolean || isTag)?Container():
                   type==ListType.image?
                   GestureDetector(
                     onTap: (){
                        onTab!();
                     },
                     child: Container(
                       width: 90,
                       height: 90,
                       decoration: BoxDecoration(
                         borderRadius: BorderRadius.circular(8.0),
                         shape: BoxShape.rectangle,
                         color: AppColors.backgroundColor,
                         border: Border.all(
                           color: Colors.grey.shade400,
                           width: 1.0,
                         ),
                       ),
                       child:  ClipRRect(
                         borderRadius: BorderRadius.circular(8.0),
                         child: Image.network(value,headers: headersMap,fit: BoxFit.fitHeight,
                           errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                             // This function will be called when the image fails to load
                             return Padding(
                               padding: const EdgeInsets.all(8.0),
                               child: Icon(Icons.person,color: Colors.grey.shade300,size: 65,),
                             ); // You can replace this with any widget you want to display
                           },
                         ),
                       ),
                     ),
                   ):
                   type==ListType.multiSelect?Wrap(
                       spacing: 5.0, // spacing between adjacent widgets
                       runSpacing: 8.0,
                       children: selection!.where((item)=>value.contains(item.key.toString()))!.map((rec){
                         return MultiTag(title:rec.value??"");
                       }).toList() ):
                   Text((value??"")+'',style: TextStyle(color: Colors.black.withOpacity(.6),fontSize: 15)),
                 ],
               ),
              // subtitle: Text(subTitle,style: TextStyle(color: Colors.black.withOpacity(.8),fontSize: 15)),
              trailing:isOnlyValue?null:isTag?tagWidget:(isBoolean && subTitle is bool)?(subTitle?Container(
                    padding: EdgeInsets.all(10),
                    child: Icon(
                    Icons.check_box_outlined,
                    color: Colors.green.withOpacity(.9), // Set the color to gray
                    size: 25,
                    ),
                    ):subTitle==false? Container(

                padding: EdgeInsets.all(10),
                child: Icon(
                  Icons.close,
                  color: Colors.redAccent.withOpacity(.9), // Set the color to gray
                  size: 25,
                ),
              ):SizedBox()) :onTab==null?null:Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey,
                size: 15,// Set the color to gray
              ),
              leading:icon==null?null:Container(

                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor, // Background color
                  borderRadius: BorderRadius.circular(10), // Border radius
                ),
                child: Icon(
                  icon,
                  color: Colors.white.withOpacity(.9), // Set the color to gray
                  size: 25,
                ),
              ),
            ),
          ),
        ),
        (hasDivider && !isBar)?Divider(color: Colors.grey.shade200,height: 1,):Container()
      ],

  );
}

Widget AppTagButton({Function? onTab,String title="",dynamic? subTitle="",IconData? icon,
  Color iconColor= AppColors.primary,bool hasDivider=true,bool isBoolean=false,List<ComboItem>? selection,bool isTag=false,bool isBar=false,bool isSelectionReverse=false,BuildContext? context,Widget? child,bool isSelected=false,bool isExpand=true}) {
  Color tagColor=Colors.grey;
  String value=subTitle.toString();
  int index=0;
  int width_per=0;
  double width=double.infinity;
  if(selection!=null && selection.length>0){
    width=context==null?double.infinity:MediaQuery.of(context!).size.width/selection!.length;
 
    var filteredList = selection!.where((rec) => rec.key == subTitle);
    if (filteredList.isNotEmpty) {
      value = filteredList.first.value.toString();
    }

    index=selection.indexWhere((rec)=>rec.key==subTitle);

    if(index>-1){
      List<int> ascendingList = List<int>.generate(selection.length, (index) => index).reversed.toList();

      if(isSelectionReverse){
        width_per=index;
      }else{
        width_per=ascendingList[index];
      }
    }


    List<Color> listColor=[AppColors.success,AppColors.warning,AppColors.danger];
    if(selection.length==3){
      listColor=[AppColors.success,AppColors.warning,AppColors.danger];
    }else if(selection.length==2){
      listColor=[AppColors.success,AppColors.danger];
    }else if(selection.length==4){
      listColor=[AppColors.success,Colors.amber,AppColors.warning,AppColors.danger];
    }
    else if(selection.length==5){
      listColor=[AppColors.success,AppColors.success.withOpacity(.6),Colors.amber,AppColors.warning,AppColors.danger];
    }else if(selection.length==6){
      listColor=[AppColors.success,AppColors.success.withOpacity(.6),Colors.amber,Colors.amber.withOpacity(.6),AppColors.warning,AppColors.danger];
    }else if(selection.length==7){
      listColor=[AppColors.success,AppColors.success.withOpacity(.6),Colors.amber,Colors.amber.withOpacity(.6),AppColors.warning,AppColors.warning.withOpacity(.6),AppColors.danger];
    }else if(selection.length==8){
      listColor=[AppColors.success,AppColors.success.withOpacity(.6),Colors.amber,Colors.amber.withOpacity(.6),AppColors.warning,AppColors.warning.withOpacity(.6),AppColors.danger,AppColors.danger.withOpacity(.6)];
    }
  
    if(isSelectionReverse)
      listColor = listColor.reversed.toList();

    tagColor=listColor[index];

  }

  return  Container(
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(0.0),
          child: Container(
             width:isExpand? double.infinity:null,
            // color: Colors.green,
            child: IntrinsicWidth (

              child:
              Container(
                // constraints: BoxConstraints(
                //   minWidth: 50.0, // Minimum width
                // ),
                // width: double.infinity,
                //height: 30,
                //width: 50,
                margin: EdgeInsets.all( 3),
                padding: EdgeInsets.symmetric(horizontal: 10,vertical: 15),
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(5), // Adjust the radius as needed
                  color: isSelected?tagColor.withOpacity(.1):Colors.white ,
                  border: Border.all(color: tagColor.withOpacity(.1),width: 2.0,),
                ),
                alignment: Alignment.center,
                child: Text(
                  value,
                  style: TextStyle(color: tagColor,fontSize: 12),
                ),
              ),

            ),
          ),
        ),
        (hasDivider && !isBar)?Divider(color: Colors.grey.shade200,height: 1,):Container()
      ],

    ),
  );
}


Widget PartnerListTitle(ResPartner partner,String baseUrl,dynamic headersMap,{Function? onTab}) {

  return  Container(

    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10), // Adjust the radius as needed
    ),
    padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
    margin: EdgeInsets.symmetric(horizontal: 3,vertical: 1),
    child: ListTile(
      onTap: (){


      },

      contentPadding: EdgeInsets.all(0),
      leading:
      Container(

        height: 60,
        width: 60,
        child: Image.network('${baseUrl}/web/image?model=res.partner&field=avatar_128&id=${partner.id}&unique=${"05152024143325"}',headers: headersMap,fit: BoxFit.fitHeight,
          errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
            // This function will be called when the image fails to load
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.person,color: Colors.grey.shade300,size: 30,),
            ); // You can replace this with any widget you want to display
          },
        ),
        //backgroundImage: NetworkImage('${AppConfig.baseURL}/web/image?model=res.partner&field=image_128&id=${employees[index]!.id}&unique=1202212040830551',headers: headersMap)),
      ),
      title: Text(partner.name??'',style: TextStyle(color:Colors.black.withOpacity(.7),fontSize: 15),),
      subtitle: Text(partner.title??"",style: TextStyle(color:Colors.grey),),
    ),
  );
}

Widget EmployeeListTitle(Employee emp,dynamic headersMap,String baseUrl,{Function? onTab,Function? onDelete,bool isEditMode=false}) {

  return  Container(


    decoration: BoxDecoration(
      // gradient: LinearGradient(
      //   colors: [Colors.grey.shade50, Colors.grey.shade100],
      //   begin: Alignment.topCenter,
      //   end: Alignment.bottomCenter,
      // ),
      color: Colors.grey.shade100,
      border: Border.all(
        color: Colors.grey.shade200,

        width: 1,
      ),
      //color: Colors.white,
      borderRadius: BorderRadius.circular(5), // Adjust the radius as needed
    ),
    padding: EdgeInsets.symmetric(horizontal: 5,vertical: 5),

    margin: EdgeInsets.symmetric(horizontal: 0,vertical: 1),
    child: ListTile(
      onTap: (){


      },

      contentPadding: EdgeInsets.all(0),
      trailing:isEditMode? IconButton(
        icon: Icon(Icons.close),
        color: Colors.red,
        iconSize: 25.0,
        onPressed: () {
            if(onDelete!=null)
              onDelete();
        },
      ):null,
      leading:
      Container(
        height: 60,
        width: 60,
        child: Image.network('${baseUrl}/web/image?model=hr.employee&field=avatar_128&id=${emp.id}&unique=${""}',headers: headersMap,fit: BoxFit.fitHeight,
          errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
            // This function will be called when the image fails to load
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.person,color: Colors.grey.shade300,size: 30,),
            ); // You can replace this with any widget you want to display
          },
        ),
        //backgroundImage: NetworkImage('${AppConfig.baseURL}/web/image?model=res.partner&field=image_128&id=${employees[index]!.id}&unique=1202212040830551',headers: headersMap)),
      ),
      title: Text(emp.name??'',style: TextStyle(color:Colors.black.withOpacity(.6),fontSize: 15),),
      // subtitle: Text(emp.title??"",style: TextStyle(color:Colors.grey),),
    ),
  );
}


Widget AppFormField({Function? onTab,String title="",String subTitle="",IconData? icon,
  Color iconColor= AppColors.primary,bool isBoolean=false}) {
  final OutlineInputBorder outlineInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(15.0),
    borderSide: BorderSide(
      color: Colors.grey.withOpacity(.0), // Set your desired border color here
    ),
  );
  return  Column(
    children: [
      Padding(
        padding: const EdgeInsets.all(0.0),
        child: Container(

          // color: Colors.green,
          child: ListTile(
            contentPadding: EdgeInsets.all(0),
            onTap:(){
              onTab!();
            },
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Text(title,style: TextStyle(color: Colors.black.withOpacity(.7),fontSize: 13,fontWeight: FontWeight.w300),),
                ),
                TextFormField(
                  style: TextStyle(color: Colors.grey),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 10.0,horizontal: 10),
                    suffixIcon: icon==null?null:Icon(icon,color: Colors.white.withOpacity(.5),),
                    labelStyle: TextStyle(color: Colors.blue), // Set label text color
                    hintStyle: TextStyle(color: Colors.blue),
                    fillColor: AppColors.formField,

                    // Customize the appearance of the input fields for the first theme
                    focusedBorder: outlineInputBorder,
                    enabledBorder: outlineInputBorder,
                    border: outlineInputBorder,
                    // Add more customizations as needed
                  ),
                  //controller: _usernameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '';
                    }
                    return null;
                  },

                ),
              ],
            ),
            // subtitle: Text(subTitle,style: TextStyle(color: Colors.black.withOpacity(.8),fontSize: 15)),
            trailing:isBoolean?(subTitle.indexOf("yes")>-1?Icon(
              Icons.check_circle,
              color: Colors.green.shade400,
              size: 25,// Set the color to gray
            ):subTitle.indexOf("no")>-1? Icon(
              Icons.cancel,
              color: Colors.redAccent.shade100,
              size: 25,// Set the color to gray
            ):SizedBox()) :onTab==null?null:Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
              size: 15,// Set the color to gray
            ),
            leading:icon==null?null:Container(

              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor, // Background color
                borderRadius: BorderRadius.circular(10), // Border radius
              ),
              child: Icon(
                icon,
                color: Colors.white.withOpacity(.9), // Set the color to gray
                size: 25,
              ),
            ),
          ),
        ),
      ),
    ],

  );
}

class AppBoolean extends StatelessWidget {
  final bool? value;

  AppBoolean({this.value});

  @override
  Widget build(BuildContext context) {
    return value!
        ? Container(
      padding: EdgeInsets.symmetric(vertical: 0,horizontal: 5),
      child: Icon(
        Icons.check_box_outlined,
        color: Colors.green.withOpacity(.9), // Set the color to green
        size: 25,
      ),
    )
    :value==false ?Container(
      padding: EdgeInsets.all(10),
      child: Icon(
        Icons.close,
        color: Colors.redAccent.withOpacity(.9), // Set the color to red
        size: 25,
      ),
    ):Container();
  }
}