import 'package:mosque_management_system/data/repositories/custom_odoo_client.dart';
import 'package:mosque_management_system/utils/shared_preference.dart';
import 'package:odoo_rpc/odoo_rpc.dart';

class User {
  final int userId;
  final String userName;
  final bool? isIDeviceIdUpdated;
  final String? deviceId;
  final String? baseUrl;
  final String? dbName;
  final String? proxy;
  OdooSession? session;
  // Add more fields as needed

  User({
    required this.userId,
    required this.userName,
    this.isIDeviceIdUpdated,
    this.deviceId,
    this.baseUrl,
    this.dbName,
    this.session,
    this.proxy
  });

  Future<Map<String, dynamic>> login(String url,String db,String email, String password) async {

    var result;
    try {
      var client = CustomOdooClient(url);
      OdooSession response=await client.authenticate(db, email, password).
      timeout( Duration(seconds: 30));
      User authUser = User(userId: response.userId,session: response,userName:response.userName );
      UserPreferences().saveUser(authUser);

      result = {'statusCode':'','status': true, 'message': 'Successful', 'user': authUser};
      
    } on OdooException catch (e) {
      result = {
        'status': false,
        'message': 'Invalid_credential'
      };
    }on Exception catch (_) {
   

      result = {
        'status': false,
        'message': _
      };
    }
    return result;
  }

  // factory User.fromJson(Map<String, dynamic> json) {
  //   return User(
  //     id: json['id'] as int,
  //     username: json['username'] as String,
  //     email: json['email'] as String,
  //     // Initialize other fields from JSON
  //   );
  // }

  // Map<String, dynamic> toJson() {
  //   return {
  //     'id': id,
  //     'username': username,
  //     'email': email,
  //     // Add other fields as needed
  //   };
  // }
}