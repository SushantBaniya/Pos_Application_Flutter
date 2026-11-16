import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/notifiers/login_notifiers.dart';
import 'package:pos_app/notifiers/order_notifiers.dart';
import 'package:pos_app/models/counter.dart';

class CounterScreen extends ConsumerStatefulWidget {
  const CounterScreen({super.key});

  @override
  ConsumerState<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends ConsumerState<CounterScreen> {
  void _showCreateCounterDialog() {
    final counterNumberController = TextEditingController();
    final locationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Counter'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: counterNumberController,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: 'Counter Number'),
              ),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final businessId =
                  ref.read(loginNotifierProvider).value?.business_id ?? 0;
              final counterRequest = CounterRequest(
                counter_number:
                    int.tryParse(counterNumberController.text) ?? 0,
                location: locationController.text,
              );
              ref
                  .read(counterNotifierProvider.notifier)
                  .createCounter(counterRequest, businessId);
              Navigator.of(context).pop();
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
    final businessId = ref.read(loginNotifierProvider).value?.business_id;
    // Fetch counters when the screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(counterNotifierProvider.notifier).fetchCounters(businessId ?? 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final counterState = ref.watch(counterNotifierProvider);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.arrow_back, color: Colors.white),
            const Text('Counters'),
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
              hintText: 'Search Counter...',
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
                Text('Counter List', style: TextStyle(fontSize: 18.0)),
                const Spacer(),
                IconButton(icon: const Icon(Icons.add), onPressed: () {
                  _showCreateCounterDialog();
                }),

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
                    child: counterState.when(
                      data: (counters) {
                        if (counters == null || counters.isEmpty) {
                          return const Center(
                            child: Text('No counters available.'),
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
                          itemCount: counters.length,
                          itemBuilder: (context, index) {
                            final counter = counters[index];
                            return Card(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(counter.counter_number != null
                                      ? 'Counter ${counter.counter_number}'
                                      : 'Counter'),
                                  Text(
                                      'Location: ${counter.location ?? 'N/A'}'),
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
