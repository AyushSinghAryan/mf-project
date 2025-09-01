// lib/screens/i_trades_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_investeeks_app/services/api_service.dart';
import 'package:flutter_investeeks_app/widgets/trade_card.dart';
import 'package:provider/provider.dart';

class ITradesScreen extends StatelessWidget {
  const ITradesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('I Trades'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Live Trades'),
              Tab(text: 'Closed Trades'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            TradesListView(status: 'live'),
            TradesListView(status: 'closed'),
          ],
        ),
      ),
    );
  }
}

class TradesListView extends StatefulWidget {
  final String status;
  const TradesListView({Key? key, required this.status}) : super(key: key);

  @override
  _TradesListViewState createState() => _TradesListViewState();
}

class _TradesListViewState extends State<TradesListView> {
  late Future<List<dynamic>> _tradesFuture;

  @override
  void initState() {
    super.initState();
    _fetchTrades();
  }

  void _fetchTrades() {
    final apiService = Provider.of<ApiService>(context, listen: false);
    _tradesFuture = apiService.getProTrades(status: widget.status);
  }

  void _toggleWatchlist(int tradeId) async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      await apiService.toggleWatchlist(tradeId);
      // Refresh the list to show the updated watchlist status
      setState(() {
        _fetchTrades();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Watchlist updated!'),
          duration: Duration(seconds: 1),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _tradesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No ${widget.status} trades found.'));
        }

        final trades = snapshot.data!;
        return ListView.builder(
          itemCount: trades.length,
          itemBuilder: (context, index) {
            final trade = trades[index];
            return TradeCard(
              trade: trade,
              onWatchlistToggle: () => _toggleWatchlist(trade['id']),
            );
          },
        );
      },
    );
  }
}
