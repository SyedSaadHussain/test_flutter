import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:mosque_management_system/constants/app_colors.dart';
import 'package:mosque_management_system/data/models/User.dart';
import 'package:mosque_management_system/data/models/app_version.dart';
import 'package:mosque_management_system/data/models/base_state.dart';
import 'package:mosque_management_system/data/models/device_info.dart';
import 'package:mosque_management_system/data/repositories/custom_odoo_client.dart';
import 'package:mosque_management_system/data/repositories/common_repository.dart';
import 'package:mosque_management_system/data/services/user_service.dart';
import 'package:mosque_management_system/presentation/screens/UpdateApp.dart';
import 'package:mosque_management_system/presentation/screens/settings.dart';
import 'package:mosque_management_system/providers/user_provider.dart';
import 'package:mosque_management_system/utils/config.dart';
import 'package:mosque_management_system/utils/device_detail.dart';
import 'package:mosque_management_system/utils/json_utils.dart';
import 'package:mosque_management_system/utils/shared_preference.dart';
import 'package:mosque_management_system/widgets/app_container.dart';
import 'package:mosque_management_system/widgets/bottom_navigation.dart';
import 'package:mosque_management_system/widgets/tag_button.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);
  @override
  _DashboardState createState() => _DashboardState();
}
// class CustomHttpClient extends http.BaseClient {
//   final http.Client _inner;
//
//   CustomHttpClient(this._inner);
//
//   @override
//   Future<http.StreamedResponse> send(http.BaseRequest request) {
//
//     // Disable certificate validation
//     HttpClient httpClient = HttpClient()
//       ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
//
//     return _inner.send(request);
//   }
// }
class _DashboardState extends BaseState<Dashboard> {
  late CommonRepository _odooRepository;
  CustomOdooClient? client;
  UserService? _userService;

