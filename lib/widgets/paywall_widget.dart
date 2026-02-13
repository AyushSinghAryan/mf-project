// lib/widgets/paywall_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_investeeks_app/screens/pricing_screen.dart';

class PaywallWidget extends StatelessWidget {
  final String featureName;

  const PaywallWidget({Key? key, required this.featureName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline,
              size: 80,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 24),
            Text(
              '$featureName is a Premium Feature',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Subscribe to a plan to get full access to professional trades and insights.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
                textStyle: const TextStyle(fontSize: 16),
              ),
              onPressed: () {
                // Navigate to the pricing screen when tapped
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const PricingScreen(),
                  ),
                );
              },
              child: const Text('View Subscription Plans'),
            ),
          ],
        ),
      ),
    );
  }
}
