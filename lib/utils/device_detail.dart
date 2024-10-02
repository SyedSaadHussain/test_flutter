import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

import '../data/models/device_info.dart';

class DeviceDetail {

  Future<DeviceInformation?> getImei() async{
    var deviceInfo = DeviceInfoPlugin();
    var info=DeviceInformation(id: 0);
    if (Platform.isIOS) { // import 'dart:io'
      var iosDeviceInfo = await deviceInfo.iosInfo;

      info.name=iosDeviceInfo.utsname.machine;
      info.os="ios";
      info.imei=iosDeviceInfo.identifierForVendor;
      info.osVersion=iosDeviceInfo.systemVersion;

      return info; // unique ID on iOS
    } else if(Platform.isAndroid) {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      info.name=androidDeviceInfo.model;
      info.os="android";
      info.imei=androidDeviceInfo.id;
      info.osVersion=androidDeviceInfo.version.release;
      return info; // unique ID on Android
    }

  }
}