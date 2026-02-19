import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:here/providers/auth_provider.dart';
import 'package:here/main_navigation.dart';
import 'package:here/auth_page.dart';

class AuthChecker extends StatefulWidget {
  const AuthChecker({super.key});

  @override
  State<AuthChecker> createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker>
    with TickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    // Splash animation
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..forward();

    // Wait for 2 seconds, then check auth status
    Future.delayed(const Duration(seconds: 2), _waitForAuth);
  }

  void _waitForAuth() async {
    final authProvider = context.read<AuthProvider>();

    // Wait until the provider finishes auto-login
    while (authProvider.status == AuthStatus.initial ||
        authProvider.isLoading) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    Widget nextScreen;

    if (authProvider.isAuthenticated) {
      nextScreen = const MainNavigation();
    } else {
      nextScreen = const AuthPage();
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => nextScreen),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FadeTransition(
          opacity: _controller,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.6, end: 1.0).animate(
              CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('images/logo.png', width: 120, height: 120),
                const SizedBox(height: 16),
                Text(
                  'Here',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}