import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:skiller/controllers/user_controller.dart';
import 'package:skiller/models/post.dart';
// import 'package:skiller/screens/profile_controller.dart';
import '../controllers/auth/auth_controller.dart';
import '../models/skill.dart';
import '../models/user.dart';
import '../server/queries.dart';
import '../server/server_provider.dart';
import '../widgets/common/shimmer_container.dart';

class ProfileScreen extends StatefulWidget {
  final bool isCurrentUser;
  final User? user;
  const ProfileScreen({Key? key, this.isCurrentUser = true, this.user})
      : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late User user;
  bool isLoading = false;
  @override
  void initState() {
    if (widget.isCurrentUser) {
      user = Get.find<AuthController>().user;
      debugPrint('isCurrentUser : ${user.toJson()}');
    } else {
      user = widget.user!;
      debugPrint('isCurrentUser Not : ${user.toJson()}');
    }
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final client = Provider.of<ServerProvider>(context).client.value;
    debugPrint('User ID for Skiller : ${user.userId}');
    // if (user.userId.isNotEmpty) {
    Get.find<UserController>()
        .getProfile(client: client, id: user.userId)
        .then((value) {
      if (value != null) {
        setState(() {
          user = value;
          debugPrint('New user : ${user.toJson()}');
        });
      }
    });
    // }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[300],
        body: NestedScrollView(
          scrollDirection: Axis.vertical,
          floatHeaderSlivers: false,
          headerSliverBuilder: (context, scoll) {
            return [_profileAppBar()];
          },
          body: SingleChildScrollView(
            child: Column(
              children: [
                _userDescriptionData(),
                // TODO : Implement this [ProfileFeatured] once all important things are Done
                // const ProfileFeatured(
                //   title: 'Featured',
                // ),
                UserSkill(
                    isCurrentUser:
                        widget.isCurrentUser), // TODO : Fetch user skills
                const UserExperience(), // TODO : Fetch user Experience
                ProfileFeatured(
                  title: 'Projects',
                  postTypeId: 2,
                ),
                ProfileFeatured(
                  title: 'Posts',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _profileAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.black,
      leading: IconButton(
        icon: const CircleAvatar(
          backgroundColor: Colors.black12,
          child: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        onPressed: () {
          Get.back();
        },
      ),
      expandedHeight: 250.0,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(user.unofficialName,
            style: const TextStyle(
                fontSize: 16.0,
                color: Colors.white,
                fontWeight: FontWeight.bold)),
        background: Image.network(
            user.photoUrl.isNotEmpty
                ? user.photoUrl
                : 'https://media.giphy.com/media/26n6G8lRMOrYC6rFS/giphy.gif',
            fit: BoxFit.cover),
      ),
    );
  }

  _userDescriptionData() {
    return Container(
      margin: const EdgeInsets.only(top: 8.0),
      padding: const EdgeInsets.all(12.0),
      color: Colors.white,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                user.title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 5),
              Text(user.description, textAlign: TextAlign.justify),
            ],
          ),
          if (!widget.isCurrentUser)
            Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  child: const Text(
                    'Connect',
                    style: TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                  onTap: () async {
                    var reasonTEC = TextEditingController();

                    Get.defaultDialog(
                      title: 'Why you want to connect me ?',
                      titlePadding: const EdgeInsets.all(10),
                      content: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          TextField(
                            maxLength: 100,
                            controller: reasonTEC,
                            autofocus: true,
                            decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Write reason in brief'),
                            maxLines: null,
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              Get.back();
                              Get.find<UserController>().sendConnectionRequest(
                                  context: context,
                                  receiverUserId: user.userId,
                                  reason: reasonTEC.text);
                              AwesomeDialog(
                                      context: context,
                                      dialogType: DialogType.SUCCES,
                                      animType: AnimType.TOPSLIDE,
                                      title: 'Request sent !',
                                      desc: 'We have sent request succesfully',
                                      btnOkColor:
                                          Theme.of(context).primaryColor,
                                      dismissOnTouchOutside: false,
                                      autoHide: const Duration(seconds: 4))
                                  .show();
                            },
                            child: const Text(
                              'Connect',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      contentPadding: const EdgeInsets.all(10),
                    );
                  },

                  // onTap: () {
                  //  Get.find<UserController>().sendConnectionRequest(context: context,receiverUserId: user.userId);
                  // },
                ))
        ],
      ),
    );
  }
}

