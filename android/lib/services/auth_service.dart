import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:waste2ways/utils/api_client.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ApiClient _apiClient = ApiClient(enableLogging: true);

  User? _user;
  UserModel? _userModel;
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  User? get user => _user;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  bool get isInitialized => _isInitialized;

  AuthService() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      if (user != null) {
        _fetchUserData(user.uid);
      } else {
        _userModel = null;
      }
      _isInitialized = true;
      notifyListeners();
    });
  }

  // Check if user is authenticated and redirect if needed
  Future<bool> checkAuthState(BuildContext context) async {
    // Wait for auth to initialize if it hasn't already
    if (!_isInitialized) {
      await Future.doWhile(
        () => Future.delayed(
          Duration(milliseconds: 100),
        ).then((_) => !_isInitialized),
      );
    }

    if (_user != null) {
      // User is logged in, redirect to home if on auth screens
      return true;
    }
    // User is not logged in
    return false;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  Future<void> _fetchUserData(String firebaseId) async {
    try {
      final userDetails = await _apiClient.get(
        "/users/me",
        fromJson: (json) => UserModel.fromJson(json),
      );

      _userModel = userDetails as UserModel?;
      notifyListeners();
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
    String? phone,
    required String city,
    required String state,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        final newUser = UserModel(
          firebaseId: result.user!.uid,
          // firebaseId: "J1VF5x1e7XdOB5qT20S2HWHh7zr2",
          email: email,
          name: name,
          phone: phone,
          city: city,
          state: state,
        );

        final object = await _apiClient.post(
          "/users/register",
          body: newUser,
          fromJson: (json) => UserModel.fromJson(json),
        );

        print(object);

        notifyListeners();
        _setLoading(false);
        return true;
      }
      _setLoading(false);
      return false;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _setError(null);

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
