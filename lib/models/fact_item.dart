import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:math';

// Generic base class (optional but can be useful)
abstract class FactItem {
  String get textToDisplay;
  String get sourceToDisplay;
}

class HealthFact implements FactItem {
  final String statement;
  final String source;

  HealthFact({required this.statement, required this.source});

  factory HealthFact.fromJson(Map<String, dynamic> json) {
    return HealthFact(
      statement: json['statement'] as String,
      source: json['source'] as String,
    );
  }

  @override
  String get textToDisplay => statement;

  @override
  String get sourceToDisplay => source;
}

class HealthMyth implements FactItem {
  final String myth;
  final String fact;
  final String source;

  HealthMyth({required this.myth, required this.fact, required this.source});

  factory HealthMyth.fromJson(Map<String, dynamic> json) {
    return HealthMyth(
      myth: json['myth'] as String,
      fact: json['fact'] as String,
      source: json['source'] as String,
    );
  }

  @override
  // Display the corrective fact for myths
  String get textToDisplay => fact;

  @override
  String get sourceToDisplay => source;
}

class HealthQuote implements FactItem {
  final String quote;
  final String author;

  HealthQuote({required this.quote, required this.author});

  factory HealthQuote.fromJson(Map<String, dynamic> json) {
    return HealthQuote(
      quote: json['quote'] as String,
      author: json['author'] as String,
    );
  }

  @override
  String get textToDisplay => quote;

  @override
  String get sourceToDisplay => author;
}

// Helper class to load and provide facts
class FactLoader {
  List<FactItem> _allItems = [];
  bool _isLoaded = false;

  Future<void> loadFacts() async {
    if (_isLoaded) return;

    try {
      // Load from the new file
      final String response = await rootBundle.loadString(
        'assets/facts_v2.json',
      );
      final data = json.decode(response) as Map<String, dynamic>;

      final List<HealthFact> healthFacts =
          (data['healthFacts'] as List)
              .map((item) => HealthFact.fromJson(item as Map<String, dynamic>))
              .toList();

      final List<HealthMyth> healthMyths =
          (data['healthMyths'] as List)
              .map((item) => HealthMyth.fromJson(item as Map<String, dynamic>))
              .toList();

      final List<HealthQuote> healthQuotes =
          (data['healthQuotes'] as List)
              .map((item) => HealthQuote.fromJson(item as Map<String, dynamic>))
              .toList();

      // Combine all items into one list
      _allItems = [...healthFacts, ...healthMyths, ...healthQuotes];
      _isLoaded = true;
      print(
        "Facts loaded successfully from facts_v2.json. Total items: ${_allItems.length}",
      );
    } catch (e, stacktrace) {
      // Add stacktrace
      print("Error loading facts_v2.json: $e");
      print("Stacktrace: $stacktrace"); // Print stacktrace for more details
      // Handle error appropriately, maybe load default facts
      _allItems = []; // Ensure list is empty on error
    }
  }

  FactItem? getRandomFact() {
    if (!_isLoaded || _allItems.isEmpty) {
      print(
        "FactLoader not loaded or items list is empty. Returning default.",
      ); // Add print here
      // Return a default/error item if not loaded or empty
      return HealthFact(statement: "Could not load facts.", source: "System");
    }
    final random = Random();
    return _allItems[random.nextInt(_allItems.length)];
  }
}
