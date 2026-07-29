import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/transaction.dart' as model;
import '../models/category.dart';
import '../models/user.dart';

/// Single point of access to the local SQLite database.
/// A singleton keeps one open connection for the whole app instead
/// of re-opening the database on every screen.
class DatabaseService {
  DatabaseService._internal();
  static final DatabaseService instance = DatabaseService._internal();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'fintrack.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            email TEXT UNIQUE NOT NULL,
            password TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE categories (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            icon TEXT,
            type TEXT CHECK(type IN ('income','expense'))
          )
        ''');

        await db.execute('''
          CREATE TABLE transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER,
            category_id INTEGER,
            amount REAL NOT NULL,
            type TEXT CHECK(type IN ('income','expense')),
            date TEXT NOT NULL,
            note TEXT,
            receipt_path TEXT,
            FOREIGN KEY (user_id) REFERENCES users(id),
            FOREIGN KEY (category_id) REFERENCES categories(id)
          )
        ''');

        // Seed a sensible set of default categories so the app is
        // usable immediately after install, before the user adds
        // any custom ones of their own.
        const defaultCategories = [
          {'name': 'Food', 'icon': 'utensils', 'type': 'expense'},
          {'name': 'Transport', 'icon': 'car', 'type': 'expense'},
          {'name': 'Shopping', 'icon': 'bag', 'type': 'expense'},
          {'name': 'Bills', 'icon': 'bills', 'type': 'expense'},
          {'name': 'Health', 'icon': 'health', 'type': 'expense'},
          {'name': 'Other', 'icon': 'other', 'type': 'expense'},
          {'name': 'Salary', 'icon': 'briefcase', 'type': 'income'},
          {'name': 'Business', 'icon': 'briefcase', 'type': 'income'},
          {'name': 'Gift', 'icon': 'gift', 'type': 'income'},
        ];
        for (final category in defaultCategories) {
          await db.insert('categories', category);
        }
      },
    );
  }

  // ---------- USER ----------
  Future<int> insertUser(AppUser user) async {
    final db = await database;
    // Normalise the email so a user can't accidentally register twice
    // with different casing, and so login isn't case-sensitive.
    final normalized = AppUser(
      name: user.name,
      email: user.email.trim().toLowerCase(),
      password: user.password,
    );
    return db.insert('users', normalized.toMap());
  }

  Future<AppUser?> getUserByEmail(String email) async {
    final db = await database;
    final rows = await db.query('users',
        where: 'email = ?', whereArgs: [email.trim().toLowerCase()]);
    if (rows.isEmpty) return null;
    return AppUser.fromMap(rows.first);
  }

  // ---------- CATEGORY ----------
  Future<int> insertCategory(Category category) async {
    final db = await database;
    return db.insert('categories', category.toMap());
  }

  Future<List<Category>> getCategories() async {
    final db = await database;
    final rows = await db.query('categories');
    return rows.map((row) => Category.fromMap(row)).toList();
  }

  // ---------- TRANSACTION ----------
  Future<int> insertTransaction(model.Transaction transaction) async {
    final db = await database;
    return db.insert('transactions', transaction.toMap());
  }

  Future<List<model.Transaction>> getTransactions(int userId) async {
    final db = await database;
    final rows = await db.query(
      'transactions',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
    return rows.map((row) => model.Transaction.fromMap(row)).toList();
  }

  Future<int> updateTransaction(model.Transaction transaction) async {
    final db = await database;
    return db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }
}