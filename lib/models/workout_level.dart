import './workout_day.dart';

enum WorkoutLevelType { easy, intermediate, advanced }

class WorkoutLevel {
  final WorkoutLevelType levelType;
  final String name; // e.g., "Easy", "Intermediate", "Advanced"
  final List<WorkoutDay> days;

  WorkoutLevel({
    required this.levelType,
    required this.name,
    required this.days,
  });
}
