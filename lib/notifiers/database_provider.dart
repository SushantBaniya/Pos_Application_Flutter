
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/core/databases/app_database.dart';
import 'package:pos_app/core/databases/product_DAO.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  
  ref.onDispose(() {
    database.close();
  });
  
  return database; 
});

final productDaoProvider = Provider<ProductDao>((ref) {
  final database = ref.watch(databaseProvider);
  return ProductDao(database);
});

final localProductProvider = StreamProvider.autoDispose<List<Product>>((ref) {
  final productDao = ref.watch(productDaoProvider);
  return productDao.watchProducts();
});