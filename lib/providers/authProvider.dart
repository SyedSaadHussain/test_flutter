import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:mosque_management_system/data/models/User.dart';
import 'package:mosque_management_system/data/repositories/custom_odoo_client.dart';
import 'package:mosque_management_system/utils/config.dart';
import 'package:mosque_management_system/utils/shared_preference.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'dart:convert';
enum Status {
  NotLoggedIn,
  NotRegistered,
  LoggedIn,
  Registered,
  Authenticating,
  Registering,
  LoggedOut
}

class AuthProvider with ChangeNotifier {
  Status _loggedInStatus = Status.NotLoggedIn;
  Status _registeredInStatus = Status.NotRegistered;

  Status get loggedInStatus => _loggedInStatus;
  Status get registeredInStatus => _registeredInStatus;

  // Future<Map<String, dynamic>> login(String email, String password) async {
  //   var result;
  //   _loggedInStatus = Status.Authenticating;
  //   notifyListeners();
  //   try {
  //     var client = CustomOdooClient(Config.baseUrl);
  //     OdooSession response=await client.authenticate(Config.database, email, password).
  //     timeout( Duration(seconds: 30));
  //     User authUser = User(userId: response.userId,session: response,userName:response.userName );
  //     UserPreferences().saveUser(authUser);
  //     _loggedInStatus = Status.LoggedIn;
  //     result = {'statusCode':'','status': true, 'message': 'Successful', 'user': authUser};
  //
  //   } on OdooException catch (e) {
  //     _loggedInStatus = Status.NotLoggedIn;
  //     notifyListeners();
  //
  //     result = {
  //       'status': false,
  //       'message': 'Invalid_credential'
  //     };
  //   }on Exception catch (_) {
  //     _loggedInStatus = Status.NotLoggedIn;
  //     notifyListeners();
  //     result = {
  //       'status': false,
  //       'message': _
  //     };
  //   }
  //   return result;
  // }
  // void doNotifyListeners(){
  //   notifyListeners();
  // }
}
