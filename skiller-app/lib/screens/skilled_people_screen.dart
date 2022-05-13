import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:skiller/screens/profile_screen.dart';
import 'package:skiller/widgets/common/loading_cube.dart';

import '../models/user.dart';
import '../server/queries.dart';

class SkilledPeopleScreen extends StatelessWidget {
  final String skill;
  final String skillId;
  SkilledPeopleScreen({Key? key, required this.skill, required this.skillId})
      : super(key: key);
  List<User> users = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(skill)),
      body: Query(
          options: QueryOptions(
              document: gql(Queries.searchBySkillIdQuery),
              variables: <String, dynamic>{'skillId': int.parse(skillId)}),
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
              return const LoadingCube();
            } else {
              debugPrint('Skilled People : ${result.data}');
              users = List<User>.from(((result.data?['searchBySkillId']
                          ?['SearchBySkillResultListVariable']) ??
                      [])
                  .map((map) => User.fromJson(map as Map<String, dynamic>)));

              debugPrint('Above GetBuilder');
              if (users.isNotEmpty) {
                return ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    User user = users[index];
                    return ListTile(
                      leading: CircleAvatar(
                          backgroundImage: NetworkImage(user.photoUrl)),
                      title: Text(user.unofficialName),
                      subtitle: Text(user.title),
                      trailing: ElevatedButton(
                        child: const Text('Connect'),
                        onPressed: () {
                          // TODO  : Connect the current user to this user
                        },
                      ),
                      onTap: () {
                        Get.to(() => ProfileScreen(
                            isCurrentUser: false,
                            user: User(
                                userId: user.userId,
                                unofficialName: user.unofficialName)));
                      },
                    );
                  },
                  separatorBuilder: (context, index) => const Divider(),
                );
              } else {
                return Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.person, size: 50, color: Colors.grey),
                    SizedBox(height: 20),
                    Text('Could not find any user with this skill',
                        style: TextStyle(color: Colors.grey))
                  ],
                ));
              }
            }
          }),
    );
  }
}
