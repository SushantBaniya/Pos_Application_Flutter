import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/Screens/home_screen.dart';
import 'package:pos_app/Screens/product_screen.dart';
import 'package:pos_app/Screens/counter_screen.dart';
import 'package:pos_app/Screens/billing_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/models/login.dart';
import 'package:pos_app/notifiers/login_notifiers.dart';
import 'package:flutter/cupertino.dart';
import 'package:pos_app/models/order.dart';
import 'package:pos_app/models/product.dart';
import 'package:pos_app/notifiers/home_screen_notifiers.dart';
import 'package:pos_app/notifiers/order_notifiers.dart';

class Options extends Notifier<int> {
  @override
  int build() {
    return 0; // Default selected index
  }

  void setSelectedIndex(int index) {
    state = index;
  }
}

final optionsProvider = NotifierProvider<Options, int>(Options.new);

class NavBar extends ConsumerStatefulWidget {
  const NavBar({super.key});

  @override
  ConsumerState<NavBar> createState() => _NavBarState();
}

class _NavBarState extends ConsumerState<NavBar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _widgetOptions = <Widget>[
      const HomeScreen(),
      const ProductScreen(),
      const CounterScreen(),
      const BillingScreen(),
    ];

    return Scaffold(
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.countertops),
            label: 'Counters',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Billing',
          ),
        ],
        currentIndex: _selectedIndex,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.white,
        backgroundColor: Color(0xFF101B55),
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Future<List<OrderResponse>>? _ordersFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final businessId = ref.read(loginNotifierProvider).value?.business_id;
      if (businessId != null) {
        ref.read(productNotifierProvider.notifier).fetchProducts(businessId);
        setState(() {
          _ordersFuture = ref.read(orderApiProvider).getOrders(businessId);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginNotifierProvider);
    final productState = ref.watch(productNotifierProvider);
    final products = productState.value ?? <ProductResponse>[];
    final lowStockProducts = products.where((product) =>
        product.is_low_stock || product.quantity <= product.reorder_level).toList();
    final inventoryValue = products.fold<double>(0, (total, product) =>
        total + ((double.tryParse(product.cost_price ?? '') ?? product.unit_price) * product.quantity));
    final now = DateTime.now();
    final user =
        loginState.value?.user; // Access the user object from the login state
    final month = const [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ][now.month - 1];
    final weekday = const [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
    ][now.weekday - 1];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      body: SafeArea(
        child: FutureBuilder<List<OrderResponse>>(
          future: _ordersFuture,
          builder: (context, orderSnapshot) {
            final orders = orderSnapshot.data ?? <OrderResponse>[];
            final currentMonthOrders = orders.where((item) =>
                item.order.order_date.year == now.year &&
                item.order.order_date.month == now.month).toList();
            final sales = currentMonthOrders.fold<double>(
                0, (total, item) => total + item.order.total_amount);
            final pendingCount = orders.where((item) =>
                (item.order.status ?? '').toLowerCase() == 'pending').length;
            final recentOrders = [...orders]
              ..sort((a, b) => b.order.order_date.compareTo(a.order.order_date));
            return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${weekday.toUpperCase()}, ${month.toUpperCase()} ${now.day}', style: const TextStyle(fontSize: 14, color: Color(0xFF718096))),
                  const SizedBox(height: 5),
                  Text('Hello, ${user?.username ?? "User"}!', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF101B55))),
                  const SizedBox(height: 2),
                  const Text("Here's your business overview", style: TextStyle(fontSize: 14, color: Color(0xFF718096))),
                ])),
                Container(width: 52, height: 52, decoration: const BoxDecoration(color: Color(0xFFEEF4FF), shape: BoxShape.circle), child: const Icon(Icons.person_outline, color: Color(0xFF2463EB), size: 27)),
              ]),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFFEEF5FF), borderRadius: BorderRadius.circular(16)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('TOTAL SALES', style: TextStyle(color: Color(0xFF174CE6), fontSize: 14, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Text('Rs. ${sales.toStringAsFixed(2)}', style: const TextStyle(fontSize: 29, fontWeight: FontWeight.w600, color: Color(0xFF101B55))),
                  const SizedBox(height: 4),
                  Text('$month ${now.year}', style: const TextStyle(color: Color(0xFF718096), fontSize: 14)),
                ]),
              ),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: _DashboardMetric(icon: Icons.shopping_cart_outlined, color: Color(0xFF00A66C), label: 'Purchase', value: '--')),
                SizedBox(width: 10),
                Expanded(child: _DashboardMetric(icon: Icons.inventory_2_outlined, color: Color(0xFF2463EB), label: 'Inventory', value: inventoryValue.toStringAsFixed(2))),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: _DashboardMetric(icon: Icons.layers_outlined, color: Color(0xFF9B27F5), label: 'Total Orders', value: '${orders.length}')),
                const SizedBox(width: 10),
                Expanded(child: _DashboardMetric(icon: Icons.access_time, color: Color(0xFFFF7900), label: 'Pending', value: '$pendingCount')),
              ]),
              const SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Recent Orders', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                TextButton(onPressed: () {}, child: const Text('View all')),
              ]),
              const SizedBox(height: 2),
              if (orderSnapshot.connectionState == ConnectionState.waiting)
                _dashboardPanel(const Center(child: CircularProgressIndicator()))
              else if (orderSnapshot.hasError)
                _dashboardPanel(Text('Could not load orders: ${orderSnapshot.error}', style: const TextStyle(color: Color(0xFF718096))))
              else if (recentOrders.isEmpty)
                _dashboardPanel(const Text('No orders found', style: TextStyle(fontSize: 16, color: Color(0xFF718096))))
              else
                ListView.builder(
                  itemCount: recentOrders.length > 3 ? 3 : recentOrders.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final order = recentOrders[index].order;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _dashboardPanel(Row(children: [
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(order.customer_name ?? 'Order #${order.id}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                          const SizedBox(height: 4),
                          Text(order.status ?? 'Order', style: const TextStyle(color: Color(0xFF718096), fontSize: 13)),
                        ])),
                        Text('Rs. ${order.total_amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                      ])),
                    );
                  },
                ),
              const SizedBox(height: 18),
              const Text('Stock Alerts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              if (productState.isLoading)
                _dashboardPanel(const Center(child: CircularProgressIndicator()))
              else if (productState.hasError)
                _dashboardPanel(Text('Could not load stock: ${productState.error}', style: const TextStyle(color: Color(0xFF718096))))
              else if (lowStockProducts.isEmpty)
                _dashboardPanel(const Text('No stock alerts', style: TextStyle(color: Color(0xFF718096))))
              else
                ListView.builder(
                  itemCount: lowStockProducts.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final product = lowStockProducts[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _dashboardPanel(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(product.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: const Color(0xFFFFEBEB), borderRadius: BorderRadius.circular(20)), child: Text('${product.quantity} left', style: const TextStyle(color: Color(0xFFE53935), fontSize: 13))),
                ]),
                const SizedBox(height: 8),
                const Text('Low stock alert: Reorder required', style: TextStyle(color: Color(0xFFFF4A4A), fontSize: 14)),
                      ])),
                    );
                  },
                ),
            ],
          ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final businessId = ref.read(loginNotifierProvider).value?.business_id;
          if (businessId == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Business information is unavailable. Please sign in again.',
                ),
              ),
            );
            return;
          }
          ref.read(counterNotifierProvider.notifier).fetchCounters(businessId);
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => SizedBox(
              height: MediaQuery.of(context).size.height * 0.48,
              child: const AddProduct(),
            ),
          );
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Item',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF101B55),
      ),
    );
  }
}

