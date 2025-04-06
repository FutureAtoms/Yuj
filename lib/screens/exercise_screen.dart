import 'dart:async'; // For Timer
import 'dart:ui' as ui; // For ImageFilter (blur)
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // Import Lottie
// Needed?
import '../models/workout_day.dart';
import '../models/exercise.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExerciseScreen extends StatefulWidget {
  final WorkoutDay workoutDay;

  const ExerciseScreen({required this.workoutDay, super.key});

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  int currentExerciseIndex = 0;
  Timer? _timer;
  int _timerSecondsRemaining = 0;
  bool isTimerRunning = false;
  bool isWorkoutComplete = false;

  @override
  void initState() {
    super.initState();
    // Initialize timer duration for the first exercise (if any)
    _resetTimerForCurrentExercise();
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel timer when the screen is disposed
    super.dispose();
  }

  Exercise get currentExercise =>
      widget.workoutDay.exercises[currentExerciseIndex];

  void _resetTimerForCurrentExercise() {
    setState(() {
      _timer?.cancel();
      isTimerRunning = false;
      if (widget.workoutDay.exercises.isNotEmpty &&
          currentExerciseIndex < widget.workoutDay.exercises.length) {
        _timerSecondsRemaining = currentExercise.timerDuration.inSeconds;
      } else {
        _timerSecondsRemaining = 0; // Or handle completion state
      }
    });
  }

  void _startTimer() {
    if (_timerSecondsRemaining <= 0 || isTimerRunning) return;

    setState(() {
      isTimerRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSecondsRemaining <= 1) {
        timer.cancel();
        setState(() {
          isTimerRunning = false;
          _timerSecondsRemaining = 0;
          // Optionally auto-advance or show a completion message
        });
        _playCompletionSound(); // Placeholder for sound
      } else {
        setState(() {
          _timerSecondsRemaining--;
        });
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      isTimerRunning = false;
    });
  }

  void _nextExercise() {
    _timer?.cancel(); // Stop timer when moving manually
    if (currentExerciseIndex < widget.workoutDay.exercises.length - 1) {
      setState(() {
        currentExerciseIndex++;
        _resetTimerForCurrentExercise();
      });
    } else {
      // Last exercise completed
      setState(() {
        isWorkoutComplete = true;
        isTimerRunning = false;
        _timerSecondsRemaining = 0;
      });
      _showCompletionDialog();
    }
  }

  void _playCompletionSound() {
    // TODO: Implement sound playback (e.g., using audioplayers package)
    print("Timer finished! (Placeholder for sound)");
  }

  void _showCompletionDialog() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      barrierDismissible: false, // User must tap button to close
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: const EdgeInsets.all(20), // Add padding around dialog
          backgroundColor: Colors.white.withOpacity(0.9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ), // More rounded
          contentPadding: const EdgeInsets.all(25), // Adjust padding
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Lottie Animation
              SizedBox(
                width: 150, // Constrain animation size
                height: 150,
                child: Lottie.asset(
                  'assets/animations/workout_complete.json',
                  repeat: false, // Play only once
                  errorBuilder: (context, error, stacktrace) {
                    print("Error loading Lottie: $error");
                    return const Icon(
                      Icons.celebration,
                      size: 60,
                      color: Colors.green,
                    ); // Fallback icon
                  },
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Workout Complete!',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Great job completing the ${widget.workoutDay.dayName} workout!',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center, // Center the button
          actionsPadding: const EdgeInsets.only(
            bottom: 20,
          ), // Padding for button
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'AWESOME!',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pop(); // Go back to DaySelectionScreen
              },
            ),
          ],
        );
      },
    );
  }

  String _formatDuration(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    // Handle edge cases: no exercises or invalid index
    if (widget.workoutDay.exercises.isEmpty ||
        currentExerciseIndex >= widget.workoutDay.exercises.length) {
      bool noExercises = widget.workoutDay.exercises.isEmpty;
      return Scaffold(
        appBar: AppBar(
          title: Text(
            noExercises
                ? widget.workoutDay.dayName
                : '${widget.workoutDay.dayName} - Error',
          ),
        ),
        body: Center(
          child: Text(
            noExercises
                ? 'No exercises for this day.'
                : 'Error: Invalid exercise index.',
          ),
        ),
      );
    }

    // Handle workout completion screen
    if (isWorkoutComplete) {
      final String completionImagePath =
          'assets/images/${widget.workoutDay.dayName.toLowerCase()}1.jpeg'; // Use first image for background
      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text('${widget.workoutDay.dayName} - Complete!'),
          backgroundColor: Colors.transparent, // Make AppBar transparent
          elevation: 0,
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Blurred Background Image
            Image.asset(
              completionImagePath,
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) => Container(
                    color: Colors.deepPurple.withOpacity(0.1),
                  ), // Fallback color
            ),
            ClipRRect(
              // Clip blur effect
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                  color: Colors.black.withOpacity(
                    0.3,
                  ), // Dark overlay for readability
                ),
              ),
            ),
            // Completion Text Content
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: Colors.greenAccent,
                      size: 80,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Workout finished! Great job!',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color:
                            Colors
                                .white, // Ensure text is visible on background
                        shadows: [
                          Shadow(
                            blurRadius: 2.0,
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Main Exercise Screen Build
    final String currentImagePath =
        'assets/images/${widget.workoutDay.dayName.toLowerCase()}${currentExercise.imageIndex}.jpeg';

    return Scaffold(
      extendBodyBehindAppBar: true, // Allow body to go behind AppBar
      appBar: AppBar(
        title: Text(
          '${widget.workoutDay.dayName} (${currentExerciseIndex + 1}/${widget.workoutDay.exercises.length})',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(blurRadius: 1.0, color: Colors.black54)],
          ), // Ensure title is visible
        ),
        backgroundColor: Colors.transparent, // Make AppBar transparent
        elevation: 0, // No shadow
        foregroundColor: Colors.white, // Back button color
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh,
              shadows: [Shadow(blurRadius: 1.0, color: Colors.black54)],
            ), // Add shadow for visibility
            tooltip: 'Reset Timer',
            onPressed: _resetTimerForCurrentExercise, // Call reset function
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Blurred Background Image
          Image.asset(
            currentImagePath,
            fit: BoxFit.cover,
            errorBuilder:
                (context, error, stackTrace) =>
                    Container(color: Colors.grey[300]), // Fallback solid color
          ),
          ClipRRect(
            // Clip blur effect
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                color: Colors.black.withOpacity(
                  0.3,
                ), // Dark overlay for readability
              ),
            ),
          ),

          // Main Content Column
          SafeArea(
            // Ensure content avoids notches/system bars
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image Display Area (Clearer image on top)
                Expanded(
                  flex: 5, // Adjust flex factor for image size
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 16.0,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 10,
                            offset: const Offset(
                              0,
                              4,
                            ), // changes position of shadow
                          ),
                        ],
                      ),
                      clipBehavior:
                          Clip.antiAlias, // Clip the image to the rounded corners
                      child: Image.asset(
                        currentImagePath,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          print(
                            "Error loading image: $currentImagePath - $error",
                          );
                          return const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 40,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Image not found',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          );
                        },
                        frameBuilder: (
                          context,
                          child,
                          frame,
                          wasSynchronouslyLoaded,
                        ) {
                          if (wasSynchronouslyLoaded) return child;
                          return AnimatedOpacity(
                            opacity: frame == null ? 0 : 1,
                            duration: const Duration(
                              milliseconds: 500,
                            ), // Faster fade
                            curve: Curves.easeIn,
                            child: child,
                          );
                        },
                      ),
                    ),
                  ),
                ),
                // Exercise Info Panel (Semi-transparent)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20.0),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 12.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(
                      0.5,
                    ), // Semi-transparent background
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        currentExercise.name,
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // White text
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${currentExercise.sets} sets, ${currentExercise.reps}',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[300], // Lighter grey text
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15), // Spacer
                // Timer and Controls Panel (Semi-transparent)
                Container(
                  margin: const EdgeInsets.only(
                    left: 20.0,
                    right: 20.0,
                    bottom: 20.0,
                  ), // Add bottom margin
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 15.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(
                      0.6,
                    ), // Slightly darker overlay
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Timer Display
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentExercise.reps == "Duration"
                                ? 'DURATION'
                                : 'REST',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[400],
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            _formatDuration(_timerSecondsRemaining),
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color:
                                  isTimerRunning
                                      ? Colors.orangeAccent
                                      : Colors.white,
                            ),
                          ),
                        ],
                      ),

                      // Buttons
                      Row(
                        children: [
                          if (_timerSecondsRemaining > 0)
                            ElevatedButton(
                              onPressed:
                                  isTimerRunning ? _stopTimer : _startTimer,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    isTimerRunning
                                        ? Colors.redAccent[700]
                                        : Colors.green[600],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 10,
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(isTimerRunning ? 'STOP' : 'START'),
                            ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: _nextExercise,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 10,
                              ),
                              textStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              currentExerciseIndex <
                                      widget.workoutDay.exercises.length - 1
                                  ? 'NEXT'
                                  : 'FINISH',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
