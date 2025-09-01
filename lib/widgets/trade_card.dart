// lib/widgets/trade_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_investeeks_app/screens/trade_chart_screen.dart';
import 'package:intl/intl.dart'; // Add 'intl' to pubspec.yaml if you don't have it

class TradeCard extends StatelessWidget {
  final Map<String, dynamic> trade;
  final VoidCallback onWatchlistToggle;

  const TradeCard({
    Key? key,
    required this.trade,
    required this.onWatchlistToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isLive = trade['is_live'] ?? false;
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardHeader(context),
            const Divider(height: 24),
            isLive
                ? _buildLiveTradeDetails(context)
                : _buildClosedTradeDetails(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCardHeader(BuildContext context) {
    final bool isWatchlisted = trade['is_watchlisted'] ?? false;
    final String symbol = trade['symbol'] ?? 'N/A';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: trade['logo_url'] != null
                    ? NetworkImage(trade['logo_url'])
                    : null,
                child: trade['logo_url'] == null
                    ? Text(trade['symbol']?.substring(0, 1) ?? 'S')
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      symbol,
                      style: Theme.of(context).textTheme.titleLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      trade['trade_category'] ?? 'Category',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.bar_chart, color: Colors.grey),
              tooltip: 'View Chart',
              onPressed: () {
                if (symbol != 'N/A') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TradeChartScreen(symbol: symbol),
                    ),
                  );
                }
              },
            ),
            IconButton(
              icon: Icon(
                isWatchlisted ? Icons.bookmark : Icons.bookmark_border,
                color: isWatchlisted
                    ? Theme.of(context).primaryColor
                    : Colors.grey,
              ),
              onPressed: onWatchlistToggle,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLiveTradeDetails(BuildContext context) {
    final entryDate = DateTime.parse(trade['trade_date']);
    final formattedDate = DateFormat('dd MMM yyyy').format(entryDate);

    return Column(
      children: [
        _buildDetailRow(
          'Action:',
          '${trade['position'] ?? 'N/A'} at ₹${trade['price'] ?? '0.0'}',
          isAction: true,
          action: trade['position'] ?? 'N/A',
        ),
        _buildDetailRow('Date:', formattedDate),
        _buildDetailRow(
          'Target:',
          '₹${trade['target'] ?? '0.0'}',
          valueColor: Colors.green.shade700,
        ),
        _buildDetailRow(
          'Stoploss:',
          '₹${trade['stoploss'] ?? '0.0'}',
          valueColor: Colors.red.shade700,
        ),
        _buildDetailRow('Duration:', '${trade['holding_period'] ?? 'N/A'}'),
      ],
    );
  }

  Widget _buildClosedTradeDetails(BuildContext context) {
    final double pnl = trade['pnl_percentage'] ?? 0.0;
    final pnlColor = pnl >= 0 ? Colors.green.shade700 : Colors.red.shade700;
    final resultStatus =
        trade['result_status'] ?? (pnl >= 0 ? 'Profit' : 'Loss');

    return Column(
      children: [
        _buildDetailRow('Entry Price:', '₹${trade['price'] ?? '0.0'}'),
        _buildDetailRow('Exit Price:', '₹${trade['exit_price'] ?? '0.0'}'),
        _buildDetailRow('Result:', resultStatus, valueColor: pnlColor),
        _buildDetailRow(
          'P&L:',
          '${pnl.toStringAsFixed(2)}%',
          valueColor: pnlColor,
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    Color? valueColor,
    bool isAction = false,
    String action = '',
  }) {
    final Color actionColor = action == 'LONG'
        ? Colors.green.shade700
        : (action == 'SHORT' ? Colors.red.shade700 : Colors.black87);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          isAction
              ? Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: actionColor,
                  ),
                )
              : Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: valueColor ?? Colors.black87,
                  ),
                ),
        ],
      ),
    );
  }
}
