import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:skiller/config/constants.dart';
import 'package:skiller/controllers/home/home_controller.dart';
import 'package:skiller/models/project.dart';
import 'package:skiller/widgets/posts_widget.dart';

import '../models/post.dart';
import '../server/queries.dart';
import 'common/shimmer_container.dart';

class ProjectsWidget extends StatelessWidget {
  final HomeController homeController = Get.find<HomeController>();

  ProjectsWidget({Key? key}) : super(key: key);

  _buildProject(BuildContext context, Post project) {
    return Container(
      margin: const EdgeInsets.only(right: 10.0),
      width: 250.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(width: 1.0, color: Colors.grey.shade200),
        color: Colors.white,
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(Constants.minPadding * 2)),
                  child: Stack(
                    children: [
                      CachedNetworkImage(
                        width: double.infinity,
                        imageUrl: project.postImageUrl,
                        fit: BoxFit.fitWidth,
                      ),
                  
                    ],
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: Constants.minPadding),
                child: Text(
                  project.postTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w400),
                ),
              )
            ],
          ),
          Positioned(
         
            child: Container(
              color: Colors.transparent,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(project.userPhotoUrl),
                ),
                title: Text(project.unofficialUsername,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: Constants.minPadding,
                          vertical: Constants.minPadding / 2),
                      decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius:
                              BorderRadius.circular(Constants.minPadding * 2)),
                      child: Row(
                        children: [
                          const Icon(Icons.thumb_up,
                              size: 14, color: Colors.white),
                          const SizedBox(width: Constants.minPadding),
                          Text(project.totalLikes.toString(),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold))
                        ],
                      ),
                    ),
                    const SizedBox(width: Constants.minPadding),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: Constants.minPadding,
                          vertical: Constants.minPadding / 2),
                      decoration: BoxDecoration(
                          color: Colors.pink,
                          borderRadius:
                              BorderRadius.circular(Constants.minPadding * 2)),
                      child: Row(
                        children: [
                          const Icon(Icons.message,
                              size: 14, color: Colors.white),
                          const SizedBox(width: Constants.minPadding),
                          Text(project.totalComments.toString(),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold))
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
              vertical: Constants.minPadding,
              horizontal: Constants.minPadding * 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Projects',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'see all',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 18.0,
                  // fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
            height: 150.0,
            child: Query(
                options: QueryOptions(
                    document: gql(Queries.getPostsQuery),
                    variables: {'postTypeId': 1}),
                builder: (
                  QueryResult result, {
                  Refetch? refetch,
                  FetchMore? fetchMore,
                }) {
                  if (result.hasException) {
                    return Center(
                        child:
                            Text('Error occurred\n\n${result.hasException}'));
                  } else if (result.isLoading) {
                    return shimmerContainer();
                  } else {
                    debugPrint('Data : ${result.data}');
                    homeController.projects = List.from(result.data?['getPosts']
                        .map((jsonPost) => Post.fromJson(jsonPost)));
                    debugPrint('Above GetBuilder');
                    return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: homeController.projects.length,
                        itemBuilder: (context, index) {
                          return _buildProject(
                            context,
                            homeController.projects[index],
                          );
                        });
                  }
                })

            // ListView.builder(
            //   physics: const BouncingScrollPhysics(),
            //   padding: const EdgeInsets.only(left: Constants.minPadding),
            //   itemCount: projects.length,
            //   scrollDirection: Axis.horizontal,
            //   itemBuilder: (context, index) {
            //     Project project = projects[index];
            //     return _buildProject(context, project);
            //   },
            // ),
            ),
      ],
    );
  }
}
