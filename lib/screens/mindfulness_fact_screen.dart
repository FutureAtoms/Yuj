import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts
import './questionnaire_screen.dart';
import './day_selection_screen.dart';
import '../models/workout_level.dart'; // To parse level name
import '../models/fact_item.dart'; // Import the new fact models and loader

class MindfulnessFactScreen extends StatefulWidget {
  const MindfulnessFactScreen({super.key});

  @override
  State<MindfulnessFactScreen> createState() => _MindfulnessFactScreenState();
}

class _MindfulnessFactScreenState extends State<MindfulnessFactScreen> {
  // Use FactItem base class
  FactItem? _factItem;
  WorkoutLevelType? _savedLevel;
  bool _isLoading = true;
  final FactLoader _factLoader = FactLoader(); // Instance of the loader

  @override
  void initState() {
    super.initState();
    _loadDataAndSelectFact();
  }

  Future<void> _loadDataAndSelectFact() async {
    setState(() => _isLoading = true);
    try {
      // Load facts using the loader
      await _factLoader.loadFacts();
      final selectedFact = _factLoader.getRandomFact();

      // Load the saved workout level
      final prefs = await SharedPreferences.getInstance();
      final levelName = prefs.getString('selectedLevel');
      WorkoutLevelType? level;
      if (levelName != null) {
        level = WorkoutLevelType.values.firstWhere((e) => e.name == levelName);
      }

      setState(() {
        _factItem = selectedFact;
        _savedLevel = level;
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading data/fact: $e");
      setState(() {
        _factItem = HealthFact(
          statement: "Could not load fact. Please proceed.",
          source: "System",
        );
        _isLoading = false;
      });
    }
  }

  void _navigateToWorkout() {
    if (_savedLevel != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => DaySelectionScreen(levelType: _savedLevel!),
        ),
      );
    } else {
      // Handle error - maybe navigate back to questionnaire or show error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Error: Workout level not found. Please redo questionnaire.',
          ),
        ),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const QuestionnaireScreen()),
      );
    }
  }

  void _navigateToQuestionnaire() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const QuestionnaireScreen()),
    );
  }

  // Helper to build the text display based on the fact type
  Widget _buildFactDisplay(BuildContext context, FactItem item) {
    final theme = Theme.of(context);
    final textStyle = GoogleFonts.merriweather(
      // Use Merriweather
      fontSize: 19, // Further reduced font size
      fontStyle: FontStyle.italic,
      fontWeight: FontWeight.w500,
      color: Colors.black.withOpacity(0.85),
      height: 1.4, // Improve line spacing
      shadows: [
        Shadow(
          blurRadius: 0.5,
          color: Colors.black.withOpacity(0.15),
          offset: const Offset(0.5, 0.5),
        ),
      ],
    );
    final sourceStyle = theme.textTheme.bodyMedium?.copyWith(
      fontStyle: FontStyle.italic,
      color: Colors.black.withOpacity(0.7),
      fontSize: 13, // Also slightly reduce source size
    );

    if (item is HealthMyth) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Myth: ${item.myth}",
            style: textStyle.copyWith(
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.normal,
            ), // Bold for myth
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          Text(
            "Fact: ${item.fact}",
            style: textStyle, // Italic for fact
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          Text(
            "- ${item.sourceToDisplay}",
            style: sourceStyle,
            textAlign: TextAlign.center,
          ),
        ],
      );
    } else {
      // Standard fact or quote display
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            item.textToDisplay,
            style: textStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          Text(
            "- ${item.sourceToDisplay}",
            style: sourceStyle,
            textAlign: TextAlign.center,
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        // Improved background gradient
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple.shade100,
              Colors.indigo.shade200,
              // Colors.teal.shade100,
              // Colors.lightBlue.shade200,
            ],
            stops: const [0.0, 0.7], // Adjust stops for smoother transition
          ),
        ),
        child: SafeArea(
          // Ensure content avoids notches/status bar
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 30.0,
                vertical: 50.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (_isLoading)
                    const CircularProgressIndicator(color: Colors.white)
                  else if (_factItem != null)
                    Expanded(
                      // Use the helper method to build the display
                      child: _buildFactDisplay(context, _factItem!),
                    ),
                  const SizedBox(height: 40),
                  if (!_isLoading)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        // Use theme colors for consistency
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                      ),
                      onPressed: _navigateToWorkout,
                      child: const Text('CONTINUE TO WORKOUT'),
                    ),
                  const SizedBox(height: 15),
                  if (!_isLoading)
                    TextButton(
                      onPressed: _navigateToQuestionnaire,
                      child: Text(
                        'Redo Questionnaire?',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                          decoration: TextDecoration.underline, // Add underline
                          decorationColor: theme.colorScheme.onSurface
                              .withOpacity(0.7), // Match color
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
