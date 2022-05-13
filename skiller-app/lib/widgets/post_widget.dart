import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:skiller/utility/app_extensions.dart';
import 'package:skiller/utility/extensions/enums_extensions.dart';
import '../config/constants.dart';
import '../config/enums.dart';
import '../models/post.dart';
import '../screens/post/post_detail_screen.dart';
import '../server/mutations.dart';
import 'common/loading_spinner.dart';
import 'common/shimmer_container.dart';

class PostWidget extends StatefulWidget {
  final Post post;
  const PostWidget({Key? key, required this.post}) : super(key: key);

  @override
  _PostWidgetState createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  // String userId = Get.find<AuthController>().user.id;
  bool showCommentTextField = false, isLoading = false;
  TextEditingController commentTEC = TextEditingController();
  late Post post;
  @override
  void initState() {
    super.initState();
    post = widget.post;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.to(() => PostDetailScreen(post: post));
      },
      child: Card(
        child: Container(
          padding: const EdgeInsets.only(bottom: Constants.minPadding),
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(5)),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.1, 0.3, 0.7],
                    colors: [
                      Colors.blue.shade200.withOpacity(0.4),
                      Colors.blue.shade100.withOpacity(0.3),
                      Colors.blue.shade50.withOpacity(0.2),
                    ],
                  ),
                ),
                child: ListTile(
                  isThreeLine: true,
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(post.userPhotoUrl),
                  ),
                subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.userTitle),
                      Text(
                          '\u{1F310} ${post.dateTime.timeAgo()} \u{2022} ${post.postType.toStr}')
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: CircleAvatar(
                            backgroundColor: Colors.grey.shade200,
                            radius: 14,
                            child: const Icon(Icons.star, size: 14)),
                        onPressed: () {
                          // TODO : Implement marking post as Starred
                        },
                      ),
                      CircleAvatar(
                        backgroundColor: Colors.grey.shade200,
                        radius: 14,
                        child: Center(
                          child: GestureDetector(
                            child: const Icon(FontAwesomeIcons.ellipsisV,
                                size: 14),
                            onTap: () {
                              // TODO : Implement that can be taken on a Post
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Constants.minPadding),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Text(
                    post.postTitle,
                    textAlign: TextAlign.justify,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: CachedNetworkImage(
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.fitWidth,
                      imageUrl: post.postImageUrl,
                      placeholder: (context, url) => shimmerContainer(),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    )),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  post.postDescription,
                  textAlign: TextAlign.justify,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.blue,
                          child: Center(
                            child: Mutation(
                              options: MutationOptions(
                                  document: gql(post.isLiked
                                      ? Mutations.deleteLikeMutation
                                      : Mutations.likePostMutation),
                                  onCompleted: (response) {
                                    debugPrint('Like completed');
                                    debugPrint('Response : $response');
                                  }),
                              builder: (MultiSourceResult<dynamic> Function(
                                          Map<String, dynamic>,
                                          {Object? optimisticResult})
                                      runMutation,
                                  QueryResult<dynamic>? result) {
                                return SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.9,
                                  height: 50,
                                  child: IconButton(
                                      icon: Icon(
                                          post.isLiked
                                              ? Icons.thumb_up
                                              : Icons.thumb_up_off_alt_outlined,
                                          size: 14,
                                          color: Colors.white),
                                      onPressed: () {
                                        setState(() {
                                          post.isLiked = !post.isLiked;
                                          if (post.isLiked) {
                                            post.totalLikes++;
                                          } else {
                                            post.totalLikes--;
                                          }
                                        });
                                        runMutation({
                                          'postId': post.postId,
                                          // 'userId': userId
                                        });
                                      }),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.pink,
                          child: IconButton(
                            icon: const Icon(Icons.message,
                                size: 14, color: Colors.white),
                            onPressed: () {
                              setState(() {
                                showCommentTextField = !showCommentTextField;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    Text((post.totalLikes != 0
                            ? '${post.totalLikes} Likes'
                            : '') +
                        ((post.totalLikes != 0 && post.totalComments != 0)
                            ? ' \u{2022} '
                            : '') +
                        (post.totalComments != 0
                            ? '${post.totalComments} Comments'
                            : ''))
                  ],
                ),
              ),
              if (showCommentTextField)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    readOnly: isLoading,
                    style: const TextStyle(fontSize: 14),
                    controller: commentTEC,
                    decoration: InputDecoration(
                      hintText: 'Type your comment ...',
                      hintStyle: TextStyle(fontSize: 14),
                      suffixIcon: Mutation(
                        options: MutationOptions(
                            document: gql(Mutations.addCommentMutation),
                            onCompleted: (response) {
                              debugPrint('Login completed');
                              debugPrint('Response : $response');
                              setState(() {
                                isLoading = false;
                                showCommentTextField = false;
                              });
                            }),
                        builder: (MultiSourceResult<dynamic> Function(
                                    Map<String, dynamic>,
                                    {Object? optimisticResult})
                                runMutation,
                            QueryResult<dynamic>? result) {
                          return IconButton(
                            icon: isLoading
                                ? const LoadingSpinner()
                                : const Icon(Icons.send),
                            onPressed: () {
                              FocusManager.instance.primaryFocus?.unfocus();
                              setState(() {
                                post.totalComments++;
                                isLoading = true;
                              });
                            },
                          );
                        },
                      ),
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
