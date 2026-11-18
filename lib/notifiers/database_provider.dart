
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/core/databases/app_database.dart';
import 'package:pos_app/core/databases/product_dao.dart';
import 'package:pos_app/notifiers/login_notifiers.dart';
import 'package:pos_app/notifiers/order_notifiers.dart';
import 'package:pos_app/Repository/product_repo.dart';

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

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final productApi = ref.watch(productApiProvider);
  final productDao = ref.watch(productDaoProvider);
  return ProductRepository(remote: productApi, local: productDao);
});

final productRefreshProvider = FutureProvider.autoDispose<void>((ref) async {
  final productRepository = ref.watch(productRepositoryProvider);
  final businessId = ref.read(loginNotifierProvider).value?.business_id;
  if (businessId == null) {
    throw Exception('Business ID is null');
  }
  await productRepository.refreshProducts(businessId);
});