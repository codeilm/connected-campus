import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skiller/config/constants.dart';
import 'package:skiller/controllers/home/home_controller.dart';
import 'package:skiller/models/project.dart';
import 'package:skiller/widgets/posts_widget.dart';
import 'package:skiller/widgets/projects_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  HomeController homeController = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Constants.minPadding),
      child: ListView(
        physics: const BouncingScrollPhysics(),
        children: [ProjectsWidget(),const PostsWidget()],
      ),
    );
  }
}
