import 'package:drift/drift.dart';

class Products extends Table{
  IntColumn get id => integer().autoIncrement()(); // The primary key column for local database
  
  IntColumn get serverId => integer().nullable()(); // The product ID column from the API response
  TextColumn get name => text()(); // The product name column
  IntColumn get category => integer().nullable()(); // The product category column
  RealColumn get unitPrice => real()(); // The product unit price column
  TextColumn get costPrice => text().nullable()(); // The product cost price column
  TextColumn get sku => text().nullable()(); // The product SKU column
  IntColumn get businessId => integer()(); // The business ID column
  IntColumn get quantity => integer()(); // The product quantity column
  IntColumn get reorderLevel => integer().nullable()(); // The product reorder level column
  BoolColumn get isLowStock => boolean()(); // The product low stock status column
  TextColumn get description => text().nullable()(); // The product description column
  TextColumn get productImage => text().nullable()(); // The product image column
  DateTimeColumn get createdAt => dateTime()(); // The product creation date column
  DateTimeColumn get updatedAt => dateTime()(); // The product update date column

  BoolColumn get isSynced => boolean().withDefault(const Constant(false))(); // The product sync status column
}