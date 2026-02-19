import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider with ChangeNotifier {
  // --- Private variables ---
  User? _currentUser;
  AuthStatus _status = AuthStatus.initial;
  String? _errorMessage;
  String? _token; // Stores auth token

  // --- Getters ---
  User? get currentUser => _currentUser;
  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == AuthStatus.loading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get hasError => _status == AuthStatus.error;
  String? get token => _token;

  static const String _tokenKey = 'auth_token';

  // --- Mock user database ---
  final Map<String, Map<String, String>> _mockUsers = {
    'user1': {
      'id': '1',
      'name': 'Allan Paterson',
      'email': 'allan@example.com',
      'password': 'password123',
      'profileImage':
          'https://cdn.now.howstuffworks.com/media-content/0b7f4e9b-f59c-4024-9f06-b3dc12850ab7-1920-1080.jpg',
    },
    'user2': {
      'id': '2',
      'name': 'Emma Watson',
      'email': 'emma@example.com',
      'password': 'password123',
      'profileImage': 'https://randomuser.me/api/portraits/women/44.jpg',
    },
  };

  AuthProvider() {
    _loadToken(); // Attempt auto-login on app start
  }

  // --- Token Logic ---
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    _token = token;
  }

  Future<void> _removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    _token = null;
  }

  Future<void> _loadToken() async {
    _setLoading();
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedToken = prefs.getString(_tokenKey);

      if (storedToken != null) {
        // Token exists → auto-login
        _token = storedToken;
        // For mock, pick first user
        final mock = _mockUsers['user1']!;
        _currentUser = User(
          id: mock['id']!,
          name: mock['name']!,
          email: mock['email']!,
          profileImage: mock['profileImage']!,
          bio: 'Hello, I\'m using the app!',
          followers: 1247,
          following: 892,
          posts: 156,
          isVerified: true,
          createdAt: DateTime.now(),
          lastActive: DateTime.now(),
        );
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
      notifyListeners();
    } catch (e) {
      _setError('Failed to load session');
    }
  }

  // --- Sign In ---
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    final validationError = _validateEmail(email) ?? _validatePassword(password);
    if (validationError != null) {
      _setError(validationError);
      return false;
    }

    _setLoading();
    await Future.delayed(const Duration(seconds: 1));

    try {
      final userEntry = _mockUsers.values.firstWhere(
        (u) => u['email'] == email && u['password'] == password,
        orElse: () => {},
      );

      if (userEntry.isEmpty) {
        _setError('Invalid email or password');
        return false;
      }

      // Generate a fake token
      final fakeToken = 'token_${userEntry['id']}';
      await _saveToken(fakeToken);

      _currentUser = User(
        id: userEntry['id']!,
        name: userEntry['name']!,
        email: userEntry['email']!,
        profileImage: userEntry['profileImage']!,
        bio: 'Hello, I\'m using the app!',
        followers: 1247,
        following: 892,
        posts: 156,
        isVerified: userEntry['id'] == '1',
        createdAt: DateTime.now(),
        lastActive: DateTime.now(),
      );

      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to sign in');
      return false;
    }
  }

  // --- Sign Up ---
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final validationError =
        _validateName(name) ?? _validateEmail(email) ?? _validatePassword(password);
    if (validationError != null) {
      _setError(validationError);
      return false;
    }

    _setLoading();
    await Future.delayed(const Duration(seconds: 1));

    if (_mockUsers.values.any((u) => u['email'] == email)) {
      _setError('Email already registered');
      return false;
    }

    final newUserId =
        (int.parse(_mockUsers.keys.last.replaceAll('user', '')) + 1).toString();

    _mockUsers['user$newUserId'] = {
      'id': newUserId,
      'name': name,
      'email': email,
      'password': password,
      'profileImage': 'https://via.placeholder.com/150',
    };

    final fakeToken = 'token_$newUserId';
    await _saveToken(fakeToken);

    _currentUser = User(
      id: newUserId,
      name: name,
      email: email,
      profileImage: 'https://via.placeholder.com/150',
      bio: 'Hello, I\'m new here!',
      followers: 0,
      following: 0,
      posts: 0,
      isVerified: false,
      createdAt: DateTime.now(),
      lastActive: DateTime.now(),
    );

    _status = AuthStatus.authenticated;
    notifyListeners();
    return true;
  }

  // --- Reset Password ---
  Future<bool> resetPassword({required String email}) async {
    final validationError = _validateEmail(email);
    if (validationError != null) {
      _setError(validationError);
      return false;
    }

    _setLoading();
    await Future.delayed(const Duration(seconds: 1));

    if (!_mockUsers.values.any((u) => u['email'] == email)) {
      _setError('Email not found');
      return false;
    }

    _status = AuthStatus.unauthenticated;
    _errorMessage = null;
    notifyListeners();
    return true;
  }

  // --- Sign Out ---
  Future<void> signOut() async {
    _setLoading();
    await Future.delayed(const Duration(seconds: 1));
    _currentUser = null;
    await _removeToken();
    _status = AuthStatus.unauthenticated;
    _errorMessage = null;
    notifyListeners();
  }

  // --- Update Profile ---
  Future<bool> updateProfile({String? name, String? bio, String? profileImage}) async {
    if (_currentUser == null) {
      _setError('No user logged in');
      return false;
    }

    _setLoading();
    await Future.delayed(const Duration(seconds: 1));

    _currentUser = _currentUser!.copyWith(
      name: name,
      bio: bio,
      profileImage: profileImage,
      lastActive: DateTime.now(),
    );
    _status = AuthStatus.authenticated;
    notifyListeners();
    return true;
  }

  // --- Update last active ---
  void updateLastActive() {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(lastActive: DateTime.now());
    notifyListeners();
  }

  // --- Clear Error ---
  void clearError() {
    if (_status == AuthStatus.error) {
      _errorMessage = null;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  // --- Private Helpers ---
  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _status = AuthStatus.error;
    _errorMessage = message;
    notifyListeners();
  }

  // --- Validators ---
  String? _validateName(String? name) {
    if (name == null || name.isEmpty) return 'Name is required';
    if (name.length < 2) return 'Name too short';
    return null;
  }

  String? _validateEmail(String? email) {
    if (email == null || email.isEmpty) return 'Email is required';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return 'Invalid email address';
    }
    return null;
  }

  String? _validatePassword(String? password) {
    if (password == null || password.isEmpty) return 'Password is required';
    if (password.length < 6) return 'Password must be at least 6 characters';
    return null;
  }
}