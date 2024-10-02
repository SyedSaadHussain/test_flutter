import 'dart:convert';
import 'dart:io';
import 'package:html/parser.dart' as html_parser;
import 'package:another_flushbar/flushbar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jhijri_picker/jhijri_picker.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:mosque_management_system/constants/app_colors.dart';
import 'package:mosque_management_system/data/models/combo_list.dart';
import 'package:mosque_management_system/data/models/employee.dart';
import 'package:mosque_management_system/data/services/user_service.dart';
import 'package:mosque_management_system/widgets/app_list_title.dart';
import 'package:mosque_management_system/widgets/attachment_card.dart';
import 'package:mosque_management_system/widgets/service_button.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:intl/intl.dart';
import 'package:jhijri/jHijri.dart';


enum FieldType {
  textField,
  number,
  double,
  textArea,
  boolean,
  date,
  image,
  selection,// `double` is a reserved keyword in Dart
  choice,
  multiSelect
  // Add more data types as needed
}

class CustomFormField extends StatefulWidget {
  final Color? color;
  final double size;
  final Function? onTab;
  final Function? onSave;
  final Function? onChanged;
  final Function? builder;
  final String? title;
  final dynamic? value;
  final IconData? icon;
  final Widget? suffixIcon;
  final Color iconColor;
  final bool isBoolean;
  final bool isReadonly;
  final bool isDisable;
  final bool isSelection;
  final bool isRequiredField;
  final bool isRequired;
  final bool isScroll;
  dynamic? formValue;
  final  FieldType type;
  final bool isSelectionReverse;
  final dynamic headersMap;
  List<DropdownMenuItem<String>>? selections;
  List<ComboItem>? options;
//List<DropdownMenuItem<String>>
  CustomFormField({this.color,this.size=50,this.icon,this.onTab,
    this.onSave,this.onChanged,this.title,this.value,this.iconColor=AppColors.primary,
    this.isBoolean=false,this.isReadonly=false,this.isDisable=false,
    this.isSelection=false,this.isRequired=false,this.isRequiredField=false,this.formValue,
    this.type=FieldType.textField,this.selections,this.options,
    this.isSelectionReverse=false,this.isScroll=false,this.builder,this.headersMap,this.suffixIcon});

  @override
  _CustomFormFieldState createState() => _CustomFormFieldState();
}

class  _CustomFormFieldState extends State<CustomFormField> {

  List<DropdownMenuItem<String>> selections=[];

  @override
  void initState() {
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

  }

  @override
  void dispose() {
     _controllerHijri.dispose();
     _controller.dispose();
    super.dispose();
  }
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _controllerHijri = TextEditingController();
  final OutlineInputBorder outlineInputBorder = OutlineInputBorder(

    borderRadius: BorderRadius.circular(15.0),
    borderSide: BorderSide(
       color: Colors.grey.withOpacity(.0), // Set your desired border color here
    ),
  );
  String add_zero(your_number) {
    // return your_number.toString();
    var num = '' + your_number.toString();
    if (your_number < 10) {
      num = '0' + num;
    }
    return num;
  }

