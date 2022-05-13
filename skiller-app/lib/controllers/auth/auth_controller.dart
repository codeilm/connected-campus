import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:skiller/main.dart';
import 'package:skiller/server/server_provider.dart';

import '../../models/user.dart';

class AuthController extends GetxController {
  late User user;

  void initializeUser(
      {required context, Map<String, dynamic>? json, bool fromLocal = false}) {
        debugPrint('User json in init : $json');
    /// [fromLocal] is used to decide whether user has to be initialized from Local db or not
    if (fromLocal) {
      user = User.fromJson(
          Map<String, dynamic>.from(userDataBox.get(UserData.userInfo)));
    } else {
      userDataBox.put(UserData.isLoggedIn, true);
      Provider.of<ServerProvider>(context, listen: false)
          .updateAuthToken(newToken: json!['token']);
      debugPrint('remote user json : ${json['user']}');
      userDataBox.put(UserData.userInfo, json['user']);
      user = User.fromJson(json['user']);
      debugPrint('remote user : ${user.toJson()}');
      
    }
  }
}

abstract class UserData {
  const UserData._();
  static const String userInfo = 'userInfo';
  static const String isLoggedIn = 'isLoggedIn';
  static const String authToken = 'authToken';
}
