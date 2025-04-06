import 'package:flutter/material.dart';
import 'dart:async'; // For Timer
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart'; // Import main to access the supabase instance
import './auth_screen.dart'; // Navigate to Auth if not logged in
import './questionnaire_screen.dart'; // Navigate to Questionnaire if needed
import './mindfulness_fact_screen.dart'; // Import the new screen

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    // Wait for initialization if needed (though main() awaits it)
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return; // Ensure widget is still mounted

    try {
      final session = supabase.auth.currentSession;

      if (session == null) {
        // Not logged in, go to AuthScreen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AuthScreen()),
        );
      } else {
        // Logged in, check if questionnaire is completed
        final prefs = await SharedPreferences.getInstance();
        final questionnaireCompleted = prefs.getBool('questionnaireCompleted') ?? false;

        if (questionnaireCompleted) {
          // Questionnaire done, go to Mindfulness Fact Screen
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MindfulnessFactScreen()),
          );
        } else {
          // Questionnaire not done, go to QuestionnaireScreen
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const QuestionnaireScreen()),
          );
        }
      }
    } catch (e) {
      // Handle potential errors (e.g., SharedPreferences failure)
      print("Error during redirection: $e");
      // Fallback to AuthScreen in case of error
      if (mounted) {
         Navigator.of(context).pushReplacement(
           MaterialPageRoute(builder: (context) => const AuthScreen()),
         );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // Simple loading indicator
      ),
    );
  }
}
