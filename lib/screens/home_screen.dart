import 'package:flutter/material.dart';
import 'package:flutter_investeeks_app/widgets/ai_chat_widget.dart';
import 'package:flutter_investeeks_app/widgets/app_drawer.dart';
import 'package:flutter_investeeks_app/widgets/company_features_widget.dart';
import 'package:flutter_investeeks_app/widgets/custom_footer.dart';
import 'package:flutter_investeeks_app/widgets/hero_section.dart';
import 'package:flutter_investeeks_app/widgets/sip_calculator_widget.dart';
import 'package:flutter_investeeks_app/widgets/team_section.dart';
import 'package:flutter_investeeks_app/widgets/trust_section.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // <-- ADD THIS IMPORT

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // A GlobalKey for the Scaffold is needed to open the drawer.
    Future<void> signOut() async {
      try {
        await Supabase.instance.client.auth.signOut();
      } catch (e) {
        // Handle potential errors, e.g., show a snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out: ${e.toString()}')),
        );
      }
    }

    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    // A placeholder function for auth state
    // bool isLoggedIn = false;

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () => scaffoldKey.currentState?.openDrawer(),
        ),
        title: Image.asset('assets/images/Investeek_Logo.png', height: 35),
        centerTitle: true,
      ),
      drawer: const AppDrawer(),
      body: const SingleChildScrollView(
        child: Column(
          children: [
            HeroSection(),
            SizedBox(height: 24),

            AiChatWidget(),
            SizedBox(height: 16),

            TrustSection(),
            SizedBox(height: 16),
            CompanyFeaturesWidget(),
            SizedBox(height: 16),
            TeamSection(),
            SizedBox(height: 16),
            CustomFooter(),
          ],
        ),
      ),
    );
  }
}
