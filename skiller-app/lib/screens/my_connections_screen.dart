import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skiller/controllers/collab_controller.dart';

import '../config/constants.dart';
import '../models/collab.dart';

class MyConnectionsScreen extends StatefulWidget {
  const MyConnectionsScreen({Key? key}) : super(key: key);

  @override
  State<MyConnectionsScreen> createState() => _MyConnectionsScreenState();
}

class _MyConnectionsScreenState extends State<MyConnectionsScreen> {
  CollabController collabController = Get.find<CollabController>();

  @override
  void initState() {
    super.initState();
    collabController.getMyConnections(context: context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Connections')),
      body: GetBuilder<CollabController>(builder: (_) {
        debugPrint('my connections builder 1');
        if (collabController.isMyConnectionsLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (collabController.myConnections.isEmpty) {
          return Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.share, size: 100, color: Colors.grey),
                  SizedBox(height: 50),
                  Text(
                    'You do not have any connections',
                    style: TextStyle(color: Colors.grey),
                  ),
                ]),
          );
        }
        debugPrint(
            'my connections builder 2, ${collabController.myConnections.length}');
        return ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: collabController.myConnections.length,
          itemBuilder: (context, index) {
            Collab collab = collabController.myConnections[index];
            debugPrint(
                'My connection in view : ${collabController.myConnections.length}');
            return ListTile(
              isThreeLine: true,
              leading: CircleAvatar(
                backgroundImage: NetworkImage(collab.photoUrl),
              ),
              title: Row(
                children: [
                  Text('${collab.name} '),
                  // TODO : Uncomment it after getting the user Type in collab
                  // if (post.userType == UserType.alumni ||
                  //     post.userType == UserType.professor)
                  //   Stack(
                  //     alignment: Alignment.center,
                  //     children: [
                  //       FaIcon(
                  //         FontAwesomeIcons.certificate,
                  //         color: post.userType == UserType.professor
                  //             ? Colors.green
                  //             : Colors.orange,
                  //         size: 14,
                  //       ),
                  //       const FaIcon(
                  //         FontAwesomeIcons.check,
                  //         color: Colors.white,
                  //         size: 8,
                  //       )
                  //     ],
                  //   )
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(collab.title),
                  // TODO : Uncommet it after getting created at
                  // Text('\u{1F310} ${post.dateTime.timeAgo()} ago')
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // if (collab.type == CollabType.received)
                  //   CircleAvatar(
                  //     backgroundColor: Colors.grey.shade200,
                  //     child: IconButton(
                  //       icon: const Icon(Icons.done),
                  //       onPressed: () {
                  //         // collabController.acceptConnectionRequest(context: context, connectionId: c)
                  //       },
                  //     ),
                  //   ),
                  // const SizedBox(width: Constants.minPadding),
                  CircleAvatar(
                    backgroundColor: Colors.grey.shade200,
                    child: GestureDetector(
                      child: const Icon(Icons.close),
                      onTap: () {
                        collabController.terminateConnectedConnection(
                            context: context,
                            connectionId: collab.connectionId);
                      },
                    ),
                  )
                ],
              ),
            );
          },
          separatorBuilder: (context, index) => const Divider(),
        );
      }),
    );
  }
}
