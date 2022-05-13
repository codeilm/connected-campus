import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';

import '../../server/mutations.dart';
import '../../server/server_provider.dart';

class LoginController extends GetxController {
  Future<void> updateProfile({required BuildContext context}) async {
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken != null) {
      debugPrint('FMC Token length : ${fcmToken.length}');
      final client =
          Provider.of<ServerProvider>(context, listen: false).client.value;
      final mutationOptions = MutationOptions(
          document: gql(Mutations.updateProfileMutation),
          variables: <String, dynamic>{'fcmToken': fcmToken});
      final QueryResult result = await client.mutate(mutationOptions);

      if (result.hasException) {
        Get.showSnackbar(const GetSnackBar(
            title: 'Error occurred',
            message: 'Something went wrong',
            duration: Duration(seconds: 4)));
      } else {
        debugPrint('Response from Graphql : ${result.data}');
        // Get.showSnackbar(const GetSnackBar(
        //     title : 'Done',message: 'Request sent successfully', duration: Duration(seconds: 4)));
      }
    }
  }
}
