
import 'package:drift/drift.dart';

import 'app_database.dart';
import 'tables/product_table.dart';

part 'product_DAO.g.dart';

@DriftAccessor(tables: [Products])
class ProductDao extends DatabaseAccessor<AppDatabase>
    with _$ProductDaoMixin {

  ProductDao(super.db);

  // READ: Observe all products
  Stream<List<Product>> watchProducts(int businessId) {
    return (select(products)..where((tbl) => tbl.businessId.equals(businessId))).watch();
  }

  // READ: Find product using Django ID
  Future<Product?> getByServerId(int serverId) {
    return (select(products)
          ..where((tbl) => tbl.serverId.equals(serverId)))
        .getSingleOrNull();
  }

  // INSERT OR UPDATE
  Future<void> upsertProducts(
    List<ProductsCompanion> items,
  ) async {
    await transaction(() async {
      for (final item in items) {
        final serverId = item.serverId.value;

        if (serverId == null) {
          throw ArgumentError(
            'Server ID is required for remote products',
          );
        }

        final existing = await getByServerId(serverId);

        if (existing != null) {
          // Update existing local record
          await (update(products)
                ..where((tbl) => tbl.id.equals(existing.id)))
              .write(item);
        } else {
          // Insert new local record
          await into(products).insert(item);
        }
      }
    });
  }

  // DELETE
  Future<int> deleteProduct(int id) {
    return (delete(products)
          ..where((tbl) => tbl.id.equals(id)))
        .go();
  }
}
