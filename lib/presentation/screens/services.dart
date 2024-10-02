import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:mosque_management_system/constants/app_colors.dart';
import 'package:mosque_management_system/constants/input_decoration_themes.dart';
import 'package:mosque_management_system/data/models/User.dart';
import 'package:mosque_management_system/data/models/base_state.dart';
import 'package:mosque_management_system/data/models/menuRights.dart';
import 'package:mosque_management_system/data/models/service_menu.dart';
import 'package:mosque_management_system/data/repositories/custom_odoo_client.dart';
import 'package:mosque_management_system/data/repositories/common_repository.dart';
import 'package:mosque_management_system/data/services/user_service.dart';
import 'package:mosque_management_system/presentation/screens/all_mosques.dart';
import 'package:mosque_management_system/presentation/screens/create_masjid.dart';
import 'package:mosque_management_system/presentation/screens/create_visit.dart';
import 'package:mosque_management_system/presentation/screens/today_visits.dart';
import 'package:mosque_management_system/providers/user_provider.dart';
import 'package:mosque_management_system/utils/shared_preference.dart';
import 'package:mosque_management_system/widgets/bottom_navigation.dart';
import 'package:mosque_management_system/widgets/service_button.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'package:provider/provider.dart';

class Services extends StatefulWidget {
  final CustomOdooClient client;
  Services({required this.client});
  @override
  State<Services> createState() => _ServicesState();
}

class _ServicesState extends BaseState<Services> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<ServiceMenu> menu=[];
  List<ServiceMenu> filteredMenu=[];

  Map<String, String> headersMap = {};
  @override
  void initState(){
    super.initState();
    _userService = UserService(this.widget.client!);

    Future.delayed(Duration.zero, () {
      getMenuRights();
    });
  }

  MenuRights? menuRights;
  UserService? _userService;
  void getMenuRights(){
    _userService!.getMenuRightsAPI().then((value){
      menuRights=value;
      loadLeaveMenu();
      userProvider.setMenu(value);
     
      setState(() {

      });
    }).catchError((e){

    });
  }

  loadLeaveMenu(){
    if(menuRights!.createMosque??false)
     menu.add(ServiceMenu(name: 'create_new_mosque'.tr(), menuUrl: 'NEW_MOSQUE',icon: Icons.add,color: AppColors.primary));
    if(menuRights!.mosqueList!.isRights)
      menu.add(ServiceMenu(name: 'mosques'.tr(), menuUrl: 'MOSQUES',icon: Icons.mosque,color: AppColors.primary,filter:menuRights!.mosqueList!.filter ));
    //menu.add(ServiceMenu(name: 'Visit', menuUrl: 'NEW_VISIT',icon: Icons.person_pin_circle_outlined,color: AppColors.primary));
    if(menuRights!.searchVisit!.isRights)
      menu.add(ServiceMenu(name: 'search_visits'.tr(), menuUrl: 'TODAY_VISIT',icon: Icons.edit_calendar_sharp,color: AppColors.primary,filter:menuRights!.mosqueList!.filter));
    if(menuRights!.createVisit!)
      menu.add(ServiceMenu(name: 'create_new_visit'.tr(), menuUrl: 'CREATE_VISIT',icon: Icons.add_location_alt,color: AppColors.primary));
    filteredMenu.addAll(menu);

  }
  void filterList(String searchText) {
    setState(() {
      filteredMenu = menu
          .where((item) =>
          item.name.toLowerCase().contains(searchText.toLowerCase()))
          .toList();
    });
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    userProvider = Provider.of<UserProvider>(context);
    _userService!.updateUserProfile(userProvider.userProfile);
  }
  late UserProvider userProvider;
  @override
  Widget build(BuildContext context) {
    // userProvider = Provider.of<UserProvider>(context);
    //loadLeaveMenu(userProvider.menuRights);
    return SafeArea(

      child: Scaffold(
        backgroundColor: AppColors.primary,
          body: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15,vertical: 5),
                //height: 170,
                child:
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Icon(Icons.arrow_back,color: Theme.of(context).colorScheme.onPrimary.withOpacity(.5),size: 25 , ),
                          ),
                        ),
                        Text('services'.tr(),style: TextStyle(fontSize: 22,color: Theme.of(context).colorScheme.onPrimary.withOpacity(.8)),),

                      ],
                    ),
                    SizedBox(height: 5,),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 0,vertical: 0),
                      child: TextField(
                        onChanged: filterList,
                        style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                        decoration: MyInputDecorationThemes.firstInputDecoration(context,label: "search".tr(),icon: Icons.search),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 5),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10.0),
                      topRight: Radius.circular(10.0),
                    ),
                    color: Colors.white,
                  ),
                  width: double.infinity,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        SizedBox(height: 20,),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          child: GridView.count(
                            crossAxisCount: 3,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            children: List.generate(
                              filteredMenu.length,
                                  (index) =>
                                      ServiceButton(text: filteredMenu[index].name,icon: filteredMenu[index].icon,color: filteredMenu[index].color,
                                      onTab: (){
                                        switch (filteredMenu[index].menuUrl) {
                                          case 'NEW_MOSQUE':
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => new CreateMosque(client: this.widget.client,),
                                                //HalqaId: 1
                                              ),
                                            );
                                            break;
                                          case 'CREATE_VISIT':
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => new CreateVisit(client: this.widget.client,),
                                                //HalqaId: 1
                                              ),
                                            );
                                            break;
                                          case 'TODAY_VISIT':
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => new TodayVisits(client: this.widget.client,filter: this.menuRights!.searchVisit!.filter),
                                                //HalqaId: 1
                                              ),
                                            );
                                            break;
                                          case 'MOSQUES':
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => new AllMosques(client: this.widget.client,filter: this.menuRights!.mosqueList!.filter),
                                              //HalqaId: 1
                                            ),
                                          );
                                            break;
                                          default:
                                            print('');
                                        }

                                      }),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
           bottomNavigationBar:this.widget.client==null?null:BottomNavigation(client: this.widget.client!,selectedIndex: 1),
      ),
    );
  }
}
