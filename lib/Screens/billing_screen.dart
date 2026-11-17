import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/models/order.dart';

class BillingInvoice {
  const BillingInvoice({required this.order, this.isPaid = false});
  final Order order;
  final bool isPaid;

  BillingInvoice copyWith({bool? isPaid}) =>
      BillingInvoice(order: order, isPaid: isPaid ?? this.isPaid);
}

class BillingInvoicesNotifier extends Notifier<List<BillingInvoice>> {
  @override
  List<BillingInvoice> build() => [];

  void addOrder(Order order) {
    if (state.any((invoice) => invoice.order.id == order.id)) return;
    state = [...state, BillingInvoice(order: order)];
  }

  void markPaid(int orderId) {
    state = [
      for (final invoice in state)
        if (invoice.order.id == orderId)
          invoice.copyWith(isPaid: true)
        else
          invoice,
    ];
  }
}

final billingInvoicesProvider =
    NotifierProvider<BillingInvoicesNotifier, List<BillingInvoice>>(
      BillingInvoicesNotifier.new,
    );

class BillingScreen extends ConsumerStatefulWidget {
  const BillingScreen({super.key, this.order});
  final Order? order;

  @override
  ConsumerState<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends ConsumerState<BillingScreen> {
  final _searchController = TextEditingController();
  String _filter = 'All';
  String _search = '';

  @override
  void initState() {
    super.initState();
    if (widget.order != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(billingInvoicesProvider.notifier).addOrder(widget.order!);
      });
    }
    _searchController.addListener(() {
      setState(() => _search = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final invoices = ref.watch(billingInvoicesProvider);
    final paidInvoices = invoices.where((invoice) => invoice.isPaid).toList();
    final pendingInvoices = invoices.where((invoice) => !invoice.isPaid).toList();
    final paidRevenue = paidInvoices.fold<double>(
      0,
      (total, invoice) => total + invoice.order.total_amount,
    );
    final outstanding = pendingInvoices.fold<double>(
      0,
      (total, invoice) => total + invoice.order.total_amount,
    );
    final visibleInvoices = invoices.where((invoice) {
      final matchesFilter = _filter == 'All' ||
          (_filter == 'Paid' && invoice.isPaid) ||
          (_filter == 'Pending' && !invoice.isPaid);
      final order = invoice.order;
      final matchesSearch = _search.isEmpty ||
          order.id.toString().contains(_search) ||
          (order.customer_name ?? '').toLowerCase().contains(_search) ||
          (order.counter_number ?? '').toLowerCase().contains(_search);
      return matchesFilter && matchesSearch;
    }).toList()
      ..sort((a, b) => b.order.order_date.compareTo(a.order.order_date));

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => setState(() {}),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Billings',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF101820),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Manage your invoices',
                          style: TextStyle(color: Color(0xFF718096)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEAF0FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      color: Color(0xFF182653),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.17,
                children: [
                  _BillingStat(
                    icon: Icons.shopping_bag_outlined,
                    color: const Color(0xFF3478F6),
                    value: '${invoices.length}',
                    label: 'Total Billings',
                    corner: '${invoices.length.toString().padLeft(2, '0')}',
                  ),
                  _BillingStat(
                    icon: Icons.check_circle_outline,
                    color: const Color(0xFF00B879),
                    value: paidRevenue.toStringAsFixed(0),
                    label: 'Paid Revenue',
                  ),
                  _BillingStat(
                    icon: Icons.attach_money,
                    color: const Color(0xFFA943FF),
                    value: outstanding.toStringAsFixed(0),
                    label: 'Outstanding Dues',
                  ),
                  _BillingStat(
                    icon: Icons.error_outline,
                    color: const Color(0xFFFF4C55),
                    value: '${pendingInvoices.length}',
                    label: 'Pending Invoices',
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search billings...',
                        hintStyle: const TextStyle(color: Color(0xFF8A9AB4)),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xFF8A9AB4),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.zero,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                            color: Color(0xFFE1E4E8),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                            color: Color(0xFFE1E4E8),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF172554),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: () => setState(() {}),
                      child: const Icon(Icons.sync),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'INVOICES (${visibleInvoices.length})',
                style: const TextStyle(
                  color: Color(0xFF526783),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _filterChip('All', invoices.length),
                  _filterChip('Paid', paidInvoices.length),
                  _filterChip('Pending', pendingInvoices.length),
                ],
              ),
              const SizedBox(height: 12),
              if (visibleInvoices.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 32,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFE1E4E8)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 38,
                        color: Color(0xFFCBD5E1),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'No billings found',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Your invoices will appear here once you create a billing.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFF718096)),
                      ),
                    ],
                  ),
                )
              else
                ListView.builder(
                  itemCount: visibleInvoices.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final invoice = visibleInvoices[index];
                    final order = invoice.order;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFE1E4E8)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Invoice #${order.id}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              _statusTag(invoice.isPaid),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            order.customer_name ??
                                (order.counter_number == null
                                    ? 'Customer'
                                    : 'Counter ${order.counter_number}'),
                            style: const TextStyle(color: Color(0xFF718096)),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${order.order_date.day}/${order.order_date.month}/${order.order_date.year}',
                                  style: const TextStyle(
                                    color: Color(0xFF718096),
                                  ),
                                ),
                              ),
                              Text(
                                'Rs. ${order.total_amount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          if (!invoice.isPaid) ...[
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              height: 44,
                              child: FilledButton(
                                onPressed: () => _payNow(order.id),
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFF172554),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Pay Now'),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterChip(String name, int count) {
    final selected = _filter == name;
    return ChoiceChip(
      label: Text('$name $count'),
      selected: selected,
      showCheckmark: false,
      onSelected: (_) => setState(() => _filter = name),
      selectedColor: const Color(0xFFDCEEFF),
      backgroundColor: const Color(0xFFEEF0F3),
      labelStyle: TextStyle(
        color: selected ? const Color(0xFF1764E8) : Colors.black,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      side: BorderSide.none,
    );
  }

  Widget _statusTag(bool isPaid) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: isPaid ? const Color(0xFFE5F8EF) : const Color(0xFFFFF2DF),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      isPaid ? 'Paid' : 'Pending',
      style: TextStyle(
        color: isPaid ? const Color(0xFF008C5A) : const Color(0xFFC47700),
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    ),
  );

  void _payNow(int orderId) {
    ref.read(billingInvoicesProvider.notifier).markPaid(orderId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invoice marked as paid.')),
    );
  }
}

class _BillingStat extends StatelessWidget {
  const _BillingStat({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
    this.corner,
  });

  final IconData icon;
  final Color color;
  final String value;
  final String label;
  final String? corner;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0xFFE1E4E8)),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const Spacer(),
            if (corner != null)
              Text(corner!, style: const TextStyle(color: Color(0xFF8A9AB4))),
          ],
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 7),
        Text(label, style: const TextStyle(color: Color(0xFF718096))),
      ],
    ),
  );
}
