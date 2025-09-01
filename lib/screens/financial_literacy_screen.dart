import 'package:flutter/material.dart';
import 'package:flutter_investeeks_app/services/api_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FinancialLiteracyScreen extends StatefulWidget {
  const FinancialLiteracyScreen({super.key});

  @override
  State<FinancialLiteracyScreen> createState() =>
      _FinancialLiteracyScreenState();
}

class _FinancialLiteracyScreenState extends State<FinancialLiteracyScreen> {
  late Future<List<dynamic>> _chapters;
  final ApiService apiService = ApiService(Supabase.instance.client);

  @override
  void initState() {
    super.initState();
    _chapters = apiService.getFinancialLiteracyChapters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Literacy'),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _chapters,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No content found.'));
          }

          final chapters = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: chapters.length,
            itemBuilder: (context, index) {
              final chapter = chapters[index];
              final List<dynamic> items = chapter['items'] ?? [];
              // Using ExpansionTile to create the accordion effect
              return Card(
                margin: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 8.0,
                ),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                clipBehavior: Clip
                    .antiAlias, // Ensures the child respects the border radius
                child: ExpansionTile(
                  title: Text(
                    chapter['title'] ?? 'Untitled Chapter',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  childrenPadding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  children: items.map<Widget>((item) {
                    // A nested ExpansionTile for the questions and answers
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: ExpansionTile(
                          backgroundColor: Theme.of(
                            context,
                          ).scaffoldBackgroundColor,
                          collapsedBackgroundColor: Theme.of(
                            context,
                          ).scaffoldBackgroundColor,
                          title: Text(
                            item['question'] ?? 'No Question',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          childrenPadding: const EdgeInsets.all(16.0),
                          children: [
                            Text(
                              item['answer'] ?? 'No Answer Provided.',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: Colors.grey[700],
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