  DateTime? _selectedDate;
  DateTime? _tempSelectedDate;
  var selectedDateHijri = new HijriCalendar.now();
  Future<void> _selectHijriDate(BuildContext context) async {
    FocusScope.of(context).unfocus();

    showGlobalDatePicker(
      context: context,
      startDate: JDateModel(
          jhijri: JHijri(
            fYear: 1357,
            fMonth: 1,
            fDay: 1,
          )),
      selectedDate: JDateModel(jhijri: JHijri(fDay: selectedDateHijri.hDay,
          fMonth: selectedDateHijri.hMonth,
          fYear: selectedDateHijri.hYear)),
      endDate: JDateModel(
          jhijri: JHijri(
            fDay: 25,
            fMonth: 1,
            fYear: 1460,
          )),
      pickerMode: DatePickerMode.day,
      pickerTheme: Theme.of(context),
      //textDirection: TextDirection.rtl,
      //locale: const Locale("ar", "SA"),
      okButtonText: "حفظ",
      cancelButtonText: "عودة",
      onChange: (JPickerValue value) {

        _tempSelectedDate=value.date;
      },
      onOk: (JPickerValue value) {
        var g_date = new HijriCalendar();
        // setState(() {
        //
        // });
        //selectedDateHijri = new HijriCalendar.fromDate(value.date);
        selectedDateHijri = new HijriCalendar.fromDate(_tempSelectedDate!);
        _controllerHijri.text=add_zero(selectedDateHijri.hDay) +
            '-' +
            add_zero(selectedDateHijri.hMonth) +
            '-' +
            selectedDateHijri.hYear.toString();
        ;



        _selectedDate =
            g_date.hijriToGregorian(selectedDateHijri.hYear, selectedDateHijri.hMonth, selectedDateHijri.hDay);

        final DateFormat formatter = DateFormat('yyyy-MM-dd');
        _controller.text=formatter.format(_selectedDate!);
  
        this.widget.onChanged!(_controller.text!);
        Future.delayed(Duration(seconds: 0),(){
          Navigator.pop(context);
        });
         //
      },
      onCancel: () {
        Navigator.pop(context);
      },
      primaryColor: Colors.blue,
      calendarTextColor: Colors.white,
      backgroundColor: Colors.black,
      borderRadius: const Radius.circular(10),
      buttonTextColor: Colors.white,
      headerTitle: const Center(
        child: Text("التقويم الهجري", style: TextStyle(color: Colors.white),),
      ),
    );
  }
  setDateControl(){

  }


