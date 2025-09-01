import 'package:flutter/material.dart';
import 'package:flutter_investeeks_app/screens/home_screen.dart';
import 'package:flutter_investeeks_app/screens/phone_verification_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Start the redirection logic as soon as the screen is built
    _redirect();
  }

  Future<void> _redirect() async {
    // Wait for the widget to be fully mounted before navigating
    await Future.delayed(Duration.zero);

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      // This case should ideally not be hit if coming from AuthGate, but is a safeguard
      return;
    }

    bool isVerified = false;
    try {
      final response = await Supabase.instance.client
          .from('user_profiles')
          .select('is_phone_verified')
          .eq('id', user.id)
          .single();
      isVerified = response['is_phone_verified'] == true;
    } catch (e) {
      // If profile doesn't exist or flag is null/false, isVerified remains false
      print(
        "Phone verification check failed (this is normal for new users): $e",
      );
    }

    if (!mounted) return; // Check if the widget is still in the tree

    if (isVerified) {
      // User is verified, go to HomeScreen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      // User is not verified, go to PhoneVerificationScreen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const PhoneVerificationScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator while the check is happening
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
