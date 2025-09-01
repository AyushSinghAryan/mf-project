// lib/widgets/custom_footer.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomFooter extends StatelessWidget {
  const CustomFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF2C3E50), // Dark blue-gray
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/Investeek_Logo.png',
            height: 40,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          const Text(
            'Your all-in-one platform for smarter financial decisions.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSocialIcon(FontAwesomeIcons.facebookF),
              const SizedBox(width: 24),
              _buildSocialIcon(FontAwesomeIcons.twitter),
              const SizedBox(width: 24),
              _buildSocialIcon(FontAwesomeIcons.linkedinIn),
              const SizedBox(width: 24),
              _buildSocialIcon(FontAwesomeIcons.instagram),
            ],
          ),
          const Divider(color: Colors.white24, height: 48),
          Text(
            '© ${DateTime.now().year} Investeeks. All rights reserved.',
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon) {
    return FaIcon(icon, color: Colors.white, size: 20);
  }
}
