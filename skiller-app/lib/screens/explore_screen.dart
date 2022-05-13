import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skiller/config/constants.dart';
import 'package:skiller/controllers/explore/explore_controller.dart';
import 'package:skiller/widgets/explore_widget.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {

 ExploreController exploreController = Get.put(ExploreController());

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Constants.minPadding),
      child: ListView(
        physics: const BouncingScrollPhysics(),
        children:  [
          ExploreWidget(title: 'Trending Technologies', postTypeId: 1,posts: exploreController.technologies),
          ExploreWidget(title: 'Tips & Tricks', postTypeId: 3,posts: exploreController.tipsAndTricks),
          ExploreWidget(title: 'Internship', postTypeId: 4,posts: exploreController.internships),
          ExploreWidget(title: 'Jobs', postTypeId: 5,posts: exploreController.jobs),
          ExploreWidget(title: 'Trending talks', postTypeId: 6,posts: exploreController.talks),
          ExploreWidget(title: 'Latest News', postTypeId: 7,posts: exploreController.news),
          ExploreWidget(title: 'Latest events', postTypeId: 8,posts: exploreController.events),
          ExploreWidget(title: 'Others', postTypeId: 9,posts: exploreController.others),
        ],
      ),
    );
  }
}
