import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skiller/controllers/chat/chat_list_controller.dart';
import 'package:skiller/models/direct_chat.dart';
import 'package:skiller/screens/chat/direct_chat_screen.dart';
import 'package:skiller/utility/app_extensions.dart';
import 'package:skiller/widgets/common/shimmer_container.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {

  ChatListController chatListController = Get.put(ChatListController());

  @override
  void initState() {
    super.initState();
    chatListController.getChatUserList(context: context);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatListController>(
      builder: (_) {
        if(chatListController.isDirectChatListLoaded){
        
        return ListView.separated(
            itemBuilder: (context, index) {
              DirectChat chat = chatListController.directChats[index];
              return ListTile(
                onTap: (){
                  Get.to(()=> DirectChatScreen(chatWith: chat));
                },
                leading: const CircleAvatar(
                  backgroundImage: NetworkImage('https://picsum.photos/200'),
                ),
                title: Text(chat.userName),
                subtitle: Text(chat.lastMessage),
                // trailing: Text('${chat.lastSeen.timeAgo()} ago'), // TODO : Sent At
              );
            },
            separatorBuilder: (context, index) => const Divider(),
            itemCount: chatListController.directChats.length);
      }
      return shimmerContainer();
      }
    );
  }
}