  Future<void> _selectDate(BuildContext context) async {
    if(_controller.text.isNotEmpty)
      _selectedDate=DateTime.parse(_controller.text);
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate??DateTime.now(),
      firstDate: DateTime(1938),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate){
      // setState(() {
      //
      // });
      _selectedDate = picked;
      selectedDateHijri = new HijriCalendar.fromDate(_selectedDate!);
      _controller.text=formatter.format(_selectedDate!);

      _controllerHijri.text = add_zero(selectedDateHijri.hDay) +
          '-' +
          add_zero(selectedDateHijri.hMonth) +
          '-' +
          selectedDateHijri.hYear.toString();



      this.widget.onChanged!(_controller.text!);

    }

  }

  bool isTrue=true;
  Uint8List? unitBytes =null;

  @override
  Widget build(BuildContext context) {
    if(this.widget.value!=null && this.widget.value!=''){

      if(this.widget.type== FieldType.selection){
        _controller.text=this.widget.value.toString()??"";
      }else{
        Future.delayed(Duration(seconds: 0), () {

          _controller.text=this.widget.value.toString()??"";
          if(this.widget.type==FieldType.date && _controller.text!=''){
            _selectedDate=DateTime.parse(_controller.text);
            selectedDateHijri = new HijriCalendar.fromDate(_selectedDate!);
            _controllerHijri.text = add_zero(selectedDateHijri.hDay) +
                '-' +
                add_zero(selectedDateHijri.hMonth) +
                '-' +
                selectedDateHijri.hYear.toString();
          }
        });
      }


    }else{
      _controller.text='';
    }



    return  Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(0.0),
          child: Container(

            // color: Colors.green,
            child: ListTile(
              contentPadding: EdgeInsets.all(0),

              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  this.widget.title!.isEmpty?Container(): Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Row(
                      children: [
                        Expanded(child: Row(
                          children: [
                            Expanded(
                              child: Text(this.widget.title??"",style: TextStyle(color: this.widget.isRequiredField?Colors.red:Colors.black.withOpacity(.7),fontSize: 13,fontWeight: FontWeight.w300),
                                ),
                            ),
                            this.widget.isRequiredField?Container(
                                padding: EdgeInsets.symmetric(horizontal: 5),
                                child: Icon(Icons.warning,color: Colors.red,size: 15,)):Container()

                          ],
                        )),
                        this.widget.type==FieldType.boolean?
                        Switch(
                          inactiveThumbColor: AppColors.gray.withOpacity(.5), // Color of the thumb when the switch is OFF
                          inactiveTrackColor: AppColors.gray.withOpacity(.3),
                          value:_controller.text=="true",
                          onChanged: (value) {


                            _controller.text = value.toString();

                            if(this.widget.onChanged!=null)
                              this.widget.onChanged!(value);
                          },

                        )
                            :Container()
                      ],
                    ),
                  ),
                  this.widget.type==FieldType.multiSelect?
                  Wrap(
                    spacing: 5.0, // spacing between adjacent widgets
                    runSpacing: 8.0,
                    children:

                    [
                      ...this.widget.options!.where((e)=>this.widget.value.contains(e.key))!.map<Widget>((obj) => this.widget.builder?.call(obj) ?? Container()).toList(),
                        SizedBox(width: 10), // Example of additional widget inside Wrap
                        GestureDetector(
                          onTap: (){
                            this.widget.onTab!();
                          },
                          child: Icon(
                            Icons.add_circle, // Replace with your icon
                            color: Colors.grey.shade400, // Icon color
                            size: 30, // Icon size
                          ),
                        ),
                     ]
                      // scrollDirection: Axis.horizontal,
                      // children: this.widget.options!.map<Widget>((item) {
                      //   return this.widget.builder?.call(item) ?? Container(); // Adjust `item` as needed
                      // }).toList(),
                   // ),
                  )
                      :this.widget.type==FieldType.choice?(this.widget.isScroll?Container(
                    height: 60,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: this.widget.options!.map((item) {
                        return GestureDetector(
                          onTap: () {
                          
                            this.widget.onChanged!(item.key);
                          },

                          child:  AppTagButton(
                            title: '', // Provide appropriate titles
                            subTitle: item.key!.trim() ?? '',
                            selection: this.widget.options, // Pass necessary parameters
                            isTag: true,
                            isSelected: item.key == this.widget.value,
                            isSelectionReverse: this.widget.isSelectionReverse,
                              isExpand:false
                          ),
                        );
                      }).toList(),
                    ),
                  ):Row(
                    children: this.widget.options!.map((item) {
                      return Expanded(
                        child: GestureDetector(
                          onTap: (){
                  
                            this.widget.onChanged!(item.key);
                          },
                          child: Container(
                            width: double.infinity,
                            child:  AppTagButton(title: '',subTitle: item.key!.trim()??'',
                                 selection:this.widget.options,isTag:true,isSelected:item.key==this.widget.value,
                                isSelectionReverse: this.widget.isSelectionReverse
                                                 ),
                          ),
                        ),
                      );

                    }).toList(),
                  )):
                  this.widget.type==FieldType.boolean?Container():
                   this.widget.type==FieldType.selection?
                   DropdownButtonHideUnderline(
                     child: DropdownButtonFormField<String>(
                       decoration: InputDecoration(
                         filled: true, // This will make sure the background is filled
                         fillColor: Colors.grey[200], // Background color
                         border: OutlineInputBorder( // Optional: Add border
                           borderRadius: BorderRadius.circular(15.0),
                           borderSide: BorderSide(color: Colors.transparent),
                         ),
                         hintText: 'Select an option', // Placeholder text
                       ),
                       validator: (text) {
                         if (this.widget.isRequired && (text == null || text.isEmpty)) {
                           return '';
                         }
                         return null;
                       },
                       hint: Text('Select an item'),
                       value: _controller.text.isNotEmpty?_controller.text:null,
                       onChanged: (String? newValue) {
                         // setState(() {
                         //   _controller.text = newValue.toString();
                         // });
                         _controller.text = newValue.toString();
                         if(this.widget.onChanged!=null)
                           this.widget.onChanged!(newValue.toString());
                       },

                       items:(this.widget.options??[])!.length>0?
                       this.widget.options!.map((item){
                         return DropdownMenuItem<String>(
                           value: item.key.toString(),
                           child: Text(item.value??""),
                         );
                       }).toList()
                           :[],

                       //items: this.widget.selections,

                       // comboItems.map<DropdownMenuItem<String>>((ComboItem item) {
                       //   return DropdownMenuItem<String>(
                       //     value: item.name,
                       //     child: Text(item.name),
                       //   );
                       // }).toList(),
                       style: TextStyle(color: Colors.grey, fontSize: 16),
                       dropdownColor: Colors.grey[200],

                     ),
                   ):
                   this.widget.type==FieldType.date?
                   Row(
                     children: [
                       Expanded(
                         child: TextFormField(
                           validator: (text) {
                             if (this.widget.isRequired && (text == null || text.isEmpty)) {
                               return '';
                             }
                             return null;
                           },
                           onChanged: (val){
                    
                             if(this.widget.onChanged!=null){
                               if(this.widget.type==FieldType.number)
                                 this.widget.onChanged!(val==''?null:int.parse(val!));
                               else if(this.widget.type==FieldType.double)
                                 this.widget.onChanged!(val==''?null:double.parse(val!));
                               else
                                 this.widget.onChanged!(val);
                             }
                           },
                           onSaved: (val){
                   
                             if(this.widget.onSave!=null){
                               if(this.widget.type==FieldType.number)
                                 this.widget.onSave!(val==''?null:int.parse(val!));
                               else if(this.widget.type==FieldType.double)
                                 this.widget.onSave!(val==''?null:double.parse(val!));
                               else
                                 this.widget.onSave!(val);
                             }

                           },
                           enabled:!this.widget.isDisable,
                           onTap: (){
                             if(this.widget.onTab!=null)
                               this.widget.onTab!();

                           },

                           readOnly:(this.widget.type==FieldType.date) || this.widget.isReadonly,
                           controller: _controller,
                           style: TextStyle(color: Colors.grey),
                           decoration: InputDecoration(
                             contentPadding: EdgeInsets.symmetric(vertical: 10.0,horizontal: 10),
                             suffixIcon:this.widget.suffixIcon!=null?this.widget.suffixIcon: (this.widget.type==FieldType.date)?IconButton( icon: Icon(Icons.calendar_month,color: Colors.grey.withOpacity(1)),
                               onPressed: (){
                                 _selectDate(context);
                               },
                             ):
                             this.widget.isSelection?Icon(Icons.arrow_right,color: Colors.grey.withOpacity(1)) :
                             this.widget.icon==null?null:
                             Icon(this.widget.icon,color: Colors.white.withOpacity(.5),),
                             labelStyle: TextStyle(color: Colors.blue), // Set label text color
                             hintStyle: TextStyle(color: Colors.blue),
                             fillColor: this.widget.isDisable?AppColors.formDisabledField:AppColors.formField,

                             // Customize the appearance of the input fields for the first theme
                             focusedBorder: outlineInputBorder,
                             enabledBorder: outlineInputBorder,
                             disabledBorder:outlineInputBorder,
                             border: outlineInputBorder,
                             // Add more customizations as needed
                           ),
                           //controller: _usernameController,


                         ),
                       ),
                       SizedBox(width: 5,),
                       Expanded(
                         child: TextFormField(
                           //this.widget.type==FieldType.textArea?
                           //this.isDisable

                           validator: (text) {
                             if (this.widget.isRequired && (text == null || text.isEmpty)) {
                               return '';
                             }
                             return null;
                           },
                           onChanged: (val){

                           },
                           onSaved: (val){

                           },
                           enabled:!this.widget.isDisable,
                           onTap: (){


                           },

                           readOnly:(this.widget.type==FieldType.date) || this.widget.isReadonly,
                           controller: _controllerHijri,
                           style: TextStyle(color: Colors.grey),
                           decoration: InputDecoration(
                             contentPadding: EdgeInsets.symmetric(vertical: 10.0,horizontal: 10),
                             suffixIcon: this.widget.suffixIcon!=null?this.widget.suffixIcon: (this.widget.type==FieldType.date)?IconButton( icon: Icon(Icons.calendar_month,color: Colors.grey.withOpacity(1)),
                               onPressed: (){
                                 _selectHijriDate(context);
                               },
                             ):
                             this.widget.isSelection?Icon(Icons.arrow_right,color: Colors.grey.withOpacity(1)) :
                             this.widget.icon==null?null:
                             Icon(this.widget.icon,color: Colors.white.withOpacity(.5),),
                             labelStyle: TextStyle(color: Colors.blue), // Set label text color
                             hintStyle: TextStyle(color: Colors.blue),
                             fillColor: this.widget.isDisable?AppColors.formDisabledField:AppColors.formField,

                             // Customize the appearance of the input fields for the first theme
                             focusedBorder: outlineInputBorder,
                             enabledBorder: outlineInputBorder,
                             disabledBorder:outlineInputBorder,
                             border: outlineInputBorder,
                             // Add more customizations as needed
                           ),
                           //controller: _usernameController,


                         ),
                       ),
                     ],
                   ):this.widget.type==FieldType.image?
                   Container(
                     // height: 50,
                     // decoration: BoxDecoration(
                     //   color: Theme.of(context).colorScheme.secondary.withOpacity(.15),
                     //   borderRadius: BorderRadius.circular(5.0), // Adjust the radius as needed
                     // ),
                     width: 90,
                     height: 90,
                     decoration: BoxDecoration(
                       borderRadius: BorderRadius.circular(8.0),
                       shape: BoxShape.rectangle,
                       // color: AppColors.backgroundColor,
                       border: Border.all(
                         color: Colors.grey.shade400,
                         width: 1.0,
                       ),
                     ),
                     alignment: Alignment.center,
                     child: Stack(
                       children: [
                         Container(
                           height: 100.0,
                           child: TextFormField(
                             style: TextStyle(
                               fontSize: 0.0, // Set the desired font size
                               color: Colors.white, // Optionally set the text color
                             ),
                             decoration: InputDecoration(
                               contentPadding: const EdgeInsets.symmetric(vertical: 50.0,),
                               border: OutlineInputBorder(
                                 borderRadius: BorderRadius.circular(5.0), // Adjust radius as needed
                               ),
                             ),
                             validator: (text) {
                               if (this.widget.isRequired && (text == null || text.isEmpty)) {
                                 return '';
                               }
                               return null;
                             },

                             controller: _controller,

                           ),
                         ),

                         unitBytes==null?Container(
                           width: 90,
                           height: 90,
                           child:  ClipRRect(
                             borderRadius: BorderRadius.circular(8.0),
                             child: Image.network(this.widget.value,headers: this.widget.headersMap,fit: BoxFit.fitHeight,
                               errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                        
                                 _controller.text='';
                                 // This function will be called when the image fails to load
                                 return Padding(
                                   padding: const EdgeInsets.all(8.0),
                                   child: Icon(Icons.person,color: Colors.grey.shade300,size: 65,),
                                 ); // You can replace this with any widget you want to display
                               },
                             ),
                           ),
                         ):Image.memory(
                           unitBytes!,
                           fit: BoxFit.cover, // You can change the BoxFit as per your requirement
                         ),
                     Container(
                       // color: Colors.grey,
                       child: Row(
                           children: [
                             Expanded(
                               child: GestureDetector(
                                   onTap: () async{
                                     final ImagePicker _picker = ImagePicker();

                                     // Capture an image using the camera
                                     XFile? image = await _picker.pickImage(source: ImageSource.camera);

                                     unitBytes=await image!.readAsBytes();
                                     String base64Content = base64Encode(unitBytes!);
                                         setState(() {

                                         });
                                     this.widget.onChanged!(base64Content);

                                     // FilePickerResult? result = await FilePicker.platform.pickFiles(
                                     //   // type: FileType.custom,
                                     //   // allowedExtensions: ['jpg', 'png', 'jpeg'],
                                     // );
                                     // if (result != null) {
                                     //   PlatformFile file = result.files.first;
                                     //   File file1 = File(file.path!);
                                     //   List<int> bytes = await file1.readAsBytes();
                                     //   if (bytes != null) {
                                     //     String base64Content = base64Encode(bytes!);//For database
                                     //     unitBytes= base64Decode(base64Content);//For Viewer
                                     //     this.widget.onChanged!(base64Content);
                                     //     setState(() {
                                     //
                                     //     });
                                     //
                                     //   }
                                     // }
                                   },
                                   child:Container(
                                     padding: EdgeInsets.symmetric(vertical: 5),
                                       color: Colors.grey.withOpacity(.7),
                                     child: Icon(Icons.edit,color:  Colors.white.withOpacity(.8),size: 20,))),
                             ),

                             Expanded(child: GestureDetector(
                               onTap: (){
                               
                                 unitBytes=null;
                                 setState(() {

                                 });
                                 this.widget.onChanged!(null);
                               },
                               child: Container(
                                   padding: EdgeInsets.symmetric(vertical: 5),
                                    color: Colors.grey.withOpacity(.7),
                                   child: Icon(Icons.delete_outline,color:  Colors.white.withOpacity(.8),size: 20)),
                             )),
                           ],
                         )),
                       ],
                     ),
                   )
                       :TextFormField(
                     //this.widget.type==FieldType.textArea?
                    //this.isDisable
                     maxLines: null,  // Allows the TextFormField to be multi-line
                     minLines: this.widget.type==FieldType.textArea?2:1,     // Sets the minimum number of lines
                     keyboardType:this.widget.type==FieldType.textArea?TextInputType.multiline:this.widget.type==FieldType.number?TextInputType.number:
                     this.widget.type==FieldType.double?TextInputType.numberWithOptions(decimal: true):TextInputType.text,
                     inputFormatters:this.widget.type==FieldType.number? <TextInputFormatter>[
                       FilteringTextInputFormatter.digitsOnly
                     ]:this.widget.type==FieldType.double?
                     <TextInputFormatter>[
                       FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                     ]
                         :null,
                    validator: (text) {
                      if (this.widget.isRequired && (text == null || text.isEmpty)) {
                        return '';
                      }
                      return null;
                    },
                     onChanged: (val){
                   
                       if(this.widget.onChanged!=null){
                         if(this.widget.type==FieldType.number)
                           this.widget.onChanged!(val==''?null:int.parse(val!));
                         else if(this.widget.type==FieldType.double)
                           this.widget.onChanged!(val==''?null:double.parse(val!));
                         else
                           this.widget.onChanged!(val);
                       }
                     },
                    onSaved: (val){
              
                      if(this.widget.onSave!=null){
                        if(this.widget.type==FieldType.number)
                          this.widget.onSave!(val==''?null:int.parse(val!));
                        else if(this.widget.type==FieldType.double)
                          this.widget.onSave!(val==''?null:double.parse(val!));
                        else
                          this.widget.onSave!(val);
                      }

                    },
                    enabled:!this.widget.isDisable,
                    onTap: (){
                           if(this.widget.onTab!=null)
                                 this.widget.onTab!();

                    },

                    readOnly:(this.widget.type==FieldType.date) || this.widget.isReadonly,
                    controller: _controller,
                    style: TextStyle(color: Colors.grey),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 10.0,horizontal: 10),
                      suffixIcon:this.widget.suffixIcon!=null?this.widget.suffixIcon: (this.widget.type==FieldType.date)?IconButton( icon: Icon(Icons.calendar_month,color: Colors.grey.withOpacity(1)),
                      onPressed: (){
                        _selectDate(context);
                      },
                      ):
                      this.widget.isSelection?Icon(Icons.arrow_right,color: Colors.grey.withOpacity(1)) :
                      this.widget.icon==null?null:
                      Icon(this.widget.icon,color: Colors.white.withOpacity(.5),),
                      labelStyle: TextStyle(color: Colors.blue), // Set label text color
                      hintStyle: TextStyle(color: Colors.blue),
                      fillColor: this.widget.isDisable?AppColors.formDisabledField:AppColors.formField,

                      // Customize the appearance of the input fields for the first theme
                      focusedBorder: outlineInputBorder,
                      enabledBorder: outlineInputBorder,
                      disabledBorder:outlineInputBorder,
                      border: outlineInputBorder,
                      // Add more customizations as needed
                    ),
                    //controller: _usernameController,


                  ),
                ],
              ),
              // subtitle: Text(subTitle,style: TextStyle(color: Colors.black.withOpacity(.8),fontSize: 15)),
              trailing:this.widget.isBoolean?((this.widget.value??"").indexOf("yes")>-1?Icon(
                Icons.check_circle,
                color: Colors.green.shade400,
                size: 25,// Set the color to gray
              ):(this.widget.value??"").indexOf("no")>-1? Icon(
                Icons.cancel,
                color: Colors.redAccent.shade100,
                size: 25,// Set the color to gray
              ):SizedBox()):null,
              leading:this.widget.icon==null?null:Container(

                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: this.widget.iconColor, // Background color
                  borderRadius: BorderRadius.circular(10), // Border radius
                ),
                child: Icon(
                  this.widget.icon,
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



}


