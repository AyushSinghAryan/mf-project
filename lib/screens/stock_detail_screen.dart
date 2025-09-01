import 'package:flutter/material.dart';
import 'package:flutter_investeeks_app/services/api_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fl_chart/fl_chart.dart';

class StockDetailScreen extends StatefulWidget {
  final String stockId;
  const StockDetailScreen({super.key, required this.stockId});

  @override
  State<StockDetailScreen> createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetailScreen> {
  late Future<Map<String, dynamic>> _stockDetails;
  final ApiService apiService = ApiService(Supabase.instance.client);

  @override
  void initState() {
    super.initState();
    _stockDetails = apiService.getStockDetail(widget.stockId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Portfolio Details')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _stockDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Portfolio not found.'));
          }

          final stock = snapshot.data!;
          final List<dynamic> constituents = stock['constituents_data'] ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(stock),
                const SizedBox(height: 24),
                _buildPerformanceChart(stock),
                const SizedBox(height: 24),
                _buildCompositionSection(constituents),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> stock) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              stock['name'] ?? 'N/A',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              'Managed by ${stock['manager'] ?? 'N/A'}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const Divider(height: 24),
            Text(
              'About this portfolio',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              stock['overview_long'] ?? 'No overview available.',
              style: const TextStyle(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceChart(Map<String, dynamic> stock) {
    final performanceData = stock['performance_data'];
    if (performanceData == null || performanceData['labels'] == null) {
      return const SizedBox.shrink();
    }

    final List<FlSpot> portfolioSpots =
        (performanceData['portfolio_values'] as List)
            .asMap()
            .entries
            .map((e) => FlSpot(e.key.toDouble(), (e.value as num).toDouble()))
            .toList();

    final List<FlSpot> benchmarkSpots =
        (performanceData['benchmark_values'] as List)
            .asMap()
            .entries
            .map((e) => FlSpot(e.key.toDouble(), (e.value as num).toDouble()))
            .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Live Performance vs ${stock['benchmark_name']}',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: portfolioSpots,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: benchmarkSpots,
                      isCurved: true,
                      color: Colors.amber,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompositionSection(List<dynamic> constituents) {
    final Map<String, double> segmentWeights = {};
    for (var item in constituents) {
      final segment = item['segment'] ?? 'Other';
      final weight = (item['weight'] as num?)?.toDouble() ?? 0.0;
      segmentWeights[segment] = (segmentWeights[segment] ?? 0) + weight;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ETFs & Weights',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                SizedBox(
                  height: 120,
                  width: 120,
                  child: PieChart(
                    PieChartData(
                      sections: segmentWeights.entries.map((entry) {
                        return PieChartSectionData(
                          value: entry.value,
                          title: '${entry.value.toStringAsFixed(0)}%',
                          color: _getColorForSegment(entry.key),
                          radius: 40,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                      sectionsSpace: 2,
                      centerSpaceRadius: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: constituents.map((item) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        // This is the Row that was causing the overflow
                        child: Row(
                          children: [
                            // --- FIX IS HERE ---
                            // Wrap the long text in an Expanded widget
                            Expanded(child: Text(item['name'] ?? 'N/A')),
                            // --- END OF FIX ---
                            const SizedBox(width: 8), // Add some spacing
                            Text(
                              '${(item['weight'] as num?)?.toDouble() ?? 0.0}%',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForSegment(String segment) {
    switch (segment.toLowerCase()) {
      case 'equity':
        return Colors.blue.shade400;
      case 'gold':
        return Colors.amber.shade400;
      case 'debt':
        return Colors.green.shade400;
      default:
        return Colors.grey.shade400;
    }
  }
}