Row skill(bool value, String text, void Function(bool?)? onChanged) {
  return Row(
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 20, right: 8),
        child: Checkbox(
          checkColor: Colors.white,
          value: value,
          onChanged: onChanged,
        ),
      ),
      Text(
        text,
        // style: const TextStyle(fontSize: 16),
      ),
    ],
  );
}

class UserSkill extends StatefulWidget {
  final bool isCurrentUser;
  const UserSkill({Key? key, required this.isCurrentUser}) : super(key: key);

  @override
  State<UserSkill> createState() => _UserSkillState();
}

class _UserSkillState extends State<UserSkill> {
  bool value = false;
  UserController userController = Get.find<UserController>();
  bool showSearchSkillField = false;
  TextEditingController searchTEC = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      margin: const EdgeInsets.only(top: 8),
      // padding: const EdgeInsets.only(top: 10, left: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Skills & Endrosements',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                if (widget.isCurrentUser)
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () {
                      setState(() {
                        showSearchSkillField = !showSearchSkillField;
                      });
                    },
                  )
              ],
            ),
          ),
          if (showSearchSkillField)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextField(
                controller: searchTEC,
                onChanged: (value) {},
                decoration: InputDecoration(
                  hintText: "Search skills here ...",
                  fillColor: const Color(0xFFF2F4FC),
                  filled: true,
                  isDense: true,
                  suffixIcon: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5), //15
                    child: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () async {
                        FocusManager.instance.primaryFocus?.unfocus();
                        await userController.searchSkillsByKeyword(
                            context: context, keyword: searchTEC.text);
                        Get.bottomSheet(
                          Material(
                            child: SizedBox(
                                child: ListView.builder(
                              itemCount: userController.searchSkills.length,
                              itemBuilder: (context, index) {
                                Skill skill =
                                    userController.searchSkills[index];
                                return Card(
                                  child: ListTile(
                                    onTap: () {
                                      Get.back();
                                    },
                                    leading: const Icon(Icons.grading),
                                    title: Text(skill.name),
                                    trailing: IconButton(
                                      icon: Icon(
                                        Icons.add_circle_outline,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          showSearchSkillField = false;
                                          Get.back();
                                          userController.addSkill(
                                              context: context, skill: skill);
                                          searchTEC.clear();
                                        });
                                      },
                                    ),
                                  ),
                                );
                              },
                            )),
                          ),
                        );
                      },
                    ),
                  ),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          GetBuilder<UserController>(builder: (_) {
            if (userController.isProfileLoaded) {
              if (userController.userSkills.isEmpty) {
                return const SizedBox(
                    height: 100,
                    child: Center(
                      child: Text(
                        'No skills added',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ));
              }
              return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: userController.userSkills.length,
                  itemBuilder: (contex, index) {
                    Skill skill = userController.userSkills[index];
                    return SkillWidget(
                        skill: skill, isCurrentUser: widget.isCurrentUser);
                  });
            }
            return shimmerContainer();
          }),
        ],
      ),
    );
  }
}

class SkillWidget extends StatefulWidget {
  final Skill skill;
  final bool isCurrentUser;

  const SkillWidget(
      {Key? key, required this.skill, required this.isCurrentUser})
      : super(key: key);

  @override
  State<SkillWidget> createState() => _SkillWidgetState();
}

class _SkillWidgetState extends State<SkillWidget> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        checkColor: Colors.white,
        value: false,
        onChanged: (value) {},
      ),
      title: Text(
        widget.skill.name,
        // style: const TextStyle(fontSize: 16),
      ),
      trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            Get.find<UserController>()
                .deleteSkill(context: context, skillId: widget.skill.id);
          }),
    );
  }
}

