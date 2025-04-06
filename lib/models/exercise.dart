class Exercise {
  final String name;
  final int sets;
  final String reps; // Use String as it can be '12 reps' or '10 reps per arm'
  final Duration timerDuration; // For rest or timed exercise
  final int imageIndex; // Index for image filename (e.g., 1 for monday1.jpeg)

  Exercise({
    required this.name,
    required this.sets,
    required this.reps,
    required this.timerDuration,
    required this.imageIndex,
  });
}
