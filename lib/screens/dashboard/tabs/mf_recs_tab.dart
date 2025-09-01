import 'package:flutter/material.dart';
import 'package:flutter_investeeks_app/services/api_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MfRecsTab extends StatefulWidget {
  const MfRecsTab({super.key});

  @override
  State<MfRecsTab> createState() => _MfRecsTabState();
}

class _MfRecsTabState extends State<MfRecsTab> {
  late Future<Map<String, dynamic>> _mfRiskData;
  final ApiService apiService = ApiService(Supabase.instance.client);

  @override
  void initState() {
    super.initState();
    _mfRiskData = apiService.getMfRiskData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _mfRiskData,
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
              'Recommended Mutual Fund Portfolio',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            ...plan.map((item) {
              return ListTile(
                title: Text(item['mf_name'] ?? 'N/A'),
                subtitle: Text(item['mf_symbol'] ?? ''),
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
