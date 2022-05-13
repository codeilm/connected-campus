import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

import '../../models/file_model.dart';
import '../enums.dart';


mixin FileHelper {
   Future<String> uploadFileToFirebaseStorage(
      {required FileModel fileModel}) async {
        
    String path;
    switch(fileModel.fileType){
      case StorageFileType.thumbnail:
      path = 'thumbnails/';
      break;
      case StorageFileType.profile:
      path  = 'profiles/';
      break;
      case StorageFileType.attachment:
      path = 'attachments/';
    }
    
    Reference reference =
        FirebaseStorage.instance.ref().child(path + const Uuid().v4());
    UploadTask uploadTask = reference.putFile(fileModel.file);
    await uploadTask.whenComplete(() {});
    return await reference.getDownloadURL();
  }
}