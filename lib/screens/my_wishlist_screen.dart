// lib/screens/my_wishlist_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_investeeks_app/services/api_service.dart';
import 'package:flutter_investeeks_app/widgets/trade_card.dart';
import 'package:provider/provider.dart';

class MyWishlistScreen extends StatefulWidget {
  const MyWishlistScreen({Key? key}) : super(key: key);

  @override
  _MyWishlistScreenState createState() => _MyWishlistScreenState();
}

class _MyWishlistScreenState extends State<MyWishlistScreen> {
  late Future<List<dynamic>> _watchlistFuture;

  @override
  void initState() {
    super.initState();
    _fetchWatchlist();
  }

  void _fetchWatchlist() {
    final apiService = Provider.of<ApiService>(context, listen: false);
    setState(() {
      _watchlistFuture = apiService.getWatchlist();
    });
  }

  void _toggleWatchlist(int tradeId) async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      // In the wishlist, toggling always means removing.
      // After removing, we refresh the list.
      await apiService.toggleWatchlist(tradeId);
      _fetchWatchlist(); // Refresh the list
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Removed from watchlist.'),
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
    return Scaffold(
      appBar: AppBar(title: const Text('My Wishlist')),
      body: FutureBuilder<List<dynamic>>(
        future: _watchlistFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Your wishlist is empty.'));
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
      ),
    );
  }
}
