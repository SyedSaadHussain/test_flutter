import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:mosque_management_system/utils/config.dart';
import 'package:mosque_management_system/utils/json_utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io' show Platform;

class AppVersion {
  String? storeVersion;
  String? lastRequiredVersion;
  String? localVersion;
  String? platform;
  String? status;
  String? description;

  String? get appStoreLink => (platform??'')=="ios"?Config.appleStoreLink:(platform??"")=="android"?Config.playStoreLink:"";

  AppVersion({
    this.lastRequiredVersion,
    this.storeVersion,
    this.platform,
    this.status,
    this.description,
   });

  factory AppVersion.fromJson(Map<String, dynamic> json){
    return AppVersion(
      storeVersion: "2.0.3",
      lastRequiredVersion: "2.0.1",
      description: "this is test",
      platform: Platform.isIOS?"ios":"android"
    );
  }

  Future<void> launchAppStore() async {
    debugPrint(appStoreLink);
    if (await canLaunch(appStoreLink!)) {
      await launch(appStoreLink!);
    } else {
      await launch(appStoreLink!);
      throw 'Could not launch appStoreLink :'+appStoreLink!;
    }
  }
  bool get inReview {
    final local = localVersion!.split('.').map(int.parse).toList();
    final store = storeVersion!.split('.').map(int.parse).toList();

    for (var i = 0; i < local.length; i++) {
      // The store version field is newer than the local version.
      if (local[i] > store[i]) {
        return true;
      }

      // The local version field is newer than the store version.
      if (store[i] > local[i]) {
        return false;
      }
    }
    // The local and store versions are the same.
    return false;
  }
  bool get hasUpdate {
    final local = localVersion!.split('.').map(int.parse).toList();
    final store = storeVersion!.split('.').map(int.parse).toList();

    for (var i = 0; i < store.length; i++) {
      // The store version field is newer than the local version.
      if (store[i] > local[i]) {
        return true;
      }

      // The local version field is newer than the store version.
      if (local[i] > store[i]) {
        return false;
      }
    }
    // The local and store versions are the same.
    return false;
  }
  bool get hasRequiredUpdate {
    final local = localVersion!.split('.').map(int.parse).toList();
    final store = lastRequiredVersion!.split('.').map(int.parse).toList();

    for (var i = 0; i < store.length; i++) {
      // The store version field is newer than the local version.
      if (store[i] > local[i]) {
        return true;
      }

      // The local version field is newer than the store version.
      if (local[i] > store[i]) {
        return false;
      }
    }
    // The local and store versions are the same.
    return false;
  }
  void showAlertIfNecessary(BuildContext context) async {
    if(hasUpdate){
      final dialogTitleWidget = Text('updateAvailable');
      final dialogTextWidget = Text(
        '${'updateAppMessage'} ${this.localVersion} ${'updateTo'} ${this.storeVersion}',
      );

      final updateButtonTextWidget = Text('update');
      final updateAction = () {
        if(this.appStoreLink!=null)
          launchAppStore();
        Navigator.of(context, rootNavigator: true).pop();

      };

      List<Widget> actions = [
        Platform.isAndroid
            ? TextButton(
          child: updateButtonTextWidget,
          onPressed: updateAction,
        )
            : CupertinoDialogAction(
          child: updateButtonTextWidget,
          onPressed: updateAction,
        ),
      ];

      final dismissButtonTextWidget = Text('cancel');

      actions.add(
        Platform.isAndroid
            ? TextButton(
          child: dismissButtonTextWidget,
          onPressed: (){
            Navigator.of(context).pop();
          },
        )
            : CupertinoDialogAction(
          child: dismissButtonTextWidget,
          onPressed: (){
            Navigator.of(context).pop();
          },
        ),
      );

      await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return WillPopScope(
              child: Platform.isAndroid
                  ? AlertDialog(
                title: dialogTitleWidget,
                content: dialogTextWidget,
                actions: actions,
              )
                  : CupertinoAlertDialog(
                title: dialogTitleWidget,
                content: dialogTextWidget,
                actions: actions,
              ),
              onWillPop: () => Future.value(true));
        },
      );
    }
  }
}
