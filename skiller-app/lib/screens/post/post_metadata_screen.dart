import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skiller/config/constants.dart';
import 'package:skiller/controllers/post/add_post_controller.dart';
import 'package:skiller/screens/post/add_post_screen.dart';
import 'package:skiller/widgets/hierarchy_tree.dart';

const spaceBetweenText = SizedBox(
  height: 20,
);

class PostMetadataScreen extends StatefulWidget {
  const PostMetadataScreen({Key? key}) : super(key: key);

  @override
  _PostMetadataScreenState createState() => _PostMetadataScreenState();
}

class _PostMetadataScreenState extends State<PostMetadataScreen> {
  // final _formKey = GlobalKey<FormState>();

  // List<DropdownMenuItem<String>> menuItems = [];

  AddPostController addPostController = Get.put(AddPostController());

  // static const Map<int, String> engineeringBranches = {
  //   0: 'All',
  //   1: 'Computer Engineering',
  //   2: 'Civil Engineering',
  //   3: 'Mechanical Engineering',
  //   4: 'Electrical Engineering',
  //   5: 'Electronics Engineering',
  // };

  // late int selectedEngineeringBranchId;

  // bool disabledDropdown = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
              child: const Text(
                'What do you want to create?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
                left: Constants.minPadding * 4,
                right: Constants.minPadding * 4),
            child: DropdownButton(
                value: addPostController.selectedPostTypeId,
                isExpanded: true,
                items: addPostController.postType.entries
                    .map((mapEntry) => DropdownMenuItem(
                          child: Text(mapEntry.value),
                          value: mapEntry.key,
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    addPostController.selectedPostTypeId = value as int;
                  });
                }),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 25, horizontal: 20),
              child: Text(
                'Who can see this post?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          const HierarchyTree(),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Get.to(() =>const AddPostScreen());
                  },
                  child: Text(
                    'Next',
                    style: TextStyle(
                      // color: Colors.black,
                      fontSize: 20,
                    ),
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PostText extends StatelessWidget {
  PostText({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.only(left: 20),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class PostTextField extends StatelessWidget {
  PostTextField({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        decoration: InputDecoration(
          hintText: label,
        ),
      ),
    );
  }
}
