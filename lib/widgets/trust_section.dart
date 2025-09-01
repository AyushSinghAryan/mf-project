// lib/widgets/trust_section.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TrustSection extends StatelessWidget {
  const TrustSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            'Fully Licensed & Regulated',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Your trust is our foundation. We're committed to the highest standards.",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.0,
            children: const [
              _TrustCard(
                image: 'assets/images/sebi-seal.png',
                title: 'SEBI Registered',
                subtitle: 'INA000019798',
              ),
              _TrustCard(
                icon: FontAwesomeIcons.fileSignature,
                color: Colors.green,
                title: 'AMFI Registered',
                subtitle: 'Mutual Fund Distributor',
              ),
              _TrustCard(
                icon: FontAwesomeIcons.shieldHalved,
                color: Colors.blue,
                title: 'Bank-Grade Security',
                subtitle: '256-bit SSL Encryption',
              ),
              _TrustCard(
                icon: FontAwesomeIcons.database,
                color: Colors.purple,
                title: '20+ Years of Data',
                subtitle: 'Powering Our Insights',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrustCard extends StatelessWidget {
  final String? image;
  final IconData? icon;
  final Color color;
  final String title;
  final String subtitle;

  const _TrustCard({
    this.image,
    this.icon,
    this.color = Colors.black,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (image != null)
              Image.asset(image!, height: 40)
            else
              FaIcon(icon, size: 36, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