class CustomListField extends StatefulWidget {

  final  String? title;
  final  bool isEditMode;
  final Function? onTab;
  final Function? onDelete;
  final Function? onEdit;
  final Function? builder;
  final IconData? buttonIcon;
  final bool isRequired;
  final Widget? actions;
  final dynamic headerMap;
  final String? baseUrl;
  List<DropdownMenuItem<String>>? selections;
  List<dynamic>? employees;


//List<DropdownMenuItem<String>>
  CustomListField({this.title,this.isEditMode=false,this.employees,this.onTab,this.onDelete,this.onEdit,this.builder,this.buttonIcon,this.isRequired=false,this.actions,this.baseUrl,this.headerMap});

  @override
  _CustomListFieldState createState() => _CustomListFieldState();
}

class  _CustomListFieldState extends State<CustomListField> {

  List<DropdownMenuItem<String>> selections=[];

  @override
  void initState() {
  
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
 
  }

  @override
  void dispose() {
    super.dispose();
  }
  final TextEditingController _controller = TextEditingController();
  final OutlineInputBorder outlineInputBorder = OutlineInputBorder(

    borderRadius: BorderRadius.circular(15.0),
    borderSide: BorderSide(
      color: Colors.grey.withOpacity(.0), // Set your desired border color here
    ),
  );

