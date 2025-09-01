// lib/widgets/company_features_widget.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Feature {
  final IconData icon;
  final String title;
  final String description;

  Feature({required this.icon, required this.title, required this.description});
}

class CompanyFeaturesWidget extends StatelessWidget {
  const CompanyFeaturesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Feature> features = [
      Feature(
        icon: FontAwesomeIcons.chartLine,
        title: 'Expert Guidance',
        description: 'Personalized strategies from SEBI registered advisors.',
      ),
      Feature(
        icon: FontAwesomeIcons.layerGroup,
        title: 'Diversified Portfolios',
        description:
            'Access mutual funds and stocks to build a balanced portfolio.',
      ),
      Feature(
        icon: FontAwesomeIcons.robot,
        title: 'AI-Powered Insights',
        description: 'Leverage tech for market analysis and recommendations.',
      ),
      Feature(
        icon: FontAwesomeIcons.shieldHalved,
        title: 'Secure & Transparent',
        description:
            'Your data and investments are protected with bank-grade security.',
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            'Why Choose Us?',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'The smarter, easier way to build wealth.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 24),
          GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            itemCount: features.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final feature = features[index];
              return Card(
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FaIcon(
                        feature.icon,
                        size: 30,
                        color: Theme.of(context).primaryColor,
                      ),
                      const Spacer(),
                      Text(
                        feature.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        feature.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
