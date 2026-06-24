import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AppState extends ChangeNotifier {
  final ApiService _api = ApiService();

  // Authentication State
  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;
  String _username = '';
  String get username => _username;

  // Workspace Settings
  int? _selectedAccountId;
  int? get selectedAccountId => _selectedAccountId;
  String? _selectedCategory;
  String? get selectedCategory => _selectedCategory;
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  // Loaded Data
  List<dynamic> _accounts = [];
  List<dynamic> get accounts => _accounts;
  List<dynamic> _emails = [];
  List<dynamic> get emails => _emails;
  Map<String, dynamic>? _selectedEmail;
  Map<String, dynamic>? get selectedEmail => _selectedEmail;
  Map<String, dynamic> _analytics = {};
  Map<String, dynamic> get analytics => _analytics;

  // AI Assistant Chat State
  final List<Map<String, String>> _chatMessages = [
    {
      'sender': 'assistant',
      'text': 'Hello! I am MailMind AI, your intelligent inbox assistant. How can I help you today?'
    }
  ];
  List<Map<String, String>> get chatMessages => _chatMessages;

  // Loading Toggles
  bool _isLoadingEmails = false;
  bool get isLoadingEmails => _isLoadingEmails;
  bool _isSendingMessage = false;
  bool get isSendingMessage => _isSendingMessage;

  Future<void> login(String user, String pass) async {
    try {
      final res = await _api.login(user, pass);
      if (res['status'] == 'success') {
        _isAuthenticated = true;
        _username = res['username'];
        notifyListeners();
        await initializeData();
      }
    } catch (e) {
      debugPrint('Login failed: $e');
      rethrow;
    }
  }

  Future<void> initializeData() async {
    await fetchAccounts();
    await fetchEmails();
    await fetchAnalytics();
  }

  Future<void> fetchAccounts() async {
    try {
      _accounts = await _api.fetchAccounts();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching accounts: $e');
    }
  }

  Future<void> fetchEmails() async {
    _isLoadingEmails = true;
    notifyListeners();
    try {
      _emails = await _api.fetchEmails(
        accountId: _selectedAccountId,
        category: _selectedCategory,
      );
    } catch (e) {
      debugPrint('Error fetching emails: $e');
    } finally {
      _isLoadingEmails = false;
      notifyListeners();
    }
  }

  Future<void> fetchAnalytics() async {
    try {
      _analytics = await _api.fetchAnalyticsStats();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching analytics: $e');
    }
  }

  void selectAccount(int? accountId) {
    _selectedAccountId = accountId;
    fetchEmails();
  }

  void selectCategory(String? category) {
    _selectedCategory = category;
    fetchEmails();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> selectEmail(int emailId) async {
    try {
      _selectedEmail = await _api.fetchEmailDetail(emailId);
      notifyListeners();
      
      // If email was unread, update it locally and on backend
      final emailIdx = _emails.indexWhere((e) => e['id'] == emailId);
      if (emailIdx != -1 && !_emails[emailIdx]['is_read']) {
        _emails[emailIdx]['is_read'] = true;
        notifyListeners();
        await _api.updateReadStatus(emailId, true);
        fetchAnalytics(); // Update unread stats count
      }
    } catch (e) {
      debugPrint('Error fetching email details: $e');
    }
  }

  Future<void> addAccount(String name, String provider, String email) async {
    try {
      await _api.addAccount(name, provider, email);
      await fetchAccounts();
    } catch (e) {
      debugPrint('Error adding account: $e');
    }
  }

  Future<void> removeAccount(int accountId) async {
    try {
      await _api.deleteAccount(accountId);
      if (_selectedAccountId == accountId) {
        _selectedAccountId = null;
      }
      await initializeData();
    } catch (e) {
      debugPrint('Error deleting account: $e');
    }
  }

  Future<void> askAssistant(String query) async {
    if (query.trim().isEmpty) return;
    
    _chatMessages.add({'sender': 'user', 'text': query});
    _isSendingMessage = true;
    notifyListeners();
    
    try {
      final reply = await _api.chatWithAssistant(query);
      _chatMessages.add({'sender': 'assistant', 'text': reply});
    } catch (e) {
      _chatMessages.add({
        'sender': 'assistant',
        'text': 'Sorry, I encountered an issue querying your mail workspace.'
      });
    } finally {
      _isSendingMessage = false;
      notifyListeners();
    }
  }

  Future<void> triggerMockSync() async {
    try {
      await _api.triggerSync();
      await initializeData();
    } catch (e) {
      debugPrint('Error syncing new mail: $e');
    }
  }

  void logout() {
    _isAuthenticated = false;
    _username = '';
    _selectedAccountId = null;
    _selectedCategory = null;
    _selectedEmail = null;
    notifyListeners();
  }
}
