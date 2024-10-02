import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:mosque_management_system/constants/app_colors.dart';
import 'package:mosque_management_system/data/models/mosque.dart';
import 'package:mosque_management_system/data/models/region.dart';
import 'package:mosque_management_system/data/repositories/custom_odoo_client.dart';
import 'package:mosque_management_system/data/services/user_service.dart';
import 'package:mosque_management_system/providers/user_provider.dart';
import 'package:mosque_management_system/utils/config.dart';
import 'package:mosque_management_system/widgets/ProgressBar.dart';
import 'package:mosque_management_system/widgets/app_form_field.dart';
import 'package:mosque_management_system/widgets/app_title.dart';
import 'package:mosque_management_system/widgets/service_button.dart';
import 'package:provider/provider.dart';
import 'dart:io' as io;

import '../data/models/meter.dart';

class MeterFrom extends StatefulWidget {
  final CustomOdooClient client;
  final Meter? item;
  final String? labelName;
  final String title;
  final Function? onSave;
  final Mosque? mosque;
  final dynamic headersMap;
  final bool isAttachment;
  final bool isShared;
  MeterFrom({required this.client,this.title='',this.onSave,this.item,this.labelName,this.mosque,this.headersMap,this.isAttachment=false,this.isShared=false});
  @override
  _MeterFromState createState() => _MeterFromState();
}

class _MeterFromState extends State<MeterFrom> {
  RegionData regionData= RegionData();
  List<Region> filteredUsers= [];
  UserService? _userService;


  List<String> filteredItems = [];
  late Meter _meter;
  late Mosque _mosque;
  @override
  void initState() {
    super.initState();
    _meter=this.widget.item??Meter(id: 0);
    _mosque =this.widget.mosque??Mosque(id: 0);
  }

  final _formMeterKey = GlobalKey<FormState>();
  late UserProvider userProvider;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    userProvider = Provider.of<UserProvider>(context);
  }
  @override
  Widget build(BuildContext context) {

   

   
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8), // Adjust top radius here
            topRight: Radius.circular(8),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [


            _meter.id>0? ModalTitle(this.widget.title,Icons.edit):ModalTitle(this.widget.title,Icons.add),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Form(
                key: _formMeterKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CustomFormField(title: this.widget.labelName,value: _meter.name,isRequired: true,onChanged:(val) => _meter.name = val,type: FieldType.textField,),

                    this.widget.isShared? CustomFormField(title: "shared".tr(),value: _meter.mosqueShared,isRequired: true,onChanged:(val) {
                      _meter.mosqueShared = val;
                      setState(() {

                      });
                    } ,type: FieldType.boolean,):Container(),

                    // Text(_meter.attachmentId.toString()),
                    this.widget.isAttachment ?CustomFormField(title: "attachment".tr(),
                        value: (_meter.attachmentId==null || _meter.attachmentId=='')?'':'${userProvider.baseUrl}/web/image?model=meter.meter&id=${_meter.id}&field=attachment_id&unique=1${_meter.uniqueId}',
                        onChanged:(val) {
                          _meter
                              .attachmentId =
                              val;
                          setState(() {
                          });
                        },type: FieldType.image
                        ,headersMap: this.widget.headersMap,isRequired: true,):Container(),




                    SizedBox(height: 10,),
                    Row(
                      children: [
                        Expanded(
                          child: _meter.id! > 0?PrimaryButton(text: "update".tr(),onTab:(){


                            if (_formMeterKey.currentState!.validate()) {
                              _formMeterKey.currentState!.save();
                              this.widget.onSave!(_meter);
                            };
                          }):PrimaryButton(text: "create".tr(),onTab:(){


                            if (_formMeterKey.currentState!.validate()) {
                              _formMeterKey.currentState!.save();
                             
                              this.widget.onSave!(_meter);
                            };
                          }),
                        ),
                        Expanded(
                          child: SecondaryButton(text: "cancel".tr(),onTab:(){
                            Navigator.pop(context);
                          }),
                        ),
                      ],
                    ),
                    SizedBox(height: 5,),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}