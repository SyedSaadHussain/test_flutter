import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

Widget ProgressBar({double opacity=0.5}) {

  return Column(
    children: [
      Expanded(
        child: Container(
          color: Colors.grey.withOpacity(opacity), // Set the overlay color and opacity
          child: Center(
            child: LoadingAnimationWidget.hexagonDots(
              color: Colors.black.withOpacity(.5),
              size: 30,
            ),
          ),
        ),
      ),
    ],
  );
}