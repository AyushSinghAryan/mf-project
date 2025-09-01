// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_investeeks_app/services/api_service.dart'; // <-- ADD THIS IMPORT

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  // This ID MUST come from the OAuth 2.0 credential of type "Web application"
  final String webClientId =
      '10020793013-g59r0it9l91ne66vith4nnf62aa20trh.apps.googleusercontent.com';

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      // 1. Start the native Google Sign-In flow
      final googleSignIn = GoogleSignIn(serverClientId: webClientId);
      final googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // The user canceled the sign-in
        setState(() => _isLoading = false);
        return;
      }

      // 2. Get the authentication details from the user
      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null) {
        throw 'Google Sign-In failed: No Access Token found.';
      }
      if (idToken == null) {
        throw 'Google Sign-In failed: No ID Token found.';
      }

      // 3. Send the ID Token to Supabase to create a session
      final response = await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      // --- FIX IS HERE ---
      // 4. After a successful login, sync the user with our Flask backend
      if (response.session != null) {
        final apiService = ApiService(Supabase.instance.client);
        await apiService.syncUser();
        print("✅ User profile synced successfully with backend!");
      } else {
        throw 'Supabase login failed after Google sign-in.';
      }
      // --- END OF FIX ---

      // AuthGate will now automatically detect the new session and navigate
      // to the HomeScreen.
    } catch (e) {
      print("Login failed: ${e.toString()}");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Login failed. Please check your app's configuration. Error: ${e.toString()}",
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton.icon(
                icon: const Icon(Icons.login), // Consider using a Google icon
                label: const Text("Sign in with Google"),
                onPressed: _signInWithGoogle,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
      ),
    );
  }
}
