import 'package:drift/drift.dart';

import 'app_database.dart';
import 'tables/product_table.dart';

part 'product_DAO.g.dart';

@DriftAccessor(tables: [Products])
class ProductDao extends DatabaseAccessor<AppDatabase> with _$ProductDaoMixin {
  ProductDao(super.db);

  // CREATE
  Future<int> insertProduct(ProductsCompanion product) {
    return into(db.products).insert(product);
  }

  // READ
  Stream<List<Product>> watchProducts() {
    return select(db.products).watch();
  }

  // READ ONE
  Future<Product?> getProduct(int id) {
    return (select(
      db.products,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  // UPDATE
  Future<bool> updateProduct(Product product) {
    return update(db.products).replace(product);
  }

  // DELETE
  Future<int> deleteProduct(int id) {
    return (delete(db.products)..where((tbl) => tbl.id.equals(id))).go();
  }
}
