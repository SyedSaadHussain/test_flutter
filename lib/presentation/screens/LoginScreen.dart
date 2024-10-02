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
import 'package:mosque_management_system/data/models/database.dart';
import 'package:mosque_management_system/data/models/user_credential.dart';
import 'package:mosque_management_system/data/repositories/custom_odoo_client.dart';
import 'package:mosque_management_system/data/repositories/common_repository.dart';
import 'package:mosque_management_system/data/services/network_service.dart';
import 'package:mosque_management_system/presentation/screens/Dashboard.dart';
import 'package:mosque_management_system/providers/authProvider.dart';
import 'package:mosque_management_system/providers/user_provider.dart';
import 'package:mosque_management_system/utils/config.dart';
import 'package:mosque_management_system/utils/shared_preference.dart';
import 'package:mosque_management_system/widgets/app_title.dart';
import 'package:mosque_management_system/widgets/bottom_navigation.dart';
import 'package:mosque_management_system/widgets/service_button.dart';
import 'package:mosque_management_system/widgets/wave_loader.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:another_flushbar/flushbar.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = new GlobalKey<FormState>();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _proxyController = TextEditingController();

  // Create an instance of your service class
  late CommonRepository _odooRepository ;
  //String defaultDB=Config.database;
  final LocalAuthentication auth = LocalAuthentication();
  bool? _canCheckBiometrics;
  List<BiometricType>? _availableBiometrics;
  String _authorized = 'Not Authorized';
  bool _isAuthenticating = false;
  List<Database> databases=[];
  Database? selectedDatabase;
  bool isShowDatabase=false;
  getDatabaseName() async{
    if(Config.isTestDb){
      databases=[];
      databases.add(Database(id: 0, baseUrl: TestDatabase.baseUrl,dbName: TestDatabase.database,name: "config"));
      selectedDatabase=databases[0];
      setState(() {
        isShowDatabase=false;
      });
    }else{
     
      final networkService = NetworkService(baseUrl: Config.discoveryUrl);
      try {
        final response = await networkService.get(
            '/api/discovery/data'
        );
       
        databases= (response['data'] as List).map((item) => Database.fromJson(item)).toList();;
        if (databases.length==1) {
          selectedDatabase = databases[0];
          isShowDatabase=false;
        }
        else if(databases.length>1){
          isShowDatabase=true;
        }
        setState(() {

        });
       
      } catch (e) {
       
        selectedDatabase=null;
      } finally {
        networkService.close();
      }
    }

  }

  showClientModal(){
    getDatabaseName();
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context)
    {
      return Container(
        // margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8), // Adjust top radius here
            topRight: Radius.circular(8),
          ),
        ),

        child: Container(
          child: Column(
            children: [
              ModalTitle("Select Client",Icons.category),
              Expanded(
                child: Container(
                  margin: EdgeInsets.all(10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(height: 10),
                      Expanded(

                        child: ListView.builder(
                          itemCount: databases.length ?? 0,
                          itemBuilder: (BuildContext context, int index) {
                            return Container(
                              padding: EdgeInsets.symmetric(vertical: 0),

                              decoration: BoxDecoration(
                                color:  index % 2 == 0 ? Colors.grey[100] : Colors.white,
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey.shade100, // Change color as needed
                                    width: 1.0, // Change thickness as needed
                                  ),
                                ),
                              ),
                              child: ListTile(

                                title: Text(databases[index].name??"",style: TextStyle(fontWeight: FontWeight.w300,color: AppColors.body),),

                                onTap: () {
                                  selectedDatabase=databases[index];
                                  setState(() {

                                  });
                                  Navigator.pop(context);

                                 // this.widget.onItemTap(data.list[index]);
                                },

                                leading:
                                (selectedDatabase!=null && databases[index].id==(selectedDatabase!.id??-1))?
                                Icon(Icons.check_circle,color: AppColors.primary):
                                Icon(Icons.circle_outlined,color: AppColors.gray,),
                              ),
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
        ),
      );
    }
    );
  }

  Future<void> _checkBiometrics() async {
    late bool canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      canCheckBiometrics = false;
    }
    if (!mounted) {
      return;
    }

    setState(() {
      _canCheckBiometrics = canCheckBiometrics;
    });
  }

  Future<void> _cancelAuthentication() async {
    await auth.stopAuthentication();
    setState(() => _isAuthenticating = false);
  }

  late UserCredential userCredentail;
  bool isAllowLocalAuth=false;
  void initState() {
    //remove if logout by session out
    Future.delayed(Duration.zero, () {
      userProvider.logout();
    });

    getDatabaseName();
    UserPreferences().getUserCredential().then((value) {
      setState(() {
        userCredentail=value;
      });
    });
    _checkBiometrics();
    UserPreferences().isAllowLocalAuth().then((value) {
      setState(() {
        isAllowLocalAuth=value;
      });
    });


  }
  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }  Future<void> _authenticate() async {
    if(!isAllowLocalAuth){
      Flushbar(
        icon: Icon(Icons.warning,color: Colors.white,),
        backgroundColor: AppColors.flushColor,
        title: 'warning'.tr(),
        message: "enable_local_authentication".tr(),
        duration: Duration(seconds: 3),
      ).show(context);
    }else if(userCredentail.userName==""){
      Flushbar(
        icon: Icon(Icons.warning,color: Colors.white,),
        backgroundColor:  AppColors.flushColor,
        title: 'warning'.tr(),
        message: "please_login".tr(),
        duration: Duration(seconds: 3),
      ).show(context);
    }else{
      // await auth.stopAuthentication();
      bool authenticated = false;
      try {
        setState(() {
          _isAuthenticating = true;
          _authorized = 'Authenticating';
        });
        authenticated = await auth.authenticate(
            localizedReason: 'localized_reason',
            // authMessages:  <AuthMessages>[
            //   AndroidAuthMessages(
            //     signInTitle: 'sign_in_title'.tr(),
            //     cancelButton: 'cancel'.tr(),
            //     biometricHint: 'biometric_hint'.tr(),
            //   ),
            // ],
            options: AuthenticationOptions(useErrorDialogs: true,sensitiveTransaction: false)

        ).catchError((_){
          setState(() {
            _isAuthenticating = false;
          });
        });
        setState(() {
          _isAuthenticating = false;
        });
      } on PlatformException catch (e) {
        await auth.stopAuthentication();
        setState(() {
          _isAuthenticating = false;
          _authorized = 'Error - ${e.message}';
        });
        return;
      }
      if (!mounted) {
        return;
      }
      if(authenticated){
        _username=userCredentail.userName;
        _password=userCredentail.password;
        _handleLogin();
      }

      // setState(
      //         () => _authorized = authenticated ? 'Authorized' : 'Not Authorized');
    }

  }
  String _username='', _password='',_proxy='';
  bool _isLoading=false;
  // Method to handle login
  void doLogin ()  {
    setState(() {
      _error_msg="";
    });
    final form = formKey.currentState;
    try{

      if (form!.validate()) {

        form.save();
        _username = _usernameController.text.trim();
        _password = _passwordController.text.trim();
        _proxy = _proxyController.text.trim();
        _handleLogin();
      } else {
      }
    }
    catch(e){
    }

  }
  Future<void> _handleLogin() async {

    setState(() {
      _isLoading=true;
    });

    http.BaseClient? httpClient;
    HttpClient proxyClient = new HttpClient();
    //
    // proxyClient.findProxy = (uri) {
    //   return "PROXY "+_proxy;
    // };
    // proxyClient.badCertificateCallback = (X509Certificate cert, String host, int port) => true; // Allow all certificates
    //
    IOClient ioClient = IOClient(proxyClient);
    httpClient=  ioClient as http.BaseClient;


    final client = CustomOdooClient(selectedDatabase!.baseUrl??"",null,httpClient);

    _odooRepository = CommonRepository(client);


    // Call your service method for authentication
    final Future<Map<String, dynamic>> successfulMessage
        =  _odooRepository.authenticate(selectedDatabase!.baseUrl??"",selectedDatabase!.dbName??"",_username, _password);
    successfulMessage.then((response) {

      setState(() {
        _isLoading=false;
      });
      if (response['status']) {
        UserPreferences().saveCredential(UserCredential(userName: _username, password: _password),selectedDatabase!,_proxy);
        // Navigate to the next screen upon successful login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Dashboard(),
          ),
        );
      } else {

        setState(() {
          _error_msg=response['message'].toString()=="Invalid_credential"?"incorrect_password".tr():response['message'].toString();
        });
       
        Flushbar(
          icon: Icon(Icons.warning,color: Colors.white,),
          backgroundColor:  AppColors.flushColor,
          title: 'warning'.tr(),
          message: _error_msg,
          duration: Duration(seconds: 3),
        ).show(context);
      }
    }).catchError((e){

      setState(() {
        _isLoading=false;
      });
    });

  }
