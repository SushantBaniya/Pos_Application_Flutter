import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/models/order.dart';

final custORCounterNotifierProvider = AsyncNotifierProvider<CustORCounterNotifier, OrderTarget?>(() => CustORCounterNotifier());

class CustORCounterNotifier extends AsyncNotifier<OrderTarget?> {
  @override
  Future<OrderTarget?> build() async {
    return null;
  }
  Future<void> setId(int? customerId, int? counterId) async {
    state = const AsyncValue.loading();
    try {
      final orderTarget = OrderTarget(customerId: customerId, counterId: counterId);
      state = AsyncValue.data(orderTarget);
    } catch (e) {
      state = AsyncValue.error('Failed to set customer or counter ID: ${e.toString()}', StackTrace.current);
    }
  }
}