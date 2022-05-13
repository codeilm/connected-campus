import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:skiller/config/constants.dart';

class LoadingCube extends StatelessWidget {
  final Color color;
  const LoadingCube({Key? key, this.color = Colors.purple})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: Constants.minPadding),
        child: SpinKitFadingCube(
          color: color,
          size: Constants.minPadding ,
        ));
  }
}