  DateTime? _selectedDate;
  Future<void> _selectDate(BuildContext context) async {
    if(_controller.text.isNotEmpty)
      _selectedDate=DateTime.parse(_controller.text);
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate??DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate){

      _selectedDate = picked;
 
      _controller.text=formatter.format(_selectedDate!);

    }

  }

  bool isTrue=true;

  @override
  Widget build(BuildContext context) {

    return  Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(0.0),
          child: Container(

            // color: Colors.green,
            child: ListTile(
              contentPadding: EdgeInsets.all(0),

              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  this.widget.title!.isEmpty?Container(): Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Row(
                      children: [
                        Expanded(child: Row(
                          children: [
                            Text(this.widget.title??"",style: TextStyle(color: this.widget.isRequired?Colors.red:Colors.black.withOpacity(.7),fontSize: 13,fontWeight: FontWeight.w300),),
                            this.widget.isRequired?Container(
                                padding: EdgeInsets.symmetric(horizontal: 5),
                                child: Icon(Icons.warning,color: Colors.red,size: 15,)):Container()
                          ],
                        )),
                        this.widget.isEditMode?
                        SecondaryOutlineButton(onTab: (){
                          if(this.widget.onTab!=null)
                            this.widget.onTab!();
                        },text: 'please_select'.tr(),icon:this.widget.buttonIcon??FontAwesomeIcons.userPlus ):this.widget.actions??Container()
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15.0),
                        topRight: Radius.circular(15.0),
                      ),
                     // color: AppColors.backgroundColor,
                    ),
                    padding: EdgeInsets.all(5),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),

                      itemCount: this.widget.employees!.length,
                      itemBuilder: (context, index) {

                        // Row(
                        //   children: [
                        //     Expanded(child: this.widget.builder?.call(this.widget.employees![index]) ?? Container())
                        //
                        //   ],
                        // ),
                        if(this.widget.builder!=null){
                          return Container(
                            color: index % 2 == 0 ? Colors.grey.shade200 : Colors.grey.shade50,
                            padding: EdgeInsets.symmetric(horizontal: 5,vertical: 0),
                            child: ListTile(
                              onTap: (){


                              },

                              contentPadding: EdgeInsets.all(0),
                              trailing:this.widget.isEditMode? Container(
                                width: 100,
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      color: Colors.lightBlue,
                                      iconSize: 25.0,
                                      onPressed: () {
                                        if(this.widget.onEdit!=null)
                                          this.widget.onEdit!(this.widget.employees![index]);


                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.restore_from_trash_outlined),
                                      color: Colors.red,
                                      iconSize: 25.0,
                                      onPressed: () {
                                        if(this.widget.onDelete!=null)
                                          this.widget.onDelete!(this.widget.employees![index]);
                                      },
                                    ),
                                  ],
                                ),
                              ):null,

                              title: this.widget.builder?.call(this.widget.employees![index]) ?? Container(),
                              // subtitle: Text(emp.title??"",style: TextStyle(color:Colors.grey),),
                            )


                          );


                          return this.widget.builder?.call(this.widget.employees![index]) ?? Container();
                          return Text('saad');
                          //this.widget.options!.where((e)=>this.widget.value.contains(e.key))!.map<Widget>((obj) => this.widget.builder?.call(obj) ?? Container()).toList()
                        }else{
                          return
                            EmployeeListTitle(this.widget.employees![index],this.widget.headerMap,this.widget.baseUrl??"",isEditMode: this.widget.isEditMode,
                                onDelete: (){
                               
                                  if(this.widget.onDelete!=null)
                                    this.widget.onDelete!(this.widget.employees![index].id);
                                }
                            )
                          ;
                        }

                      },
                    ),
                  ),

                ],
              ),
              // subtitle: Text(subTitle,style: TextStyle(color: Colors.black.withOpacity(.8),fontSize: 15)),

            ),
          ),
        ),
      ],

    );
  }



}


