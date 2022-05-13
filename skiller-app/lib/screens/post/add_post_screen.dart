import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:html_editor_enhanced/html_editor.dart';
import 'package:skiller/config/constants.dart';
import 'package:skiller/controllers/auth/auth_controller.dart';
import 'package:skiller/controllers/post/add_post_controller.dart';
import 'package:skiller/screens/main_screen.dart';
import 'package:skiller/server/mutations.dart';
// import 'package:skiller/server/queries.dart';
import 'package:skiller/utility/mixins/file_helper.dart';
import 'package:skiller/utility/mixins/image_helper.dart';
import 'package:skiller/widgets/common/loading_spinner.dart';
import 'package:file_picker/file_picker.dart';

import '../../models/file_model.dart';
import '../../utility/enums.dart';

class AddPostScreen extends StatefulWidget {
  // final PostMetaData postMetaData;
  const AddPostScreen({Key? key /*, required this.postMetaData*/})
      : super(key: key);

  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen>
    with ImageHelper, FileHelper {
  final _formKey = GlobalKey<FormState>();

  AddPostController addPostController = Get.find<AddPostController>();
  final titleTEC = TextEditingController();
  final descriptionTEC = TextEditingController();
  bool isLoading = false;

  _attachmentDataItem(BuildContext context, Icon icons, String name, colors,
      int index, void Function()? onTap) {
    return Expanded(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        GestureDetector(
            onTap: onTap,
            child: CircleAvatar(
                child: icons, backgroundColor: colors, radius: 25)),
        const SizedBox(height: Constants.minPadding),
        Text(name)
      ]),
    );
  }

  // void getImage({required ImageSource source}) async {
  //   final file = await ImagePicker().pickImage(source: source);

  //   if (file?.path != null) {
  //     setState(() {
  //       addPostController.thumbnailImage = File(file!.path);
  //     });
  //   }
  // }

  showAttachmentDialog() {
    return showDialog(
      barrierColor: Colors.transparent,
      context: context,
      builder: (context) {
        return AlertDialog(
          elevation: 25,
          content: Container(
            padding: const EdgeInsets.symmetric(vertical: Constants.minPadding),
            width: double.infinity,
            child: Row(
              children: [
                _attachmentDataItem(
                  context,
                  const Icon(Icons.camera_alt_rounded,
                      size: 25, color: Colors.white),
                  "Camera",
                  Colors.pink[800],
                  1,
                  () async {
                    File? imageFile = await pickAndCropImage(isGallery: false);
                    if (imageFile != null) {
                      addPostController.attachments.add(FileModel(
                          path: imageFile.path,
                          fileType: StorageFileType.attachment));
                      Navigator.of(context).pop();

                      setState(() {});
                    }
                  },
                ),
                _attachmentDataItem(
                  context,
                  const Icon(Icons.panorama, size: 25, color: Colors.white),
                  "Gallery",
                  Colors.purple,
                  2,
                  () async {
                    File? imageFile = await pickAndCropImage();
                    if (imageFile != null) {
                      addPostController.attachments.add(FileModel(
                          path: imageFile.path,
                          fileType: StorageFileType.attachment));
                      Navigator.of(context).pop();
                      setState(() {});
                    }
                  },
                ),
                _attachmentDataItem(
                  context,
                  const Icon(Icons.picture_as_pdf,
                      size: 30, color: Colors.white),
                  "PDF",
                  Colors.indigo[800],
                  3,
                  () async {
                    FilePickerResult? result = await FilePicker.platform
                        .pickFiles(
                            type: FileType.custom, allowedExtensions: ['pdf']);
                    debugPrint('Picked filep ath : ${result?.paths}');
                    if (result?.paths.isNotEmpty ?? false) {
                      addPostController.attachments.add(FileModel(
                          path: result!.paths.first!,
                          fileType: StorageFileType.attachment));
                      Navigator.of(context).pop();
                      setState(() {});
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.chevronLeft, color: Colors.black),
          onPressed: () {
            Get.back();
          },
        ),
        title: const Text('Share something',
            style: TextStyle(color: Colors.black)),
        actions: [
          Mutation(
            options: MutationOptions(
                document: gql(Mutations.addPostMutation),
                onCompleted: (response) {
                  debugPrint('Post added');
                  debugPrint('Response : $response');
                  setState(() {
                    isLoading = false;
                  });
                  Get.to(() => const MainScreen());
                },
                onError: (e) {
                  debugPrint('Error occurred in Posting add : $e');
                }),
            builder: (MultiSourceResult<dynamic> Function(Map<String, dynamic>,
                        {Object? optimisticResult})
                    runMutation,
                QueryResult<dynamic>? result) {
              return TextButton(
                  child: isLoading
                      ? const LoadingSpinner()
                      : const Text('POST',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          )),
                  // child: const Text('Login'),
                  onPressed: () async {
                    String? imageUrl;
                    FocusManager.instance.primaryFocus?.unfocus();

                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        isLoading = true;
                      });
                      debugPrint(
                          'Post data : ${titleTEC}, ${descriptionTEC.text}, ${addPostController.selectedNodes.toList()}, ');
                      if (addPostController.thumbnailImage != null) {
                        imageUrl = await uploadFileToFirebaseStorage(
                          fileModel: FileModel(
                              path: addPostController.thumbnailImage!.path,
                              fileType: StorageFileType.thumbnail),
                        );
                      }
                      for (int i = 0;
                          i < addPostController.attachments.length;
                          i++) {
                        String fileUrl = await uploadFileToFirebaseStorage(
                            fileModel: addPostController.attachments[i]);
                        addPostController.attachments[i].fileUrl = fileUrl;
                      }
                      debugPrint(
                          'Attachments : ${addPostController.attachments.map((e) => e.fileUrl).toList()}');
                      debugPrint('thumbnail Image : $imageUrl');
                      runMutation({
                        // 'userId': Get.find<AuthController>().user.id,
                        'postTypeId': addPostController.selectedPostTypeId,
                        'imageUrl': imageUrl,
                        'attachments': addPostController.attachments
                            .map((e) => e.fileUrl)
                            .toList(),
                        'title': titleTEC.text,
                        'description': descriptionTEC.text,
                        'forWhom': addPostController.selectedNodes.toList()
                      });
                        addPostController.thumbnailImage = null;
                    }
                  });
            },
          ),
        ],
      ),
      body: Center(
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(
                    horizontal: Constants.minPadding * 2),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(Constants.minPadding * 3)),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: titleTEC,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white)),
                            hintText: 'Type here title ...'),
                        maxLength: 100,
                        // maxLines: 15,
                        autovalidateMode: AutovalidateMode.onUserInteraction,

                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter title';
                          }
                        },
                      ),
                    ),
                    Stack(alignment: Alignment.center, children: [
                      if (addPostController.thumbnailImage != null) ...[
                        Image.file(addPostController.thumbnailImage!),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: IconButton(
                            icon: CircleAvatar(
                              backgroundColor: Colors.grey.shade100,
                              child: Icon(Icons.edit, color: Colors.deepPurple),
                            ),
                            onPressed: () async {
                              addPostController.thumbnailImage =
                                  await selectImageSource();
                              setState(() {});
                            },
                          ),
                        )
                      ],
                      if (addPostController.thumbnailImage == null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: OutlinedButton(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Expanded(
                                    child: Text('Add Thumbnail',
                                        textAlign: TextAlign.center)),
                                Icon(Icons.upload),
                              ],
                            ),
                            onPressed: () async {
                              // addPostController.thumbnailImage =
                              //     await pickAndCropImage();
                              addPostController.thumbnailImage =
                                  await selectImageSource();
                              setState(() {});
                            },
                          ),
                        ),
                    ]),
                    // if (addPostController.thumbnailImage != null)
                    //   Image.file(addPostController.thumbnailImage!),
                    Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: descriptionTEC,
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.white)),
                                hintText: 'Type here description ...'),
                            maxLength: 1000,
                            maxLines: 15,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter description';
                              }
                            },
                          ),
                        ),
                        Positioned(
                          right: Constants.minPadding * 4,
                          bottom: Constants.minPadding * 8,
                          child: CircleAvatar(
                            backgroundColor: Colors.grey.shade300,
                            child: IconButton(
                              icon: const FaIcon(FontAwesomeIcons.paperclip),
                              onPressed: () {
                                FocusScope.of(context).unfocus();
                                showAttachmentDialog();
                              },
                            ),
                          ),
                        )
                      ],
                    ),

                    Container(
                      color: Colors.grey.shade100,
                      child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: addPostController.attachments.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2),
                          itemBuilder: (BuildContext context, int index) {
                            FileModel fileModel =
                                addPostController.attachments[index];
                            return Card(
                                child: GridTile(
                                    header: Align(
                                      alignment: Alignment.topRight,
                                      child: GestureDetector(
                                        child: Container(
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              borderRadius: const BorderRadius
                                                      .only(
                                                  bottomLeft: Radius.circular(
                                                      Constants.minPadding *
                                                          2)),
                                            ),
                                            padding: const EdgeInsets.all(
                                                Constants.minPadding),
                                            child: const Icon(Icons.close)),
                                        onTap: () {
                                          addPostController.attachments
                                              .removeAt(index);
                                          setState(() {});
                                        },
                                      ),
                                    ),
                                    child: fileModel.extension ==
                                            FileExtension.pdf
                                        ? PDFView(filePath: fileModel.file.path)
                                        : Image.file(fileModel.file)));
                          }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
