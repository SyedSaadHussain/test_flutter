import 'dart:async';
import 'dart:convert';
import 'package:mosque_management_system/data/models/User.dart';
import 'package:mosque_management_system/data/models/database.dart';
import 'package:mosque_management_system/data/models/user_credential.dart';
import 'package:odoo_rpc/odoo_rpc.dart';

import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {


  Future<bool> saveUser(User user) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt("userId", user.userId);
    prefs.setString("userName", user.userName);
    prefs.setString("session", json.encode(user.session!.toJson()));
    return prefs.commit();
  }
  // Future<bool> saveDeviceId(String deviceId) async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   prefs.setString("deviceId", deviceId);
  //   return prefs.commit();
  // }
  // Future<bool> isVerifyDevice(bool isVerify) async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   prefs.setBool("isVerifyDevice", isVerify);
  //   return prefs.commit();
  // }

  Future<User> getUser() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt("userId");
      String? dbName = prefs.getString("dbName");
      String? baseUrl = prefs.getString("dbBaseUrl");
      String? userName = prefs.getString("userName");
      String? proxy = prefs.getString("proxy");
      OdooSession? session = prefs.getString("session")==null?null:OdooSession.fromJson(json.decode(prefs.getString("session")??''));
      return User(
          userId: userId??0,
          userName: userName??'',
          dbName: dbName??'',
          baseUrl: baseUrl??'',
          session: session,
          proxy: proxy
      );
    } catch (e) {
      // Handle platform exceptions here
      throw Exception();
    }


  }

  void removeUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.remove("userId");
    prefs.remove("userName");
    prefs.remove("session");
  }

  Future<String?> getToken(args) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    return token;
  }

  Future<String> getName(args) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("name");
    return token??'';
  }

  Future<String?> getId(args) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("userId");
    return token;
  }

  Future<bool> setLanguage(String lang) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("language", lang);
    return true;
  }

  Future<bool> setIsTokenUpdated(bool isUpdate) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("isTokenUpdated", isUpdate);
    return true;
  }

  Future<bool> isAllowLocalAuth() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    bool isAllow = prefs.getBool("localAuth")??true;

    return isAllow;
  }

  Future<bool> setAllowLocalAuth(bool isAllow) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("localAuth", isAllow);
    return true;
  }

  Future<bool> saveCredential(UserCredential cred,Database? selectedDatabase,String? proxy) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString("credentialUserName", cred.userName);
    prefs.setString("credentialUserPassword", cred.password);
    prefs.setInt("dbId", selectedDatabase!.id??0);
    prefs.setString("databaseName", selectedDatabase.dbName??"");
    prefs.setString("dbBaseUrl", selectedDatabase.baseUrl??"");
    prefs.setString("proxy", proxy??"");
    return prefs.commit();
  }

  Future<UserCredential> getUserCredential() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userName = prefs.getString("credentialUserName");
    String? password = prefs.getString("credentialUserPassword");
    return UserCredential(
        userName: userName??"",
        password: password??""
    );
  }
}
