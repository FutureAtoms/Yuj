import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../models/workout_day.dart';

class RestDayScreen extends StatelessWidget {
  final WorkoutDay workoutDay;

  const RestDayScreen({required this.workoutDay, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String imagePath =
        workoutDay.restDayImagePath ??
        'assets/images/placeholder.png'; // Provide a fallback image

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          workoutDay.dayName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(blurRadius: 1.0, color: Colors.black54)],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Blurred Background Image
          Image.asset(
            imagePath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              print(
                "Error loading rest day background image: $imagePath - $error",
              );
              // Fallback solid color or different pattern
              return Container(color: Colors.blueGrey[100]);
            },
          ),
          ClipRRect(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
              child: Container(
                color: Colors.black.withOpacity(
                  0.2,
                ), // Slightly lighter overlay than exercise screen
              ),
            ),
          ),
          // Content: Theme Title and maybe image again (clearer)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(
                bottom: 20.0,
                left: 20.0,
                right: 20.0,
              ), // Add bottom padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Use Expanded for the image area
                  Expanded(
                    flex: 5, // Give image area more space
                    child: Center(
                      // Center the image container within the Expanded area
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 20.0,
                        ), // Add vertical margin
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.8,
                        ), // Limit width if needed
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.asset(
                          imagePath,
                          fit: BoxFit.contain, // Contain within the bounds
                          errorBuilder:
                              (context, error, stackTrace) => const Icon(
                                Icons.image_not_supported,
                                size: 60,
                                color: Colors.white54,
                              ),
                        ),
                      ),
                    ),
                  ),
                  // Spacer
                  const SizedBox(height: 20),
                  // Text content below the image
                  Text(
                    workoutDay.themeTitle,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 2.0,
                          color: Colors.black.withOpacity(0.6),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (workoutDay.themeSubtitle.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        workoutDay.themeSubtitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white70,
                          shadows: [
                            Shadow(
                              blurRadius: 1.0,
                              color: Colors.black.withOpacity(0.5),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  // Add a relaxation quote or message?
                  // const SizedBox(height: 20),
                  // Text(
                  //   '"Rest is not idleness..." - John Lubbock',
                  //   style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white60, fontStyle: FontStyle.italic),
                  //   textAlign: TextAlign.center,
                  // )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
