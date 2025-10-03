// lib/screens/i_trades_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_investeeks_app/services/api_service.dart';
import 'package:flutter_investeeks_app/widgets/paywall_widget.dart';
import 'package:flutter_investeeks_app/widgets/trade_card.dart';
import 'package:provider/provider.dart';

class ITradesScreen extends StatefulWidget {
  const ITradesScreen({Key? key}) : super(key: key);

  @override
  State<ITradesScreen> createState() => _ITradesScreenState();
}

class _ITradesScreenState extends State<ITradesScreen> {
  late Future<bool> _isSubscribedFuture;

  @override
  void initState() {
    super.initState();
    final apiService = Provider.of<ApiService>(context, listen: false);
    _isSubscribedFuture = apiService.getUserStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('I Trades')),
      body: FutureBuilder<bool>(
        future: _isSubscribedFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // If user is NOT subscribed (or there's an error), show the paywall
          if (snapshot.hasError || snapshot.data == false) {
            return const PaywallWidget(featureName: 'I Trades');
          }
          // If user IS subscribed, show the real content
          return const TradesContent();
        },
      ),
    );
  }
}

// This widget holds the original UI and is only shown to subscribed users
class TradesContent extends StatelessWidget {
  const TradesContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: const [
          TabBar(
            tabs: [
              Tab(text: 'Live Trades'),
              Tab(text: 'Closed Trades'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                TradesListView(status: 'live'),
                TradesListView(status: 'closed'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Your existing TradesListView remains unchanged
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
