import 'package:flutter/foundation.dart';
import 'package:mosque_management_system/data/models/menuRights.dart';
import 'package:mosque_management_system/data/models/userProfile.dart';
import 'package:mosque_management_system/utils/config.dart';

class UserProvider with ChangeNotifier {
  UserProfile _userProfile= UserProfile(userId: 0);
  MenuRights? _menuRights;
  String? _baseUrl;
  int _pendingApproval=0;
  bool _isDeviceVerify=false;

  UserProfile get userProfile => _userProfile;
  MenuRights? get menuRights => _menuRights;
  int get totalPendingApproval => _pendingApproval;
  bool get isDeviceVerify => _isDeviceVerify;
  String get baseUrl => _baseUrl??"";
  void setDatabaseUrl(String? url) {
    _baseUrl = url;
    notifyListeners();
  }
  void setMenu(MenuRights menu) {
    _menuRights = menu;
    notifyListeners();
  }
  void setLanguage(String language) {
    _userProfile.language=language=='ar'?Language.arabic:Language.english;
    notifyListeners();
  }
  void setDeviceStatus(bool isVerify) {
    _isDeviceVerify=isVerify;
    notifyListeners();
  }
  void setUserProfile(UserProfile user) {
    _userProfile = user;
    notifyListeners();
  }
  void setPendingApproval(int value) {
    _pendingApproval = value;
    notifyListeners();
  }
  void logout() {
    _isDeviceVerify=false;
    _pendingApproval=0;
    _menuRights=null;
    _baseUrl=null;
    _userProfile= UserProfile(userId: 0);
    notifyListeners();
  }
}
