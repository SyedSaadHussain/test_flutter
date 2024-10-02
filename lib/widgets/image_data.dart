import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mosque_management_system/utils/config.dart';
import 'package:mosque_management_system/widgets/FullImageViewer.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ImageData extends StatefulWidget {
  final int id;
  final String? uniqueId;
  final String baseUrl;
  final dynamic headersMap;
  final String modelName;
  final String fieldId;
  final double width;
  final double height;
  final String? title;
  ImageData({required this.id,required this.modelName,required this.baseUrl,this.uniqueId,this.headersMap,this.height=60,this.width=60,this.title,required this.fieldId});
  @override
  _ImageDataState createState() => _ImageDataState();
}

class  _ImageDataState extends State<ImageData> {

  @override
  void initState() {

  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  GestureDetector(
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FullScreenImagePage(
              title: this.widget.title,
              imageUrl: '${this.widget.baseUrl}/web/image?model=${this.widget.modelName}&id=${this.widget.id}&field=${this.widget.fieldId}&unique=1${this.widget.uniqueId}',
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),

        height: this.widget.height,
        width: this.widget.width,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network('${this.widget.baseUrl}/web/image?model=${this.widget.modelName}&id=${this.widget.id}&field=${this.widget.fieldId}&unique=1${this.widget.uniqueId}',headers: this.widget.headersMap,fit: BoxFit.fitHeight,
            errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
              // This function will be called when the image fails to load
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.person,color: Colors.grey.shade300,size: 30,),
              ); // You can replace this with any widget you want to display
            },
          ),
        ),
        //backgroundImage: NetworkImage('${AppConfig.baseURL}/web/image?model=res.partner&field=image_128&id=${employees[index]!.id}&unique=1202212040830551',headers: headersMap)),
      ),
    );
  }



}