import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:here/providers/auth_provider.dart';
import 'package:here/main_navigation.dart'; // We'll create this next
import 'package:here/auth_page.dart';

class AuthChecker extends StatelessWidget {
const AuthChecker({super.key});

@override
Widget build(BuildContext context) {
final authState = context.watch<AuthProvider>();

if (authState.isLoading) {  
  return const Scaffold(  
    body: Center(child: CircularProgressIndicator()),  
  );  
}  
  
if (authState.isAuthenticated) {  
  return const MainNavigation(); // Your 5 buttons live here  
} else {  
  return const AuthPage(); // Your login page  
}

}
}