class MultipleAttachmentField extends StatefulWidget {

  final  String? title;
  final  bool isEditMode;
  final Function? onTab;
  final Function? onDelete;
  final Function? onEdit;
  final Function? builder;
  final String baseUrl;
  final dynamic headerMap;
  final IconData? buttonIcon;
  final bool isRequired;
  final Widget? actions;
  final UserService? userService;
  List<DropdownMenuItem<String>>? selections;
  List<dynamic>? data;


//List<DropdownMenuItem<String>>
  MultipleAttachmentField({this.title,this.isEditMode=false,this.data,this.onTab,this.onDelete,this.onEdit,this.builder,this.buttonIcon,this.isRequired=false,this.actions,required this.headerMap,this.userService,required this.baseUrl});

  @override
  _MultipleAttachmentFieldState createState() => _MultipleAttachmentFieldState();
}

class  _MultipleAttachmentFieldState extends State<MultipleAttachmentField> {
  @override
  void initState() {

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

  }

  @override
  void dispose() {
    super.dispose();
  }
  bool isLoadingAttachment=false;
  final TextEditingController _controller = TextEditingController();
  final OutlineInputBorder outlineInputBorder = OutlineInputBorder(

    borderRadius: BorderRadius.circular(15.0),
    borderSide: BorderSide(
      color: Colors.grey.withOpacity(.0), // Set your desired border color here
    ),
  );

