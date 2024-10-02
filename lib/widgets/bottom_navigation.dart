import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:mosque_management_system/constants/app_colors.dart';
import 'package:mosque_management_system/data/repositories/custom_odoo_client.dart';
import 'package:mosque_management_system/presentation/screens/profile.dart';
import 'package:mosque_management_system/presentation/screens/services.dart';
import 'package:provider/provider.dart';
import 'dart:io' as io;

class BottomNavigation extends StatefulWidget {
  final CustomOdooClient client;
  final int selectedIndex;
  BottomNavigation({required this.client,required this.selectedIndex});
  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {

  @override
  void initState() {

  }
  //int _selectedIndex = 4;
  //UserPreferences
  @override
  Widget build(BuildContext context) {
    //HalqaProvider auth = Provider.of<HalqaProvider>(context);
    return SizedBox(
      // height: 30,
      child: BottomNavigationBar(
        backgroundColor: AppColors.backgroundColor,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.black54.withOpacity(.5),
        iconSize: 21,
        unselectedFontSize: 11,
        selectedFontSize: 11,
        showSelectedLabels: true,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
        showUnselectedLabels: true,
        currentIndex: this.widget.selectedIndex, // this
        type: BottomNavigationBarType.fixed,// will be set when a new tab is tapped
        items: [
          BottomNavigationBarItem(
            icon: new Icon(Icons.home_outlined),
            label: 'home'.tr(),
            activeIcon:  Icon(Icons.home),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.apps_rounded),
            label: 'services'.tr(),
            activeIcon:  Icon(Icons.folder),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'profile'.tr(),
            activeIcon:  Icon(Icons.person),
          ),

        ],
        onTap: (int index) {
       
          switch (index) {

            case 0:
              Navigator.of(context).pushNamedAndRemoveUntil(
                  '/dashboard', (Route<dynamic> route) => false);
              // if(index!=this.widget.selectedIndex) {
              //
              // }
              break;
            case 1:
              if(index!=this.widget.selectedIndex) {
                if(this.widget.selectedIndex!=0)
                  Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                    new Services(client: this.widget.client),
                  ),
                );
              }
              break;
            case 2:
              if(index!=this.widget.selectedIndex) {
                if(this.widget.selectedIndex!=0)
                  Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                    new Profile(client: this.widget.client),
                  ),
                );
              }
          }
        },
      ),
    );
  }
}