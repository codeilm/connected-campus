// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:graphql_flutter/graphql_flutter.dart';
// import 'package:provider/provider.dart';

// import '../models/skill.dart';
// import '../server/queries.dart';
// import '../server/server_provider.dart';

// class ProfileController extends GetxController {
//   bool isUserSkillsLoaded = false;
//   List<Skill> userSkills = [];

//     Future<void> getUserSkills({required BuildContext context}) async {
//     final client =
//         Provider.of<ServerProvider>(context, listen: false).client.value;

//     final queryOptions =
//         QueryOptions(document: gql(Queries.getSkillsQuery));
//     final QueryResult result = await client.query(queryOptions);

//     if (result.hasException) {
//       Get.showSnackbar(const GetSnackBar(
//           title: 'Error occurred',
//           message: 'Something went wrong',
//           duration: Duration(seconds: 4)));
//     } else {
//       debugPrint('Response from Graphql user skills : ${result.data}');
//       userSkills = List<Skill>.from(result
//           .data!['getSkills']
//           .map((skillMap) => Skill.fromMap(skillMap)));
//       // debugPrint('Collabs : $collabsInProgress');
//       isUserSkillsLoaded = true;
//       update();
//     }
//   }

// }