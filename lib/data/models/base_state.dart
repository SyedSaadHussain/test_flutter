import 'package:flutter/material.dart';
import 'package:mosque_management_system/data/models/User.dart';
import 'package:mosque_management_system/data/repositories/custom_odoo_client.dart';
import 'package:mosque_management_system/data/repositories/common_repository.dart';
import 'package:mosque_management_system/providers/user_provider.dart';
import 'package:mosque_management_system/utils/config.dart';
import 'package:mosque_management_system/utils/shared_preference.dart';
import 'package:provider/provider.dart';

abstract class BaseState<T extends StatefulWidget> extends State<T> {
  @override
  void initState() {
    super.initState();
  }
  late UserProvider userProvider;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    userProvider = Provider.of<UserProvider>(context);
    checkSession();
  }
  void checkSession() async {
    try {
      User user = await UserPreferences().getUser();
      var client = CustomOdooClient(userProvider.baseUrl, user.session);
      var repository = CommonRepository(client);
   

      bool isLoggedIn = !(await repository.ischeckSessionExpire().timeout(Duration(seconds: 5)));
      if (!isLoggedIn) {

        UserPreferences().removeUser();
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
      }
    } catch (e) {
  
    }
  
  }
  
}