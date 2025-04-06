import './exercise.dart';

class WorkoutDay {
  final String dayName; // e.g., "Monday", "Tuesday"
  final String themeTitle; // e.g., "Graceful Beginnings"
  final String themeSubtitle; // e.g., "(Full Body Integration)"
  final List<Exercise> exercises;
  final bool isRestDay;
  final String? restDayImagePath; // Path to image for rest days

  WorkoutDay({
    required this.dayName,
    required this.themeTitle,
    required this.themeSubtitle,
    required this.exercises,
    this.isRestDay = false,
    this.restDayImagePath, // Add to constructor
  });
}
