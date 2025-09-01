// lib/widgets/app_drawer.dart
import 'package:flutter/material.dart';
import 'package:flutter_investeeks_app/screens/dashboard/dashboard_screen.dart';
import 'package:flutter_investeeks_app/screens/financial_literacy_screen.dart'; // <-- Import the new screen
import 'package:flutter_investeeks_app/screens/i_trades_screen.dart';
import 'package:flutter_investeeks_app/screens/mutual_funds_screen.dart';
import 'package:flutter_investeeks_app/screens/my_wishlist_screen.dart';
import 'package:flutter_investeeks_app/screens/pricing_screen.dart';
import 'package:flutter_investeeks_app/screens/sip_calculator_screen.dart';
import 'package:flutter_investeeks_app/screens/stock_list_screen.dart';
import 'package:flutter_investeeks_app/screens/support_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/Investeek_Logo.png',
                  height: 40,
                  color: Colors.white,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Your Financial Guide',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.candlestick_chart_outlined,
            text: 'Mutual Funds',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MutualFundsScreen(),
                ),
              );
            },
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.dashboard_outlined,
            text: 'Dashboard',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
            ),
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.calculate_outlined,
            text: 'SIP Calculator',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SipCalculatorScreen(),
                ),
              );
            },
          ),
          // --- ADDED FINANCIAL LITERACY NAVIGATION ---
          _buildDrawerItem(
            context: context,
            icon: Icons.school_outlined,
            text: 'Financial Literacy',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FinancialLiteracyScreen(),
                ),
              );
            },
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.show_chart,
            text: 'Stocks',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StockListScreen(),
                ),
              );
            },
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.price_change_outlined,
            text: 'Pricing',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PricingScreen()),
            ),
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.work_outline,
            text: 'I Trades',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ITradesScreen()),
              );
            },
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.bookmark_border_outlined,
            text: 'My Wishlist',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyWishlistScreen(),
                ),
              );
            },
          ),
          // --- ADDED SUPPORT NAVIGATION ---
          _buildDrawerItem(
            context: context,
            icon: Icons.support_agent_outlined,
            text: 'Support',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SupportScreen()),
            ),
          ),
          const Divider(),
          _buildDrawerItem(
            context: context,
            icon: Icons.logout,
            text: 'Logout',
            onTap: () async {
              await Supabase.instance.client.auth.signOut();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(text),
      onTap: () {
        Navigator.pop(context); // Close the drawer first
        onTap(); // Then execute the navigation
      },
    );
  }
}
