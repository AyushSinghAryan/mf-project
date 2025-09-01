// lib/screens/mutual_funds_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_investeeks_app/services/api_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MutualFundsScreen extends StatefulWidget {
  const MutualFundsScreen({super.key});

  @override
  _MutualFundsScreenState createState() => _MutualFundsScreenState();
}

class _MutualFundsScreenState extends State<MutualFundsScreen> {
  late Future<List<dynamic>> _mutualFunds;
  final ApiService apiService = ApiService(Supabase.instance.client);

  @override
  void initState() {
    super.initState();
    _mutualFunds = apiService.getMutualFunds();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mutual Funds'),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _mutualFunds,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Failed to load data. Please check your network connection and try again.\n\nError: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No mutual funds found.'));
          }

          final funds = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: funds.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final fund = funds[index];
              return MutualFundCard(fund: fund);
            },
          );
        },
      ),
    );
  }
}

/// A new custom widget to display mutual fund data in a visually appealing card.
class MutualFundCard extends StatelessWidget {
  final Map<String, dynamic> fund;

  const MutualFundCard({super.key, required this.fund});

  @override
  Widget build(BuildContext context) {
    // --- FIX IS HERE: Using the new keys from the refactored API ---
    final String name = fund['name'] ?? 'Unnamed Fund';
    final String house = fund['house'] ?? 'N/A';
    final String return1Y = fund['return_1year']?.toString() ?? '-';
    final String return3Y = fund['return_3year']?.toString() ?? '-';
    final int rating =
        int.tryParse(fund['investeeks_rating']?.toString() ?? '0') ?? 0;
    // --- END OF FIX ---

    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              house,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 8),

            _buildRatingStars(rating),
            const Divider(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPerformanceMetric(
                  label: '1Y Return',
                  value: '$return1Y',
                  context: context,
                ),
                _buildPerformanceMetric(
                  label: '3Y Return',
                  value: '$return3Y',
                  context: context,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingStars(int rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star_rounded : Icons.star_border_rounded,
          color: Colors.amber,
          size: 20,
        );
      }),
    );
  }

  Widget _buildPerformanceMetric({
    required String label,
    required String value,
    required BuildContext context,
  }) {
    // Added a check for empty/null values to display '-'
    final displayValue = (value.isNotEmpty && value != '%') ? value : '-';
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          displayValue,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }
}
