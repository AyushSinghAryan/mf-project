// lib/screens/my_orders_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_investeeks_app/services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({Key? key}) : super(key: key);

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  late Future<List<dynamic>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    final apiService = Provider.of<ApiService>(context, listen: false);
    _ordersFuture = apiService.getOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: FutureBuilder<List<dynamic>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('You have no past orders.'));
          }

          final orders = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return OrderCard(order: order);
            },
          );
        },
      ),
    );
  }
}

class OrderCard extends StatefulWidget {
  final Map<String, dynamic> order;
  const OrderCard({Key? key, required this.order}) : super(key: key);

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  // bool _isLoading = false;

  // Future<void> _handleDownload() async {
  //   // Request storage permission on Android
  //   if (await Permission.storage.request().isGranted) {
  //     setState(() => _isLoading = true);
  //     final apiService = Provider.of<ApiService>(context, listen: false);
  //     final scaffoldMessenger = ScaffoldMessenger.of(context);

  //     try {
  //       await apiService.downloadInvoice(widget.order['order_id']);
  //       scaffoldMessenger.showSnackBar(
  //         const SnackBar(content: Text('Invoice downloaded and opened.')),
  //       );
  //     } catch (e) {
  //       scaffoldMessenger.showSnackBar(
  //         SnackBar(
  //           content: Text('Error: ${e.toString()}'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     } finally {
  //       if (mounted) {
  //         setState(() => _isLoading = false);
  //       }
  //     }
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Storage permission is required to download invoices.'),
  //       ),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final orderDate = DateFormat(
      'd MMMM yyyy',
    ).format(DateTime.parse(order['created_at']));
    final planEndDate = DateFormat(
      'd MMMM yyyy',
    ).format(DateTime.parse(order['plan_end_date']));
    final bool isExpired =
        order['status'].toString().toLowerCase() == 'expired';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Subscription Purchase',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Subscription ID: ${order['order_id'] ?? 'N/A'}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Status: '),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isExpired
                        ? Colors.red.shade100
                        : Colors.green.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isExpired ? 'Expired' : 'Active',
                    style: TextStyle(
                      color: isExpired
                          ? Colors.red.shade800
                          : Colors.green.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('Valid Until: $planEndDate'),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Purchased on: $orderDate',
                  style: const TextStyle(color: Colors.grey),
                ),
                // ElevatedButton.icon(
                //   onPressed: _isLoading ? null : _handleDownload,
                //   icon: _isLoading
                //       ? const SizedBox(
                //           width: 16,
                //           height: 16,
                //           child: CircularProgressIndicator(strokeWidth: 2),
                //         )
                //       : const Icon(Icons.download_rounded, size: 18),
                //   label: Text(_isLoading ? 'Downloading...' : 'Invoice'),
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
