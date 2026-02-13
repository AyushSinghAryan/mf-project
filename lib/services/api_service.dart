// lib/services/api_service.dart
import 'dart:convert';
// import 'dart:io';
import 'package:http/http.dart' as http;
// import 'package:open_file_plus/open_file_plus.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ApiService {
  Future<bool> getUserStatus() async {
    try {
      // Get the current user's ID
      final userId = _supabase.auth.currentUser!.id;

      // Directly query the user_profiles table in Supabase
      final data = await _supabase
          .from('user_profiles')
          .select('is_active')
          .eq('id', userId)
          .single(); // Use single() for efficiency

      // Return the is_active value, defaulting to false if null
      return data['is_active'] ?? false;
    } catch (e) {
      // If the profile doesn't exist or any other error occurs,
      // safely assume the user is not subscribed.
      print('Error fetching user status from Supabase: $e');
      return false;
    }
  }

  // IMPORTANT: Replace with your computer's local IP address
  static const String _baseUrl = 'add_your_ip_address';
  final SupabaseClient _supabase;
  ApiService(this._supabase);

  // Helper for auth headers
  Future<Map<String, String>> _getHeaders() async {
    final session = _supabase.auth.currentSession;
    if (session == null) return {'Content-Type': 'application/json'};
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${session.accessToken}',
    };
  }

  // --- AUTHENTICATION ---
  Future<void> syncUser() async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$_baseUrl/api/sync_user'),
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to sync user with backend.');
    }
  }

  // --- PUBLIC DATA ---
  Future<List<dynamic>> getMutualFunds() async {
    final response = await http.get(Uri.parse('$_baseUrl/api/mutual-funds'));
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load mutual funds');
  }

  Future<List<dynamic>> getFinancialLiteracyChapters() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/financial-literacy'),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load financial literacy content');
    }
  }

  Future<List<dynamic>> getStocks() async {
    final response = await http.get(Uri.parse('$_baseUrl/api/stocks'));
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load stocks');
  }

  // --- NEW METHOD FOR STOCK DETAILS ---
  Future<Map<String, dynamic>> getStockDetail(String stockId) async {
    final response = await http.get(Uri.parse('$_baseUrl/api/stock/$stockId'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('Stock portfolio not found.');
    } else {
      throw Exception('Failed to load stock details');
    }
  }

  // Future<List<dynamic>> getPricingPlans() async {
  //   final response = await http.get(Uri.parse('$_baseUrl/api/pricing'));
  //   print(response.body);
  //   if (response.statusCode == 200) {
  //     return jsonDecode(response.body);
  //   } else {
  //     throw Exception('Failed to load pricing plans');
  //   }
  // }

  Future<List<dynamic>> getPricingPlans() async {
    final response = await http.get(Uri.parse('$_baseUrl/api/pricing'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> decodedJson = jsonDecode(response.body);
      print(response.body);

      final Map<String, dynamic> plansMap = decodedJson['plans'];
      return plansMap.values.toList();
    } else {
      throw Exception('Failed to load pricing plans');
    }
  }

  /// Correctly handles FunctionException by using e.toString()
  Future<Map<String, dynamic>> createStripeCheckout(String priceId) async {
    final supabase = Supabase.instance.client;

    try {
      final response = await supabase.functions.invoke(
        'create-stripe-checkout',
        body: {'priceId': priceId},
      );

      if (response.status != 200) {
        final errorDetails =
            response.data['error'] ?? 'Unknown error from function.';
        throw Exception('Failed to create checkout session: $errorDetails');
      }

      return response.data;
    } on FunctionException catch (e) {
      // FIX: Use e.toString() for a descriptive error message
      throw Exception('Failed to invoke function: ${e.toString()}');
    } catch (e) {
      throw Exception('An unknown error occurred: $e');
    }
  }

  Future<Map<String, dynamic>> createPaymentIntent(String priceId) async {
    final supabase = Supabase.instance.client;
    try {
      final response = await supabase.functions.invoke(
        'create-payment-intent', // The name of your NEW edge function
        body: {'priceId': priceId},
      );
      if (response.status != 200) {
        final errorDetails =
            response.data['error'] ?? 'Unknown function error.';
        throw Exception('Failed to create payment intent: $errorDetails');
      }
      return response.data;
    } on FunctionException catch (e) {
      throw Exception('Failed to invoke function: ${e.toString()}');
    } catch (e) {
      throw Exception('An unknown error occurred: $e');
    }
  }

  // --- PROTECTED DATA ---
  Future<Map<String, dynamic>> getHomeData() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl/api/home_data'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      // Decode the error from the server for better debugging
      final errorBody = jsonDecode(response.body);
      throw Exception('Failed to load home screen data: ${errorBody['error']}');
    }
  }

  Future<Map<String, dynamic>> getPortfolioData() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl/api/portfolio_data'),
      headers: headers,
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load portfolio data');
  }

  Future<Map<String, dynamic>> getStockRiskData() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl/api/risk_data'),
      headers: headers,
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load stock risk data');
  }

  Future<Map<String, dynamic>> getMfRiskData() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl/api/mf_risk_data'),
      headers: headers,
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load mutual fund risk data');
  }

  Future<String> getChatResponse(String message) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/chat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'message': message}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Assuming the response structure is {'status': 'success', 'response': '...'}
      return data['response'] ?? 'Sorry, I could not get a response.';
    } else {
      throw Exception('Failed to get chat response from server.');
    }
  }

  Future<void> updateUserProfile(Map<String, dynamic> profileData) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$_baseUrl/api/update-profile'),
      headers: headers,
      body: jsonEncode(profileData),
    );

    if (response.statusCode != 200) {
      // You can add more detailed error handling here
      throw Exception('Failed to update user profile.');
    }
  }

  /// Fetches trades with optional filtering.
  /// Corresponds to the /api/pro_trades backend endpoint.
  Future<List<dynamic>> getProTrades({
    String status = 'live',
    String category = 'All',
    String tag = 'All',
  }) async {
    final headers = await _getHeaders();
    final uri = Uri.parse(
      '$_baseUrl/api/pro_trades?status=$status&category=$category&tag=$tag',
    );
    final response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load pro trades');
    }
  }

  /// Fetches all trades from the user's watchlist.
  /// Corresponds to the /api/watchlist backend endpoint.
  Future<List<dynamic>> getWatchlist() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl/api/watchlist'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load watchlist');
    }
  }

  Future<List<dynamic>> getOrders() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl/api/get_orders'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load orders');
    }
  }

  // Method to download an invoice, save it, and open it
  // Future<void> downloadInvoice(String orderId) async {
  //   final headers = await _getHeaders();
  //   final response = await http.get(
  //     Uri.parse('$_baseUrl/api/invoice/$orderId/download'),
  //     headers: headers,
  //   );

  //   if (response.statusCode == 200) {
  //     // 1. Get the directory to save the file
  //     final directory = await getApplicationDocumentsDirectory();
  //     final filePath = '${directory.path}/invoice_$orderId.pdf';
  //     final file = File(filePath);

  //     // 2. Write the PDF data to the file
  //     await file.writeAsBytes(response.bodyBytes);

  //     // 3. Open the file for the user to view
  //     final result = await OpenFile.open(filePath);
  //     if (result.type != ResultType.done) {
  //       throw Exception(
  //         'Could not open the downloaded file: ${result.message}',
  //       );
  //     }
  //   } else {
  //     final errorData = jsonDecode(response.body);
  //     throw Exception(errorData['error'] ?? 'Failed to download invoice');
  //   }
  // }

  /// Adds or removes a trade from the user's watchlist.
  /// Corresponds to the /api/toggle_watchlist backend endpoint.
  Future<Map<String, dynamic>> toggleWatchlist(int tradeId) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$_baseUrl/api/toggle_watchlist'),
      headers: headers,
      body: jsonEncode({'trade_id': tradeId}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to toggle watchlist status');
    }
  }
}
