// services/db/db_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('pos_system.db_v2.19');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // users table
    await db.execute(
      """CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        role TEXT NOT NULL
      )""",
    );

    // products table (مع أعمدة التواريخ وحقول الحالة)
    await db.execute(
      """CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        barcode TEXT,
        name TEXT NOT NULL,
        purchase_price REAL NOT NULL,
        selling_price REAL NOT NULL,
        quantity INTEGER NOT NULL,
        units_in_carton INTEGER NOT NULL,
        production_date TEXT,
        expiry_date TEXT,
        low_stock_seen INTEGER NOT NULL DEFAULT 0,
        expiry_seen INTEGER NOT NULL DEFAULT 0
      )""",
    );

    // sales table
    await db.execute(
      """CREATE TABLE sales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        total REAL NOT NULL,
        date TEXT NOT NULL,
        cashier_username TEXT
      )""",
    );

    // sale_items table
    await db.execute(
      """CREATE TABLE sale_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sale_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        price REAL NOT NULL,
        FOREIGN KEY (sale_id) REFERENCES sales(id),
        FOREIGN KEY (product_id) REFERENCES products(id)
      )""",
    );

    // insert default users
    await db.insert('users', {
      'username': 'admin',
      'password': '1234',
      'role': 'admin',
    });

    await db.insert('users', {
      'username': 'cashier',
      'password': '1234',
      'role': 'cashier',
    });
  }

  // ---------------------------------------------------------------------------
  // auth
  Future<Map<String, dynamic>?> login(String username, String password) async {
    final db = await instance.database;
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    if (result.isNotEmpty) return result.first;
    return null;
  }

  Future<int> changePassword(String username, String newPassword) async {
    final db = await instance.database;
    return await db.update(
      'users',
      {'password': newPassword},
      where: 'username = ?',
      whereArgs: [username],
    );
  }

  // ---------------------------------------------------------------------------
  // Products CRUD (insert/update include dates & seen flags)
  Future<int> insertProduct(Map<String, dynamic> product) async {
    final db = await instance.database;
    return await db.insert('products', {
      'barcode': product['barcode'] ?? '',
      'name': product['name'] ?? '',
      'purchase_price': (product['purchase_price'] ?? 0).toDouble(),
      'selling_price': (product['selling_price'] ?? 0).toDouble(),
      'units_in_carton': product['units_in_carton'] ?? 0,
      'quantity': product['quantity'] ?? 0,
      'production_date': product['production_date'] ?? '',
      'expiry_date': product['expiry_date'] ?? '',
      'low_stock_seen': product['low_stock_seen'] ?? 0,
      'expiry_seen': product['expiry_seen'] ?? 0,
    });
  }

  Future<List<Map<String, dynamic>>> getAllProducts() async {
    final db = await instance.database;
    final products = await db.query('products', orderBy: 'name');

    return products.map((product) {
      final quantity = product['quantity'] as int;
      final unitsInCarton = product['units_in_carton'] as int;
      return {
        ...product,
        'total_units': quantity * unitsInCarton, // عدد الوحدات الكلي
      };
    }).toList();
  }

  Future<int> updateProduct(Map<String, dynamic> product) async {
    final db = await instance.database;
    return await db.update(
      'products',
      {
        'barcode': product['barcode'],
        'name': product['name'],
        'purchase_price': product['purchase_price'],
        'selling_price': product['selling_price'],
        'units_in_carton': product['units_in_carton'],
        'quantity': product['quantity'],
        'production_date': product['production_date'],
        'expiry_date': product['expiry_date'],
        // لا نغيّر flags هنا تلقائياً — يمكنك التحكم فيها بعد الحفظ إذا أردت
      },
      where: 'id = ?',
      whereArgs: [product['id']],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await instance.database;
    return await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<String, dynamic>?> getProductByBarcode(String barcode) async {
    final db = await instance.database;
    final res = await db.query('products', where: 'barcode = ?', whereArgs: [barcode], limit: 1);
    if (res.isNotEmpty) {
      final product = res.first;
      product['total_units'] = (product['quantity'] as int) * (product['units_in_carton'] as int);
      return product;
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // utility profit
  double calculateTotalProfit({
    required double cartonPurchasePrice,
    required double unitSellingPrice,
    required int unitsInCarton,
    required int cartonsQuantity,
  }) {
    double totalSelling = unitSellingPrice * unitsInCarton * cartonsQuantity;
    double totalPurchase = cartonPurchasePrice * cartonsQuantity;
    return totalSelling - totalPurchase;
  }

  // ---------------------------------------------------------------------------
  // Low stock (existing behavior)
  Future<int> getLowStockUnseenCount() async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM products WHERE quantity < ? AND COALESCE(low_stock_seen, 0) = 0',
      [5],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<List<Map<String, dynamic>>> getLowStockUnseenProducts() async {
    final db = await instance.database;
    final rows = await db.rawQuery(
      'SELECT *, COALESCE(low_stock_seen, 0) as low_stock_seen FROM products WHERE quantity < ? AND COALESCE(low_stock_seen, 0) = 0 ORDER BY quantity ASC',
      [5],
    );
    return rows;
  }

  Future<int> setProductLowStockSeen(int productId, bool seen) async {
    final db = await instance.database;
    return await db.update(
      'products',
      {'low_stock_seen': seen ? 1 : 0},
      where: 'id = ?',
      whereArgs: [productId],
    );
  }

  Future<int> markAllLowStockSeen() async {
    final db = await instance.database;
    return await db.update(
      'products',
      {'low_stock_seen': 1},
      where: 'quantity < ?',
      whereArgs: [5],
    );
  }

  // ---------------------------------------------------------------------------
  // Expiry (قرب الانتهاء) - new methods
  Future<void> ensureProductDatesColumns() async {
    final db = await instance.database;

    final cols = await db.rawQuery("PRAGMA table_info(products);");

    if (!cols.any((c) => c['name'] == 'production_date')) {
      await db.execute('ALTER TABLE products ADD COLUMN production_date TEXT;');
    }

    if (!cols.any((c) => c['name'] == 'expiry_date')) {
      await db.execute('ALTER TABLE products ADD COLUMN expiry_date TEXT;');
    }
  }

  Future<void> ensureExpirySeenColumn() async {
    final db = await instance.database;
    final cols = await db.rawQuery("PRAGMA table_info(products);");
    final hasColumn = cols.any((c) => c['name'] == 'expiry_seen');

    if (!hasColumn) {
      await db.execute('ALTER TABLE products ADD COLUMN expiry_seen INTEGER NOT NULL DEFAULT 0;');
      await db.update('products', {'expiry_seen': 0});
    }
  }

  Future<int> getExpiringUnseenCount({required int daysThreshold}) async {
    final db = await instance.database;
    final now = DateTime.now();
    final thresholdDate = now.add(Duration(days: daysThreshold));
    final thresholdStr = thresholdDate.toIso8601String().split('T').first;

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM products WHERE expiry_date IS NOT NULL AND expiry_date != ? AND expiry_date <= ? AND COALESCE(expiry_seen, 0) = 0',
      ['', thresholdStr],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<List<Map<String, dynamic>>> getExpiringUnseenProducts({required int daysThreshold}) async {
    final db = await instance.database;
    final now = DateTime.now();
    final thresholdDate = now.add(Duration(days: daysThreshold));
    final thresholdStr = thresholdDate.toIso8601String().split('T').first;

    final rows = await db.rawQuery(
      'SELECT *, COALESCE(expiry_seen, 0) as expiry_seen FROM products WHERE expiry_date IS NOT NULL AND expiry_date != ? AND expiry_date <= ? AND COALESCE(expiry_seen, 0) = 0 ORDER BY expiry_date ASC',
      ['', thresholdStr],
    );
    return rows;
  }

  Future<int> setProductExpirySeen(int productId, bool seen) async {
    final db = await instance.database;
    return await db.update(
      'products',
      {'expiry_seen': seen ? 1 : 0},
      where: 'id = ?',
      whereArgs: [productId],
    );
  }

  Future<int> markAllExpirySeen({required int daysThreshold}) async {
    final db = await instance.database;
    final now = DateTime.now();
    final thresholdDate = now.add(Duration(days: daysThreshold));
    final thresholdStr = thresholdDate.toIso8601String().split('T').first;

    return await db.rawUpdate(
      'UPDATE products SET expiry_seen = 1 WHERE expiry_date IS NOT NULL AND expiry_date != ? AND expiry_date <= ?',
      ['', thresholdStr],
    );
  }

  // ---------------------------------------------------------------------------
  // Ensure low_stock_seen exists (migration helper)
  Future<void> ensureLowStockSeenColumn() async {
    final db = await instance.database;
    final cols = await db.rawQuery("PRAGMA table_info(products);");
    final hasColumn = cols.any((c) => c['name'] == 'low_stock_seen');

    if (!hasColumn) {
      await db.execute('ALTER TABLE products ADD COLUMN low_stock_seen INTEGER NOT NULL DEFAULT 0;');
      await db.update('products', {'low_stock_seen': 0});
    }
  }
}
