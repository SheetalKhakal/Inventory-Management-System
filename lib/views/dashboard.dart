// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:inventory_management_system/services/database_helper.dart';

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

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
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

  Future<void> _addOrUpdateProduct({Map<String, dynamic>? product}) async {
    String title = product == null ? 'Add Product' : 'Update Product';
    String buttonText = product == null ? 'Add' : 'Update';

    String name = product?['name'] ?? '';
    int quantity = product?['quantity'] ?? 0;
    double price = product?['price'] ?? 0.0;

    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Form(
            key: formKey,
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
                  initialValue: quantity.toString(),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Quantity'),
                  onChanged: (value) => quantity = int.tryParse(value) ?? 0,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter quantity' : null,
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
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  if (product == null) {
                    // Add new product
                    await _dbHelper.insertProduct({
                      'name': name,
                      'quantity': quantity,
                      'price': price,
                    });
                  } else {
                    // Update existing product
                    await _dbHelper.updateProduct({
                      'id': product['id'],
                      'name': name,
                      'quantity': quantity,
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
      appBar: AppBar(title: Text('Beauty Store Dashboard')),
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
                        title: Text(product['name']),
                        subtitle: Text(
                            'Quantity: ${product['quantity']} - Price: \$${product['price']}'),
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
