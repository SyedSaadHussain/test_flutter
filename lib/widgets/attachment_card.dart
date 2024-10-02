import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mosque_management_system/constants/app_colors.dart';
import 'package:mosque_management_system/data/models/ir_attachment.dart';
import 'package:mosque_management_system/utils/config.dart';
import 'package:mosque_management_system/widgets/wave_loader.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class AttachmentCard extends StatefulWidget {
  final Attachment attachment;
  final Function? onDelete;
  final String baseUrl;
  final dynamic headersMap;
  final bool isALlowDelete;
  AttachmentCard({required this.attachment,required this.headersMap,this.onDelete,this.isALlowDelete=true,required this.baseUrl});
  @override
  _AttachmentCardState createState() => _AttachmentCardState();
}


class  _AttachmentCardState extends State<AttachmentCard> {

  @override
  void initState() {

  }

  @override
  Widget build(BuildContext context) {
    return  Container(
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(.05),
        borderRadius: BorderRadius.circular(5.0), // Adjust the radius as needed
      ),
      width: (MediaQuery.of(context).size.width / 2)-20,
      alignment: Alignment.center,
      child: Stack(
        children: [

          ListTile(



            onTap: () async{
              var urlToOpen="${this.widget.baseUrl}/web/content/${this.widget.attachment.id}?download=true";

              setState(() {
                this.widget.attachment.isLoading=true;
              });
              try {

                setState(() {
                  this.widget.attachment.isLoading=true;
                });
                final response = await http.get(Uri.parse(urlToOpen), headers: this.widget.headersMap);
            
                if (response.statusCode == 200) {
                  setState(() {
                    this.widget.attachment.isLoading=false;
                  });
                  final Directory appDocDir = await getApplicationDocumentsDirectory();
                  final String appDocPath = appDocDir.path;
                  final Uint8List bytes = response.bodyBytes;


                  // Determine file extension based on content type
                  final String contentType = response.headers['content-type'].toString();
                  final String fileExtension = contentType.split('/').last;

                  // Generate a unique file name with the determined extension
                  final String fileName = 'sample.${fileExtension.toLowerCase()}';
                  final String filePath = '$appDocPath/$fileName';
                  File file = File(filePath);
                  await file.writeAsBytes(  bytes);
                  final result = await OpenFilex.open(filePath).then((value) {
                 
                  });



                } else {
                  setState(() {
                    this.widget.attachment.isLoading=false;
                  });
                  // Handle errors
              
                }
              } catch (e) {
                // Handle exceptions
                setState(() {
                  this.widget.attachment.isLoading=false;
                });
                
              }
            },
            leading : this.widget.attachment.icon,
            title: Text(
              this.widget.attachment.name??"",
              style: TextStyle(color: AppColors.primary,fontSize: 14),overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(this.widget.attachment.extension,style: TextStyle(color: Colors.grey,fontSize: 12),),
          ),
          this.widget.attachment.isLoading?Container(
            color: Colors.grey.withOpacity(.5),
            width: double.infinity,
            height: 70,
            child: Center(child: WaveLoader(color: Colors.white,size: 25)),
          ):Container(),
          this.widget.onDelete==null?Container():Positioned(
              bottom: 0.0, // Distance from the bottom
              right: 0.0, // Distance from the right
              child: Container(
                color: Colors.grey.withOpacity(.5),
                height: 30,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: (){
                        if(this.widget.onDelete!=null)
                        {
                          this.widget.onDelete!();
                        }

                        // this.widget.repository.createLeave(leave);
                      },

                      child: Container(
                          height: double.infinity,
                          padding: EdgeInsets.all(5),
                          color: Colors.black.withOpacity(.1),
                          child: Icon(Icons.delete_outline,color: Colors.white.withOpacity(.8),size: 20,)),
                    ),
                  ],
                ),
              )),


        ],
      ),
    );
  }



}