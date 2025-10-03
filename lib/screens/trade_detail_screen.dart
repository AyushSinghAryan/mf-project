// lib/screens/trade_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TradeDetailScreen extends StatelessWidget {
  final Map<String, dynamic> trade;

  const TradeDetailScreen({Key? key, required this.trade}) : super(key: key);

  // Helper to build a styled row for details
  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  // CORRECTED: This version safely handles both int and double types from JSON.
  Widget _buildPerformanceBar() {
    // Safely parse the numbers, accepting both int and double from JSON
    final num? changeNum = trade['changes_so_far_percent'];
    final double? changePercent = changeNum?.toDouble();

    final num? potentialNum = trade['potential_left_percent'];
    final double? potentialPercent = potentialNum?.toDouble();

    String formatPercentage(double? value, {bool addPlus = false}) {
      if (value == null) return '--';
      String sign = value > 0 && addPlus ? '+' : '';
      return '$sign${value.toStringAsFixed(2)}%';
    }

    Color getChangeColor(double? value) {
      if (value == null || value == 0) return Colors.grey;
      return value > 0 ? Colors.green : Colors.red;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  const Text(
                    'Change so far:',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatPercentage(changePercent, addPlus: true),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: getChangeColor(changePercent),
                    ),
                  ),
                ],
              ),
            ),
            Container(height: 40, width: 1, color: Colors.grey.shade300),
            Expanded(
              child: Column(
                children: [
                  const Text(
                    'Potential left:',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatPercentage(potentialPercent),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
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

  // UPDATED: Wrapped the DataTable in a horizontal scroll view to prevent overflow.
  Widget _buildTradeLog(BuildContext context) {
    final List<dynamic> specifics = trade['specifics'] ?? [];

    // Combine all actions into a single list of maps
    final allActions = [
      // The initial trade action
      {
        'date': trade['trade_date'],
        'action': trade['position'] == 'LONG' ? 'Buy' : 'Short',
        'price': trade['price'],
        'start_price': trade['start_price'], // For Range
        'end_price': trade['end_price'], // For Range
      },
      // Additional actions like "Average"
      ...specifics.map(
        (s) => {
          'date': s['action_date'],
          'action': s['trade_action'],
          'price': s['price'],
          'start_price': s['start_price'], // For Range
          'end_price': s['end_price'], // For Range
        },
      ),
    ];

    // For closed trades, add the exit action
    if (trade['is_live'] == false) {
      allActions.add({
        'date': trade['exit_date'],
        'action': 'Exit Full',
        'price': trade['exit_price'],
        'start_price': null, // No range for exit
        'end_price': null,
      });
    }

    // Sort all actions by date
    allActions.sort(
      (a, b) => DateTime.parse(a['date']).compareTo(DateTime.parse(b['date'])),
    );

    // NEW: Wrap the DataTable to allow horizontal scrolling
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 16.0,
        columns: const [
          DataColumn(
            label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text(
              'Action',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text('Price', style: TextStyle(fontWeight: FontWeight.bold)),
            numeric: true,
          ),
          DataColumn(
            label: Text('Range', style: TextStyle(fontWeight: FontWeight.bold)),
            numeric: true,
          ),
        ],
        rows: allActions.map((action) {
          final String rangeText =
              (action['start_price'] != null && action['end_price'] != null)
              ? '${action['start_price']} - ${action['end_price']}'
              : 'N/A';

          return DataRow(
            cells: [
              DataCell(
                Text(
                  DateFormat(
                    'd MMM yyyy',
                  ).format(DateTime.parse(action['date'])),
                ),
              ),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    action['action'],
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              DataCell(
                Text('₹${action['price']?.toStringAsFixed(2) ?? '0.00'}'),
              ),
              DataCell(Text(rangeText)),
            ],
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isLive = trade['is_live'] ?? true;
    final bool isProfit = (trade['pnl_percentage'] ?? 0.0) >= 0;
    final Color pnlColor = isProfit ? Colors.green : Colors.red;

    return Scaffold(
      appBar: AppBar(title: Text(trade['symbol'] ?? 'Trade Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // This is a placeholder icon logic, update if you have real logos
                    const Icon(Icons.business, size: 50, color: Colors.grey),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trade['symbol'] ?? 'N/A',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // Assuming company_name is not in the JSON, you can remove or hide it
                          // Text(
                          //   trade['company_name'] ?? '',
                          //   style: const TextStyle(color: Colors.grey),
                          // ),
                        ],
                      ),
                    ),
                    if (!isLive)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${trade['pnl_percentage']?.toStringAsFixed(2) ?? '0.00'}%',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: pnlColor,
                            ),
                          ),
                          Text('Net P&L', style: TextStyle(color: pnlColor)),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // NEW: Added the performance bar here
            if (isLive) ...[_buildPerformanceBar(), const SizedBox(height: 16)],

            // Key Details Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    if (isLive) ...[
                      _buildDetailRow(
                        'Target',
                        '₹${trade['target']?.toStringAsFixed(2) ?? 'N/A'}',
                        valueColor: Colors.green,
                      ),
                      const Divider(),
                      _buildDetailRow(
                        'Stoploss',
                        '₹${trade['stoploss']?.toStringAsFixed(2) ?? 'N/A'}',
                        valueColor: Colors.red,
                      ),
                    ] else ...[
                      _buildDetailRow(
                        'Entry Price',
                        '₹${trade['price']?.toStringAsFixed(2) ?? 'N/A'}',
                      ),
                      const Divider(),
                      _buildDetailRow(
                        'Exit Price',
                        '₹${trade['exit_price']?.toStringAsFixed(2) ?? 'N/A'}',
                      ),
                    ],
                    const Divider(),
                    _buildDetailRow(
                      'Duration',
                      trade['holding_period'] ?? 'N/A',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Trade Log Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Trade Log',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // The new data table will be rendered here
                    _buildTradeLog(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