  bool isTrue=true;

  @override
  Widget build(BuildContext context) {

    return  Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(0.0),
          child: Container(

            // color: Colors.green,
            child: ListTile(
              contentPadding: EdgeInsets.all(0),

              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  this.widget.title!.isEmpty?Container(): Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Row(
                      children: [
                        Expanded(child: Row(
                          children: [
                            Text(this.widget.title??"",style: TextStyle(color: this.widget.isRequired?Colors.red:Colors.black.withOpacity(.7),fontSize: 13,fontWeight: FontWeight.w300),),
                            this.widget.isRequired?Container(
                                padding: EdgeInsets.symmetric(horizontal: 5),
                                child: Icon(Icons.warning,color: Colors.red,size: 15,)):Container()
                          ],
                        )),
                        this.widget.isEditMode?
                        SecondaryOutlineButton(onTab: () async{
                          FilePickerResult? result = await FilePicker.platform.pickFiles();
                          if (result != null) {
                            setState(() {
                              isLoadingAttachment=true;
                            });
                            this.widget.userService!.uploadAttachment(result.files.single.path!).then((value){
                              setState(() {
                                isLoadingAttachment=false;
                              });


                              if(value!=null){
                                if(this.widget.onTab!=null)
                                  this.widget.onTab!(value);
                              }
                            }).catchError((e){
                          
                              dynamic document = html_parser.parse(e);
                              dynamic pElement = document.querySelector('p');
                            
                              Flushbar(
                                icon: Icon(Icons.warning,color: Colors.white,),
                                backgroundColor: AppColors.danger,
                                message: pElement?.text ?? "unhandled error occurred",
                                duration: Duration(seconds: 3),
                              ).show(context);
                              setState(() {
                                isLoadingAttachment=false;
                              });
                            });
                          }

                        },
                         isLoading:isLoadingAttachment,
                            text: 'add'.tr(),
                            icon:this.widget.buttonIcon??FontAwesomeIcons.paperclip ):
                        this.widget.actions??Container(),

                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15.0),
                        topRight: Radius.circular(15.0),
                      ),
                      // color: AppColors.backgroundColor,
                    ),
                    padding: EdgeInsets.all(0),
                    child: Container(
                      width: double.infinity,
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.start,
                        spacing: 3,
                        runSpacing: 3,
                        children: this.widget.data!.map((item) => AttachmentCard(attachment: item,baseUrl:this.widget.baseUrl ,headersMap:this.widget.headerMap,
                            onDelete: this.widget.isEditMode? (){
                                  this.widget.onDelete!(item);
                            }:null)).toList(),
                      ),
                    ),
                  ),

                ],
              ),
              // subtitle: Text(subTitle,style: TextStyle(color: Colors.black.withOpacity(.8),fontSize: 15)),

            ),
          ),
        ),
      ],

    );
  }



}

