import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import './auth_screen.dart'; // Navigate to AuthScreen
import '../main.dart'; // To access supabase client
import './home_or_questionnaire_navigator.dart'; // Decides next screen after login

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

    final session = supabase.auth.currentSession;

    if (session == null) {
      // Not logged in, go to AuthScreen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AuthScreen()),
      );
    } else {
      // Logged in, decide where to go next (check profile)
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const HomeOrQuestionnaireNavigator(),
        ),
      );
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