String _error_msg='';
  bool isObscureText=true;
  void togglePasswordVisibility() {
    setState(() {
      isObscureText = !isObscureText;
    });
  }

  final OutlineInputBorder outlineInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(8.0),
    borderSide: BorderSide(
      color: Colors.white.withOpacity(.2), // Set your desired border color here
    ),
  );

  bool loginWithUserName=false;
  bool get loginOnlyBiometric =>(loginWithUserName==false) && (_canCheckBiometrics??false) && userCredentail.userName!="" && isAllowLocalAuth;

  late UserProvider userProvider;
  @override
  Widget build(BuildContext context) {
    AuthProvider auth = Provider.of<AuthProvider>(context);
    userProvider = Provider.of<UserProvider>(context);
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
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    'assets/images/logo.png',
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(height: 40,),
                 (loginOnlyBiometric || isShowDatabase==false)?Container():Align(
                    alignment: Alignment.centerRight,
                    child: AppButton(
                      onTab: (){
                        showClientModal();
                      },
                      text:  selectedDatabase==null?"Select Client":selectedDatabase!.name??"",
                      isFullWidth: false,isOutline: true,color: selectedDatabase==null?AppColors.danger:AppColors.secondly
                    ),
                  ),
                  // TextFormField(
                  //   style: TextStyle(color: Colors.white),
                  //   decoration: MyInputDecorationThemes.firstInputDecoration(context,label: "Proxy[IP:PORT]",icon: Icons.security),
                  //   controller: _proxyController,
                  //   validator: (value) {
                  //     if (value == null || value.isEmpty) {
                  //       return '';
                  //     }
                  //     return null;
                  //   },
                  //
                  // ),
                  SizedBox(height: 5,),


                  loginOnlyBiometric==true?
                  Column(
                    children: [
                      Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _authenticate, // Call _handleLogin method on button press
                          child: SizedBox(
                            width: double.infinity,
                            child:_isLoading?WaveLoader(color: Theme.of(context).colorScheme.primary,size: 25)  : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.fingerprint), // Add your login icon here
                                SizedBox(width: 8), // Add some spacing between the icon and text
                                Text(
                                  "login".tr(),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          TextButton(
                            onPressed:(){
                              setState(() {
                                loginWithUserName=true;
                              });
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.login,color: Theme.of(context).colorScheme.onPrimary,),
                                SizedBox(width: 5),
                                Text('login_another_account'.tr(),style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),), // Display the current language code
                              ],
                            ),
                          ),
                          Expanded(child: Container()),
                          TextButton(
                            onPressed: () {
                              // Toggle language between Arabic and English
                              if (LocalizeAndTranslate.getLanguageCode() == 'ar') {
                                LocalizeAndTranslate.setLanguageCode('en');
                              } else {
                                LocalizeAndTranslate.setLanguageCode('ar');
                              }
                              // Set the locale based on the current context
                              LocalizeAndTranslate.setLocale(context.locale);
                              //Navigator.pop(context, 'es');
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(context.locale.languageCode!='ar'?'العربي':'English',style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),), // Display the current language code
                                SizedBox(width: 5), // Add some space between text and icon
                                Icon(Icons.language,color: Theme.of(context).colorScheme.onPrimary,), // Add an icon (you can replace it with your desired icon)
                              ],
                            ),
                          ),
                        ],
                      )
                    ],
                  ):
                  Column(
                    children: [

                      TextFormField(
                        style: TextStyle(color: Colors.white),
                        decoration: MyInputDecorationThemes.firstInputDecoration(context,label: "user_name".tr(),icon: Icons.person),
                        controller: _usernameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '';
                          }
                          return null;
                        },

                      ),
                      SizedBox(height: 5.0),
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '';
                          }
                          return null;
                        },
                        controller: _passwordController,
                        obscureText: this.isObscureText,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 10.0,horizontal: 10),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isObscureText ? FontAwesomeIcons.eye : FontAwesomeIcons.eyeSlash,
                              color: Colors.white,
                            ),
                            onPressed: togglePasswordVisibility,
                          ),
                          labelStyle: TextStyle(color: Colors.blue), // Set label text color
                          hintStyle: TextStyle(color: Colors.blue),
                          label: Text("password".tr(),style: TextStyle(color: Colors.white.withOpacity(.4)),),
                          fillColor: Colors.white.withOpacity(.2),

                          // Customize the appearance of the input fields for the first theme
                          focusedBorder: outlineInputBorder,
                          enabledBorder: outlineInputBorder,
                          border: outlineInputBorder,
                          // Add more customizations as needed
                        ),


                      ),
                      SizedBox(height: 5.0),
                      Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading?null:doLogin, // Call _handleLogin method on button press
                          child: SizedBox(
                            width: double.infinity,
                            child:_isLoading?WaveLoader(color: Theme.of(context).colorScheme.primary,size: 25)  : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.login), // Add your login icon here
                                SizedBox(width: 8), // Add some spacing between the icon and text
                                Text(
                                  "login".tr(),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      Row(
                        children: [
                          if (!(_canCheckBiometrics??false))
                            Container()
                          else if (_isAuthenticating)
                            TextButton(
                              onPressed: _cancelAuthentication,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('cancel_authentication'.tr(),style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),), // Display the current language code
                                  SizedBox(width: 5), // Add some space between text and icon
                                  Icon(Icons.cancel,color: Theme.of(context).colorScheme.onPrimary,), // Add an icon (you can replace it with your desired icon)
                                ],
                              ),
                            )
                          else
                            TextButton(
                              onPressed: _authenticate,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.fingerprint,color: Theme.of(context).colorScheme.onPrimary,),
                                  SizedBox(width: 5),
                                  Text('using_biometric'.tr(),style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),), // Display the current language code
                                ],
                              ),
                            ),
                          Expanded(child: Container()),
                          TextButton(
                            onPressed: () {
                              // Toggle language between Arabic and English
                              if (LocalizeAndTranslate.getLanguageCode() == 'ar') {
                                LocalizeAndTranslate.setLanguageCode('en');
                              } else {
                                LocalizeAndTranslate.setLanguageCode('ar');
                              }
                              // Set the locale based on the current context
                              LocalizeAndTranslate.setLocale(context.locale);
                              //Navigator.pop(context, 'es');
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(context.locale.languageCode!='ar'?'العربي':'English',style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),), // Display the current language code
                                SizedBox(width: 5), // Add some space between text and icon
                                Icon(Icons.language,color: Theme.of(context).colorScheme.onPrimary,), // Add an icon (you can replace it with your desired icon)
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),


                ],
              ),
            ),
          ),
        ],
      ),

    );
  }
}