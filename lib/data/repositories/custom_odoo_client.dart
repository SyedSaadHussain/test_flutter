import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:mosque_management_system/presentation/screens/Dashboard.dart';
import 'package:mosque_management_system/utils/config.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'package:http/http.dart' as http;

class CustomOdooClient extends OdooClient {
  // The SpecialButton class inherits from the CustomButton class

  CustomOdooClient(String baseURL,
  [OdooSession? sessionId, http.BaseClient? httpClient]) : super(baseURL,sessionId=sessionId,httpClient=httpClient);

  // Future<String> authenticate1(
  //     String db, String login, String password) async {
  //   final params = {'db': db, 'login': login, 'password': password};
  //   const headers = {'Content-type': 'application/json'};
  //   final uri = Uri.parse(Config.baseUrl+'/web/session/authenticate');
  //   final body = json.encode({
  //     'jsonrpc': '2.0',
  //     'method': 'call',
  //     'params': params,
  //     'id': sha1.convert(utf8.encode(DateTime.now().toString())).toString()
  //   });
  //   try {
  //    // final dynamic response = await httpClient.post(uri, body: body, headers: headers);
  //     var response = await http.post(uri, body: body, headers: headers);
  //     var result = json.decode(response.body);
  //
  //     if (result['error'] != null) {
  //       if (result['error']['code'] == 100) {
  //         // session expired
  //
  //         final err = result['error'].toString();
  //         throw OdooSessionExpiredException(err);
  //       } else {
  //         // Other error
  //         final err = result['error'].toString();
  //         throw OdooException(err);
  //       }
  //     }
  //     // Odoo 11 sets uid to False on failed login without any error message
  //     if (result['result'].containsKey('uid')) {
  //       if (result['result']['uid'] is bool) {
  //         throw OdooException('Authentication failed');
  //       }
  //     }
  //
  //
  //     return "";
  //   } catch (e) {
  //
  //     rethrow;
  //   }
  // }

  Future<dynamic> callKwCustom(params) async {
    return callRPCCustom('/web/dataset/call_kw', 'call', params);
  }
  Future<dynamic> checkSessionCustom() async {
    return callRPCCustom('/web/session/check', 'call', {});
  }

  Future<dynamic> callRPCCustom(path, funcName, params) async {
    var headers = {'Content-type': 'application/json'};
    var cookie = '';
    if (sessionId != null) {
      cookie = 'session_id=' + sessionId!.id;
    }
    if (frontendLang.isNotEmpty) {
      if (cookie.isEmpty) {
        cookie = 'frontend_lang=$frontendLang';
      } else {
        cookie += '; frontend_lang=$frontendLang';
      }
    }
    if (cookie.isNotEmpty) {
      headers['Cookie'] = cookie;
    }
    headers['APIAccessToken'] = Config.discoveryApiToken;
    

    final uri = Uri.parse(baseURL + path);
    var body = json.encode({
      'jsonrpc': '2.0',
      'method': 'funcName',
      'params': params,
      'id': sha1.convert(utf8.encode(DateTime.now().toString())).toString()
    });

    try {

      
      final response = await httpClient.post(uri, body: body, headers: headers);
      
     
      var result = json.decode(response.body);
      if (result['error'] != null) {
        if (result['error']['code'] == 100) {
          final err = result['error'].toString();
          destroySession();
          throw OdooSessionExpiredException(err);
        } else {
       
          final err = result['error']['data']['message'].toString();
          throw OdooException(err);
        }
      }
      return result['result'];
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> post(path, params) async {
    var headers = {'Content-type': 'application/json'};
    var cookie = '';
    if (sessionId != null) {
      cookie = 'session_id=' + sessionId!.id;
    }
    if (frontendLang.isNotEmpty) {
      if (cookie.isEmpty) {
        cookie = 'frontend_lang=$frontendLang';
      } else {
        cookie += '; frontend_lang=$frontendLang';
      }
    }
    if (cookie.isNotEmpty) {
      headers['Cookie'] = cookie;
    }
    headers['APIAccessToken'] = Config.discoveryApiToken;


    final url = Uri.parse(baseURL + path);
    
    var body = json.encode(params);

    try {

      var response = await httpClient.post(url,headers:headers,body: body );
      var result = json.decode(response.body);
      if (result['error'] != null) {
        if (result['error']['code'] == 100) {
          final err = result['error'].toString();
          destroySession();
          throw OdooSessionExpiredException(err);
        } else {
          
          final err = result['error']['data']['message'].toString();
          throw OdooException(err);
        }
      }
      return result['result'];

    } catch (e) {
      rethrow;
    }
  }

// Add additional customization if needed
}