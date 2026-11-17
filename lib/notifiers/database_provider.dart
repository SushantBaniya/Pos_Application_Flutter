
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/core/databases/app_database.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  
  ref.onDispose(() {
    database.close();
  });
  
  return database; 
});