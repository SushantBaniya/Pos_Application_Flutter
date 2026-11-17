import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/notifiers/login_notifiers.dart';
import 'package:pos_app/notifiers/order_notifiers.dart';
import 'package:pos_app/screens/billing_screen.dart';

class CounterDetails extends ConsumerStatefulWidget {
  final int counterId;

  const CounterDetails({super.key, required this.counterId});

  @override
  ConsumerState<CounterDetails> createState() => _CounterDetailsState();
}

class _CounterDetailsState extends ConsumerState<CounterDetails> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) { // Fetch orders for the specific counter after the first frame ie after the widget is built
      final businessId = ref.read(loginNotifierProvider).value?.business_id ?? 0;
      ref.read(fetchOrderNotifierProvider.notifier).fetchOrders(businessId, widget.counterId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(fetchOrderNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Counter ${widget.counterId} Orders'),
      ),
      body: orderState.when(
        data: (orders) {
          if (orders == null || orders.isEmpty) {
            return const Center(child: Text('No orders found for this counter.'));
          }
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return ListTile(
                title: Text('Order ID: ${order.id}'),
                subtitle: Text('Total Amount: \$${order.total_amount.toStringAsFixed(2)}'),
                trailing: SizedBox(
                  width: 100,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to BillingScreen with the order details
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BillingScreen(order: order),
                        ),
                      );
                    },
                    child: const Text('Bill'),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error fetching orders: $error')),
      ),
    );
  }
}
