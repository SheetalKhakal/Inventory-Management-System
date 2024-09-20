import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final _databaseName = "beauty_store.db";
  static final _databaseVersion = 1;

  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('inventory.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        sku TEXT NOT NULL,
        category TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        primary_image TEXT,
        description TEXT NOT NULL,
        price REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE categories (
      id INTEGER PRIMARY KEY,
      name TEXT NOT NULL,
      description TEXT NOT NULL
    )
    ''');

    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY,
        username TEXT NOT NULL,
        email TEXT NOT NULL,
        phone TEXT NOT NULL,
        password TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE actions_history (
        id INTEGER PRIMARY KEY,
        user_id INTEGER NOT NULL,
        action TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');
  }

  // Insert a new categoryFuture<int> insertCategory(Map<String, dynamic> category) async {
  Future<int> insertCategory(Map<String, dynamic> category) async {
    try {
      Database db = await instance.database;

      // Log the category data for debugging
      print('Inserting category: $category');

      return await db.insert('categories', category);
    } catch (e) {
      print('Error inserting category: $e');
      return -1; // Return -1 if there's an error
    }
  }

  // Update an existing category
  Future<int> updateCategory(Map<String, dynamic> category) async {
    Database db = await instance.database;
    return await db.update(
      'categories',
      category,
      where: 'id = ?',
      whereArgs: [category['id']],
    );
  }

  // Delete a category
  Future<int> deleteCategory(int id) async {
    Database db = await instance.database;
    return await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

// Fetch all categories
  Future<List<Map<String, dynamic>>> fetchCategories() async {
    Database db = await instance.database;
    return await db.query('categories');
  }

  Future<int> insertProduct(Map<String, dynamic> product) async {
    Database db = await instance.database;
    return await db.insert('products', product);
  }

  Future<void> logUserAction(int userId, String action) async {
    Database db = await instance.database;
    await db.insert('actions_history', {
      'user_id': userId,
      'action': action,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> queryUserActions(int userId) async {
    Database db = await instance.database;
    return await db
        .query('actions_history', where: 'user_id = ?', whereArgs: [userId]);
  }

  Future<List<Map<String, dynamic>>> queryAllProducts() async {
    Database db = await instance.database;
    return await db.query('products');
  }

  Future<List<Map<String, dynamic>>> queryAllCategories() async {
    Database db = await instance.database;
    return await db.query('categories');
  }

  Future<List<Map<String, dynamic>>> queryAllUsers() async {
    Database db = await instance.database;
    return await db.query('users');
  }

  Future<List<Map<String, dynamic>>> queryLowInventoryProducts() async {
    Database db = await instance.database;
    return await db.query('products', where: 'quantity < ?', whereArgs: [10]);
  }

  // database_helper.dart

  Future<int> insertUser(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert('users', row);
  }

  Future<Map<String, dynamic>?> queryUserByEmail(String email) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> result =
        await db.query('users', where: 'email = ?', whereArgs: [email]);

    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateProduct(Map<String, dynamic> product) async {
    Database db = await instance.database;
    return await db.update('products', product,
        where: 'id = ?', whereArgs: [product['id']]);
  }

  Future<int> deleteProduct(int id) async {
    Database db = await instance.database;
    return await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }
}
