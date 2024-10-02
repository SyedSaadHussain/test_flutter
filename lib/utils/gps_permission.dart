import 'dart:async';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';


import 'package:http/http.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:location/location.dart';
enum GPSPermissionStatus{
  checking,
  locationDisabled,
  permissionDenied,
  permissionDeniedForever,
  unAuthorizeLocation,
  locationOpening,
  permissionInProcess,
  fetchingGPSLocation,
  failFetchCoordinate,
  mocked,
  authorize
}
class GPSPermission {
  StreamController fetchDoneController = new StreamController.broadcast();
  Stream get listner => fetchDoneController.stream;
  bool get isCompleted => status==GPSPermissionStatus.authorize ||
      status==GPSPermissionStatus.unAuthorizeLocation ||
      status==GPSPermissionStatus.permissionDenied ||
      status==GPSPermissionStatus.permissionDeniedForever ||
      status==GPSPermissionStatus.locationDisabled ||
      status==GPSPermissionStatus.mocked ||
      status==GPSPermissionStatus.failFetchCoordinate;
  bool get showTryAgainButton =>
      status==GPSPermissionStatus.unAuthorizeLocation ||
          status==GPSPermissionStatus.permissionDenied ||
          status==GPSPermissionStatus.locationDisabled ||
          status==GPSPermissionStatus.mocked ||
          status==GPSPermissionStatus.failFetchCoordinate;
  GPSPermissionStatus status=GPSPermissionStatus.checking;
  String errorMessage='';
  bool isAllow=false;
  int allowDistance=100;
  double latitude;
  double longitude;
  bool isOnlyGPS;// if this is true then it will only set current location
  String get statusDesc=>status==GPSPermissionStatus.authorize?('gps_status_authorize'.tr()):
  status==GPSPermissionStatus.unAuthorizeLocation?('gps_status_un_authorize_location'.tr())+'('+outsideRadius.toString()+')':
  status==GPSPermissionStatus.locationDisabled?('gps_status_location_disabled'.tr()):
  status==GPSPermissionStatus.permissionDenied?('gps_status_permission_denied'.tr()):
  status==GPSPermissionStatus.checking?('gps_status_checking'.tr()):
  status==GPSPermissionStatus.fetchingGPSLocation?('gps_status_fetching_gps_location'.tr()):
  status==GPSPermissionStatus.failFetchCoordinate?('gps_status_fail_fetch_coordinate'.tr()):
  status==GPSPermissionStatus.permissionInProcess?('gps_status_permission_in_process'.tr()):
  status==GPSPermissionStatus.permissionDeniedForever?('gps_status_permission_denied_forever'.tr()):
  status==GPSPermissionStatus.mocked ?('gps_status_mocked_location'.tr()):
  status==GPSPermissionStatus.locationOpening?('gps_status_location_opening'.tr()):'';

  int get outsideRadius=> (this.allowDistance-this.distanceInMeters).round();
  GPSPermission({
    required this.allowDistance,
    required this.latitude,
    required this.longitude,
    this.isOnlyGPS=false
  });

  void checkPermission() async{
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    //enableMobileLocation();
    if (!serviceEnabled) {
      this.status=GPSPermissionStatus.locationDisabled;
      fetchDoneController.add(false);
      enableMobileLocation();
    }else{
      allowPermission();
    }
  }
  void enableMobileLocation() async{
    bool _serviceEnabled;
    Location location = new Location();
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      this.status=GPSPermissionStatus.locationOpening;
      fetchDoneController.add(false);
      _serviceEnabled = await location.requestService();
      if (_serviceEnabled) {
        allowPermission();
      }else{
        this.status=GPSPermissionStatus.locationDisabled;
        fetchDoneController.add(false);
      }
    }
  }
  void allowPermission() async{
    LocationPermission permission;
    this.status=GPSPermissionStatus.permissionInProcess;
    fetchDoneController.add(false);
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
     
      if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
     
        getCurrentLocation();
      }else if (permission == LocationPermission.deniedForever) {
        this.status=GPSPermissionStatus.permissionDeniedForever;
        fetchDoneController.add(false);
      }else{
        this.status=GPSPermissionStatus.permissionDenied;
        fetchDoneController.add(false);
      }
    }else{
    
      getCurrentLocation();
    }
  }
  Position? currentPosition;
  double distanceInMeters=0;
  void getCurrentLocation(){
    status=GPSPermissionStatus.fetchingGPSLocation;

    fetchDoneController.add(false);
    Geolocator.getCurrentPosition().then((value){
   
      currentPosition=value;
  
      if(value.isMocked){
        status=GPSPermissionStatus.mocked;
        fetchDoneController.add(false);
      }else if(isOnlyGPS){
        status=GPSPermissionStatus.authorize;
        fetchDoneController.add(true);
      }else{
        // distanceInMeters = Geolocator.distanceBetween(24.468789, 39.611047, 24.469638, 39.611122);
        // distanceInMeters = Geolocator.distanceBetween(currentPosition.latitude, currentPosition.longitude, this.latitude, this.longitude);
        distanceInMeters = Geolocator.distanceBetween(currentPosition!.latitude, currentPosition!.longitude, this.latitude, this.longitude);
        //distanceInMeters = Geolocator.distanceBetween(currentPosition.latitude, currentPosition.longitude, 24.963330, 67.074874);
      
        if(distanceInMeters<=allowDistance){
          status=GPSPermissionStatus.authorize;
          fetchDoneController.add(true);
          isAllow=true;
        }else{
          //distanceInMeters=500;
          status=GPSPermissionStatus.unAuthorizeLocation;
          fetchDoneController.add(false);
        }
      }


    }).catchError((e){
      status=GPSPermissionStatus.failFetchCoordinate;
      fetchDoneController.add(false);
    });
  }

}
