import 'dart:io';

import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:mosque_management_system/constants/app_colors.dart';
import 'package:mosque_management_system/data/repositories/custom_odoo_client.dart';
import 'package:mosque_management_system/data/repositories/common_repository.dart';
import 'package:mosque_management_system/providers/authProvider.dart';
import 'package:mosque_management_system/providers/user_provider.dart';
import 'package:mosque_management_system/utils/config.dart';
import 'package:mosque_management_system/utils/shared_preference.dart';
import 'package:mosque_management_system/widgets/waiting_page.dart';
import 'package:provider/provider.dart';

import 'data/models/User.dart';
import 'presentation/screens/Dashboard.dart';
import 'presentation/screens/LoginScreen.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //HttpOverrides.global = MyHttpOverrides();
  await LocalizeAndTranslate.init(
    assetLoader: const AssetLoaderRootBundleJson('assets/lang/'), 
    supportedLanguageCodes: <String>['ar', 'en'],
    defaultType: LocalizationDefaultType.asDefined,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});
  Future<bool> isUserLogin() async {

    bool isLoggedIn = false;
    User userData =await UserPreferences().getUser();
    //return true;
    if(userData!.session == null || userData!.session!.id=='')
    {
      return false;
    }else{
      return true;
      // try{
      //   var client = CustomOdooClient(Config.baseUrl,userData!.session);
      //   var repository=new CommonRepository(client);
      //   isLoggedIn=!(await repository.ischeckSessionExpire().timeout(Duration(seconds: 5)));
      //   return isLoggedIn;
      // }catch(e){
      //   return true;
      // }
    }
    return isLoggedIn;
  }
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    Future<User> getUserData() => UserPreferences().getUser();
    return LocalizedApp(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => UserProvider()),
        ],
        child: MaterialApp(
           debugShowCheckedModeBanner: false,
          // style 1
          localizationsDelegates: context.delegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          builder: (BuildContext context, Widget? child) {
            child = LocalizeAndTranslate.directionBuilder(context, child);

            return child;
          },
          theme: ThemeData(
            canvasColor: Colors.white,
            tabBarTheme: TabBarTheme(

              unselectedLabelColor: Colors.grey,
              dividerHeight: 1
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: AppColors.backgroundColor,
              surfaceTintColor:  AppColors.backgroundColor,
              titleTextStyle: TextStyle(fontSize: 16,color: AppColors.gray,fontWeight: FontWeight.w300)
            ),
            dialogBackgroundColor: Color(0xfffbffe1),
            dialogTheme: DialogTheme(
              titleTextStyle: TextStyle(fontSize: 20,color: Color(0xff4a4a4a)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
              ),
            ),// Change this color as needed
            scaffoldBackgroundColor:  AppColors.backgroundColor,
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(AppColors.secondly),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0), // Adjust the value as needed
                  ),
                ),
                // Customize other button properties here
              ),
            ),
            inputDecorationTheme:InputDecorationTheme(
              filled: true,

              fillColor: Colors.white,
              hintStyle: TextStyle(color: Colors.grey), // Set hint text color here
              labelStyle: TextStyle(color: Colors.grey), // Set label text color here
              contentPadding: EdgeInsets.all(15),
              isDense: true,
              errorStyle: TextStyle(fontSize: 0),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(
                  color: Colors.grey.shade300, // Set your desired border color here
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(
                  color: Colors.grey.shade300, // Set your desired border color here
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(
                  color: Colors.grey.shade300, // Set your desired border color here
                ),
              ),

            ),
            colorScheme: ColorScheme.fromSwatch().copyWith(
              primary:AppColors.primary,
              primaryContainer: AppColors.primaryContainer,
              secondary:AppColors.secondly,
            ),
          ),
          home:  FutureBuilder(
              future: isUserLogin(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                  return WaitingPage(() {
                    isUserLogin();
                    // setState(() {});
                  });
                  default:
                    if (snapshot.hasError)
                      return Text('Error: ${snapshot.error}');
                    else if (snapshot.data! == null || snapshot.data==false)
                      return LoginScreen();

                    else{

                      //Navigator.pushReplacementNamed(context, '/dashboard');
                      return Dashboard();
                    }
                }
              }
          ),
          routes: {
            '/login': (context) => LoginScreen(),
            '/dashboard': (context) => Dashboard(),
            // '/blueButton': (context) => BlueButton(),
          }
        ),
      ),
    );
  }
}
