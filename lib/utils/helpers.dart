import 'package:flutter/material.dart';

// Simple helper to show a SnackBar
void showSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  if (!context.mounted) return; // Check if context is still valid

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor:
          isError
              ? Theme.of(context).colorScheme.error
              : Theme.of(context).snackBarTheme.backgroundColor,
      behavior: SnackBarBehavior.floating, // Make it float
      shape: RoundedRectangleBorder(
        // Add rounded corners
        borderRadius: BorderRadius.circular(10.0),
      ),
      margin: const EdgeInsets.all(10.0), // Add margin
    ),
  );
}
