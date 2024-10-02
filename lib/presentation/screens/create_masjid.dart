import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:enhance_stepper/enhance_stepper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:mosque_management_system/constants/app_colors.dart';
import 'package:mosque_management_system/data/models/User.dart';
import 'package:mosque_management_system/data/models/base_state.dart';
import 'package:mosque_management_system/data/models/center.dart';
import 'package:mosque_management_system/data/models/combo_list.dart';
import 'package:mosque_management_system/data/models/distract.dart';
import 'package:mosque_management_system/data/models/employee.dart';
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
import 'package:mosque_management_system/list/region_list.dart';
import 'package:mosque_management_system/presentation/screens/all_mosques.dart';
import 'package:mosque_management_system/presentation/screens/create_employee.dart';
import 'package:mosque_management_system/presentation/screens/mosque_detail.dart';
import 'package:mosque_management_system/providers/user_provider.dart';
import 'package:mosque_management_system/utils/config.dart';
import 'package:mosque_management_system/utils/gps_permission.dart';
import 'package:mosque_management_system/widgets/ProgressBar.dart';
import 'package:mosque_management_system/widgets/app_form_field.dart';
import 'package:mosque_management_system/widgets/app_list_title.dart';
import 'package:mosque_management_system/widgets/bottom_navigation.dart';
import 'package:mosque_management_system/widgets/custom_enhance_stepper.dart';
import 'package:mosque_management_system/widgets/service_button.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'package:provider/provider.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class CreateMosque extends StatefulWidget {
  final CustomOdooClient client;
  CreateMosque({required this.client});
  @override
  _CreateMosqueViewState createState() => _CreateMosqueViewState();
}
class _CreateMosqueViewState extends BaseState<CreateMosque> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


  late UserService _userService;
  late MosqueService _mosqueService;
  List<Employee> _imams=[];
  List<Employee> _muezzin=[];
  List<Employee> _khadem=[];
  List<Employee> _khatib=[];
  bool isSaving=true;
  UserProfile _userProfile =UserProfile(userId: 0);
  Mosque newMosque=Mosque(id: 0);

  bool isVerifyDevice(){
    //return true;
    if(userProvider.isDeviceVerify) return true;
    else{
      Flushbar(
        icon: Icon(Icons.warning,color: Colors.white,),
        backgroundColor: AppColors.danger,
        message: "device_not_unverified".tr(),
        duration: Duration(seconds: 3),
      ).show(context);
      return false;
    }


  }
  @override
  void initState(){
    super.initState();
    _userService = UserService(this.widget.client);
    _mosqueService = MosqueService(this.widget.client);
    Future.delayed(Duration.zero, () {
      _mosqueService.loadMosque().then((_mosque){
        newMosque=_mosque;
       
      });
    });

    Future.delayed(Duration.zero, () {

      _mosqueService.loadMosqueView().then((list){
       
        fields.list=list;
        setState(() {
          isSaving=false;
        });
        
      }).catchError((e){
        setState(() {
          isSaving=false;
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
  showRegionModal(){
    showModalBottomSheet(

      context: context,
      builder: (BuildContext context) {
        return RegionList(client: this.widget.client,
          countryId: newMosque.countryId??0,
          onItemTap: (Region val){
  
          newMosque.region=val.name;
          newMosque.regionId=val.id;

          newMosque.city=null;
          newMosque.cityId=null;

          newMosque.moiaCenter=null;
          newMosque.moiaCenterId=null;
          
          setState(() {

          });
      
            Navigator.of(context).pop();

          },);
      },
    );
  }
  showDistrictModal(){
    showModalBottomSheet(

      context: context,
      builder: (BuildContext context) {
        return DistrictList(client: this.widget.client,
          onItemTap: (Distract val){
          
            newMosque.district=val.name;
            newMosque.districtId=val.id;
         
            setState(() {

            });
            Navigator.of(context).pop();

          },);
      },
    );
  }
  showCenterModal(){
    
    showModalBottomSheet(

      context: context,
      builder: (BuildContext context) {
        
        return CenterList(client: this.widget.client,
          cityId: newMosque.cityId??0,
          onItemTap: (MoiCenter val){
 
            newMosque.moiaCenter=val.name;
            newMosque.moiaCenterId=val.id;


            setState(() {

            });
            Navigator.of(context).pop();

          },);
      },
    );
  }
  showCityModal(){
    
    showModalBottomSheet(

      context: context,
      builder: (BuildContext context) {
        return CityList(client: this.widget.client,
          regionId: newMosque.regionId,

          onItemTap: (City val){

             newMosque.city=val.name;
             newMosque.cityId=val.id;

             newMosque.moiaCenter=null;
             newMosque.moiaCenterId=null;
          
            setState(() {

            });
            Navigator.of(context).pop();

          },);
      },
    );
  }
  showAlimModal(){
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return MosqueUserList(client: this.widget.client,
          onItemTap: (City val){
            newMosque.alImam=val.name;
            newMosque.alImamId=val.id;
            setState(() {

            });
            Navigator.of(context).pop();
          },);
      },
    );
  }
  showAlmudhinModal(){
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return MosqueUserList(client: this.widget.client,
          onItemTap: (City val){
            newMosque.alMudhin=val.name;
            newMosque.alMudhinId=val.id;
            setState(() {

            });
            Navigator.of(context).pop();
          },);
      },
    );
  }
  showAlkhatibModal(){
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return MosqueUserList(client: this.widget.client,
          onItemTap: (City val){
            newMosque.alKhatib=val.name;
            newMosque.alKhatibId=val.id;
            setState(() {

            });
            Navigator.of(context).pop();
          },);
      },
    );
  }
  showComboListModal(){
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ComboBoxList(client: this.widget.client,
          label: fields.getField('classification_id').label,
          onItemTap: (ComboItem val){
        
            newMosque.classification=val.value;
            newMosque.classificationId=val.key;
            
            setState(() {

            });
            Navigator.of(context).pop();

          },);
      },
    );
  }
  createMosque(){
    setState(() {
      isSaving=true;
    });
    _mosqueService!.createMosque(newMosque).then((value){
      
        setState(() {
          _index = 2;
          isSaving=false;
        });
    }).catchError((_){
   
      setState(() {
        isSaving=false;
      });
   

      Flushbar(
        icon: Icon(Icons.warning,color: Colors.white,),
        backgroundColor: AppColors.danger,
        message: _.message.toString(),
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
                createMosque();
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
                                    Text('create_new_mosque'.tr(),style: TextStyle(color: AppColors.onPrimary,fontSize: 20),)
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
                      padding: EdgeInsets.symmetric(horizontal: 0),
                      //decoration: BodyBoxDecoration4(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Expanded(
                            child: CustomEnhanceStepper(

                                stepIconSize: 40,
                                type: _type,
                                // horizontalTitlePosition: HorizontalTitlePosition.bottom,
                                // horizontalLinePosition: HorizontalLinePosition.top,
                                currentStep: _index,
                                physics: ClampingScrollPhysics(),
                                steps: [
                                  CustomEnhanceStep(
                                   icon: Icon(Icons.account_balance, color: Colors.redAccent, size: 30,),
                                  state: StepState.editing,
                                  isActive: _index >= 0,
                                  title: Text("mosque".tr(),style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color:_index>-1?AppColors.secondly: AppColors.primary.withOpacity(.2)),),
                                  subtitle: Text("",),
                                  content: Form(
                                    key: _formKey,
                                    child: Column(
                                      children: [
                                        // CustomListField(title: fields.getField('observer_ids').label,employees: _observers,),
                                        CustomFormField(title: fields.getField('name').label,value: newMosque.name,isRequired: true,onChanged:(val) => newMosque.name = val,),

                                        CustomFormField(title: fields.getField('region_id').label,onTab: (){
                                          showRegionModal();
                                        },value: newMosque.region,isReadonly:true,isSelection:true,isRequired: true,),

                                        CustomFormField(title: fields.getField('city').label,onTab: (){
                                          showCityModal();
                                        },value: newMosque.city,isReadonly:true,isDisable: (newMosque.region==null),isSelection:true,isRequired: true,),

                                        CustomFormField(title: fields.getField('moia_center_id').label,onTab: (){
                                          showCenterModal();
                                        },value: newMosque.moiaCenter,isReadonly:true,isSelection:true,),


                                        newMosque.isAnotherNeighborhood??false?Container():CustomFormField(title: fields.getField('district').label,onTab: (){
                                          showDistrictModal();
                                        },value: newMosque.district,isReadonly:true,isSelection:true),

                                        CustomFormField(title: fields.getField('is_another_neighborhood').label,value: newMosque.isAnotherNeighborhood,
                                            onChanged:(val){
                                              newMosque.isAnotherNeighborhood= val;
                                              setState(() {});
                                            } ,type:FieldType.boolean),

                                        newMosque.isAnotherNeighborhood??false?
                                        CustomFormField(title: fields.getField('another_neighborhood_char').label,value: newMosque.anotherNeighborhoodChar,onChanged:(val) => newMosque.anotherNeighborhoodChar = val,):Container(),



                                        CustomFormField(title: fields.getField('street').label,value: newMosque.street,onChanged:(val) => newMosque.street = val,),
                                        CustomFormField(title: fields.getField('classification_id').label,onTab: (){
                                          showComboListModal();
                                        },value: newMosque.classification,isReadonly:true,isSelection:true,isRequired: true,),


                                        CustomFormField(title: fields.getField('establishment_date').label,value: newMosque.establishmentDate,onChanged:(val) {

                                          newMosque.establishmentDate = val;
                                        
                                          setState(() {
                                            
                                          });
                                        } ,type: FieldType.date,),



                                      ],
                                    ),
                                  ),
                                ),
                                  CustomEnhanceStep(
                                    // icon: Icon(Icons.add, color: Colors.redAccent, size: 30,),
                                    state: StepState.indexed,
                                    isActive: _index >= 1,
                                    title: Text("crew".tr(),style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color:_index>0?AppColors.secondly: AppColors.onPrimary.withOpacity(.5))),
                                    subtitle: Text("",),
                                    content: Form(
                                      key: _crewFormKey,
                                      child: Column(
                                        children: [
                                          CustomListField(title: fields.getField('imam_ids').label,employees: _imams,isEditMode:true,
                                              onDelete: (id){
                                              
                                                _imams.removeWhere((item) => item.id == id);
                                                setState(() {

                                                });
                                              },
                                              onTab:(){
                                           
                                                showModalBottomSheet(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return MosqueUserList(client: this.widget.client,
                                                      type: "imam",
                                                      title: fields.getField('imam_ids').label,
                                                      onAddEmployee: (){
                                                        Navigator.of(context).pop();
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) => new CreateEmployee(client: this.widget.client,),
                                                            //HalqaId: 1
                                                          ),
                                                        );
                                                      },
                                                      onItemTap: (Employee val){
                                                      
                                                        if(_imams.where((number) => number.id==val.id).length==0)
                                                          _imams.add(Employee(id:val.id,name: val.name ));
                                                        setState(() {

                                                        });
                                                        Navigator.of(context).pop();
                                                      },);
                                                  },
                                                );
                                              }),
                                          CustomListField(title: fields.getField('muezzin_ids').label,employees: _muezzin,isEditMode:true,
                                              onDelete: (id){
                                           
                                                _muezzin.removeWhere((item) => item.id == id);
                                                setState(() {

                                                });
                                              },
                                              onTab:(){
                                                showModalBottomSheet(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return MosqueUserList(client: this.widget.client,
                                                      type: "muezzin",
                                                      title: fields.getField('muezzin_ids').label,
                                                      onAddEmployee: (){
                                                        Navigator.of(context).pop();
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) => new CreateEmployee(client: this.widget.client,),
                                                            //HalqaId: 1
                                                          ),
                                                        );
                                                      },
                                                      onItemTap: (Employee val){
                                                       
                                                        if(_muezzin.where((number) => number.id==val.id).length==0)
                                                          _muezzin.add(Employee(id:val.id,name: val.name ));
                                                        setState(() {

                                                        });
                                                        Navigator.of(context).pop();
                                                      },);
                                                  },
                                                );
                                              }),
                                          CustomListField(title: fields.getField('khadem_ids').label,employees: _khadem,isEditMode:true,
                                              onDelete: (id){
                                              
                                                _khadem.removeWhere((item) => item.id == id);
                                                setState(() {

                                                });
                                              },
                                              onTab:(){
                                                showModalBottomSheet(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return MosqueUserList(client: this.widget.client,
                                                      type: "khadem",
                                                      title: fields.getField('khadem_ids').label,
                                                      onAddEmployee: (){
                                                        Navigator.of(context).pop();
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) => new CreateEmployee(client: this.widget.client,),
                                                            //HalqaId: 1
                                                          ),
                                                        );
                                                      },
                                                      onItemTap: (Employee val){
                                                      
                                                        if(_khadem.where((number) => number.id==val.id).length==0)
                                                          _khadem.add(Employee(id:val.id,name: val.name ));
                                                        setState(() {

                                                        });
                                                        Navigator.of(context).pop();
                                                      },);
                                                  },
                                                );
                                              }),
                                          CustomListField(title: fields.getField('khatib_ids').label,employees: _khatib,isEditMode:true,
                                              onDelete: (id){
                                                
                                                _khatib.removeWhere((item) => item.id == id);
                                                setState(() {

                                                });
                                              },
                                              onTab:(){
                                                showModalBottomSheet(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return MosqueUserList(client: this.widget.client,
                                                      type: "khatib",
                                                      title: fields.getField('khatib_ids').label,
                                                      onAddEmployee: (){
                                                        Navigator.of(context).pop();
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) => new CreateEmployee(client: this.widget.client,),
                                                            //HalqaId: 1
                                                          ),
                                                        );
                                                      },
                                                      onItemTap: (Employee val){
                                                   
                                                        if(_khatib.where((number) => number.id==val.id).length==0)
                                                          _khatib.add(Employee(id:val.id,name: val.name ));
                                                        setState(() {

                                                        });
                                                        Navigator.of(context).pop();
                                                      },);
                                                  },
                                                );
                                              }),
                                          // CustomFormField(title: 'Alimam',onTab: (){
                                          //   showAlimModal();
                                          // },value: newMosque.alImam,isRequired: true,onSave:(val) => newMosque.alImam = val,isSelection:true,isReadonly:true,),
                                          // CustomFormField(title: 'Almudhin',onTab: (){
                                          //   showAlmudhinModal();
                                          // },value: newMosque.alMudhin,isRequired: true,onSave:(val) => newMosque.alMudhin = val,isSelection:true,isReadonly:true,),
                                          // CustomFormField(title: 'Alkhatib',onTab: (){
                                          //   showAlkhatibModal();
                                          // },value: newMosque.alKhatib,isRequired: true,onSave:(val) => newMosque.alKhatib = val,isSelection:true,isReadonly:true,),

                                        ],

                                      ),
                                    ),
                                  ),
                                  CustomEnhanceStep(
                                    // icon: Icon(Icons.add, color: Colors.redAccent, size: 30,),
                                    state: StepState.editing,
                                    isActive: _index >= 2,
                                    title: Text("complete".tr(),style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color:_index>1?AppColors.secondly: AppColors.onPrimary.withOpacity(.5))),
                                    subtitle: Text("",),
                                    content: Container(
                                      padding: EdgeInsets.only(top: 100),
                                      child: Column(
                                        children: [
                                          Icon(FontAwesomeIcons.smile,color: AppColors.secondly,size: 200,),
                                          SizedBox(height: 30,),

                                          Text("success".tr(),style: TextStyle(color: AppColors.secondly,fontSize: 40),),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                                onStepCancel: () {
                                  go(-1);
                                },
                                onStepContinue: () {
                                  go(1);
                                },
                             
                              stepIconBuilder: (int index,StepState step){
                                  return Icon(index==0?FontAwesomeIcons.mosque:index==1?FontAwesomeIcons.peopleGroup:Icons.check_circle, color: (_index>=index)?AppColors.secondly: AppColors.onPrimary.withOpacity(.5), size: 25,);
                              },
                              controlsBuilder: (BuildContext context, ControlsDetails details) {
                                return _index==0?Row(
                                  children: [
                                    Expanded(child: PrimaryButton(text: "next".tr(),onTab:(){
                                      if(isVerifyDevice()) {
                                        //go(1);
                                        if (_formKey.currentState!.validate()) {
                                          _formKey.currentState!.save();
                                          setState(() {

                                          });
                                          go(1);
                                        }
                                      }
                                      
                                      //key: _formKey,
                                      //
                                    })),
                                  ],
                                ):_index==1?(
                                    isVisiablePermission? Visibility(
                                      visible:  isVisiablePermission,
                                      child: Container(
                                          margin: EdgeInsets.only(bottom: 5),
                                          padding: EdgeInsets.all(10),
                                          //height: 30,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(7),
                                            border: Border.all(
                                              color: Colors.grey.shade200,  // Set this to the desired color when not authorized
                                              width: 1.0,       // Adjust the width as needed
                                            ),
                                            color: permission.status==GPSPermissionStatus.authorize?AppColors.backgroundColor :AppColors.backgroundColor,
                                          ),
                                          child: Row(
                                            children: [
                                              permission.status==GPSPermissionStatus.authorize?Icon(Icons.check_circle,color: Colors.grey.shade400,):Icon(Icons.warning_amber,color: Colors.grey.shade400,),
                                              SizedBox(width: 5,),
                                              Expanded(
                                                  child: Text(permission.statusDesc,style: TextStyle(fontSize: 13 ,color: Colors.grey.shade400),)
                                              ),
                                              !permission.isCompleted?SizedBox(
                                                  height: 25.0,
                                                  width: 25.0,
                                                  child: CircularProgressIndicator(color: Colors.grey.shade400,)):permission.showTryAgainButton?
                                              TextButton(
                                                  style: TextButton.styleFrom(
                                                      padding: EdgeInsets.zero,
                                                      minimumSize: Size(50, 25),
                                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                      alignment: Alignment.centerLeft),
                                                  onPressed: () {
                                                    if(permission.status==GPSPermissionStatus.locationDisabled){
                                                      permission.enableMobileLocation();
                                                    }else if(permission.status==GPSPermissionStatus.permissionDenied){
                                                      permission.allowPermission();
                                                    }else if(permission.status==GPSPermissionStatus.failFetchCoordinate || permission.status==GPSPermissionStatus.unAuthorizeLocation){
                                                      permission.getCurrentLocation();
                                                    }
                                                  },child: Text('try_again'.tr(),style: TextStyle(color: Colors.grey.shade400,decoration: TextDecoration.underline,),)):Container() ,
                                            ],
                                          )
                                      ),
                                    ):
                                    Row(
                                  children: <Widget>[
                                    Expanded(
                                      child:PrimaryButton(text: "create".tr(),onTab: ()async{
                                      //  createMosque();
                                        newMosque.imamIds = _imams.map((item) => item.id!.toInt()).toList();
                                        newMosque.muezzinIds = _muezzin.map((item) => item.id!.toInt()).toList();
                                        newMosque.khademIds = _khadem.map((item) => item.id!.toInt()).toList();
                                        newMosque.khatibIds = _khatib.map((item) => item.id!.toInt()).toList();
                                       
                                        if (_crewFormKey.currentState!.validate()) {
                                          _crewFormKey.currentState!.save();
                                          permission=new GPSPermission(
                                              allowDistance: 0,
                                              latitude:0,
                                              longitude:0,
                                              isOnlyGPS: true
                                          );
                                          setState((){
                                            isVisiablePermission=true;
                                          });
                                          permission.checkPermission();
                                          permission.listner.listen((value){
                                        

                                            if(value){
                                            
                                              newMosque.latitude=double.parse(permission.currentPosition!.latitude.toStringAsFixed(6));
                                              newMosque.longitude= double.parse(permission.currentPosition!.longitude.toStringAsFixed(6));
                                              setState((){
                                                isVisiablePermission=false;
                                              });
                                              confirmationMessage();
                                              //createMosque();

                                            }else{
                                              // setState((){
                                              //   isVisiablePermission=false;
                                              // });
                                            }
                                            setState((){

                                            });
                                          });

                                        }

                                      }),
                                    ),
                                    Expanded(
                                      child: SecondaryButton(
                                        onTab: details.onStepCancel,
                                        text:  'back'.tr(),
                                      ),
                                    ),
                                  ],
                                )):Row(
                                  children: [
                                    Expanded(child: PrimaryButton(text: "view_detail".tr(),onTab: (){
                                      Navigator.pop(context);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                          new MosqueDetail(client: this.widget.client,mosqueId: newMosque.id,),
                                        ),
                                      );
                                    })),
                                  ],
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
