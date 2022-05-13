import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'package:skiller/controllers/home/home_controller.dart';
import 'package:skiller/models/post.dart';
import 'package:skiller/server/queries.dart';

import 'common/shimmer_container.dart';
import 'post_widget.dart';

class PostsWidget extends StatefulWidget {
  const PostsWidget({Key? key}) : super(key: key);

  @override
  _PostsWidgetState createState() => _PostsWidgetState();
}

class _PostsWidgetState extends State<PostsWidget> {
  HomeController homeController = Get.find<HomeController>();
  @override
  Widget build(BuildContext context) {
    return Query(
        options: QueryOptions(document: gql(Queries.getPostsQuery)),
        builder: (
          QueryResult result, {
          Refetch? refetch,
          FetchMore? fetchMore,
        }) {
          print(result);
          if (result.hasException) {
            return Center(
                child: Text('Error occurred\n\n${result.hasException}'));
          } else if (result.isLoading) {
            return shimmerContainer();
          } else {
          
            return ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: homeController.popularPosts.length,
                itemBuilder: (context, index) {
                  return PostWidget(
                    post: homeController.popularPosts[index],
                  );
                });
          }
        });
  
  }
}


