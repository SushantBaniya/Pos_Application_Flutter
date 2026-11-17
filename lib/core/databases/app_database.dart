import 'package:drift/drift.dart';
import 'tables/product_table.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'dart:io';


part 'app_database.g.dart';

@DriftDatabase(tables: [Products])

class AppDatabase extends _$AppDatabase {
  AppDatabase(): super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() { // lazy database connection to ensure the database is only opened when needed or first accessed, improving performance and resource usage.
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory(); // Get the application documents directory to store the database file
    final file = File(p.join(dbFolder.path, 'pasale.db')); // Create a file path for the database file named 'pasale.db' in the application documents directory
    return NativeDatabase(file); // Create a NativeDatabase instance using the file path, which will be used to interact with the database
  });
}