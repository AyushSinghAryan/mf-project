import 'package:flutter/material.dart';
import 'package:flutter_investeeks_app/screens/onboarding/user_details_form_screen.dart';

class CreateAccountIntroScreen extends StatelessWidget {
  const CreateAccountIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Open Your Account'),
        automaticallyImplyLeading: false, // Removes back button
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "What you'll need",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Gather these documents and details before you begin.",
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            const InfoTile(
              icon: Icons.credit_card,
              title: 'PAN details',
              subtitle: 'Add your PAN information',
            ),
            const InfoTile(
              icon: Icons.admin_panel_settings_outlined,
              title: 'KYC details',
              subtitle: 'Add your KYC details',
            ),
            const InfoTile(
              icon: Icons.person_outline,
              title: 'Basic details',
              subtitle: 'Give us your basic information',
            ),
            const InfoTile(
              icon: Icons.receipt_long_outlined,
              title: 'Tax details',
              subtitle: 'Provide tax-related information',
            ),
            const InfoTile(
              icon: Icons.account_balance_outlined,
              title: 'Bank account details',
              subtitle: 'Add your bank account',
            ),
            const InfoTile(
              icon: Icons.group_add_outlined,
              title: 'Nominee details',
              subtitle: 'Add a nominee for your investments',
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const UserDetailsFormScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Get Started'),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const InfoTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
      ),
    );
  }
}
