import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/models/login.dart';
import 'package:pos_app/notifiers/login_notifiers.dart';
import 'package:flutter/cupertino.dart';
import 'package:pos_app/models/order.dart';
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

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginNotifierProvider);
    final user =
        loginState.value?.user; // Access the user object from the login state

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(Icons.account_circle, size: 30),
            const SizedBox(width: 10),
            Text('${user?.username ?? "User"}', style: TextStyle(fontSize: 20)),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                // Handle logout logic here
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/second');
              },
              child: const Text('Go to Second Screen'),
            ),
          ),
        ],
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
        backgroundColor: Color(0xFF101B55),
      ),
    );
  }
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
                        loading: () => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        error: (error, stack) => Center(
                          child: Text('Could not load counters: $error'),
                        ),
                        data: (counters) {
                          final counterList = counters ?? const [];
                          return DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Select Counter',
                              border: OutlineInputBorder(),
                            ),
                            items: counterList.map((counter) {
                              return DropdownMenuItem<String>(
                                value: counter.counter_number.toString(),
                                child: Text(counter.counter_number.toString()),
                              );
                            }).toList(),
                            initialValue: target2 != null
                                ? counterList
                                    .firstWhere(
                                        (counter) => counter.id == target2)
                                    .counter_number
                                    .toString()
                                : null,
                            onChanged: (value) {
                              target2 = value == 'Counter 1'
                                  ? 1
                                  : value == 'Counter 2'
                                      ? 2
                                      : value == 'Counter 3'
                                          ? 3
                                          : null;
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
                            content: Text(
                              'Please select a valid counter.',
                            ),
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
                                      child: Column(
                                        children: [
                                          Expanded(
                                            child: product.product_image.isEmpty
                                                ? const Icon(Icons.inventory_2)
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
                          const ListTile(
                            dense: true,
                            title: Text(
                              'Cart',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const Divider(height: 1),
                          const Expanded(
                            child: Center(
                              child: Text(
                                'No items added yet',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          const Divider(height: 1),
                          const ListTile(
                            dense: true,
                            title: Text(
                              'Total:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            trailing: Text('Rs. 0.00'),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: SizedBox(
                              width: double.infinity,
                              height: 42,
                              child: ElevatedButton(
                                onPressed: null,
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
