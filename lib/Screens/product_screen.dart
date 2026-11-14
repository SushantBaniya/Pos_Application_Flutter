import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/notifiers/login_notifiers.dart';
import 'package:pos_app/notifiers/order_notifiers.dart';
import 'package:pos_app/models/product.dart';

class ProductScreen extends ConsumerStatefulWidget {
  const ProductScreen({super.key});

  @override
  ConsumerState<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends ConsumerState<ProductScreen> {
  void _showCreateProductDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final costController = TextEditingController();
    final categoryController = TextEditingController();
    final skuController = TextEditingController();
    final quantityController = TextEditingController();
    final reorderController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Product'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Product name'),
              ),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Unit price'),
              ),
              TextField(
                controller: costController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Cost price'),
              ),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              TextField(
                controller: skuController,
                decoration: const InputDecoration(labelText: 'SKU'),
              ),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantity'),
              ),
              TextField(
                controller: reorderController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Reorder level'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final businessId =
                  ref.read(loginNotifierProvider).value?.business_id ?? 0;
              if (businessId == 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Business ID is not available.'),
                  ),
                );
                return;
              }

              ref
                  .read(productNotifierProvider.notifier)
                  .createProduct(
                    businessId,
                    ProductRequest(
                      product_name: nameController.text,
                      unit_price: double.tryParse(priceController.text) ?? 0.0,
                      category: int.tryParse(categoryController.text) ?? 0,
                      cost_price: costController.text,
                      sku: skuController.text,
                      quantity: int.tryParse(quantityController.text) ?? 0,
                      reorder_level: int.tryParse(reorderController.text) ?? 0,
                      description: descriptionController.text,
                    ),
                  );
              Navigator.pop(context);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final businessId = ref.read(loginNotifierProvider).value?.business_id;

      if (businessId != null) {
        ref.read(productNotifierProvider.notifier).fetchProducts(businessId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.arrow_back, color: Colors.white),
            const Text('Products'),
            IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
          ],
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.only(top: 18.0, left: 18.0, right: 18.0),
        child: Column(
          children: [
            SearchBar(
              onSubmitted: (value) {},
              textInputAction: TextInputAction.search,
              hintText: 'Search products...',
              backgroundColor: WidgetStateProperty.all(
                // ignore: deprecated_member_use
                Theme.of(context).colorScheme.primary.alpha > 0.5
                    ? const Color.fromARGB(255, 255, 255, 255)
                    : Colors.grey.shade200,
              ),
            ),
            const SizedBox(height: 30),

            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Product List', style: TextStyle(fontSize: 18.0)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    _showCreateProductDialog();
                  },
                ),

                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {
                    // Handle filter action
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: productState.when(
                      data: (products) {
                        if (products == null || products.isEmpty) {
                          return const Center(
                            child: Text('No products available.'),
                          );
                        }
                        return GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 3 / 2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final product = products[index];
                            return Card(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(product.name),
                                  Text(
                                    '\$${product.unit_price.toStringAsFixed(2)}',
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, stackTrace) =>
                          Center(child: Text('Error: $error')),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
