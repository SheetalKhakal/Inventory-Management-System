// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api, use_key_in_widget_constructors

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inventory_management_system/services/database_helper.dart';
import 'package:inventory_management_system/views/category_screen.dart';
import 'package:inventory_management_system/widgets/custom_appbar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _numProducts = 0;
  int _numCategories = 0;
  int _numUsers = 0;
  int _lowInventoryCount = 0;

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  File? _primaryImageFile;

  @override
  void initState() {
    super.initState();
    _requestPermissions(); // Request permissions here
    _fetchDashboardData();
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.camera,
      Permission.storage,
    ].request();
  }

  Future<void> _fetchDashboardData() async {
    final products = await _dbHelper.queryAllProducts();
    final categories = await _dbHelper.queryAllCategories();
    final users = await _dbHelper.queryAllUsers();
    final lowInventory = await _dbHelper.queryLowInventoryProducts();

    setState(() {
      _numProducts = products.length;
      _numCategories = categories.length;
      _numUsers = users.length;
      _lowInventoryCount = lowInventory.length;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // Save the image
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/${pickedFile.name}';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(await File(pickedFile.path).readAsBytes());

      setState(() {
        _primaryImageFile = imageFile; // Set the state with the new image
      });
    }
  }

  Future<void> _addOrUpdateProduct({Map<String, dynamic>? product}) async {
    String title = product == null ? 'Add Product' : 'Update Product';
    String buttonText = product == null ? 'Add' : 'Update';

    String name = product?['name'] ?? '';
    String sku = product?['sku'] ?? '';
    String category = product?['category'] ?? '';
    int quantity = product?['quantity'] ?? 0;
    String primaryImage = product?['primary_image'] ?? '';
    String description = product?['description'] ?? '';
    double price = product?['price'] ?? 0.0;

    final formKey = GlobalKey<FormState>();

    if (primaryImage.isNotEmpty && _primaryImageFile == null) {
      // If there's an existing primary image URL, use it
      _primaryImageFile = File(primaryImage);
    }

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: name,
                    decoration: InputDecoration(labelText: 'Name'),
                    onChanged: (value) => name = value,
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter product name' : null,
                  ),
                  TextFormField(
                    initialValue: sku,
                    decoration: InputDecoration(labelText: 'SKU'),
                    onChanged: (value) => sku = value,
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter SKU' : null,
                  ),
                  TextFormField(
                    initialValue: category,
                    decoration: InputDecoration(labelText: 'Category'),
                    onChanged: (value) => category = value,
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter category' : null,
                  ),
                  TextFormField(
                    initialValue: quantity.toString(),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Quantity'),
                    onChanged: (value) => quantity = int.tryParse(value) ?? 0,
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter quantity' : null,
                  ),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _primaryImageFile != null
                            ? Image.file(
                                _primaryImageFile!,
                                height: 200,
                                width: 200,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                height: 200,
                                width: 200,
                                color: Colors.grey[300],
                                child: Icon(Icons.camera_alt),
                              ),
                        SizedBox(height: 5),
                        Text('Tap to select primary image'),
                      ],
                    ),
                  ),
                  TextFormField(
                    initialValue: description,
                    decoration: InputDecoration(labelText: 'Description'),
                    onChanged: (value) => description = value,
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter description' : null,
                  ),
                  TextFormField(
                    initialValue: price.toString(),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Price'),
                    onChanged: (value) => price = double.tryParse(value) ?? 0.0,
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter price' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  // Add or update the product
                  if (product == null) {
                    await _dbHelper.insertProduct({
                      'name': name,
                      'sku': sku,
                      'category': category,
                      'quantity': quantity,
                      'primary_image':
                          _primaryImageFile?.path ?? '', // Use the path
                      'description': description,
                      'price': price,
                    });
                  } else {
                    await _dbHelper.updateProduct({
                      'id': product['id'],
                      'name': name,
                      'sku': sku,
                      'category': category,
                      'quantity': quantity,
                      'primary_image': _primaryImageFile?.path ??
                          product[
                              'primary_image'], // Use existing if not picking new
                      'description': description,
                      'price': price,
                    });
                  }
                  Navigator.pop(context);
                  _fetchDashboardData();
                }
              },
              child: Text(buttonText),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteProduct(int id) async {
    await _dbHelper.deleteProduct(id);
    _fetchDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Beauty Store Dashboard'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Products: $_numProducts',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Total Categories: $_numCategories',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Registered Users: $_numUsers',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Products Low in Inventory: $_lowInventoryCount',
                style: TextStyle(fontSize: 18, color: Colors.red)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _addOrUpdateProduct(),
              child: Text('Add Product'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => CategoryScreen()));
              },
              child: Text('Category'),
            ),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _dbHelper.queryAllProducts(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.data!.isEmpty) {
                    return Center(child: Text('No Products Available'));
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final product = snapshot.data![index];
                      return ListTile(
                        contentPadding: EdgeInsets.all(8.0),
                        leading: product['primary_image'] != null
                            ? Image.file(
                                File(product['primary_image']),
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 50,
                                height: 50,
                                color: Colors.grey[300],
                                child: Icon(Icons.image, size: 30),
                              ),
                        title: Text(product['name']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Quantity: ${product['quantity']}'),
                            Text('Price: \$${product['price']}'),
                            Text('Description: ${product['description']}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () =>
                                  _addOrUpdateProduct(product: product),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => _deleteProduct(product['id']),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
