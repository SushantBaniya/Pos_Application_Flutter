import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/models/order.dart';
import 'package:pos_app/notifiers/providers.dart';
import 'package:pos_app/services/retrofit_all.dart';
import 'package:pos_app/models/product.dart';

class OrderNotifier extends AsyncNotifier<OrderResponse?> {
  @override
  Future<OrderResponse?> build() async {
    return null;
  }

  Future<void> createOrder(Map<String, dynamic> orderData) async {
    state = const AsyncValue.loading();
    try {
      final orderApi = ref.read(orderApiProvider);
      final response = await orderApi.createOrder(orderData);
      state = AsyncValue.data(response);
    } on SocketException catch (e) {
      state = AsyncValue.error('No Internet connection: ${e.message}', StackTrace.current);
    } catch (e) {
      state = AsyncValue.error('Order creation failed: ${e.toString()}', StackTrace.current);
    }
  }
}

final orderNotifierProvider = AsyncNotifierProvider<OrderNotifier, OrderResponse?>(
  () => OrderNotifier(),
);

final orderApiProvider = Provider<OrderApi>((ref) {
  final dio = ref.read(dioClientProvider);
  return OrderApi(dio);
});


final  productApiProvider = Provider<ProductApi>((ref) {
  final dio = ref.read(dioClientProvider);
  return ProductApi(dio);
});

class ProductNotifier extends AsyncNotifier<List<ProductResponse>?> {
  @override
  Future<List<ProductResponse>?> build() async {
    return null;
  }

  Future<void> fetchProducts(int businessId) async {
    state = const AsyncValue.loading();
    try {
      final productApi = ref.read(productApiProvider);
      final response = await productApi.getProducts(businessId);
      state = AsyncValue.data(response);
    } on SocketException catch (e) {
      state = AsyncValue.error('No Internet connection: ${e.message}', StackTrace.current);
    } catch (e) {
      state = AsyncValue.error('Failed to fetch products: ${e.toString()}', StackTrace.current);
    }
  }
}

final productNotifierProvider = AsyncNotifierProvider<ProductNotifier, List<ProductResponse>?>(
  () => ProductNotifier(),
);
