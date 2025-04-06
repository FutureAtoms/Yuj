import 'package:flutter/material.dart';
import '../data/workout_parser.dart'; // To load data
import '../models/workout_level.dart';
import './exercise_screen.dart'; // To navigate to workout
import './rest_day_screen.dart'; // To navigate to rest day

// Helper function to get display name for level
String _getDisplayLevelName(WorkoutLevelType levelType) {
  switch (levelType) {
    case WorkoutLevelType.easy:
      return 'Gentle Flow'; // Meditative name for Easy
    case WorkoutLevelType.intermediate:
      return 'Steady Rhythm'; // Meditative name for Intermediate
    case WorkoutLevelType.advanced:
      return 'Full Power'; // Meditative name for Advanced
  }
}

class DaySelectionScreen extends StatefulWidget {
  final WorkoutLevelType levelType;

  const DaySelectionScreen({required this.levelType, super.key});

  @override
  State<DaySelectionScreen> createState() => _DaySelectionScreenState();
}

class _DaySelectionScreenState extends State<DaySelectionScreen> {
  late WorkoutLevel workoutLevelData;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadWorkoutData();
  }

  void _loadWorkoutData() {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    try {
      // We only handle the 'easy' level for now.
      if (widget.levelType == WorkoutLevelType.easy) {
        workoutLevelData = WorkoutDataParser().parseEasyWorkout();
      } else {
        // Handle other levels or show an empty state
        workoutLevelData = WorkoutLevel(
          levelType: widget.levelType,
          name: widget.levelType.toString().split('.').last.toUpperCase(),
          days: [],
        );
      }
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error loading workout data: $e';
        // Create a default empty level to avoid null errors in build
        workoutLevelData = WorkoutLevel(
          levelType: widget.levelType,
          name: widget.levelType.toString().split('.').last.toUpperCase(),
          days: [],
        );
      });
      print("Error parsing workout data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use the helper function for the display name
    final displayLevelName =
        isLoading
            ? 'Loading...'
            : _getDisplayLevelName(workoutLevelData.levelType);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('$displayLevelName - Select Day'),
        // Theme handles styling
      ),
      body: Container(
        // Add subtle gradient background
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary.withAlpha((255 * 0.05).round()),
              colorScheme.secondary.withAlpha((255 * 0.1).round()),
            ],
          ),
        ),
        child:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage.isNotEmpty
                ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      errorMessage,
                      style: TextStyle(color: colorScheme.error, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
                : workoutLevelData.days.isEmpty
                ? const Center(
                  child: Text(
                    'No workouts defined for this level yet.',
                    style: TextStyle(fontSize: 16),
                  ),
                )
                : ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 16.0,
                  ),
                  itemCount: workoutLevelData.days.length,
                  separatorBuilder:
                      (context, index) =>
                          const SizedBox(height: 10), // Space between cards
                  itemBuilder: (context, index) {
                    final day = workoutLevelData.days[index];
                    return Card(
                      clipBehavior: Clip.antiAlias,
                      child: ListTile(
                        leading: Container(
                          width: 50, // Give leading container fixed width
                          height: 50, // and height
                          decoration: BoxDecoration(
                            color:
                                day.isRestDay
                                    ? Colors.grey.shade300
                                    : colorScheme.primaryContainer.withAlpha(
                                      (255 * 0.8).round(),
                                    ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          // Use Image for rest day, Icon otherwise
                          child:
                              day.isRestDay
                                  ? day.restDayImagePath != null
                                      ? ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          6.0,
                                        ),
                                        child: Image.asset(
                                          day.restDayImagePath!,
                                          fit: BoxFit.cover,
                                          // Make image fill the container
                                          width: 50,
                                          height: 50,
                                          errorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                            print(
                                              "Error loading rest day image: ${day.restDayImagePath} - $error",
                                            );
                                            return Icon(
                                              Icons.bedtime_outlined,
                                              color: Colors.grey.shade800,
                                              size: 28,
                                            );
                                          },
                                        ),
                                      )
                                      // Fallback icon if rest day image path is null
                                      : Icon(
                                        Icons.bedtime_outlined,
                                        color: Colors.grey.shade800,
                                        size: 28,
                                      )
                                  : Icon(
                                    Icons.fitness_center_outlined,
                                    color: colorScheme.onPrimaryContainer,
                                    size: 28,
                                  ),
                        ),
                        title: Text(
                          day.dayName,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          "${day.themeTitle} ${day.themeSubtitle}".trim(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[700],
                          ),
                        ),
                        trailing: Icon(
                          Icons.chevron_right,
                          color: Colors.grey[400],
                        ), // Show chevron for all
                        onTap: () {
                          // Handle tap for both types
                          if (day.isRestDay) {
                            // Navigate to RestDayScreen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => RestDayScreen(workoutDay: day),
                              ),
                            );
                          } else {
                            // Navigate to ExerciseScreen for the selected day
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        ExerciseScreen(workoutDay: day),
                              ),
                            );
                          }
                        },
                        tileColor:
                            theme.cardColor, // Use default card color for all
                        enabled: true, // All tiles are tappable
                      ),
                    );
                  },
                ),
      ),
    );
  }
}
