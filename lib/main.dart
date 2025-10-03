import 'package:flutter/material.dart';
import 'package:flutter_investeeks_app/auth_gate.dart';
import 'package:flutter_investeeks_app/services/api_service.dart'; //
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart'; //
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_investeeks_app/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey =
      'pk_test_51PjywcGXrV9hQ5aLOxlkKeE85xyViWSrCPRLCInoVZe3gaxQhfIKakThRfFWsCPH028vKiNCQEN5KiN0oXuAChSF00yfBZYlVE';

  await Supabase.initialize(
    url: 'https://tkotrtgvjqtbyszvjygj.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRrb3RydGd2anF0YnlzenZqeWdqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDkzNTkzNjUsImV4cCI6MjA2NDkzNTM2NX0.Ixt1P7taOFG74TXuht424qHcsxB2z4zFXdA-di9a_gs',
  );

  // --- . Wrap your App with MultiProvider ---
  runApp(
    MultiProvider(
      providers: [
        // This makes a single instance of ApiService available to the entire app
        Provider<ApiService>(create: (_) => ApiService(supabase)),
        // You can add more providers here in the future
      ],
      child: const MyApp(),
    ),
  );
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Investeeks',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const AuthGate(),
    );
  }
}
