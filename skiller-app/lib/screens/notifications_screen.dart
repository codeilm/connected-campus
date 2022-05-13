import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:skiller/models/notification.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
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
        title:
            const Text('Notifications', style: TextStyle(color: Colors.black)),
      ),
      body: ListView.separated(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            AppNotification notification = notifications[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(notification.profilePhoto),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(notification.userName),
                  Text(
                      '${DateTime.now().difference(notification.dateTime).inHours}h ago',
                      style: const TextStyle(color: Colors.grey, fontSize: 14))
                ],
              ),
              subtitle:
                  Text(notification.message, overflow: TextOverflow.ellipsis),
            );
          },
          separatorBuilder: (context, index) {
            return const Divider();
          }),
    );
  }
}
