import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:skiller/controllers/chat/direct_chat_controller.dart';
import 'package:skiller/models/direct_chat.dart';
import 'package:skiller/screens/profile_screen.dart';
import 'package:skiller/server/server_provider.dart';
import 'package:skiller/utility/app_extensions.dart';
import 'package:skiller/models/direct_message.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skiller/widgets/common/shimmer_container.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../controllers/auth/auth_controller.dart';

class DirectChatScreen extends StatefulWidget {
  final DirectChat chatWith;
  const DirectChatScreen({Key? key, required this.chatWith}) : super(key: key);

  @override
  _DirectChatScreenState createState() => _DirectChatScreenState();
}

class _DirectChatScreenState extends State<DirectChatScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController messageTEC = TextEditingController();
  // DirectChat chat = chats[0];
  bool emojiShowing = false;
  File? imageFile;
  String? text;
  final chatChannel = WebSocketChannel.connect(
    Uri.parse(ServerProvider.chatWebsocketUrl),
  );

  String currentUserId = Get.find<AuthController>().user.userId;

  // List<DirectMessage> directMessages = [
  //   DirectMessage(
  //       messageId: '16f7fe44-325b-4c28-9bfb-13751d36c23d',
  //       senderId: '879066b8-e7dc-40bd-9353-27d6d086d601',
  //       receiverId: '',
  //       content: 'Codeilm Some message',
  //       sentAt: DateTime.now().subtract(const Duration(minutes: 15))),
  //   DirectMessage(
  //       messageId: 'd3a83b35-19b8-42bd-9aa0-ea5946bc1358',
  //       senderId: '91d83c6f-aaf5-403f-a304-51c9c3ff9035',
  //       receiverId: '',
  //       content: 'receiver Some message',
  //       sentAt: DateTime.now().subtract(const Duration(minutes: 2000))),
  // ];

  DirectChatController directChatController = Get.put(DirectChatController());

  FocusNode focusNode = FocusNode();

  void getImage({required ImageSource source}) async {
    final file = await ImagePicker().pickImage(source: source);

    if (file?.path != null) {
      setState(() {
        imageFile = File(file!.path);
      });
    }
  }

  _onEmojiSelected(Emoji emoji) {
    messageTEC
      ..text += emoji.emoji
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: messageTEC.text.length));
  }

  _onBackspacePressed() {
    messageTEC
      ..text = messageTEC.text.characters.skipLast(1).toString()
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: messageTEC.text.length));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    directChatController.getDirectMessages(
        context: context, chatWithUserId: widget.chatWith.userId);
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        setState(() {
          emojiShowing = false;
        });
      }
    });
  }

  _showAttachmentDialog() {
    return showDialog(
      barrierColor: Colors.transparent,
      context: context,
      builder: (context) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: const EdgeInsets.only(top: 20),
            height: 100,
            margin: const EdgeInsets.only(bottom: 70, left: 10, right: 12),
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(10),
            ),
            child: GridView.count(
              childAspectRatio: 1.5,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              children: [
                _attachmentDataItem(
                  context,
                  const Icon(Icons.camera_alt_rounded,
                      size: 25, color: Colors.white),
                  "Camera",
                  Colors.pink[800],
                  1,
                  () {
                    getImage(source: ImageSource.camera);
                  },
                ),
                _attachmentDataItem(
                  context,
                  const Icon(Icons.panorama, size: 25, color: Colors.white),
                  "Gallery",
                  Colors.purple,
                  2,
                  () {
                    getImage(source: ImageSource.gallery);
                  },
                ),
                _attachmentDataItem(
                  context,
                  const Icon(Icons.document_scanner_sharp,
                      size: 30, color: Colors.white),
                  "Document",
                  Colors.indigo[800],
                  3,
                  () {
                    // getImage(source: ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  _attachmentDataItem(BuildContext context, Icon icons, String name, colors,
      int index, void Function()? onTap) {
    return Column(children: [
      GestureDetector(
          onTap: onTap,
          child:
              CircleAvatar(child: icons, backgroundColor: colors, radius: 25)),
      Material(
        color: Colors.grey[400],
        child: Text(name,
            style: const TextStyle(
              fontSize: 14,
            )),
      )
    ]);
  }

  void setCurrentUserIdInChatSocket() {
    debugPrint('setting up the client id : $currentUserId');
    chatChannel.sink.add(jsonEncode({'set_client_id': currentUserId,'client_name' : Get.find<AuthController>().user.unofficialName}));
  }

  void sendMessage() {
    if (messageTEC.text.isNotEmpty) {
      String messageId = const Uuid().v4();
      DirectMessage directMessage = DirectMessage(
          messageId: messageId,
          senderId: currentUserId,
          receiverId: widget.chatWith.userId,
          content: messageTEC.text,
          sentAt: DateTime.now());
      directChatController.directMessages.insert(0, directMessage);
      messageTEC.clear();
      directChatController.update();
      debugPrint('sending message : $currentUserId');
      chatChannel.sink.add(directMessage.toJson());
    }
  }

  @override
  void dispose() {
    chatChannel.sink.close();
    messageTEC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.chevronLeft, color: Colors.black),
          onPressed: () {
            Get.back();
          },
        ),
        actions: [
          IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.more_vert,
                color: Colors.black,
              )),
        ],
        title: GestureDetector(
          onTap: () {
            Get.to(ProfileScreen());
          },
          child: ListTile(
            leading: const CircleAvatar(
              backgroundImage: NetworkImage('https://picsum.photos/200'),
            ),
            title: Text(widget.chatWith.userName),
            // subtitle: Text('${widget.chatWith.lastSeen.timeAgo()} ago'),// TODO : Show last seen
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder(
                stream: chatChannel.stream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final receivedMessage = jsonDecode(snapshot.data as String);
                    if (receivedMessage == 'send_client_id') {
                      setCurrentUserIdInChatSocket();
                    } else if (receivedMessage['sender_id'] != null) {
                      log('Direct message from stream : ${receivedMessage}');
                      // DirectMessage message = DirectMessage.fromMap(
                      //     receivedMessage as Map<String, dynamic>);
                      DirectMessage message = DirectMessage(messageId: receivedMessage['message_id'], senderId: receivedMessage['sender_id'], receiverId: receivedMessage['receiver_id'], content: receivedMessage['content'], sentAt: DateTime.parse(receivedMessage['sent_at']));
                      directChatController.directMessages.insert(0, message);
                      log('New message from socket : ${message.senderId} : ${message.content}');
                    }
                    // print(data);

                  }
                  return GetBuilder<DirectChatController>(builder: (_) {
                    if (directChatController.isMessagesLoaded) {
                      return ListView.builder(
                        reverse: true,
                        itemCount: directChatController.directMessages.length,
                        shrinkWrap: true,
                        padding: const EdgeInsets.only(top: 10, bottom: 10),
                        itemBuilder: (context, index) {
                          return Container(
                            padding: const EdgeInsets.only(
                                left: 14, right: 14, top: 10, bottom: 10),
                            child: Align(
                              alignment: (directChatController
                                          .directMessages[index].senderId ==
                                      widget.chatWith.userId
                                  ? Alignment.topLeft
                                  : Alignment.topRight),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: (directChatController
                                              .directMessages[index].senderId ==
                                          widget.chatWith.userId
                                      ? Colors.grey.shade100
                                      : Colors.green.shade50),
                                ),
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  directChatController
                                      .directMessages[index].content,
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }
                    return shimmerContainer();
                  });
                }),
          ),
          Container(
            padding: const EdgeInsets.only(left: 10, bottom: 10, right: 10),
            width: double.infinity,
            color: Colors.white,
            child: WillPopScope(
              child: Stack(children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            focusNode.unfocus();
                            focusNode.canRequestFocus = false;
                            setState(() {
                              emojiShowing = !emojiShowing;
                            });
                          },
                          child: Container(
                            height: 30,
                            width: 30,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: const Icon(
                              Icons.add_reaction_outlined,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        Expanded(
                          child: TextFormField(
                            onChanged: (value) {
                              text = value;
                            },
                            focusNode: focusNode,
                            controller: messageTEC,
                            decoration: const InputDecoration(
                              hintText: "Type a message....",
                              hintStyle: TextStyle(color: Colors.black54),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        // const SizedBox(
                        //   width: 15,
                        // ),
                        // const Icon(Icons.attach_file),
                        IconButton(
                          icon: const Icon(Icons.attach_file),
                          iconSize: 25.0,
                          color: Colors.grey,
                          onPressed: () {
                            setState(() {});
                            //_showAttachmentDialog();
                            if (!emojiShowing) {
                              _showAttachmentDialog();
                            }
                          },
                        ),
                        FloatingActionButton(
                          mini: true,
                          onPressed: sendMessage,
                          child: const Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 18,
                          ),
                          backgroundColor: Colors.green,
                          elevation: 0,
                        ),
                      ],
                    ),
                    Offstage(
                      offstage: !emojiShowing,
                      child: SizedBox(
                        height: 250,
                        child: EmojiPicker(
                          onEmojiSelected: (Category category, Emoji emoji) {
                            _onEmojiSelected(emoji);
                          },
                          onBackspacePressed: _onBackspacePressed,
                        ),
                      ),
                    ),
                  ],
                ),
              ]),
              onWillPop: () {
                if (emojiShowing) {
                  setState(() {
                    emojiShowing = false;
                  });
                } else {
                  Navigator.pop(context);
                }
                return Future.value(false);
              },
            ),
          ),
        ],
      ),
    );
  }
}
