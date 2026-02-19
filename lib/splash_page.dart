// splash_page.dart (simplified)
import 'package:flutter/material.dart';
import 'package:here/auth_checker.dart'; // Import new file

class SplashPage extends StatefulWidget {
const SplashPage({super.key});

@override
State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
late final AnimationController _controller;

@override
void initState() {
super.initState();
_controller = AnimationController(
duration: const Duration(milliseconds: 1200),
vsync: this,
)..forward();

// Navigate after 2 seconds  
Future.delayed(const Duration(seconds: 2), () {  
  if (mounted) {  
    Navigator.pushReplacement(  
      context,  
      MaterialPageRoute(builder: (_) => const AuthChecker()),  
    );  
  }  
});

}

@override
void dispose() {
_controller.dispose();
super.dispose();
}

@override
Widget build(BuildContext context) {
// Keep your beautiful animation code here
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
// Your logo and text here
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