// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:inventory_management_system/services/database_helper.dart';
import 'package:inventory_management_system/widgets/custom_appbar.dart';

class CategoryScreen extends StatefulWidget {
  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  int _numCategories = 0;

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    final categories = await _dbHelper.queryAllCategories();

    setState(() {
      _numCategories = categories.length;
    });
  }

  Future<void> _addOrUpdateCategory({Map<String, dynamic>? category}) async {
    String title = category == null ? 'Add category' : 'Update category';
    String buttonText = category == null ? 'Add' : 'Update';

    String name = category?['name'] ?? '';
    String description = category?['description'] ?? '';

    final formKey = GlobalKey<FormState>();

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
                        value!.isEmpty ? 'Please enter category name' : null,
                  ),
                  TextFormField(
                    initialValue: description,
                    decoration: InputDecoration(labelText: 'Description'),
                    onChanged: (value) => description = value,
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter description' : null,
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
                  // Add or update the category
                  if (category == null) {
                    await _dbHelper.insertCategory({
                      'name': name,
                      'description': description,
                    });
                  } else {
                    await _dbHelper.updateCategory({
                      'id': category['id'],
                      'name': name,
                      'description': description,
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

  Future<void> _deleteCategory(int id) async {
    await _dbHelper.deleteCategory(id);
    _fetchDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Beauty Store Categories'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Categories: $_numCategories',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _addOrUpdateCategory(),
              child: Text('Add Category'),
            ),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _dbHelper.queryAllCategories(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.data!.isEmpty) {
                    return Center(child: Text('No Category Available'));
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final category = snapshot.data![index];
                      return ListTile(
                        contentPadding: EdgeInsets.all(8.0),
                        title: Text(category['name']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Description: ${category['description']}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () =>
                                  _addOrUpdateCategory(category: category),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => _deleteCategory(category['id']),
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
