import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart'; // Access supabase
import './questionnaire_screen.dart';
import './day_selection_screen.dart';
import '../models/workout_level.dart'; // For enum

// This widget decides whether to show the Questionnaire or the main workout flow (DaySelection)
class HomeOrQuestionnaireNavigator extends StatefulWidget {
  const HomeOrQuestionnaireNavigator({super.key});

  @override
  State<HomeOrQuestionnaireNavigator> createState() =>
      _HomeOrQuestionnaireNavigatorState();
}

class _HomeOrQuestionnaireNavigatorState
    extends State<HomeOrQuestionnaireNavigator> {
  @override
  Widget build(BuildContext context) {
    // Use a FutureBuilder to check the user's profile
    return FutureBuilder<Map<String, dynamic>?>(
      // Expect profile data or null
      future: _fetchUserProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          // Handle error or missing profile - maybe go back to Auth or show error
          print("Error fetching profile: ${snapshot.error}");
          // For now, fallback to Questionnaire as profile might be incomplete
          // In a production app, might redirect to auth with an error message
          return const QuestionnaireScreen();
        }

        final profile = snapshot.data!;
        final assignedLevelString = profile['assigned_level'];

        // Check if an assigned level exists in the profile
        if (assignedLevelString != null && assignedLevelString.isNotEmpty) {
          // User has completed questionnaire, navigate to DaySelectionScreen
          try {
            // Convert the string level back to the enum
            final level = WorkoutLevelType.values.firstWhere(
              (e) => e.toString() == 'WorkoutLevelType.$assignedLevelString',
            );
            // Use WidgetsBinding to navigate after build completes
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                // Check if widget is still mounted before navigating
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => DaySelectionScreen(levelType: level),
                  ),
                );
              }
            });
            // Return loading indicator while navigation happens post-frame
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } catch (e) {
            print("Error parsing assigned level '$assignedLevelString': $e");
            // Fallback to questionnaire if level is invalid
            return const QuestionnaireScreen();
          }
        } else {
          // No assigned level, user needs to complete the questionnaire
          return const QuestionnaireScreen();
        }
      },
    );
  }

  // Fetches the user profile from Supabase
  Future<Map<String, dynamic>?> _fetchUserProfile() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not logged in');
    }

    try {
      final response =
          await supabase
              .from('profiles') // Assuming your table is named 'profiles'
              .select() // Select all columns
              .eq('id', userId) // Filter by the user's ID
              .single(); // Expect exactly one row

      return response; // Returns the profile map
    } catch (e) {
      print("Supabase fetch profile error: $e");
      // If profile doesn't exist yet (e.g., right after signup before insert),
      // return null or an empty map to indicate it needs creation/completion.
      if (e is PostgrestException && e.code == 'PGRST116') {
        // PGRST116: JSON object requested, multiple (or no) rows returned
        // This likely means no profile row exists yet.
        return null;
      }
      rethrow; // Rethrow other errors
    }
  }
}
