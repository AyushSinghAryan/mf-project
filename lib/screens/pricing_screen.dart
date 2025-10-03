import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart'
    hide Card; // 👈 Make sure this import is here
import 'package:flutter_investeeks_app/services/api_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// You can remove the url_launcher import

class PricingScreen extends StatefulWidget {
  const PricingScreen({super.key});

  @override
  State<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends State<PricingScreen> {
  late Future<List<dynamic>> _plans;
  final ApiService apiService = ApiService(Supabase.instance.client);

  @override
  void initState() {
    super.initState();
    _plans = apiService.getPricingPlans();
  }

  @override
  Widget build(BuildContext context) {
    // ... This build method does not need to change ...
    return Scaffold(
      appBar: AppBar(title: const Text('Pricing Plans')),
      body: FutureBuilder<List<dynamic>>(
        future: _plans,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No pricing plans found.'));
          }

          final plans = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Choose Your Plan',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select the plan that best fits your investment needs.',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: plans.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 24),
                  itemBuilder: (context, index) {
                    final plan = plans[index];
                    return PricingCard(plan: plan);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class PricingCard extends StatefulWidget {
  final Map<String, dynamic> plan;
  const PricingCard({super.key, required this.plan});

  @override
  State<PricingCard> createState() => _PricingCardState();
}

class _PricingCardState extends State<PricingCard> {
  bool _isLoading = false;

  // This is the new payment handling logic using flutter_stripe
  Future<void> _handlePayment() async {
    if (mounted) {
      setState(() => _isLoading = true);
    }

    final apiService = ApiService(Supabase.instance.client);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      // 1. Create payment intent on your server
      final paymentIntentData = await apiService.createPaymentIntent(
        widget.plan['priceId'],
      );
      final clientSecret = paymentIntentData['clientSecret'];

      // 2. Initialize the payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          merchantDisplayName: 'Investeeks Pro',
          paymentIntentClientSecret: clientSecret,
        ),
      );

      // 3. Display the payment sheet
      await Stripe.instance.presentPaymentSheet();

      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Payment successful! Your subscription is active.'),
        ),
      );
    } on StripeException catch (e) {
      // Handle cancellation and other Stripe errors
      if (e.error.code != FailureCode.Canceled) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Payment failed: ${e.error.message}')),
        );
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isHighlighted = widget.plan['highlight'] ?? false;
    final List<dynamic> features = widget.plan['features'] ?? [];

    return Card(
      elevation: isHighlighted ? 8 : 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: isHighlighted
            ? BorderSide(color: Theme.of(context).primaryColor, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // ... (UI code for plan name, price, description, features remains the same)
            Text(
              widget.plan['name'] ?? 'N/A',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              widget.plan['price'] ?? 'N/A',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.plan['description'] ?? '',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const Divider(height: 32),
            ...features.map(
              (feature) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green.shade600,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(feature.toString())),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _handlePayment,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: isHighlighted
                    ? Theme.of(context).primaryColor
                    : null,
                foregroundColor: isHighlighted ? Colors.white : null,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                  : const Text('Get Started'),
            ),
          ],
        ),
      ),
    );
  }
}
