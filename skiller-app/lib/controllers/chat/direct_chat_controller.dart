import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:skiller/models/direct_message.dart';

import '../../server/queries.dart';
import '../../server/server_provider.dart';

class DirectChatController extends GetxController {
  bool isMessagesLoaded = false;

  List<DirectMessage> directMessages = [];

  Future<void> getDirectMessages(
      {required BuildContext context, required String chatWithUserId}) async {
    final client =
        Provider.of<ServerProvider>(context, listen: false).client.value;
    final queryOptions = QueryOptions(
        document: gql(Queries.getDirectMessagesQuery),
        variables: <String, dynamic>{'chatWithUserId': chatWithUserId});
    final QueryResult result = await client.query(queryOptions);

    if (result.hasException) {
      Get.showSnackbar(const GetSnackBar(
          title: 'Error occurred',
          message: 'Something went wrong',
          duration: Duration(seconds: 4)));
    } else {
      debugPrint(
          'Response from Graphql chat list in My connections : ${result.data}');
      directMessages = List<DirectMessage>.from(result
          .data!['getDirectMessages']
          .map((skillMap) => DirectMessage.fromMap(skillMap)));
      isMessagesLoaded = true;
      update();
    }
  }
}
