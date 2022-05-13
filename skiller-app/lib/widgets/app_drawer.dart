import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:skiller/config/constants.dart';
import 'package:skiller/main.dart';
import 'package:skiller/widgets/custom_listtile.dart';
import '../controllers/auth/auth_controller.dart';
import '../models/user.dart';
import '../services/routes/route_list.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({
    Key? key,
  }) : super(key: key);

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  bool isLoaded = false;
  TextEditingController nameController = TextEditingController();
  User user = Get.find<AuthController>().user;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Stack(
        children: [
          ListView(children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                colors: [Colors.grey.shade200, Colors.grey.shade100],
              )),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CachedNetworkImage(
                    imageUrl: user.photoUrl,
                    imageBuilder: (context, imageProvider) => Container(
                      width: 100.0,
                      height: 100.0,
                      decoration: BoxDecoration(
                        border: Border.all(),
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: imageProvider, fit: BoxFit.fill),
                      ),
                    ),
                    // placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                  Text(
                    user.unofficialName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 18),
                  )
                ],
              ),
            ),
            CustomListTile(
              title: 'About us',
              iconData: FontAwesomeIcons.users,
              color: Colors.lightBlue,
              onTap: () {
              },
            ),
            const CustomListTile(
              title: 'Logout',
              iconData: Icons.logout,
              color: Colors.red,
              onTap: logout,
            ),
            CustomListTile(
              title: 'Privacy Policy',
              iconData: Icons.security,
              color: Colors.grey,
              onTap: () {
              },
            ),
            CustomListTile(
              title: 'Suggestions or Feedback',
              iconData: Icons.email,
              color: Colors.orange,
              onTap: () async {
               
              },
            ),
          ]),
          const Align(
            alignment: Alignment.bottomCenter,
            child: Text(
              'Version : ${Constants.appVersion}',
              style: TextStyle(color: Colors.grey),
            ),
          )
        ],
      ),
    );
  }
}

void logout() {
  userDataBox.put(UserData.authToken, null);
  userDataBox.put(UserData.isLoggedIn, false);
  Get.offAllNamed(RouteList.loginScreen);
}
