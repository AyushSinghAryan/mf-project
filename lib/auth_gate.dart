import 'package:flutter/material.dart';
import 'package:flutter_investeeks_app/screens/login_screen.dart';
import 'package:flutter_investeeks_app/screens/splash_screen.dart'; // Import the new splash screen
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data?.session != null) {
          // User is logged in. Let the SplashScreen handle where to go next.
          return const SplashScreen();
        }

        // User is not logged in
        return const LoginScreen();
      },
    );
  }
}
