import 'package:flutter/material.dart';
import 'package:flutter_investeeks_app/screens/dashboard/tabs/current_investments_tab.dart';
import 'package:flutter_investeeks_app/screens/dashboard/tabs/mf_recs_tab.dart';
import 'package:flutter_investeeks_app/screens/dashboard/tabs/stocks_recs_tab.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // The number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard'),
          bottom: const TabBar(
            isScrollable: true, // Allows tabs to scroll if they don't fit
            tabs: [
              Tab(text: 'Current Investments'),
              Tab(text: 'Stocks Recommendation'),
              Tab(text: 'Mutual Funds Recs'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [CurrentInvestmentsTab(), StocksRecsTab(), MfRecsTab()],
        ),
      ),
    );
  }
}
