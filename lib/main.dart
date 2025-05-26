import 'package:flutter/material.dart';
import 'services/api_service.dart';
// Import your required screens
import 'screens/home_screen.dart'; // Replace with your actual home screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize API service with stored URL
  await ApiService.initializeBaseUrl();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bantoo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomeScreen(), // Replace with your home screen
      // Your app routes
    );
  }
}