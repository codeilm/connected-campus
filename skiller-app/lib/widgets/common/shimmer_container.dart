import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

Widget shimmerContainer() {
  return Shimmer.fromColors(
      loop: 100,
      baseColor: Colors.black,
      highlightColor: Colors.grey.shade500,
      child: SizedBox(height: 200, width: double.infinity));
}