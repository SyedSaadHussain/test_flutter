import 'package:flutter/material.dart';
import 'package:mosque_management_system/constants/app_colors.dart';
import 'package:mosque_management_system/widgets/service_button.dart';

void showDisclaimerDialog(BuildContext context,{String? text,Function? onApproved}) {
  bool isApproved = false; // Initial state of the switch

  showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
          builder: (context, StateSetter setState) {
            return AlertDialog(
              title: Text('Terms & Condition'),
              content:  Wrap(
                children: [
                  Text(text??""),
                  SizedBox(height:10 ,),
                  Row(
                    children: [
                      Text('Accept Terms & condition'),
                      Expanded(child: Container()),
                      Switch(
                        inactiveThumbColor: AppColors.gray.withOpacity(.5), // Color of the thumb when the switch is OFF
                        inactiveTrackColor: AppColors.gray.withOpacity(.3),
                        value:isApproved,
                        onChanged: (value) {
                          setState(() {
                            isApproved=value;
                          });
                        },

                      ),
                    ],
                  )
                ],
              ),
              actions: <Widget>[
                Row(
                  children: [
                    Expanded(child: PrimaryButton(text: 'Approve',onTab:isApproved?(){
                      Navigator.of(context).pop(true);
                    }:null)),
                    Expanded(child: SecondaryButton(text: 'Reject',onTab: (){
                      Navigator.of(context).pop(false);
                    })),

                  ],
                ),

              ],
            );
          }
      );
    },
  ).then((res) {
   
    if (res == true) {
      if(onApproved!=null)
        onApproved();
    }
  });
}