import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:cross_file_image/cross_file_image.dart';
import 'dart:io';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker(this.imagePickFn, {super.key});
  final void Function(XFile pickedImage) imagePickFn;

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  // XFile? _pickedImage;
  File? image;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
      maxWidth: 150,
    );
    final pickedImageFile = XFile(pickedImage!.path);
    setState(() {
      image = File(pickedImageFile.path);
    });
    widget.imagePickFn(pickedImageFile);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey,
            backgroundImage: image != null ? FileImage(image!) : null),
        TextButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.image),
          label: const Text('Add Image'),
        ),
      ],
    );
  }
}
