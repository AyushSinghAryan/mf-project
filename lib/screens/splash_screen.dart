import 'package:flutter/material.dart';
import 'package:flutter_investeeks_app/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    // Wait for the widget to be fully mounted before navigating.
    await Future.delayed(Duration.zero);

    if (!mounted) return;

    // Since the user is authenticated (verified by AuthGate),
    // navigate directly to the HomeScreen.
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator while the redirection happens.
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
