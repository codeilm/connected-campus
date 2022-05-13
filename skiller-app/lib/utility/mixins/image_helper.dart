import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skiller/config/constants.dart';

mixin ImageHelper {

  void deleteImage({required String path}) {
    FirebaseStorage.instance.ref().child(path).delete();
  }

  Future<File?> selectImageSource() async {
    File? imageFile;
    await Get.dialog(Dialog(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Image Source',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const Divider(
              thickness: 1,
              color: Colors.grey,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                    onPressed: () async {
                      imageFile = await pickAndCropImage(isGallery: false);
                      Get.back();
                    },
                    icon: const FaIcon(
                      FontAwesomeIcons.camera,
                      size: 50,
                    )),
                IconButton(
                    onPressed: () async {
                      imageFile = await pickAndCropImage(isGallery: true);
                      Get.back();
                    },
                    icon: const FaIcon(
                      FontAwesomeIcons.images,
                      size: 50,
                    )),
              ],
            ),
            const SizedBox(
              height: Constants.minPadding * 4,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [Text('Camera'), Text('Gallery')],
            ),
          ],
        ),
      ),
    ));
    return imageFile;
  }

  Future<File?> pickAndCropImage({bool isGallery = true}) async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: isGallery ? ImageSource.gallery : ImageSource.camera,
      maxWidth: 500,
      maxHeight: 500,
    );
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      debugPrint('Original Image ${imageFile.lengthSync()}');
      File? croppedFile = await imageCropper(file: imageFile);
      debugPrint('Final Image ${imageFile.lengthSync()}');
      if (croppedFile != null) {
        return croppedFile;
      } else {
        return imageFile;
      }
    }
  }

  Future<File?> imageCropper({required File file}) async {
    return await ImageCropper().cropImage(
        compressFormat: ImageCompressFormat.png,
        sourcePath: file.path,
        aspectRatioPresets: Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ]
            : [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio5x3,
                CropAspectRatioPreset.ratio5x4,
                CropAspectRatioPreset.ratio7x5,
                CropAspectRatioPreset.ratio16x9
              ],
        androidUiSettings: const AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepPurple,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: const IOSUiSettings(
          title: 'Cropper',
        ));
  }
}
