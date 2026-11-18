
import 'package:drift/drift.dart';

import 'package:pos_app/core/databases/app_database.dart';
import 'package:pos_app/core/databases/tables/product_table.dart';
import 'package:pos_app/core/databases/product_dao.dart';
import 'package:pos_app/services/retrofit_all.dart';

class ProductRepository {
  final ProductApi remote;
  final ProductDao local;

  ProductRepository({
    required this.remote,
    required this.local,
  });

  // READ LOCAL PRODUCTS
  Stream<List<Product>> watchProducts() {
    return local.watchProducts();
  }

  // FETCH FROM DJANGO AND SAVE TO SQLITE
  Future<void> refreshProducts(int businessId) async {
    final remoteProducts = await remote.getProducts(businessId); // Replace with the actual business ID

    final localProducts = remoteProducts.map((product) {
      return ProductsCompanion.insert(
        serverId: Value(product.id),
        name: product.name,
        category: Value(product.category),
        unitPrice: product.unit_price,
        costPrice: Value(product.cost_price),
        sku: Value(product.sku),
        businessId: product.business_id,
        quantity: product.quantity,
        reorderLevel: product.reorder_level,
        isLowStock: product.is_low_stock,
        description: Value(product.description),
        productImage: Value(product.product_image),
        createdAt: product.is_created_at,
        updatedAt: product.is_updated_at, 
      );
    }).toList();

    await local.upsertProducts(localProducts);
  }
}
