import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:enhance_stepper/enhance_stepper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:mosque_management_system/constants/app_colors.dart';
import 'package:mosque_management_system/data/models/User.dart';
import 'package:mosque_management_system/data/models/base_state.dart';
import 'package:mosque_management_system/data/models/center.dart';
import 'package:mosque_management_system/data/models/combo_list.dart';
import 'package:mosque_management_system/data/models/distract.dart';
import 'package:mosque_management_system/data/models/employee.dart';
import 'package:mosque_management_system/data/models/employee_category.dart';
import 'package:mosque_management_system/data/models/mosque.dart';
import 'package:mosque_management_system/data/models/region.dart';
import 'package:mosque_management_system/data/models/res_city.dart';
import 'package:mosque_management_system/data/models/userProfile.dart';
import 'package:mosque_management_system/data/repositories/custom_odoo_client.dart';
import 'package:mosque_management_system/data/repositories/common_repository.dart';
import 'package:mosque_management_system/data/services/mosque_service.dart';
import 'package:mosque_management_system/data/services/user_service.dart';
import 'package:mosque_management_system/list/center_list.dart';
import 'package:mosque_management_system/list/city_list.dart';
import 'package:mosque_management_system/list/combo_list.dart';
import 'package:mosque_management_system/list/district_list.dart';
import 'package:mosque_management_system/list/mosque_user_list.dart';
import 'package:mosque_management_system/list/multi_item_list.dart';
import 'package:mosque_management_system/list/region_list.dart';
import 'package:mosque_management_system/presentation/screens/all_mosques.dart';
import 'package:mosque_management_system/presentation/screens/mosque_detail.dart';
import 'package:mosque_management_system/providers/user_provider.dart';
import 'package:mosque_management_system/utils/config.dart';
import 'package:mosque_management_system/utils/gps_permission.dart';
import 'package:mosque_management_system/utils/json_utils.dart';
import 'package:mosque_management_system/widgets/ProgressBar.dart';
import 'package:mosque_management_system/widgets/app_form_field.dart';
import 'package:mosque_management_system/widgets/app_list_title.dart';
import 'package:mosque_management_system/widgets/bottom_navigation.dart';
import 'package:mosque_management_system/widgets/custom_enhance_stepper.dart';
import 'package:mosque_management_system/widgets/service_button.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'package:provider/provider.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class CreateEmployee extends StatefulWidget {
  final CustomOdooClient client;
  CreateEmployee({required this.client});
  @override
  _CreateEmployeeViewState createState() => _CreateEmployeeViewState();
}
class _CreateEmployeeViewState extends BaseState<CreateEmployee> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


  late UserService _userService;
  late MosqueService _mosqueService;
  List<Employee> _imams=[];
  List<Employee> _muezzin=[];
  List<Employee> _khadem=[];
  List<Employee> _khatib=[];
  bool isSaving=true;
  UserProfile _userProfile =UserProfile(userId: 0);
  EmployeeCategoryData categoryData=EmployeeCategoryData();
  Employee newEmployee=Employee(id: 0);
  List<ComboItem> categoryItems=[];
  List<ComboItem> selectedCategory=[];
  @override
  void initState(){
    super.initState();
    _userService = UserService(this.widget.client);
    _mosqueService = MosqueService(this.widget.client);
    Future.delayed(Duration.zero, () {
   
    });

    Future.delayed(Duration.zero, () {
      getClassificationId();
      _userService.loadEmployeeView().then((list){
   
        fields.list=list;
        setState(() {
          isSaving=false;
        });
     
      }).catchError((e){
        setState(() {
          isSaving=false;
        });
      });
      _userService.getEmployeeCategory().then((value){
        categoryData.list=value;
        categoryData.list.forEach((item){
          categoryItems.add(ComboItem(key: item.id,value: item.name));
        
        });
        setState(() {

        });
    
      });
    });



  }
  late UserProvider userProvider;

  StepperType _type = StepperType.horizontal;


  int _index = 0;
  void go(int index) {
    if (index == -1 && _index <= 0 ) {
 
      return;
    }

    if (index == 1 && _index >= 2) {
 
      return;
    }

    setState(() {
      _index += index;
    });
  }
  showCategoryModal(){
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return MultiItemList(
          client: this.widget.client,
          selectedValue: newEmployee.categoryIds,
          title: 'Select Tag',
          items: categoryItems,
          onItemTap: (ComboItem val){
            
            if(newEmployee.categoryIds==null)
              newEmployee.categoryIds=[];
            if (!newEmployee.categoryIds!.contains(val.key)) {
              newEmployee.categoryIds!.add(val.key);
            }
            setState(() {

            });
         
            Navigator.of(context).pop();
          },);
      },
    );
  }
  bool isYakeenValidate=false;
  validateYakeenAPI(){
    setState(() {
      isSaving=true;
    });
    String nameArabic='';
    String nameEnglish='';
    _mosqueService!.validteYakeenApi(newEmployee).then((value){
   
      if(value['result']['code']==200){
         isYakeenValidate=true;
       
        dynamic info=value['personBasicInfo'];
        nameArabic=(JsonUtils.toText(info['firstName'])??"")+ " " + (JsonUtils.toText(info['fatherName'])??"")+ " " + (JsonUtils.toText(info['grandFatherName'])??"")+ " " + (JsonUtils.toText(info['familyName'])??"");
        nameEnglish=(JsonUtils.toText(info['firstNameT'])??"")+ " " + (JsonUtils.toText(info['fatherNameT'])??"")+ " " + (JsonUtils.toText(info['grandFatherNameT'])??"")+ " " + (JsonUtils.toText(info['familyNameT'])??"");
       
        newEmployee.name=nameArabic;
      }else
      {
      
        Flushbar(
          icon: Icon(Icons.warning,color: Colors.white,),
          backgroundColor: AppColors.danger,
          message: value['result']['error']['errorDetail']['errorMessage'],
          duration: Duration(seconds: 3),
        ).show(context);
      }


      setState(() {
        // isYakeenValidate=true;
        isSaving=false;
      });
    }).catchError((e){
    
      setState(() {
        isSaving=false;
      });
      Flushbar(
        icon: Icon(Icons.warning,color: Colors.white,),
        backgroundColor: AppColors.danger,
        message: 'Not valid information ',
        duration: Duration(seconds: 3),
      ).show(context);
    });
  }
  validateNationalId(){
    setState(() {
      isSaving=true;
    });
    String nameArabic='';
    String nameEnglish='';
    _mosqueService!.validteNationalId(newEmployee).then((value){
      setState(() {
        // isYakeenValidate=true;
        isSaving=false;
      });
      Navigator.of(context).pop();
    }).catchError((e){
    
      setState(() {
        isSaving=false;
      });
      Flushbar(
        icon: Icon(Icons.warning,color: Colors.white,),
        backgroundColor: AppColors.danger,
        message: e.message,
        duration: Duration(seconds: 3),
      ).show(context);
    });
  }
  int? classificationId;
  getClassificationId(){
    _mosqueService!.getClassificationIdByCode("mansoob").then((value){
 
      classificationId=value;
 
    }).catchError((e){

    });
  }
  createEmployee(){
    setState(() {
      isSaving=true;
    });
    _userService!.createEmployee(newEmployee).then((value){
        newEmployee.id=value.id;
        validateNationalId();
        // setState(() {
        //   isSaving=false;
        // });
        // Navigator.of(context).pop();
    }).catchError((e){
     
      setState(() {
        isSaving=false;
      });
      Flushbar(
        icon: Icon(Icons.warning,color: Colors.white,),
        backgroundColor: AppColors.danger,
        message: e.message.toString(),
        duration: Duration(seconds: 3),
      ).show(context);
    });

    // await Future.delayed(Duration(seconds: 2));
    // setState(() {
    //   _index = 2;
    //   isSaving=false;
    // });
  }
  final _formKey = GlobalKey<FormState>();
  final _crewFormKey = GlobalKey<FormState>();
  bool isVisiablePermission=false;
  late GPSPermission permission;
  List<Employee> _observers=[];
  FieldListData fields=FieldListData();
  void confirmationMessage(){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('confirm'.tr()),
          content: Text('current_location'.tr()),
          actions: <Widget>[
            TextButton(
              onPressed: () {

                Navigator.of(context).pop(); // Closes the dialog
                // Perform your action here
                // For example, you can delete something or confirm an action
              },
              child: Text('confirm'.tr()),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Closes the dialog
                // Perform any other action you want here
                // This could be canceling the action or doing nothing
              },
              child: Text('cancel'.tr()),
            ),
          ],
        );
      },
    );
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    userProvider = Provider.of<UserProvider>(context);
    _userService!.updateUserProfile(userProvider.userProfile);
    _mosqueService.updateUserProfile(userProvider.userProfile);
  }
  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<UserProvider>(context);
    _mosqueService.repository.userProfile=userProvider.userProfile;
    _userService.repository.userProfile=userProvider.userProfile;
    return SafeArea(

      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: Container(

          child: Stack(
            children: [
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 15,vertical: 5),
                    //height: 170,
                    child:
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 5,vertical: 5),
                                child: Row(
                                  children: [
                                    Icon(Icons.arrow_back,color: Theme.of(context).colorScheme.onPrimary.withOpacity(.5),size: 25 , ),
                                    Text('create_new_employee'.tr(),style: TextStyle(color: AppColors.onPrimary,fontSize: 20),)
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: Container(

                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15.0),
                          topRight: Radius.circular(15.0),
                        ),
                        color: Colors.white

                      ),
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      //decoration: BodyBoxDecoration4(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Expanded(
                            child: SingleChildScrollView(
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    // CustomListField(title: fields.getField('observer_ids').label,employees: _observers,),
                                    CustomFormField(title: fields.getField('name').label,value: newEmployee.name,onChanged:(val) => newEmployee.name = val,isDisable: true,
                                     suffixIcon:isYakeenValidate?Icon(Icons.check_circle,color: Colors.green.withOpacity(.6),):null
                                    ),

                                    // CustomFormField(title: fields.getField('number').label,value: newEmployee.jobNumber,isRequired: true,onSave:(val) => newEmployee.jobNumber = val,),

                                    CustomFormField(title: fields.getField('birthday').label,value: newEmployee.birthday,onChanged:(val) {


                                      newEmployee.birthday = val;

                                    } ,type: FieldType.date,isRequired: true,isDisable:isYakeenValidate, suffixIcon:isYakeenValidate?Icon(Icons.check_circle,color: Colors.green.withOpacity(.6),):null),


                                    CustomFormField(title: fields.getField('identification_id').label,value: newEmployee.identificationId,isRequired: true,onChanged:(val) {

                                      newEmployee.identificationId = (val??"").toString();
                                      setState(() {

                                      });
                                    },type: FieldType.number,isDisable:isYakeenValidate, suffixIcon:isYakeenValidate?Icon(Icons.check_circle,color: Colors.green.withOpacity(.6),):null),

                                    CustomFormField(title: fields.getField('staff_relation_type').label,
                                      value: newEmployee.staffRelationType,isRequired: true,
                                      onChanged:(val) {
                                        newEmployee.staffRelationType = val;
                                        setState(() {

                                        });
                                      },options: fields.getField('staff_relation_type').list,type: FieldType.selection,),

                                    CustomFormField(title: fields.getField('category_ids').label,onTab: (){

                                       showCategoryModal();

                                    },value: newEmployee.categoryIds??[],options: this.categoryItems,isReadonly:true,isSelection:true,type: FieldType.multiSelect,
                                        builder:(ComboItem value){
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
                                                         value.value??"",
                                                         style: TextStyle(fontSize: 12.0),
                                                       ),

                                                         GestureDetector(
                                                           onTap: (){
                                                             
                                                             newEmployee.categoryIds!.removeWhere((categoryId) => categoryId == value.key);
                                                             setState(() {

                                                             });

                                                           },
                                                           child: Container(
                                                               padding: EdgeInsets.symmetric(horizontal: 5),
                                                               child: Icon(Icons.close, color: Colors.grey,size: 15,)),
                                                         ),
                                                     ],
                                                   ),
                                                 ),
                                               );
                                        },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Row(
                            children: <Widget>[
                              //
                              isYakeenValidate? Expanded(
                                child:PrimaryButton(text: "create".tr(),onTab: ()async{
                                  newEmployee.classificationId=null;
                                  //newEmployee.
                                  if((newEmployee.categoryIds??[]).where((emp) {
                                    return  categoryData.list.where((rec)=>rec.id==emp && (rec.type=='imam' || rec.type=='khatib' || rec.type=='khadem' || rec.type=='muezzin')).length>0;
                                  }).length>0){
                                    newEmployee.classificationId=classificationId;
                                  }
                               

                                
                                  if (_formKey.currentState!.validate()) {
                                    _formKey.currentState!.save();
                                    createEmployee();
                                  }

                                }),
                              ):Expanded(
                                child:PrimaryButton(text: "verify".tr(),onTab: ()async{
                                 
                                  if (_formKey.currentState!.validate()) {
                                    _formKey.currentState!.save();
                                    validateYakeenAPI();
                                  }

                                }),
                              ),
                              Expanded(
                                child: SecondaryButton(
                                  onTab: (){
                                    Navigator.of(context).pop();
                                  },
                                  text:  'back'.tr(),
                                ),
                              ),
                            ],
                          )

                        ],
                      ),
                    ),
                  ),
                ],
              ),
              isSaving
                  ? ProgressBar()
                  : SizedBox.shrink(),
            ],
          ),
        ),
        //bottomNavigationBar:this.widget.client==null?null:BottomNavigation(client: this.widget.client!,selectedIndex: 2),
      ),
    );
  }
}
