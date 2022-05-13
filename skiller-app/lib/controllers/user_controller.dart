import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
// import 'package:graphql/graphql.dart';
import 'package:provider/provider.dart';
import 'package:skiller/server/mutations.dart';
import 'package:skiller/server/server_provider.dart';

import '../models/skill.dart';
import '../models/user.dart';
import '../server/queries.dart';

class UserController extends GetxController {
  bool isProfileLoaded = false;

  List<Skill> userSkills = [];

  List<Skill> searchSkills = [];

  Future<User?> getProfile(
      {required GraphQLClient client, required String id}) async {
    final queryOptions = QueryOptions(
        document: gql(Queries.getUserProfileQuery),
        variables: <String, dynamic>{'id': id});
    final QueryResult result = await client.query(queryOptions);

    if (result.hasException) {
      debugPrint('Error occurred while getting profile : ${result.exception}');
      // Get.showSnackbar(const GetSnackBar(
      //     title: 'Error occurred', duration: Duration(seconds: 4)));
    } else {
      debugPrint('Response from Graphql getProfile : ${result.data}');
      userSkills = List<Skill>.from(result.data!['getUserProfile']['skills']
          .map((skillMap) => Skill.fromMap(skillMap)));
      isProfileLoaded = true;
      update();
      return User.fromJson(result.data!['getUserProfile']);
    }
    return null;
  }

  Future<void> searchSkillsByKeyword(
      {required BuildContext context, required String keyword}) async {
    final client =
        Provider.of<ServerProvider>(context, listen: false).client.value;

    final queryOptions = QueryOptions(
        document: gql(Queries.searchSkillsByKeywordQuery),
        variables: <String, dynamic>{'keyword': keyword});
    final QueryResult result = await client.query(queryOptions);

    if (result.hasException) {
      Get.showSnackbar(const GetSnackBar(
          title: 'Error occurred',
          message: 'Something went wrong',
          duration: Duration(seconds: 4)));
    } else {
      debugPrint(
          'Response from Graphql collabs in My connections : ${result.data}');
     
        searchSkills = List<Skill>.from(result
            .data!['searchSkillsByKeyword']
            .map((skillMap) => Skill.fromMap(skillMap)));
    }
  }

   Future<void> addSkill(
      {required BuildContext context, required Skill skill}) async {
        userSkills.insert(0, skill);
        update();
    final client =
        Provider.of<ServerProvider>(context, listen: false).client.value;
    final mutationOptions = MutationOptions(
        document: gql(Mutations.addSkillMutation),
        variables: <String, dynamic>{'skillId' : skill.id});

    final QueryResult result = await client.mutate(mutationOptions);

    if (result.hasException) {
      Get.showSnackbar(const GetSnackBar(
          title: 'Error occurred',
          message: 'Something went wrong',
          duration: Duration(seconds: 4)));
    } else {
      
      debugPrint('Response from Graphql : ${result.data}');
      // Get.showSnackbar(const GetSnackBar(
      //     title : 'Done',message: 'Request sent successfully', duration: Duration(seconds: 4)));
      Get.showSnackbar(const GetSnackBar(
          title: 'Done!',
          message: 'Skill added successfully',
          duration: Duration(seconds: 4)));
    }
  }

  

  Future<void> deleteSkill(
      {required BuildContext context, required skillId}) async {
    final client =
        Provider.of<ServerProvider>(context, listen: false).client.value;
    final mutationOptions = MutationOptions(
        document: gql(Mutations.deleteSkillMutation),
        variables: <String, dynamic>{'skillId': skillId});
    final QueryResult result = await client.mutate(mutationOptions);

    if (result.hasException) {
      Get.showSnackbar(const GetSnackBar(
          title: 'Error occurred',
          message: 'Something went wrong',
          duration: Duration(seconds: 4)));
    } else {
      userSkills.removeWhere((collab) => collab.id == skillId);
      update();
      debugPrint('Response from Graphql : ${result.data}');
      // Get.showSnackbar(const GetSnackBar(
      //     title : 'Done',message: 'Request sent successfully', duration: Duration(seconds: 4)));
      Get.showSnackbar(const GetSnackBar(
          title: 'Done!',
          message: 'Skill removed',
          duration: Duration(seconds: 4)));
    }
  }

  Future<void> sendConnectionRequest(
      {required BuildContext context,
      required String receiverUserId,
      required String reason}) async {
    final client =
        Provider.of<ServerProvider>(context, listen: false).client.value;
    final mutationOptions = MutationOptions(
        document: gql(Mutations.sendConnectionRequestMutation),
        variables: <String, dynamic>{
          'receiverUserId': receiverUserId,
          'message': reason
        });
    final QueryResult result = await client.mutate(mutationOptions);

    if (result.hasException) {
      Get.showSnackbar(const GetSnackBar(
          title: 'Error occurred',
          message: 'Something went wrong',
          duration: Duration(seconds: 4)));
    } else {
      debugPrint('Response from Graphql : ${result.data}');
      // Get.showSnackbar(const GetSnackBar(
      //     title : 'Done',message: 'Request sent successfully', duration: Duration(seconds: 4)));
    }
  }
}