Widget _dashboardPanel(Widget child) => Container(
  width: double.infinity,
  padding: const EdgeInsets.all(15),
  decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFE1E4E8)), borderRadius: BorderRadius.circular(16)),
  child: child,
);

class _DashboardMetric extends StatelessWidget {
  const _DashboardMetric({required this.icon, required this.color, required this.label, required this.value});
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
    height: 130,
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFE1E4E8)), borderRadius: BorderRadius.circular(16)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: color, size: 22),
      const SizedBox(height: 12),
      Text(label, style: const TextStyle(color: Color(0xFF718096), fontSize: 14)),
      const Spacer(),
      Text(value, style: const TextStyle(color: Color(0xFF101B55), fontSize: 22, fontWeight: FontWeight.w600)),
    ]),
  );
}

class AddProduct extends ConsumerStatefulWidget {
  const AddProduct({super.key});

  @override
  ConsumerState<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends ConsumerState<AddProduct> {
  int? target1;
  int? target2;
  final TextEditingController _customerNameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final counterAsync = ref.watch(counterNotifierProvider);
    final tab = ref.watch(optionsProvider);
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            'Add Product',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text('Enter product details below:', style: TextStyle(fontSize: 16)),
          const Divider(height: 20, thickness: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                TextField(
                  controller: _customerNameController,
                  decoration: const InputDecoration(
                    labelText: 'Customer Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: CupertinoSlidingSegmentedControl<int>(
                    groupValue: ref.watch(optionsProvider),
                    children: const {0: Text('Customer'), 1: Text('Counter')},
                    onValueChanged: (int? value) {
                      if (value != null) {
                        ref
                            .read(optionsProvider.notifier)
                            .setSelectedIndex(value);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 20),
                tab == 0
                    ? TextField(
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                      )
                    : counterAsync.when(
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (error, stack) => Center(
                          child: Text('Could not load counters: $error'),
                        ),
                        data: (counters) {
                          final counterList = counters ?? const [];
                          return DropdownButtonFormField<int>(
                            decoration: const InputDecoration(
                              labelText: 'Select Counter',
                              border: OutlineInputBorder(),
                            ),
                            items: counterList.map((counter) {
                              return DropdownMenuItem<int>(
                                value: counter.id,
                                child: Text(
                                  counter.counter_number?.toString() ??
                                      'Unknown Counter',
                                ),
                              );
                            }).toList(),
                            onChanged: (int? value) {
                              setState(() {
                                target2 = value;
                              });
                            },
                          );
                        },
                      ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    final businessId = ref
                        .read(loginNotifierProvider)
                        .value
                        ?.business_id;
                    if (businessId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Business information is unavailable. Please sign in again.',
                          ),
                        ),
                      );
                      return;
                    }
                    if (tab == 0) {
                      target1 = int.tryParse(_customerNameController.text);
                      ref
                          .read(custORCounterNotifierProvider.notifier)
                          .setId(target1 ?? 0, null);
                      if (target1 == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Please enter a valid customer name.',
                            ),
                          ),
                        );
                        return;
                      }
                    } else {
                      if (target2 == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select a valid counter.'),
                          ),
                        );
                        return;
                      }
                      ref
                          .read(custORCounterNotifierProvider.notifier)
                          .setId(null, target2 ?? 0);
                    }
                    showModalBottomSheet(
                      isScrollControlled: true,
                      context: context,
                      builder: (context) => SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        width: double.infinity,
                        child: const AddCart(),
                      ),
                    );
                    ref
                        .read(productNotifierProvider.notifier)
                        .fetchProducts(businessId);
                  },
                  child: const Text(
                    'Submit',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

extension on AsyncValue<LoginResponse?> {
  get valueOrNull => null;
}

class AddCart extends ConsumerStatefulWidget {
  const AddCart({super.key});

  @override
  ConsumerState<AddCart> createState() => _AddCartState();
}

class _AddCartState extends ConsumerState<AddCart> {
  @override
  Widget build(BuildContext context) {
    final productsAsyncValue = ref.watch(productNotifierProvider);
    final target = ref.watch(custORCounterNotifierProvider);
    final cart = ref.watch(cartNotifierProvider);
    final products = productsAsyncValue.value ?? const <ProductResponse>[];
    final productsById = {for (final product in products) product.id: product};
    final cartTotal = cart.entries.fold<double>(0.0, (total, entry) {
      final product = productsById[entry.key];
      return total + (product?.unit_price ?? 0.0) * entry.value;
    });
    final orderState = ref.watch(orderNotifierProvider);
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final cartWidth = (constraints.maxWidth * 0.30)
              .clamp(180.0, 390.0)
              .toDouble();

          return Column(
            children: [
              // Compact menu header to fit the existing half-height sheet.
              SizedBox(
                height: 48,
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Add Products to Cart',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close',
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                            child: SizedBox(
                              height: 44,
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Search for Products...',
                                  prefixIcon: const Icon(Icons.search),
                                  contentPadding: EdgeInsets.zero,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: productsAsyncValue.when(
                              loading: () => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              error: (error, stack) => Center(
                                child: Text('Could not load products: $error'),
                              ),
                              data: (products) {
                                final productList = products ?? const [];
                                return GridView.builder(
                                  itemCount: productList.length,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 8,
                                        mainAxisSpacing: 8,
                                        childAspectRatio: 0.9,
                                      ),
                                  itemBuilder: (context, index) {
                                    final product = productList[index];

                                    return Card(
                                      child: InkWell(
                                        onTap: () {
                                          ref
                                              .read(
                                                cartNotifierProvider.notifier,
                                              )
                                              .addProduct(product);
                                        },
                                        child: Column(
                                          children: [
                                            Expanded(
                                              child:
                                                  product.product_image.isEmpty
                                                  ? const Icon(
                                                      Icons.inventory_2,
                                                    )
                                                  : Image.network(
                                                      product.product_image,
                                                      errorBuilder: (_, _, _) =>
                                                          const Icon(
                                                            Icons.inventory_2,
                                                          ),
                                                    ),
                                            ),
                                            Text(product.name),
                                            Text(
                                              'Rs. ${product.unit_price.toStringAsFixed(2)}',
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const VerticalDivider(width: 1),
                    SizedBox(
                      width: cartWidth,
                      child: Column(
                        children: [
                          ListTile(
                            dense: true,
                            title: Text(
                              'Cart',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const Divider(height: 1),
                          Expanded(
                            child: cart.isEmpty
                                ? const Center(
                                    child: Text(
                                      'No items added yet',
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                : ListView(
                                    children: cart.entries.map((entry) {
                                      final product = productsById[entry.key];
                                      if (product == null) {
                                        return const SizedBox.shrink();
                                      }
                                      return ListTile(
                                        dense: true,
                                        title: Text(product.name),
                                        subtitle: Text(
                                          '${entry.value} x Rs. ${product.unit_price.toStringAsFixed(2)}',
                                        ),
                                        trailing: Text(
                                          'Rs. ${(product.unit_price * entry.value).toStringAsFixed(2)}',
                                        ),
                                      );
                                    }).toList(),
                                  ),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            dense: true,
                            title: Text(
                              'Total:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            trailing: Text(
                              'Rs. ${cartTotal.toStringAsFixed(2)}',
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: SizedBox(
                              width: double.infinity,
                              height: 42,
                              child: ElevatedButton(
                                onPressed: () {
                                  final businessId = ref
                                      .read(loginNotifierProvider)
                                      .value
                                      ?.business_id;
                                  if (businessId == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Business information is unavailable. Please sign in again.',
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  final orderTarget = target.value;
                                  if (orderTarget == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Please select a customer or counter before proceeding.',
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  final items = ref
                                      .read(cartNotifierProvider.notifier)
                                      .toOrderItems();
                                  ref
                                      .read(orderNotifierProvider.notifier)
                                      .createOrder(
                                        OrderRequest(
                                          customer_id: orderTarget.customerId,
                                          counter_id: orderTarget.counterId,
                                          total_amount: cartTotal,
                                          tax: 0.0,
                                          discount: 0.0,
                                          items: items,
                                        ),
                                        businessId,
                                      );
                                  orderState.whenData((order) {
                                    if (order != null) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Order created successfully!',
                                              ),
                                            ),
                                          );
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const CounterScreen(),
                                        ),
                                      );
                                    }
                                  });
                                },
                                child: const Text('Add to Cart'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
