import 'package:flutter/material.dart';
import 'package:flutter_investeeks_app/services/api_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StocksRecsTab extends StatefulWidget {
  const StocksRecsTab({super.key});

  @override
  State<StocksRecsTab> createState() => _StocksRecsTabState();
}

class _StocksRecsTabState extends State<StocksRecsTab> {
  late Future<Map<String, dynamic>> _riskData;
  final ApiService apiService = ApiService(Supabase.instance.client);

  @override
  void initState() {
    super.initState();
    _riskData = apiService.getStockRiskData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _riskData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: Text('No data found.'));
        }

        final data = snapshot.data!;
        final String riskProfile = data['risk_profile'] ?? 'N/A';
        final List<dynamic> portfolioPlan = data['portfolio_plan'] ?? [];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildRiskProfileCard(riskProfile),
              const SizedBox(height: 16),
              _buildPortfolioPlanCard(portfolioPlan),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRiskProfileCard(String riskProfile) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.shield_outlined),
        title: Text(
          'Your Risk Profile: $riskProfile',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text('This is used to generate recommendations.'),
      ),
    );
  }

  Widget _buildPortfolioPlanCard(List<dynamic> plan) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recommended Stock Portfolio',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            ...plan.map((item) {
              return ListTile(
                title: Text(item['stock_symbol'] ?? 'N/A'),
                trailing: Text(
                  '${item['weightage']}%',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
