import '../models/exercise.dart';
import '../models/workout_day.dart';
import '../models/workout_level.dart';

// Represents the raw workout data provided.
// In a real app, this might come from a file, API, or database.
const String rawWorkoutData = """
🌸 Monday – Graceful Beginnings (Full Body Integration)

Theme Colors: Soft pastels
Mood: Awakening, gentle activation

Routine:
	•	Warm-up (5 min): Gentle stretching with deep breathing
Inhale as you extend limbs, exhale as you relax.
	•	Goblet Squat: 3 sets, 12 reps, 60 sec rest
Inhale down, exhale rise. Strengthens legs and core.
	•	Dumbbell Row: 3 sets, 12 reps per arm, 60 sec rest
Exhale pulling up, inhale lowering. Builds back and arms.
	•	Shoulder Press: 3 sets, 10 reps, 60 sec rest
Exhale lifting weights, inhale lowering. Tones shoulders.
	•	Cooldown (5 min): Rhythmic, full-body stretches

Benefit:

Muscles awaken gently, bones strengthen with breath—your energy begins to rise.
(Strengthens muscles, improves bone density, enhances metabolism)

⸻

☁️ Tuesday – Empowering Balance (Upper Body Focus)

Theme Colors: Cool blues and silvers
Mood: Strength and grace

Routine:
	•	Warm-up (5 min): Neck and shoulder rolls with deep breaths
	•	Chest Press: 3 sets, 12 reps, 60 sec rest
Exhale up, inhale down. Engages chest and triceps.
	•	Bicep Curls: 3 sets, 12 reps, 60 sec rest
Exhale curling up, inhale lowering. Tones arms.
	•	Triceps Kickbacks: 3 sets, 10 reps, 60 sec rest
Exhale extend, inhale return. Defines triceps.
	•	Cooldown (5 min): Arm and shoulder stretches

Benefit:

Arms embracing strength gracefully, heart steady, beating stronger.
(Tones upper body, boosts endurance, improves posture)

⸻

🌙 Wednesday – Reflective Pause (Rest Day)

Theme Colors: Silver, indigo, midnight blue
Mood: Stillness, restoration

Routine:
	•	10 minutes of breathing meditation
Inhale calm, exhale tension.

Benefit:

Rest deepens strength, like silence between notes creating music.
(Supports muscle repair, reduces cortisol, balances nervous system)

⸻

🌿 Thursday – Rooted Strength (Lower Body Focus)

Theme Colors: Earthy greens, browns, terracotta
Mood: Grounded, powerful

Routine:
	•	Warm-up (5 min): Gentle leg swings
	•	Lunges: 3 sets, 10 reps per leg, 60 sec rest
Inhale step forward, exhale return.
	•	Dumbbell Deadlifts: 3 sets, 10 reps, 60 sec rest
Exhale rise, inhale lower. Activates hamstrings and glutes.
	•	Calf Raises: 3 sets, 15 reps, 60 sec rest
Exhale lift, inhale lower.
	•	Cooldown (5 min): Hamstring & quad stretches

Benefit:

Resilience blooms from stable foundations—your body grounded, enduring.
(Improves balance, leg strength, and joint health)

⸻

🌊 Friday – Gentle Fortitude (Core & Stability)

Theme Colors: Soft ocean blues, moonlit greys
Mood: Centering, internal strength

Routine:
	•	Warm-up (5 min): Slow torso rotations
	•	Russian Twists: 3 sets, 15 reps per side, 60 sec rest
Exhale twist, inhale center.
	•	Weighted Sit-ups: 3 sets, 10 reps, 60 sec rest
Exhale rise, inhale lower.
	•	Plank with Dumbbell Tap: 3 sets, 30 sec, 60 sec rest
Steady breath, tap dumbbell side to side.
	•	Cooldown (5 min): Seated or lying spine and side-body stretches

Benefit:

Core quiet and strong, breath steadying the storm—calm and controlled.
(Improves core stability, balance, and spine support)

⸻

🍃 Saturday – Healing Stillness (Rest Day)

Theme Colors: Misty green, gold, ivory
Mood: Peaceful recovery

Routine:
	•	Stillness or gentle walk (10 min)
Feel your breath, soften your presence.

Benefit:

Let the peace of today nourish tomorrow's strength.
(Enhances repair, reduces fatigue, nurtures mental clarity)

⸻

🌅 Sunday – Harmonious Flow (Full Body Routine)

Theme Colors: Sunrise coral, sky blue, golden glow
Mood: Flow, unity, elevation

Routine:
	•	Warm-up (5 min): Full-body mindful stretching
	•	Dumbbell Thrusters: 3 sets, 10 reps, 60 sec rest
Inhale squat, exhale press.
	•	Bent-over Rows: 3 sets, 12 reps, 60 sec rest
Exhale pull, inhale release.
	•	Side Lunges: 3 sets, 10 per side, 60 sec rest
Inhale out, exhale return.
	•	Cooldown (5 min): Forward folds, child's pose

Benefit:

Breath and body entwined, health blooming in full harmony.
(Boosts coordination, mobility, and overall strength)
""";

