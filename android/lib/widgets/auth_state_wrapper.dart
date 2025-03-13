import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class AuthStateWrapper extends StatelessWidget {
  final Widget authenticatedRoute;
  final Widget unauthenticatedRoute;
  final Widget? loadingWidget;

  const AuthStateWrapper({
    Key? key,
    required this.authenticatedRoute,
    required this.unauthenticatedRoute,
    this.loadingWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, _) {
        // Show loading indicator while auth is initializing
        if (!authService.isInitialized) {
          return loadingWidget ??
              Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // Route based on authentication state
        if (authService.isAuthenticated) {
          return authenticatedRoute;
        } else {
          return unauthenticatedRoute;
        }
      },
    );
  }
}
