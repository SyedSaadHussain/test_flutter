import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:mosque_management_system/constants/app_colors.dart';
import 'package:mosque_management_system/constants/input_decoration_themes.dart';
import 'package:mosque_management_system/data/models/User.dart';
import 'package:mosque_management_system/data/models/app_version.dart';
import 'package:mosque_management_system/data/models/user_credential.dart';
import 'package:mosque_management_system/data/repositories/custom_odoo_client.dart';
import 'package:mosque_management_system/data/repositories/common_repository.dart';
import 'package:mosque_management_system/data/services/user_service.dart';
import 'package:mosque_management_system/presentation/screens/Dashboard.dart';
import 'package:mosque_management_system/providers/authProvider.dart';
import 'package:mosque_management_system/providers/user_provider.dart';
import 'package:mosque_management_system/utils/config.dart';
import 'package:mosque_management_system/utils/shared_preference.dart';
import 'package:mosque_management_system/widgets/bottom_navigation.dart';
import 'package:mosque_management_system/widgets/wave_loader.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:another_flushbar/flushbar.dart';

class UpdateApp extends StatefulWidget {
  final CustomOdooClient client;
  final AppVersion version;
  UpdateApp({required this.client,required this.version});
  @override
  _UpdateAppState createState() => _UpdateAppState();
}

class _UpdateAppState extends State<UpdateApp> {
  AppVersion? version;
  void initState() {
    _userService = UserService(this.widget.client);
    version=this.widget.version;
  }
  UserService? _userService;
  // Method to handle login
  void doLogin ()  {
    setState(() {
      _isLoading=true;
    });

    _userService!.getAppVersion().then((response){
      setState(() {
        _isLoading=false;
      });

      version=response;
      if(version!=null){
     
        version!.launchAppStore();


      }
    }).catchError((e){
      setState(() {
        _isLoading=true;
      });
    });
  }
  bool _isLoading=false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    userProvider = Provider.of<UserProvider>(context);
    _userService!.updateUserProfile(userProvider.userProfile);
  }


  late UserProvider userProvider;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Image.asset(
                'assets/images/headder.jpg', // Replace with your image URL
                fit: BoxFit.cover,
              ),
              Expanded(
                child:Container(
                  color: Theme.of(context).primaryColor,


                )
              )

            ],
          ),
          Padding(
            padding: EdgeInsets.all(20.0),
            child: Form(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 100,),
                  Image.asset(
                    'assets/images/logo.png',
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(height: 50,),
                  Container(
                      padding: EdgeInsets.symmetric(horizontal: 30),

                      child: Center(child: Text('New Update is Available',style: TextStyle(color: AppColors.onPrimary,fontSize: 25),textAlign: TextAlign.center,))),

                  SizedBox(height: 10,),
                  Expanded(child: Container(
                    width: double.infinity,
                    child: SingleChildScrollView(
                        child: Container(
                          child:
                          Text(version!.description??"",
                            style: TextStyle(color: AppColors.onPrimary,height: 1.8,fontSize: 15),),

                        )),
                  )),
                  SizedBox(height: 20,),
                  ElevatedButton(
                    onPressed: doLogin, // Call _handleLogin method on button press
                    child: SizedBox(
                      width: double.infinity,
                      child:_isLoading?WaveLoader(color: Theme.of(context).colorScheme.primary,size: 25)  : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FaIcon(FontAwesomeIcons.rocket),// Add your login icon here
                          SizedBox(width: 8), // Add some spacing between the icon and text
                          Text(
                            "Update Now!",
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 5,),
                  this.version!.hasRequiredUpdate?Container():GestureDetector(

                      onTap: (){
                        Navigator.of(context).pop();
                      },
                      child: Text('Not Now',style: TextStyle(color: AppColors.secondly),))


                ],
              ),
            ),
          ),
        ],
      ),

    );
  }
}