import 'package:flutter/material.dart';
import 'package:pemmob/screens/login_screen.dart';
import 'package:pemmob/screens/splash_screen.dart';
import 'package:pemmob/screens/dashboard_screen.dart';
import 'package:pemmob/screens/register_screen.dart'; // Tambahkan import ini

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bantoo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // Tambahkan konfigurasi warna dan font sesuai dengan desain Figma
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E2A78),
          primary: const Color(0xFF1E2A78),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E2A78),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(), // Tambahkan route register
        '/dashboard': (context) => const DashboardScreen(),
        // Add other routes as needed
      },
    );
  }
}