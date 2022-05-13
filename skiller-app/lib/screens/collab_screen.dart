import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:skiller/config/constants.dart';
import 'package:skiller/config/enums.dart';
import 'package:skiller/models/collaboration.dart';
import 'package:skiller/utility/app_extensions.dart';
import 'package:skiller/widgets/common/shimmer_container.dart';

import '../models/collab.dart';
import '../services/routes/route_list.dart';
import '../controllers/collab_controller.dart';

class CollabScreen extends StatefulWidget {
  const CollabScreen({Key? key}) : super(key: key);

  @override
  _CollabScreenState createState() => _CollabScreenState();
}

class _CollabScreenState extends State<CollabScreen> {
  CollabController collabController = Get.put(CollabController());

  @override
  void initState() {
    super.initState();
    collabController.getInProgressConnections(context: context);
  }

  // Collaboration post = collaborations[0];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<CollabController>(builder: (collabController) {
        if (collabController.isConnectionInProgressLoading) {
          return shimmerContainer();
        }
        return ListView(
          children: [
            Card(
              child: ListTile(
                onTap: () {
                  Get.toNamed(RouteList.myConnectionsScreen);
                },
                title: const Text(
                  'Manage Connections',
                  style: TextStyle(
                    // color: Colors.blue,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                trailing: const FaIcon(FontAwesomeIcons.chevronRight,
                    color: Colors.black),
              ),
            ),
            Card(
              child: ListTile(
                onTap: () {
                  // TODO : Navigate to Invitations screen
                  debugPrint('gotoo');
                },
                title: const Text(
                  'Invitations',
                  style: TextStyle(
                    // color: Colors.blue,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                trailing: const FaIcon(FontAwesomeIcons.chevronRight,
                    color: Colors.black),
              ),
            ),
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: collabController.collabsInProgress.length,
              itemBuilder: (context, index) {
                Collab collab = collabController.collabsInProgress[index];
                // Collaboration post = collaborations[index];
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
                      if (collab.type == CollabType.received)
                        CircleAvatar(
                          backgroundColor: Colors.grey.shade200,
                          child: IconButton(
                            icon: const Icon(Icons.done),
                            onPressed: () {
                              collabController.acceptConnectionRequest(context: context, connectionId: collab.connectionId);
                            },
                          ),
                        ),
                      const SizedBox(width: Constants.minPadding),
                      CircleAvatar(
                        backgroundColor: Colors.grey.shade200,
                        child: GestureDetector(
                          child: const Icon(Icons.close),
                          onTap: () {
                              collabController.rejectConnectionRequest(context: context, connectionId: collab.connectionId);
                          },
                        ),
                      )
                    ],
                  ),
                );
              },
              separatorBuilder: (context, index) => const Divider(),
            ),
            Card(
              child: ListTile(
                onTap: () {
                  // TODO : Navigate to Communities screen
                  debugPrint('goto');
                },
                title: const Text(
                  'Communities',
                  style: TextStyle(
                    // color: Colors.blue,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                trailing: const FaIcon(FontAwesomeIcons.chevronRight,
                    color: Colors.black),
              ),
            ),
            ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  Collaboration post = collaborations[index];
                  return ListTile(
                    isThreeLine: true,
                    leading: const CircleAvatar(
                      backgroundImage:
                          NetworkImage('https://picsum.photos/200'),
                    ),
                    title: Row(
                      children: [
                        Text('${post.userName} '),
                        if (post.userType == UserType.alumni ||
                            post.userType == UserType.professor)
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              FaIcon(
                                FontAwesomeIcons.certificate,
                                color: post.userType == UserType.professor
                                    ? Colors.green
                                    : Colors.orange,
                                size: 14,
                              ),
                              const FaIcon(
                                FontAwesomeIcons.check,
                                color: Colors.white,
                                size: 8,
                              )
                            ],
                          )
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(post.userDescription),
                        Text('\u{1F310} ${post.dateTime.timeAgo()} ago')
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.grey.shade200,
                          child: IconButton(
                            icon: Icon(Icons.done),
                            onPressed: () {},
                          ),
                        ),
                        const SizedBox(width: Constants.minPadding),
                        CircleAvatar(
                          backgroundColor: Colors.grey.shade200,
                          child: GestureDetector(
                            child: Icon(Icons.close),
                            onTap: () {},
                          ),
                        )
                      ],
                    ),
                  );
                },
                separatorBuilder: (context, index) => const Divider(),
                itemCount: collaborations.length),
          ],
        );
      }),
    );
  }
}
