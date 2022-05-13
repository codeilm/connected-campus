import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';

import '../../models/direct_chat.dart';
import '../../server/queries.dart';
import '../../server/server_provider.dart';

class ChatListController extends GetxController {
  bool isDirectChatListLoaded = false;

  List<DirectChat> directChats = [
    // DirectChat(
    //   userId: '879066b8-e7dc-40bd-9353-27d6d086d601',
    //   userName: 'Codeilm-Israr',
    //   profilePhoto: 'https://picsum.photos/200',
    //   lastMessage: 'We are done with that task',
    //   lastSeen: DateTime.parse('2021-10-22 16:52:02.053'),
    // ),
    // DirectChat(
    //   userId: '91d83c6f-aaf5-403f-a304-51c9c3ff9035',
    //   userName: 'Google-Dev-Arman',
    //   profilePhoto: 'https://picsum.photos/200',
    //   lastMessage: 'We are done with that task',
    //   lastSeen: DateTime.parse('2021-10-22 16:52:02.053'),
    // )
  ];

  Future<void> getChatUserList({required BuildContext context}) async {
    final client =
        Provider.of<ServerProvider>(context, listen: false).client.value;
    final queryOptions = QueryOptions(
        document: gql(Queries.getDirectChatsListQuery),
        variables: const <String, dynamic>{});
    final QueryResult result = await client.query(queryOptions);

    if (result.hasException) {
      Get.showSnackbar(const GetSnackBar(
          title: 'Error occurred',
          message: 'Something went wrong',
          duration: Duration(seconds: 4)));
    } else {
      debugPrint(
          'Response from Graphql chat list in My connections : ${result.data}');
      directChats = List<DirectChat>.from(result.data!['getDirectChatsList']
          .map((skillMap) => DirectChat.fromMap(skillMap)));
      isDirectChatListLoaded = true;
      update();
    }
  }
}
