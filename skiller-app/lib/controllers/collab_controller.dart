import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';

import '../models/collab.dart';
import '../server/mutations.dart';
import '../server/queries.dart';
import '../server/server_provider.dart';

class CollabController extends GetxController {
  bool isConnectionInProgressLoading = true;
  bool isMyConnectionsLoading = true;

  List<Collab> collabsInProgress = [];
  List<Collab> myConnections = [];

  Future<void> getInProgressConnections({required BuildContext context}) async {
    final client =
        Provider.of<ServerProvider>(context, listen: false).client.value;

    final queryOptions =
        QueryOptions(document: gql(Queries.viewInProgressConnectionsQuery));
    final QueryResult result = await client.query(queryOptions);

    if (result.hasException) {
      Get.showSnackbar(const GetSnackBar(
          title: 'Error occurred',
          message: 'Something went wrong',
          duration: Duration(seconds: 4)));
    } else {
      debugPrint('Response from Graphql collabs : ${result.data}');
      collabsInProgress = List<Collab>.from(result
          .data!['viewInProgressConnections']['myConenctionListVariable']
          .map((collabMap) => Collab.fromMap(collabMap)));
      debugPrint('Collabs : $collabsInProgress');
      isConnectionInProgressLoading = false;
      update();
    }
  }

  Future<void> acceptConnectionRequest(
      {required BuildContext context, required connectionId}) async {
    final client =
        Provider.of<ServerProvider>(context, listen: false).client.value;
    final mutationOptions = MutationOptions(
        document: gql(Mutations.acceptConnectionRequestMutation),
        variables: <String, dynamic>{'id': connectionId});
    final QueryResult result = await client.mutate(mutationOptions);

    if (result.hasException) {
      Get.showSnackbar(const GetSnackBar(
          title: 'Error occurred',
          message: 'Something went wrong',
          duration: Duration(seconds: 4)));
    } else {
      collabsInProgress
          .removeWhere((collab) => collab.connectionId == connectionId);
      update();
      debugPrint('Response from Graphql : ${result.data}');
      // Get.showSnackbar(const GetSnackBar(
      //     title : 'Done',message: 'Request sent successfully', duration: Duration(seconds: 4)));
      Get.showSnackbar(const GetSnackBar(
          title: 'Done!',
          message: 'Connection accepted',
          duration: Duration(seconds: 4)));
    }
  }

  Future<void> rejectConnectionRequest(
      {required BuildContext context, required connectionId}) async {
    final client =
        Provider.of<ServerProvider>(context, listen: false).client.value;
    final mutationOptions = MutationOptions(
        document: gql(Mutations.rejectConnectionRequestMutation),
        // TODO : Later on add the functionality to add the reason for rejection
        variables: <String, dynamic>{'id': connectionId, 'message': ''});
    final QueryResult result = await client.mutate(mutationOptions);

    if (result.hasException) {
      Get.showSnackbar(const GetSnackBar(
          title: 'Error occurred',
          message: 'Something went wrong',
          duration: Duration(seconds: 4)));
    } else {
      collabsInProgress
          .removeWhere((collab) => collab.connectionId == connectionId);
      update();
      debugPrint('Response from Graphql : ${result.data}');
      // Get.showSnackbar(const GetSnackBar(
      //     title : 'Done',message: 'Request sent successfully', duration: Duration(seconds: 4)));
      Get.showSnackbar(const GetSnackBar(
          title: 'Done!',
          message: 'Connection rejected',
          duration: Duration(seconds: 4)));
    }
  }

  Future<void> terminateConnectionRequest(
      {required BuildContext context, required connectionId}) async {
    // TODO : Integrate this API in UI
    final client =
        Provider.of<ServerProvider>(context, listen: false).client.value;
    final mutationOptions = MutationOptions(
        document: gql(Mutations.terminateConnectionRequestMutation),
        variables: <String, dynamic>{'id': connectionId});
    final QueryResult result = await client.mutate(mutationOptions);

    if (result.hasException) {
      Get.showSnackbar(const GetSnackBar(
          title: 'Error occurred',
          message: 'Something went wrong',
          duration: Duration(seconds: 4)));
    } else {
      collabsInProgress
          .removeWhere((collab) => collab.connectionId == connectionId);
      update();
      debugPrint('Response from Graphql : ${result.data}');
      // Get.showSnackbar(const GetSnackBar(
      //     title : 'Done',message: 'Request sent successfully', duration: Duration(seconds: 4)));
      // Get.showSnackbar(const GetSnackBar(
      //     title: 'Done!',message: 'Connection rejected', duration: Duration(seconds: 4)));
    }
  }

  Future<void> getMyConnections({required BuildContext context}) async {
    final client =
        Provider.of<ServerProvider>(context, listen: false).client.value;

    final queryOptions =
        QueryOptions(document: gql(Queries.viewConnectedConnectionsQuery));
    final QueryResult result = await client.query(queryOptions);

    if (result.hasException) {
      Get.showSnackbar(const GetSnackBar(
          title: 'Error occurred',
          message: 'Something went wrong',
          duration: Duration(seconds: 4)));
    } else {
      debugPrint(
          'Response from Graphql collabs in My connections : ${result.data}');
      if (result.data!['viewConnectedConnections']['__typename'] !=
          'acknowledge') {
        myConnections = List<Collab>.from(result
            .data!['viewConnectedConnections']['myConenctionListVariable']
            .map((collabMap) => Collab.fromMap(collabMap)));
      }
      debugPrint('Collabs my connections : $collabsInProgress');
      isMyConnectionsLoading = false;
      update();
    }
  }

  Future<void> terminateConnectedConnection(
      {required BuildContext context, required connectionId}) async {
    final client =
        Provider.of<ServerProvider>(context, listen: false).client.value;
    final mutationOptions = MutationOptions(
        document: gql(Mutations.terminateConnectedConnectionMutation),
        variables: <String, dynamic>{'id': connectionId});
    final QueryResult result = await client.mutate(mutationOptions);

    if (result.hasException) {
      Get.showSnackbar(const GetSnackBar(
          title: 'Error occurred',
          message: 'Something went wrong',
          duration: Duration(seconds: 4)));
    } else {
      myConnections
          .removeWhere((collab) => collab.connectionId == connectionId);
      update();
      debugPrint('Response from Graphql : ${result.data}');
      // Get.showSnackbar(const GetSnackBar(
      //     title : 'Done',message: 'Request sent successfully', duration: Duration(seconds: 4)));
      Get.showSnackbar(const GetSnackBar(
          title: 'Done!',
          message: 'Connection deleted',
          duration: Duration(seconds: 4)));
    }
  }
}
