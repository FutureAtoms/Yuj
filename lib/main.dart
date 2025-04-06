import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts
import './screens/splash_screen.dart'; // We'll create this soon
// Needed for potential navigation

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Required for async main

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://bkgruwhwxdxmnwcwmrrh.supabase.co', // <<< --- UPDATED
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJrZ3J1d2h3eGR4bW53Y3dtcnJoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDM4Mzc0NzEsImV4cCI6MjA1OTQxMzQ3MX0.enkJsj3J5rvDr7rnFe7LbKBvgHUVFer8-8zmue2Fb0U', // <<< --- UPDATED
  );

  runApp(const GymApp());
}

// Helper function to get the Supabase client instance
final supabase = Supabase.instance.client;

class GymApp extends StatelessWidget {
  const GymApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // Define base text theme using Lato
    final baseTextTheme = GoogleFonts.latoTextTheme(
      Theme.of(context).textTheme,
    );
    // Define headline theme using EB Garamond
    final headlineTextTheme = GoogleFonts.ebGaramondTextTheme(baseTextTheme);

    return MaterialApp(
      title: 'Yuj',
      theme: ThemeData(
        // Use Material 3 design principles
        useMaterial3: true,

        // Define the default brightness and colors.
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light, // Ensuring light theme base
        ),

        // Define the default AppBar theme
        appBarTheme: AppBarTheme(
          // Use Garamond for AppBar title
          titleTextStyle: headlineTextTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              const Shadow(blurRadius: 1.0, color: Colors.black38),
            ], // Consistent shadow
          ),
          backgroundColor: Colors.deepPurpleAccent.withOpacity(
            0.9,
          ), // Slightly transparent
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(
            color: Colors.white,
            shadows: [Shadow(blurRadius: 1.0, color: Colors.black38)],
          ), // Ensure icons match
        ),

        // Define the default ElevatedButton theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.deepPurple,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            // Use Lato Bold for button text (from baseTextTheme.labelLarge)
            textStyle: baseTextTheme.labelLarge,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 3,
          ),
        ),

        // Define the default Card theme
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 12,
          ), // Adjusted margins
        ),

        // Define the default Text theme
        textTheme: baseTextTheme.copyWith(
          // Override specific styles with Garamond where needed
          displayLarge: headlineTextTheme.displayLarge,
          displayMedium: headlineTextTheme.displayMedium,
          displaySmall: headlineTextTheme.displaySmall,
          headlineLarge: headlineTextTheme.headlineLarge,
          headlineMedium: headlineTextTheme.headlineMedium,
          headlineSmall: headlineTextTheme.headlineSmall,
          titleLarge: headlineTextTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ), // Garamond for titles, slightly bolder
          // Keep Lato for body, labels etc.
          bodyLarge: baseTextTheme.bodyLarge?.copyWith(
            fontSize: 16,
          ), // Slightly larger body text
          bodyMedium: baseTextTheme.bodyMedium?.copyWith(fontSize: 14),
          labelLarge: baseTextTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ), // Bolder button text
        ),

        // Define Input Decoration Theme for TextFields (AuthScreen)
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withOpacity(0.8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none, // No border needed if filled
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.deepPurple, width: 1.5),
          ),
          labelStyle: baseTextTheme.bodyMedium?.copyWith(
            color: Colors.grey[700],
          ),
          prefixIconColor: Colors.deepPurple.withOpacity(0.8),
        ),

        // Define ChoiceChip theme (Questionnaire/AuthScreen)
        chipTheme: ChipThemeData(
          backgroundColor: Colors.deepPurple.withOpacity(0.05),
          selectedColor: Colors.deepPurple.withOpacity(0.8),
          labelStyle: baseTextTheme.bodyMedium, // Lato for chip text
          secondaryLabelStyle: baseTextTheme.bodyMedium?.copyWith(
            color: Colors.white,
          ), // Text color when selected
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
            side: BorderSide(color: Colors.deepPurple.withOpacity(0.2)),
          ),
          selectedShadowColor: Colors.black26,
          elevation: 1,
          pressElevation: 3,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
      // Start with SplashScreen to check auth state
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false, // Remove debug banner
    );
  }
}
