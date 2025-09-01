import 'package:flutter/material.dart';
import 'package:flutter_investeeks_app/services/api_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class CurrentInvestmentsTab extends StatefulWidget {
  const CurrentInvestmentsTab({super.key});

  @override
  State<CurrentInvestmentsTab> createState() => _CurrentInvestmentsTabState();
}

class _CurrentInvestmentsTabState extends State<CurrentInvestmentsTab> {
  late Future<Map<String, dynamic>> _portfolioData;
  final ApiService apiService = ApiService(Supabase.instance.client);

  @override
  void initState() {
    super.initState();
    _portfolioData = apiService.getPortfolioData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _portfolioData,
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
        final userDetails = data['user_details'] ?? {};
        final tableData = data['table_data'] as List? ?? [];
        final chartData = data['chart_data'] ?? {};
        final currencyFormat = NumberFormat.currency(
          locale: 'en_IN',
          symbol: '₹',
          decimalDigits: 0,
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // User Details and Chart Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildUserDetails(userDetails),
                      const Divider(height: 32),
                      _buildPortfolioChart(chartData),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Portfolio Table Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildPortfolioTable(tableData, currencyFormat),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserDetails(Map<String, dynamic> details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('User Details', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text('Name: ${details['name'] ?? 'N/A'}'),
        Text('Email: ${details['email'] ?? 'N/A'}'),
      ],
    );
  }

  Widget _buildPortfolioChart(Map<String, dynamic> chartData) {
    final List<dynamic> labels = chartData['labels'] ?? [];
    final List<dynamic> data = chartData['data'] ?? [];

    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: List.generate(labels.length, (i) {
            return PieChartSectionData(
              value: (data[i] as num).toDouble(),
              title: labels[i],
              color: Colors.primaries[i % Colors.primaries.length],
              radius: 80,
            );
          }),
        ),
      ),
    );
  }

  Widget _buildPortfolioTable(List<dynamic> tableData, NumberFormat formatter) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Portfolio Details',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        DataTable(
          columns: const [
            DataColumn(label: Text('Folio')),
            DataColumn(label: Text('Amount'), numeric: true),
            DataColumn(label: Text('Return'), numeric: true),
          ],
          rows: tableData.map((item) {
            return DataRow(
              cells: [
                DataCell(Text(item['folio'] ?? '')),
                DataCell(Text(formatter.format(item['amount'] ?? 0))),
                DataCell(Text('${item['return_percentage'] ?? 0}%')),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
