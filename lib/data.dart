import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DataLoader {
  static const String _tableName = 'plans';
  static const String _databaseName = 'planner.db';
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE $_tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT NOT NULL,
            plan TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<List<String>> loadPlans(DateTime date) async {
    final db = await database;
    final dateKey = _formatDate(date);

    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'date = ?',
      whereArgs: [dateKey],
    );

    return List.generate(maps.length, (i) => maps[i]['plan'] as String);
  }

  Future<void> addPlan({required DateTime date, required String plan}) async {
    final db = await database;
    final dateKey = _formatDate(date);
    print('Adding plan: $plan for date: $dateKey');
    await db.insert(
      _tableName,
      {'date': dateKey, 'plan': plan},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print("Success");
  }

  Future<void> deletePlan({required DateTime date, required String plan}) async {
    print('Deleting plan: $plan for date: $date');
    final db = await database;
    final dateKey = _formatDate(date);

    await db.delete(
      _tableName,
      where: 'date = ? AND plan = ?',
      whereArgs: [dateKey, plan],
    );
  }

  Future<void> clearPlansForDate(DateTime date) async {
    final db = await database;
    final dateKey = _formatDate(date);

    await db.delete(
      _tableName,
      where: 'date = ?',
      whereArgs: [dateKey],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class Cache {
  final Map<DateTime, List<String>> _cache = {};
  final DataLoader _dataLoader = DataLoader();
  static const _kMaxCacheSize = 100;

  Future<List<String>> getPlans(DateTime date) async {
    final dateKey = DateTime(date.year, date.month, date.day);

    if (!_cache.containsKey(dateKey)) {
      final plansFromDb = await _dataLoader.loadPlans(dateKey);
      addToCache(dateKey, plansFromDb);
    }

    return _cache[dateKey] ?? [];
  }

  void addToCache(DateTime date, List<String> plans) {
    if (_cache.length >= _kMaxCacheSize) {
      _cache.remove(_cache.keys.first); // Remove the oldest entry
    }
    _cache[date] = plans;
  }

  void deletePlan(DateTime date, String plan) {
    final dateKey = DateTime(date.year, date.month, date.day);
    print("Deleting plan: $plan for date: $dateKey");
    _cache[dateKey]?.remove(plan);
    _dataLoader.deletePlan(date: dateKey, plan: plan);
  }

  void addPlan(DateTime date, String plan, {int cacheIndex=-1}) {
    final dateKey = DateTime(date.year, date.month, date.day);
    
    if (cacheIndex != -1) {
        print("Deleting old plan for: $plan");
        final oldPlan = _cache[dateKey]?[cacheIndex];
        if (oldPlan != "" && oldPlan != null) {
            print("Removing old plan: $oldPlan");
            _dataLoader.deletePlan(date: dateKey, plan: oldPlan);
            _cache[dateKey]?.remove(oldPlan);
        }
    }
    print('Adding plan to cache: $plan for date: $dateKey');

    _dataLoader.addPlan(date: dateKey, plan: plan);
    if (_cache[dateKey] == null) {
      _cache[dateKey] = [];
    }
    _cache[dateKey]!.add(plan);
  }
}