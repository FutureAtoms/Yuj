import 'package:flutter/material.dart';
import './day_selection_screen.dart'; // We need this screen
import '../models/workout_level.dart'; // Import the model

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // In a real app, this would come from a state management solution
  // or be passed in. For now, hardcoding for simplicity.
  final WorkoutLevelType easyLevel = WorkoutLevelType.easy;
  final WorkoutLevelType intermediateLevel = WorkoutLevelType.intermediate;
  final WorkoutLevelType advancedLevel = WorkoutLevelType.advanced;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gym App - Select Level'),
        // Theme handles styling
      ),
      body: Container(
        // Add subtle gradient background matching DaySelectionScreen
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary.withOpacity(0.05),
              colorScheme.secondary.withOpacity(0.1),
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _buildLevelButton(
                  context,
                  'Easy',
                  Icons.directions_run, // Icon for Easy
                  easyLevel,
                  Colors.green.shade600,
                  true, // Enabled
                ),
                const SizedBox(height: 25),
                _buildLevelButton(
                  context,
                  'Intermediate',
                  Icons.fitness_center, // Icon for Intermediate
                  intermediateLevel,
                  Colors.orange.shade700,
                  false, // Disabled for now
                ),
                const SizedBox(height: 25),
                _buildLevelButton(
                  context,
                  'Advanced',
                  Icons.local_fire_department, // Icon for Advanced
                  advancedLevel,
                  Colors.red.shade700,
                  false, // Disabled for now
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLevelButton(
    BuildContext context,
    String title,
    IconData icon,
    WorkoutLevelType levelType,
    Color color,
    bool enabled,
  ) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 28),
      label: Text(title),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: enabled ? color : Colors.grey.shade500,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        textStyle: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0), // More rounded corners
        ),
        elevation: enabled ? 5 : 0, // Add elevation for enabled buttons
        shadowColor: enabled ? color.withOpacity(0.4) : Colors.transparent,
      ),
      onPressed:
          enabled
              ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => DaySelectionScreen(levelType: levelType),
                  ),
                );
              }
              : null,
    );
  }
}
