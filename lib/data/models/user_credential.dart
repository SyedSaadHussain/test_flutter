import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:odoo_rpc/odoo_rpc.dart';

class UserCredential {
  String userName;
  String password;

  UserCredential({
    required this.userName,
    required this.password,
  });
}
