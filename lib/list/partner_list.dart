import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:mosque_management_system/constants/app_colors.dart';
import 'package:mosque_management_system/data/models/employee.dart';
import 'package:mosque_management_system/data/models/region.dart';
import 'package:mosque_management_system/data/models/res_city.dart';
import 'package:mosque_management_system/data/models/res_partner.dart';
import 'package:mosque_management_system/data/models/userProfile.dart';
import 'package:mosque_management_system/data/repositories/custom_odoo_client.dart';
import 'package:mosque_management_system/data/services/user_service.dart';
import 'package:mosque_management_system/widgets/ProgressBar.dart';
import 'package:mosque_management_system/widgets/app_title.dart';
import 'package:mosque_management_system/widgets/service_button.dart';
import 'package:provider/provider.dart';
import 'dart:io' as io;

class PartnerList extends StatefulWidget {
  final CustomOdooClient client;
  final Function onItemTap;
  final Function? onAddEmployee;
  final String? type;
  final String? title;
  PartnerList({required this.client,required this.onItemTap,this.type,this.title,this.onAddEmployee});
  @override
  _PartnerListState createState() => _PartnerListState();
}

class _PartnerListState extends State<PartnerList> {
  ResPartnerData data= ResPartnerData();
  List<Region> filteredUsers= [];
  UserService? _userService;

  TextEditingController _controller = TextEditingController();
  @override
  void initState() {
    _userService = UserService(this.widget.client!);
    super.initState();
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  bool showCreateEmoployee=false;

  void searchRecords(bool isReload){

    if(isReload){
      data.reset();
    }
    data.init();
    
    _userService!.getPartner(10,data.pageIndex,_controller.text).then((value){

      // data.hasMore=true;
      // data.isloading=true;
      showCreateEmoployee=true;

      if(data.pageIndex>1){
        if(value==null || value.isEmpty){
          setState((){
            data.isloading=false;
            data.hasMore=false;
          });
        }else{
          setState((){
            data.list!.addAll(value!.toList());
            data.isloading=false;
          });
        }

      }else{
        setState((){
          data.list=value;
          data.isloading=false;
        });
      }

    }).catchError((e){
    
      setState((){
        data.list=[];
        data.isloading=false;
        data.hasMore=false;
      });
      Flushbar(
        icon: Icon(Icons.warning,color: Colors.white,),
        backgroundColor: AppColors.danger,
        message: e.message,
        duration: Duration(seconds: 3),
      ).show(context);
    });

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8), // Adjust top radius here
          topRight: Radius.circular(8),
        ),
      ),

      child: Container(
        padding: EdgeInsets.symmetric(horizontal:5 ),
        margin: EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ModalTitle(this.widget.title??"",FontAwesomeIcons.users,
            //     leading:
            // showCreateEmoployee?DefaultButton(text: 'Create employee',icon:FontAwesomeIcons.userPlus,onTab: (){
            //     this.widget.onAddEmployee!();
            //   }):Container()
            ),
            TextField(
              controller: _controller,
              onChanged: (val){
                setState(() {

                });
              },

              onSubmitted: (value) {
                searchRecords(true);
              },
              decoration: InputDecoration(
                hintText: 'search'.tr(),
                suffixIcon: Container(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _controller.text.isEmpty
                          ?Container(): IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {

                          _controller.clear();
                          searchRecords(true);
                          FocusScope.of(context).unfocus();
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {
                          searchRecords(true);
                          FocusScope.of(context).unfocus();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            (data.isloading==false && data.list!.length==0)?Center(child: Text('no_record_found'.tr(),style: TextStyle(color: Colors.grey),)):Container(),
            Expanded(
              child: ListView.builder(
                itemCount: data.list!.length+((data.hasMore)?1:0),
                itemBuilder: (BuildContext context, int index) {
                  if(index >= data.list!.length)
                  {
                    data.pageIndex=data.pageIndex+1;
                    searchRecords(false);
                    return Container(
                        height: 100,
                        child: ProgressBar(opacity: 0));
                  }
                  else {
                    return Container(
                      padding: EdgeInsets.symmetric(vertical: 0),

                      decoration: BoxDecoration(
                        color:  index % 2 == 0 ? Colors.grey[100] : Colors.white,
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey.shade100, // Change color as needed
                            width: 1.0, // Change thickness as needed
                          ),
                        ),
                      ),
                      child: ListTile(

                        title: Text(data.list[index].displayName??"",style: TextStyle(fontWeight: FontWeight.w300,color: AppColors.body),),

                        onTap: () {
                         
                          this.widget.onItemTap(data.list[index]);
                        },
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}