import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:skiller/utility/app_extensions.dart';
import '../../config/constants.dart';
import '../../config/enums.dart';
import 'package:skiller/models/post.dart';
import '../../widgets/common/shimmer_container.dart';
import '../../widgets/posts_widget.dart';

class PostDetailScreen extends StatefulWidget {
  final Post post;

  const PostDetailScreen({Key? key, required this.post}) : super(key: key);

  @override
  _PostDetailScreenState createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late final Post post;

  @override
  void initState() {
    super.initState();
    post = widget.post;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: FaIcon(
            FontAwesomeIcons.chevronLeft,
            color: Colors.grey[600],
          ),
          onPressed: () {
            Get.back();
          },
        ),
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: Constants.minPadding * 3,
                  bottom: Constants.minPadding * 3,
                  right: Constants.minPadding),
              child: CircleAvatar(
                backgroundImage: NetworkImage(post.userPhotoUrl),
              ),
            ),
            Text(
              '${post.unofficialUsername} ',
              style: TextStyle(color: Colors.black),
            ),
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
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: CircleAvatar(
                      backgroundColor: Colors.grey.shade200,
                      radius: 14,
                      child: const Icon(Icons.star, size: 14)),
                  onPressed: () {},
                ),
                CircleAvatar(
                  backgroundColor: Colors.grey.shade200,
                  radius: 14,
                  child: Center(
                    child: GestureDetector(
                      child: const Icon(
                        FontAwesomeIcons.ellipsisV,
                        size: 14,
                      ),
                      onTap: () {},
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: Constants.minPadding * 3,
                  left: Constants.minPadding * 2,
                  right: Constants.minPadding * 2),
              child: Text(
                widget.post.postTitle,
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
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
              padding: const EdgeInsets.all(Constants.minPadding * 2),
              child: Text(post.postDescription),
            ),
            SizedBox(
              height: 75,
              child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 150,
                      padding: const EdgeInsets.only(right: 10.0, left: 10.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: CachedNetworkImage(
                          height: 75,
                          width: 150,
                          fit: BoxFit.fitWidth,
                          imageUrl: post.postImageUrl,
                        ),
                      ),
                    );
                  }),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.blue,
                          child: IconButton(
                              icon: const Icon(Icons.thumb_up,
                                  size: 14, color: Colors.white),
                              onPressed: () {
                                /// TODO : Increment likes
                              })),
                      const SizedBox(width: 10),
                      CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.pink,
                          child: IconButton(
                              icon: const Icon(Icons.message,
                                  size: 14, color: Colors.white),
                              onPressed: () {
                                /// TODO : Comment implementation
                              })),
                    ],
                  ),
                  Text(
                    '${post.totalLikes} Likes \u{2022} ${post.totalComments} Comments',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            Divider(
              color: Colors.grey[300],
              thickness: 2,
              indent: 8,
              endIndent: 8,
              height: 5,
            ),
            Container(
                padding: const EdgeInsets.all(8.0),
                child: const Text(
                  'Liked by',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.black45),
                )),
            SizedBox(
              height: 50,
              child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: CircleAvatar(
                            radius: 25,
                            backgroundImage:
                                NetworkImage('${posts[index].postImageUrl}'),
                          ),
                        ),
                      ],
                    );
                  }),
            ),
            Container(
                padding: const EdgeInsets.only(top: 12.0, left: 8.0),
                child: const Text(
                  'Comments',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.black45),
                )),
            ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    isThreeLine: true,
                    leading: const CircleAvatar(
                      backgroundImage:
                          NetworkImage('https://picsum.photos/200'),
                    ),
                    title: Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.only(top: 11),
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '${posts[index].unofficialUsername} ',
                                    style: const TextStyle(
                                        color: Color(0xFF53008B)),
                                  ),
                                  if (posts[index].userType ==
                                          UserType.alumni ||
                                      posts[index].userType ==
                                          UserType.professor)
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        FaIcon(
                                          FontAwesomeIcons.certificate,
                                          color: posts[index].userType ==
                                                  UserType.professor
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
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: Constants.minPadding),
                                    child: Text(
                                      '${posts[index].dateTime.timeAgo()} ago',
                                      style: const TextStyle(
                                          color: Colors.grey, fontSize: 12),
                                    ),
                                  )
                                ],
                              ),
                              CircleAvatar(
                                backgroundColor: Colors.grey.shade200,
                                radius: 14,
                                child: GestureDetector(
                                  child: const Icon(FontAwesomeIcons.ellipsisH,
                                      size: 14),
                                  onTap: () {},
                                ),
                              ),
                            ],
                          ),
                          // Text(
                          //   '${posts[index].userDescription}',
                          //   style: TextStyle(color: Colors.grey[500]),
                          // ),
                          // Text(
                          //   '\u{1F310} ${posts[index].dateTime.timeAgo()} \u{2022} ${posts[index].postTypeText()}',
                          //   style: TextStyle(color: Colors.grey[500]),
                          // ),
                          // const SizedBox(
                          //   height: 20,
                          // ),
                          const Text(
                            'Awesome work',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                    // trailing: CircleAvatar(
                    //   backgroundColor: Colors.grey.shade200,
                    //   radius: 14,
                    //   child: GestureDetector(
                    //     child: const Icon(FontAwesomeIcons.ellipsisH, size: 14),
                    //     onTap: () {},
                    //   ),
                    // ),
                    subtitle: const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text('Like  |  Reply'),
                    ),
                  );
                }),
          ],
        ),
      ),
    );
  }
}
