// lib/widgets/trade_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_investeeks_app/screens/trade_chart_screen.dart';
import 'package:flutter_investeeks_app/screens/trade_detail_screen.dart';
// import 'package:flutter_investeeks_app/screens/trade_detail_screen.dart';

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
    final bool isLive = trade['is_live'] ?? true;
    final bool isProfit = (trade['pnl_percentage'] ?? 0.0) >= 0;
    final bool isWatchlisted = trade['is_watchlisted'] ?? false;
    final Color pnlColor = isProfit
        ? Colors.green.shade700
        : Colors.red.shade700;
    final String symbol = trade['symbol'] ?? 'N/A';
    final String? logoUrl = trade['logo_url']; // Store the URL in a variable

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: logoUrl != null
                      ? NetworkImage(logoUrl)
                      : null,
                  onBackgroundImageError: logoUrl != null ? (_, __) {} : null,
                  child: logoUrl == null
                      ? Text(symbol.isNotEmpty ? symbol[0] : '?')
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        symbol,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        trade['company_name'] ?? '',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // --- DETAILS ---
            IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (isLive) ...[
                    _buildStatColumn(
                      'Entry Price',
                      '₹${trade['price']?.toStringAsFixed(2)}',
                    ),
                    const VerticalDivider(),
                    _buildStatColumn(
                      'Target',
                      '₹${trade['target']?.toStringAsFixed(2)}',
                      valueColor: Colors.green,
                    ),
                    const VerticalDivider(),
                    _buildStatColumn(
                      'Stoploss',
                      '₹${trade['stoploss']?.toStringAsFixed(2)}',
                      valueColor: Colors.red,
                    ),
                  ] else ...[
                    _buildStatColumn(
                      'Result',
                      trade['result_status'],
                      valueColor: pnlColor,
                    ),
                    const VerticalDivider(),
                    _buildStatColumn(
                      'Net P&L',
                      '${trade['pnl_percentage']?.toStringAsFixed(2)}%',
                      valueColor: pnlColor,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 8),

            // --- ACTION BUTTONS ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => TradeDetailScreen(trade: trade),
                        ),
                      );
                    },
                    child: const Text('About Trade'),
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.bar_chart_rounded),
                      tooltip: 'View Chart',
                      onPressed: () {
                        if (symbol != 'N/A') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TradeChartScreen(
                                key: ValueKey(symbol), // <-- ADD THIS LINE
                                symbol: symbol,
                              ),
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
                            : null,
                      ),
                      tooltip: isWatchlisted
                          ? 'Remove from Watchlist'
                          : 'Add to Watchlist',
                      onPressed: onWatchlistToggle,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, {Color? valueColor}) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: valueColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
