// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class ApiService {
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

  Future<List<dynamic>> getPricingPlans() async {
    final response = await http.get(Uri.parse('$_baseUrl/api/pricing'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load pricing plans');
    }
  }

  // --- PROTECTED DATA ---

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
