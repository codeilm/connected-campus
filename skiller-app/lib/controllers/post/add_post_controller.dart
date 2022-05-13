import 'dart:io';
import 'package:get/get.dart';
import '../../models/file_model.dart';

class AddPostController extends GetxController {
  /// TODO : We can make it Dynamic on the basis of Requirement, table is already there in the DB
  final postType = {
    1: 'Technology',
    2: 'Project',
    3: 'Tips & Tricks',
    4: 'Internship',
    5: 'Jobs',
    6: 'Talks',
    7: 'News',
    8: 'Event',
9:'Other'
  };

  int selectedPostTypeId = 2;

  Set<int> selectedNodes = {};

  File? thumbnailImage;

  List<FileModel> attachments = [];
}
