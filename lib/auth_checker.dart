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

    // Start the auth check process
    _checkAuthWithTimeout();
  }

  /// Refactored to prevent "Blank Screen of Death"
  Future<void> _checkAuthWithTimeout() async {
    // 1. Minimum splash time (Wait for animation + a bit of extra time)
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    final authProvider = context.read<AuthProvider>();

    // 2. Safety Timeout Logic
    // We check every 100ms for a status change, but stop after 5 seconds total.
    int maxAttempts = 50; 
    int currentAttempt = 0;

    while ((authProvider.status == AuthStatus.initial || authProvider.isLoading) && 
           currentAttempt < maxAttempts) {
      await Future.delayed(const Duration(milliseconds: 100));
      currentAttempt++;
    }

    // 3. Decide where to go
    Widget nextScreen;
    
    // If authenticated, go to main. 
    // If NOT authenticated OR if we timed out, go to AuthPage.
    if (authProvider.isAuthenticated) {
      nextScreen = const MainNavigation();
    } else {
      nextScreen = const AuthPage();
    }

    // 4. Navigate
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
    // We use a light/dark aware color to ensure the logo is visible
    final color = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: FadeTransition(
          opacity: _controller,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(
              CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ensure this path is correct in your pubspec.yaml
                Image.asset(
                  'images/logo.png', 
                  width: 120, 
                  height: 120,
                  errorBuilder: (context, error, stackTrace) => 
                    Icon(Icons.location_on, size: 100, color: color),
                ),
                const SizedBox(height: 24),
                Text(
                  'Here',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                        letterSpacing: 1.2,
                      ),
                ),
                const SizedBox(height: 10),
                // Tiny loading indicator to show the app hasn't frozen
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(color.withOpacity(0.5)),
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
