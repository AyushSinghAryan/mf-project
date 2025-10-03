// lib/screens/my_wishlist_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_investeeks_app/services/api_service.dart';
import 'package:flutter_investeeks_app/widgets/paywall_widget.dart';
import 'package:flutter_investeeks_app/widgets/trade_card.dart';
import 'package:provider/provider.dart';

class MyWishlistScreen extends StatefulWidget {
  const MyWishlistScreen({Key? key}) : super(key: key);

  @override
  _MyWishlistScreenState createState() => _MyWishlistScreenState();
}

class _MyWishlistScreenState extends State<MyWishlistScreen> {
  late Future<bool> _isSubscribedFuture;

  @override
  void initState() {
    super.initState();
    // First, check if the user is subscribed
    final apiService = Provider.of<ApiService>(context, listen: false);
    _isSubscribedFuture = apiService.getUserStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Wishlist')),
      body: FutureBuilder<bool>(
        future: _isSubscribedFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // If not subscribed, show the paywall
          if (snapshot.hasError || snapshot.data == false) {
            return const PaywallWidget(featureName: 'My Wishlist');
          }
          // If subscribed, show the actual wishlist content
          return const WishlistContent();
        },
      ),
    );
  }
}

// This widget holds the original UI and is only shown to subscribed users
class WishlistContent extends StatefulWidget {
  const WishlistContent({Key? key}) : super(key: key);

  @override
  State<WishlistContent> createState() => _WishlistContentState();
}

class _WishlistContentState extends State<WishlistContent> {
  late Future<List<dynamic>> _watchlistFuture;

  @override
  void initState() {
    super.initState();
    _fetchWatchlist();
  }

  void _fetchWatchlist() {
    final apiService = Provider.of<ApiService>(context, listen: false);
    // CRITICAL: Wrap this in setState to allow the UI to refresh with the new future
    setState(() {
      _watchlistFuture = apiService.getWatchlist();
    });
  }

  void _toggleWatchlist(int tradeId) async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      await apiService.toggleWatchlist(tradeId);
      // After toggling, re-fetch the watchlist to refresh the screen
      _fetchWatchlist();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Removed from wishlist.'),
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
              // Note: The is_watchlisted flag will be true for all items here
              onWatchlistToggle: () => _toggleWatchlist(trade['id']),
            );
          },
        );
      },
    );
  }
}