class ProfileFeatured extends StatelessWidget {
  final String title;
  final int? postTypeId;
  List<Post> posts = [];
  ProfileFeatured({Key? key, required this.title, this.postTypeId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.only(top: 8.0),
        padding: const EdgeInsets.only(bottom: 8.0),
        color: Colors.white,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w400,
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
          ),
          SizedBox(
            height: 180,
            width: double.infinity,
            child: Query(
                options: QueryOptions(
                    document: gql(Queries.getPostsQuery),
                    variables: {
                      'isForOnlyCurrentUser': true,
                      'postTypeId': postTypeId
                    }),
                builder: (
                  QueryResult result, {
                  Refetch? refetch,
                  FetchMore? fetchMore,
                }) {
                  print(result);
                  if (result.hasException) {
                    return Center(
                        child:
                            Text('Error occurred\n\n${result.hasException}'));
                  } else if (result.isLoading) {
                    return shimmerContainer();
                  } else {
                    debugPrint('Data : ${result.data}');
                    posts = List.from(result.data?['getPosts']
                        .map((jsonPost) => Post.fromJson(jsonPost)));
                    debugPrint('Above Profile Post GetBuilder');
                    return posts.isNotEmpty
                        ? ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: posts.length,
                            itemBuilder: (context, index) {
                              return Container(
                                width: 250,
                                padding: const EdgeInsets.only(
                                    right: 10.0, left: 10.0),
                                child: Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10.0),
                                      child: CachedNetworkImage(
                                        height: 150,
                                        width: 250,
                                        fit: BoxFit.fitWidth,
                                        imageUrl: posts[index].postImageUrl,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: Text(posts[index].postTitle,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis),
                                    )
                                  ],
                                ),
                              );
                            })
                        : Center(
                            child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: const [
                              Icon(
                                Icons.post_add,
                                size: 50,
                                color: Colors.grey,
                              ),
                              Text(
                                'Nothing found',
                                style: TextStyle(color: Colors.grey),
                              )
                            ],
                          ));
                  }
                }),
          ),
        ]),
      ),
    );
  }
}

class UserExperience extends StatelessWidget {
  const UserExperience({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Experience',
            style: TextStyle(fontSize: 20),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    text: 'Spark Foundation',
                    style: DefaultTextStyle.of(context).style,
                    children: const [
                      TextSpan(
                          text: ' . ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          )),
                      TextSpan(
                          text: 'Internship',
                          style: TextStyle(color: Colors.green)),
                    ],
                  ),
                ),
                const Text('Data Analyst'),
                RichText(
                  text: const TextSpan(
                      text: 'May 21',
                      style: TextStyle(color: Colors.grey),
                      children: [
                        TextSpan(text: ' - Present'),
                        TextSpan(text: ' - 4 mons'),
                      ]),
                ),
                const SizedBox(
                  height: 15,
                ),
                RichText(
                  text: TextSpan(
                    text: 'Spark Foundation',
                    style: DefaultTextStyle.of(context).style,
                    children: const [
                      TextSpan(
                          text: ' . ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          )),
                      TextSpan(
                          text: 'Internship',
                          style: TextStyle(color: Colors.green)),
                    ],
                  ),
                ),
                const Text('Web Developer'),
                RichText(
                  text: const TextSpan(
                      text: 'May 21',
                      style: TextStyle(color: Colors.grey),
                      children: [
                        TextSpan(text: ' - Present'),
                        TextSpan(text: ' - 4 mons'),
                      ]),
                ),
                const SizedBox(
                  height: 15,
                ),
                RichText(
                  text: TextSpan(
                    text: 'Spark Foundation',
                    style: DefaultTextStyle.of(context).style,
                    children: const [
                      TextSpan(
                          text: ' . ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          )),
                      TextSpan(
                          text: 'Internship',
                          style: TextStyle(color: Colors.green)),
                    ],
                  ),
                ),
                const Text('Data Analyst'),
                RichText(
                  text: const TextSpan(
                      text: 'May 21',
                      style: TextStyle(color: Colors.grey),
                      children: [
                        TextSpan(text: ' - Present'),
                        TextSpan(text: ' - 4 mons'),
                      ]),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
