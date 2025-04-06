import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart'; // Access supabase
import './day_selection_screen.dart';
import '../models/workout_level.dart';
import '../utils/helpers.dart';

class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

// Simple data structure for a question
class Question {
  final String id;
  final String text;
  final List<String> options;

  Question({required this.id, required this.text, required this.options});
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  final Map<String, String?> _answers =
      {}; // Store selected answer for each question id
  bool _isLoading = false;

  // Define the questions
  final List<Question> _questions = [
    Question(
      id: 'goal',
      text:
          "Welcome! I'm Avi, your virtual trainer. What brings you here today?",
      options: [
        'Lose Weight',
        'Get Fitter (General)',
        'Build Muscle',
        'Improve Endurance',
      ],
    ),
    Question(
      id: 'experience',
      text: "How familiar are you with dumbbell exercises?",
      options: [
        'Complete Newbie',
        'Tried a few times',
        'Comfortable',
        'Very Experienced',
      ],
    ),
    Question(
      id: 'frequency',
      text: "How many days a week can you realistically commit to working out?",
      options: ['1-2 days', '3-4 days', '5+ days'],
    ),
    Question(
      id: 'energy',
      text:
          "How would you describe your usual energy levels throughout the day?",
      options: ['Generally Low', 'Moderate / Varies', 'Usually High'],
    ),
  ];

  // Simple logic to determine level based on answers (can be more sophisticated)
  WorkoutLevelType _determineLevel() {
    // Example logic: Prioritize experience, then goals/frequency
    final experience = _answers['experience'];
    final goal = _answers['goal'];
    final frequency = _answers['frequency'];

    if (experience == 'Complete Newbie' || experience == 'Tried a few times') {
      return WorkoutLevelType.easy;
    }
    if (experience == 'Very Experienced') {
      if (goal == 'Build Muscle' || frequency == '5+ days') {
        return WorkoutLevelType.advanced; // Only if specific goals/frequency
      }
      return WorkoutLevelType.intermediate;
    }
    // Default to intermediate if comfortable but not explicitly advanced criteria
    return WorkoutLevelType.intermediate;
  }

  Future<void> _submitAnswers() async {
    // Check if all questions are answered
    if (_answers.length < _questions.length || _answers.containsValue(null)) {
      showSnackBar(context, 'Please answer all questions.', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final determinedLevel = _determineLevel();

      // Update the user's profile with the assigned level
      await supabase
          .from('profiles')
          .update({
            'assigned_level': determinedLevel.name,
          }) // Store enum name as string
          .eq('id', userId);

      if (mounted) {
        showSnackBar(context, 'Got it! Finding the best plan for you...');
        await Future.delayed(
          const Duration(milliseconds: 800),
        ); // Small delay for effect

        // Navigate to DaySelectionScreen with the determined level
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder:
                (context) => DaySelectionScreen(levelType: determinedLevel),
          ),
        );
      }
    } catch (e) {
      if (mounted)
        showSnackBar(
          context,
          'Error saving answers: ${e.toString()}',
          isError: true,
        );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Getting to Know You'),
        automaticallyImplyLeading: false, // No back button
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.background,
              colorScheme.primary.withOpacity(0.1),
            ],
          ),
        ),
        child: ListView.separated(
          padding: const EdgeInsets.all(20.0),
          itemCount: _questions.length + 1, // +1 for the submit button
          separatorBuilder: (context, index) => const SizedBox(height: 25),
          itemBuilder: (context, index) {
            if (index == _questions.length) {
              // Render Submit Button
              return Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child:
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton.icon(
                          onPressed: _submitAnswers,
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text('FIND MY PLAN'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            textStyle: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
              );
            }

            // Render Question
            final question = _questions[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${index + 1}. ${question.text}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colorScheme.onBackground.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children:
                      question.options.map((option) {
                        final isSelected = _answers[question.id] == option;
                        return ChoiceChip(
                          label: Text(option),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _answers[question.id] = selected ? option : null;
                            });
                          },
                          pressElevation: 2,
                          backgroundColor:
                              colorScheme
                                  .surfaceContainerHighest, // Lighter background for chips
                          selectedColor: colorScheme.primaryContainer,
                          labelStyle: TextStyle(
                            color:
                                isSelected
                                    ? colorScheme.onPrimaryContainer
                                    : colorScheme.onSurfaceVariant,
                            fontWeight:
                                isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            side: BorderSide(
                              color:
                                  isSelected
                                      ? colorScheme.primary
                                      : Colors.grey.shade300,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 8.0,
                          ),
                        );
                      }).toList(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
