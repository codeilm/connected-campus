import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:skiller/config/constants.dart';
import 'package:skiller/models/project.dart';

import '../models/post.dart';
import '../server/queries.dart';
import 'common/shimmer_container.dart';
import 'posts_widget.dart';

class ExploreWidget extends StatelessWidget {
  final String title;
  final int postTypeId;
  List<Post> posts;
  ExploreWidget(
      {Key? key,
      required this.title,
      required this.postTypeId,
      required this.posts})
      : super(key: key);

  _buildEploreWidget(BuildContext context, Post post) {
    return Container(
      margin: const EdgeInsets.only(right: Constants.minPadding),
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
                        imageUrl: post.postImageUrl,
                        fit: BoxFit.fitWidth,
                      ),
                     
                    ],
                  ),
                ),
              ),
              ListTile(
               
                title: Text(post.unofficialUsername,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
               
              )
            ],
          ),
          Positioned(
            top: 100,
            left: 0,
            width: 250,
            child: Container(
              color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.all(Constants.minPadding),
                child: Text(post.postTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700)),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Text(
              'see all',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 18.0,
                // fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