  int? _loginEmployeeId;
  @override
  void dispose() {
    super.dispose();
  
    client!.close();
  }
  @override
  void initState() {
    super.initState();


    Future<User> user = UserPreferences().getUser();
    user.then((value) {

      http.BaseClient? httpClient;
      HttpClient proxyClient = new HttpClient();

      // proxyClient.findProxy = (uri) {
      //   return "PROXY "+(value.proxy??"");
      // };
      // proxyClient.badCertificateCallback = (X509Certificate cert, String host, int port) => true; // Allow all certificates
      //
      IOClient ioClient = IOClient(proxyClient);
      httpClient=  ioClient as http.BaseClient;




      client = CustomOdooClient(value.baseUrl??"",value.session,httpClient);

      userProvider.setDatabaseUrl(value.baseUrl);
      setState(() {

      });
      _userService = UserService(client!);
      //checkForUpdated();
      setState(() {

      });
      _odooRepository = CommonRepository(client);
      _odooRepository!.getUserInfo(value!.session!.userId).then((value) {
        userProvider.setUserProfile(value);
        _loginEmployeeId=value.employeeId;
        checkDeviceVerification(false);
        userProvider.setLanguage(LocalizeAndTranslate.getLanguageCode());
      });
      Future.delayed(Duration.zero, () {
        getDashboardAPI();
      });
    });

  }
  void checkForUpdated(){
    AppVersion? version;
    _userService!.getAppVersion().then((response){
      version=response;
      if(version!=null){
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
            new UpdateApp(client: client!,version: version!,),
          ),
        );
       // version!.showAlertIfNecessary(context);
      }
    });

  }
  void checkDeviceVerification(bool isOnlyLoad){

    DeviceDetail().getImei().then((deviceDetail){
      DeviceInformation? deviceInfo=null;
      List<DeviceInformation> devices=[];
      _userService!.getUserImei(_loginEmployeeId!).then((values){

        devices=values;
        deviceInfo=devices.where((rec)=>(rec.imei??"")==(deviceDetail!.imei??"")).firstOrNull;

        if(deviceInfo!=null){
          if(deviceInfo!.status=="live")
            userProvider.setDeviceStatus(true);
          else
            userProvider.setDeviceStatus(false);

        }else{
          if(isOnlyLoad==false && AppUtils.isNotNullOrEmpty(deviceDetail!.imei)){
            deviceInfo=devices.where((rec)=>(rec.employeeId??"")==(userProvider.userProfile.employeeId)).firstOrNull;
            if(deviceInfo==null){
              deviceDetail!.status=devices.length>0?"temp":"live";
              _userService!.saveImei(deviceDetail).then((values){
                checkDeviceVerification(true);
              }).catchError((_){

              });
            }
          }
        }
      }).catchError((e){

      });
    });

  }
  void registerDevice(){

  }
  Map<String, dynamic>?  visitGraph;
  Map<String, dynamic>?  mosqueGraph;
  List<dynamic>?  visitSummaryDetail;
  void getDashboardAPI(){
    _userService!.getDashboardAPI().then((value){


        Map<String, dynamic> json=value;
        visitGraph=value['mosqueRequest']['general_information'];
        visitSummaryDetail=value['mosqueRequest']['visit_by_mosque'];
        setState(() {

        });
      }).catchError((e){

    });
    _userService!.getMasjidSummaryAPI().then((value){
      mosqueGraph=value['mosqueRequest']["mosques"];
      setState(() {

      });
    }).catchError((e){
    
    });
  }
  late UserProvider userProvider;

  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<UserProvider>(context);
    if(_userService!=null)
      _userService!.updateUserProfile(userProvider.userProfile);

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [

              Expanded(
                  child:Container(
                    color: Theme.of(context).primaryColor,


                  )
              )

            ],
          ),
          Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15),

                height: 170,
                child:
                Column(
                  children: [
                    SizedBox(height: 30,),
                    Align(
                        alignment: Alignment.topRight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            PopupMenuButton(
                              color: AppColors.flushColor,
                              icon: Icon(Icons.more_vert,color:Theme.of(context).colorScheme.onPrimary.withOpacity(.8) ,), // Dotted button icon
                              itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                                PopupMenuItem(
                                  child: ListTile(
                                    leading: Icon(Icons.settings,color: Theme.of(context).colorScheme.onPrimary.withOpacity(.7),),
                                    title: Text('settings'.tr(),style: TextStyle(color:Theme.of(context).colorScheme.onPrimary.withOpacity(.7) ),),
                                  ),
                                  value: 'settings',
                                ),

                                PopupMenuItem(
                                  child: ListTile(
                                    leading: Icon(Icons.logout,color: Theme.of(context).colorScheme.onPrimary.withOpacity(.7) ),
                                    title: Text('logout'.tr(),style: TextStyle(color:Theme.of(context).colorScheme.onPrimary.withOpacity(.7) )),
                                  ),
                                  value: 'logout',
                                ),
                              ],
                              onSelected: (value) {
                                // Handle menu item selection
                                switch (value) {
                                  case 'settings':
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                        new Settings(client: client!),
                                      ),
                                    );
                                    break;
                                  case 'logout':
                                    Future<User> user2 = UserPreferences().getUser();
                                    user2.then((value) {
                                      UserPreferences().removeUser();
                                      userProvider.logout();
                                      Navigator.of(context).pushNamedAndRemoveUntil(
                                          '/login', (Route<dynamic> route) => false);
                                    });
                                    break;
                                }
                              },
                            ),
                          ],
                        )
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children:[
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.backgroundColor,
                            border: Border.all(
                              color: Color(0xff288056),
                              width: 5.0,
                            ),
                          ),
                          child:  ClipOval(
                            child: Image.network('${userProvider.baseUrl}/web/image?model=res.partner&field=avatar_128&id=${userProvider.userProfile.userId}&unique=${0}',headers: _userService?.headersMap!??null,fit: BoxFit.fitHeight,
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
                        SizedBox(width: 8,),
                        Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(userProvider.userProfile.name??"",style: TextStyle(color: AppColors.onPrimary,fontSize: 18),),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 5),
                                      child: userProvider.isDeviceVerify?Icon(
                                        Icons.check_circle,
                                        color: Colors.green, // Set the color to green
                                        size: 20.0, // Optional: Adjust the size of the icon
                                      ):GestureDetector(
                                        onTap: (){
                                          checkDeviceVerification(false);
                                        },
                                        child: Icon(
                                          Icons.warning,
                                          color: Colors.amber, // Set the color to green
                                          size: 20.0, // Optional: Adjust the size of the icon
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                Text(userProvider.userProfile.company??"",style: TextStyle(color: AppColors.onPrimary,fontSize: 13),  softWrap: true,),
                              ],
                            )
                        ),
                      ]
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15.0),
                        topRight: Radius.circular(15.0),
                      ),
                      color: Colors.white,
                    ),
                    width: double.infinity,
                  
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(height: 20,),
                          // AppLargeContainer((){
                          //   Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //       builder: (context) => new AllMosques(client: client!,),
                          //       //HalqaId: 1
                          //     ),
                          //   );
                          //
                          // },color:AppColors.flushColor,
                          //     onColor: Colors.white,icon: Icons.mosque,
                          //     value: "15",
                          //     text:  "Total Mosque you can see"),
                          mosqueGraph!=null?AppLargeContainer((){

                          },color:AppColors.flushColor,
                              onColor: Colors.white,icon: Icons.mosque,
                              child: SingleChildScrollView(
                                 scrollDirection: Axis.horizontal,
                                child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children:
                                    (mosqueGraph?? {}).entries.map((entry) {
                                      return        Container(
                                        padding: EdgeInsets.symmetric(horizontal: 3),
                                        child: Column(
                                          children: [

                                            Text(entry.key,style: TextStyle(color: Colors.white.withOpacity(.7),fontSize: 15),),
                                            Text(JsonUtils.convertToString(entry.value),style: TextStyle(color: Colors.white.withOpacity(.6),fontSize: 25,fontWeight: FontWeight.w300),),
                                          ],
                                        ),
                                      );
                                    }).toList()
                                ),
                              ),
                              text:  "mosques_summary".tr()):Container(),

                          visitGraph!=null?AppLargeContainer((){

                          },color:Colors.blueGrey,
                              onColor: Colors.white,icon: Icons.location_history,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children:

                                (visitGraph?? {}).entries.map((entry) {
                                  return        Container(
                                      child: Column(
                                        children: [

                                          Text(entry.key,style: TextStyle(color: Colors.white.withOpacity(.7)),),
                                          Text(JsonUtils.convertToString(entry.value),style: TextStyle(color: Colors.white.withOpacity(.6),fontSize: 25,fontWeight: FontWeight.w300),),
                                        ],
                                      ),
                                    );
                                }).toList()
                              ),
                              text:  "visit_summary".tr()):Container(),

                          visitSummaryDetail!=null?Container(
                            margin: EdgeInsets.symmetric(horizontal: 6,vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.grey.shade300, // Change this to your desired border color
                                width: 1.0, // Adjust the width as needed
                              ),

                            ),
                            child: Column(
                              children: (visitSummaryDetail??[]).map((item) {

                                return Container(

                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.grey.shade200, // Border color
                                        width: 1.0, // Border width
                                      ),
                                    ),
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 6,vertical: 0),
                                  child: ListTile(

                                    contentPadding: EdgeInsets.all(0),

                                    // leading:

                                    title: Row(
                                      children: [
                                        // ImageData(id: 0, modelName: Model.mosque, fieldId: "outer_image",uniqueId: '',headersMap: _userService!.headersMap,height: 90,width: 80,),
                                        Expanded(
                                          child: Container(
                                              padding: EdgeInsets.all(5),
                                              //color: Colors.lightBlueAccent,

                                              child:
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [

                                                  Text(item["mosque_name"],style: TextStyle(color:Colors.black.withOpacity(.5),fontSize: 14),),
                                                  SizedBox(height: 5,),

                                                  item["visit_info"]==null?Container(): SingleChildScrollView(
                                                    scrollDirection: Axis.horizontal,
                                                    child: Row(
                                                      children:
                                                      item["visit_info"]!.entries.map<Widget>((entry) {
                                                        return   CustomTag(title:(JsonUtils.convertToString(entry.key)+" "+JsonUtils.convertToString(entry.value)));
                                                      }).toList()


                                                      // [
                                                      //   CustomTag(title:( (item["visit_info"]["Done"]??0).toString())+" "+'draft'.tr()),
                                                      //   CustomTag( title:((item["visit_info"]["Draft"]??0).toString())+" "+'done'.tr()),
                                                      //   CustomTag(title:((item["visit_info"]["Supervisor"]??0).toString())+" "+'supervisor'.tr()),
                                                      //   CustomTag(title:((item["visit_info"]["Management"]??0).toString())+" "+'management'.tr()),
                                                      // ],
                                                    ),
                                                  )


                                                ],
                                              )
                                          ),
                                        ),
                                      ],
                                    ),

                                  ),
                                );

                              }).toList(),
                            ),
                          ):Container()

                        ],
                      ),
                    ),
                  ),

              ),
              // Add more widgets as needed
            ],
          ),
        ],
      ),
      bottomNavigationBar:client==null?null:BottomNavigation(client: client!,selectedIndex: 0),
    );
  }
}