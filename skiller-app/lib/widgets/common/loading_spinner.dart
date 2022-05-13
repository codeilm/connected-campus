import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:skiller/config/constants.dart';

class LoadingSpinner extends StatelessWidget {
  final Color color;
  const LoadingSpinner({Key? key, this.color = Colors.purple})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SpinKitFadingCircle(
      color: color,
      size: Constants.minPadding ,
    );
  }
}
