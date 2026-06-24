import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }

  Future<List<dynamic>> fetchAccounts() async {
    final response = await http.get(Uri.parse('$baseUrl/accounts'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch accounts');
    }
  }

  Future<Map<String, dynamic>> addAccount(String name, String provider, String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/accounts'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'provider': provider,
        'email_address': email,
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to add account');
    }
  }

  Future<void> deleteAccount(int accountId) async {
    final response = await http.delete(Uri.parse('$baseUrl/accounts/$accountId'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete account');
    }
  }

  Future<List<dynamic>> fetchEmails({int? accountId, String? category}) async {
    String url = '$baseUrl/emails?';
    if (accountId != null) url += 'account_id=$accountId&';
    if (category != null) url += 'category=$category';
    
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch emails');
    }
  }

  Future<Map<String, dynamic>> fetchEmailDetail(int emailId) async {
    final response = await http.get(Uri.parse('$baseUrl/emails/$emailId'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch email detail');
    }
  }

  Future<void> updateReadStatus(int emailId, bool isRead) async {
    final response = await http.put(
      Uri.parse('$baseUrl/emails/$emailId/read'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'is_read': isRead}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update read status');
    }
  }

  Future<String> chatWithAssistant(String query) async {
    final response = await http.post(
      Uri.parse('$baseUrl/assistant/chat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'query': query}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['response'];
    } else {
      throw Exception('Assistant error');
    }
  }

  Future<Map<String, dynamic>> fetchAnalyticsStats() async {
    final response = await http.get(Uri.parse('$baseUrl/analytics/stats'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch analytics');
    }
  }

  Future<Map<String, dynamic>> triggerSync() async {
    final response = await http.post(Uri.parse('$baseUrl/sync/mock'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to sync new mail');
    }
  }
}