class WorkoutDataParser {
  // Parses the raw workout data string into a WorkoutLevel object.
  WorkoutLevel parseEasyWorkout() {
    final List<WorkoutDay> days = [];
    final daySections = rawWorkoutData.split('⸻');

    for (final section in daySections) {
      if (section.trim().isEmpty) continue;

      final lines = section.trim().split('\n');
      final titleLine = lines.firstWhere(
        (line) => line.contains('–'),
        orElse: () => '',
      );
      if (titleLine.isEmpty) continue;

      final dayName =
          titleLine
              .split('–')
              .first
              .trim()
              .replaceAll('🌸', '')
              .replaceAll('☁️', '')
              .replaceAll('🌙', '')
              .replaceAll('🌿', '')
              .replaceAll('🌊', '')
              .replaceAll('🍃', '')
              .replaceAll('🌅', '')
              .trim();
      final themeParts = titleLine
          .split('–')
          .sublist(1)
          .join('–')
          .trim()
          .split('(');
      final themeTitle = themeParts[0].trim();
      final themeSubtitle =
          themeParts.length > 1 ? '(${themeParts[1].trim()}' : '';

      final bool isRestDay =
          themeTitle.toLowerCase().contains('rest day') ||
          themeTitle.toLowerCase().contains('reflective pause') ||
          themeTitle.toLowerCase().contains('healing stillness');

      final List<Exercise> exercises = [];
      int exerciseCounter = 0; // Counter for image index within the day
      String? restDayImagePath; // Variable to hold rest day image path

      if (!isRestDay) {
        final routineStartIndex = lines.indexWhere(
          (line) => line.trim().toLowerCase() == 'routine:',
        );
        if (routineStartIndex != -1) {
          final routineLines = lines.sublist(routineStartIndex + 1);
          for (final line in routineLines) {
            final trimmedLine = line.trim();
            if (trimmedLine.startsWith('•')) {
              // Simple parsing logic - assumes format "Name: X sets, Y reps, Z sec rest" or "Name: X sets, Y duration"
              final parts = trimmedLine.substring(1).trim().split(':');
              if (parts.length >= 2) {
                final name = parts[0].trim();
                final details = parts[1].trim();

                // Default values
                int sets =
                    1; // Default to 1 set if not specified (e.g., Warm-up)
                String reps = "N/A";
                Duration timerDuration = Duration(
                  seconds: 60,
                ); // Default rest/duration

                // Extract Sets
                final setsMatch = RegExp(r'(\d+)\s+sets').firstMatch(details);
                if (setsMatch != null) {
                  sets = int.tryParse(setsMatch.group(1) ?? '1') ?? 1;
                }

                // Extract Reps (handle variations like "12 reps", "10 reps per leg", "15 reps per side")
                final repsMatch = RegExp(
                  r'(\d+\s+reps(?:\s+per\s+\w+)*)',
                ).firstMatch(details);
                if (repsMatch != null) {
                  reps = repsMatch.group(1)?.trim() ?? "N/A";
                } else {
                  // Handle cases like "Warm-up (5 min)" or "Plank...30 sec" where reps aren't standard
                  final durationMatch = RegExp(
                    r'\((\d+)\s+min\)',
                    caseSensitive: false,
                  ).firstMatch(name); // Check name first
                  if (durationMatch != null) {
                    reps = "Duration";
                    timerDuration = Duration(
                      minutes: int.tryParse(durationMatch.group(1) ?? '5') ?? 5,
                    );
                  } else {
                    final durationMatchDetails = RegExp(
                      r'(\d+)\s+sec',
                      caseSensitive: false,
                    ).firstMatch(details); // Check details
                    if (durationMatchDetails != null &&
                        !details.contains('rest')) {
                      // Ensure it's not the rest time
                      reps = "Duration";
                      timerDuration = Duration(
                        seconds:
                            int.tryParse(
                              durationMatchDetails.group(1) ?? '30',
                            ) ??
                            30,
                      );
                    }
                  }
                }

                // Extract Timer Duration (specifically look for 'rest' or explicit duration not covered above)
                final restMatch = RegExp(
                  r'(\d+)\s+sec\s+rest',
                  caseSensitive: false,
                ).firstMatch(details);
                if (restMatch != null) {
                  timerDuration = Duration(
                    seconds: int.tryParse(restMatch.group(1) ?? '60') ?? 60,
                  );
                } else if (reps == "Duration") {
                  // Timer duration already set from reps parsing logic for timed exercises
                } else if (name.toLowerCase().contains('warm-up') ||
                    name.toLowerCase().contains('cooldown')) {
                  final durationMatch = RegExp(
                    r'\((\d+)\s+min\)',
                    caseSensitive: false,
                  ).firstMatch(name);
                  if (durationMatch != null) {
                    timerDuration = Duration(
                      minutes: int.tryParse(durationMatch.group(1) ?? '5') ?? 5,
                    );
                    reps =
                        "Duration"; // Set reps to duration for warmups/cooldowns
                  }
                }
                // If no explicit rest or duration found, keep the default 60 seconds.

                // Removed image placeholder logic

                // Skip adding if it's just descriptive text without exercise details
                if (name.isNotEmpty && sets > 0) {
                  exerciseCounter++; // Increment counter for the valid exercise
                  exercises.add(
                    Exercise(
                      name: name,
                      sets: sets,
                      reps: reps,
                      timerDuration: timerDuration,
                      imageIndex: exerciseCounter, // Assign the current index
                    ),
                  );
                }
              }
            }
          }
        }
      } else {
        // It IS a rest day, determine the image path
        // Assuming format dayname1.jpeg or dayname1.jpg
        restDayImagePath = 'assets/images/${dayName.toLowerCase()}1.jpeg';
        // Note: This assumes the file exists. We could add file existence check here
        // but for simplicity, we'll rely on the errorBuilder in the UI.
        // We could also check for .jpg if .jpeg isn't found.
      }

      days.add(
        WorkoutDay(
          dayName: dayName,
          themeTitle: themeTitle,
          themeSubtitle: themeSubtitle,
          exercises: exercises, // Will be empty for rest days
          isRestDay: isRestDay,
          restDayImagePath: restDayImagePath, // Pass the path
        ),
      );
    }

    return WorkoutLevel(
      levelType: WorkoutLevelType.easy,
      name: 'Easy',
      days: days,
    );
  }
}
