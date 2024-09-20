// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, prefer_const_constructors_in_immutables, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:inventory_management_system/services/database_helper.dart';
import 'package:inventory_management_system/widgets/custom_appbar.dart';

class AddOrUpdateCategory extends StatefulWidget {
  final Map<String, dynamic>? category;

  AddOrUpdateCategory({this.category, required DatabaseHelper dbHelper});

  @override
  _AddOrUpdateCategoryState createState() => _AddOrUpdateCategoryState();
}

class _AddOrUpdateCategoryState extends State<AddOrUpdateCategory> {
  String name = '';
  String description = '';
  File? image;
  final ImagePicker picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File? croppedImage = (await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.blue,
            toolbarWidgetColor: Colors.white,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Crop Image',
          ),
        ],
      )) as File?;

      if (croppedImage != null) {
        setState(() {
          image = File(croppedImage.path);
        });
      }
    }
  }

  Future<void> _saveCategory() async {
    if (name.isEmpty || description.isEmpty || image == null) {
      // Handle validation error
      return;
    }

    final category = {
      'name': name,
      'description': description,
      'image': image!.path,
    };

    if (widget.category == null) {
      // Insert new category
      await DatabaseHelper.instance.insertCategory(category);
    } else {
      // Update existing category
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
          title: widget.category == null ? 'Add Category' : 'Update Category'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              initialValue: widget.category?['name'] ?? '',
              decoration: InputDecoration(labelText: 'Category Name'),
              onChanged: (value) => name = value,
            ),
            TextFormField(
              initialValue: widget.category?['description'] ?? '',
              decoration: InputDecoration(labelText: 'Description'),
              onChanged: (value) => description = value,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Choose Image'),
            ),
            SizedBox(height: 16),
            image != null
                ? Image.file(image!, width: 100, height: 100)
                : Text('No Image Selected'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveCategory,
              child: Text(
                  widget.category == null ? 'Add Category' : 'Update Category'),
            ),
          ],
        ),
      ),
    );
  }
}
