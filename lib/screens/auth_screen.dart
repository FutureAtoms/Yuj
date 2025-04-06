import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart'; // Access supabase client
import './home_or_questionnaire_navigator.dart'; // Navigate after success
import '../utils/helpers.dart'; // For showSnackBar

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true; // Toggle between Login and Register
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  String? _selectedGoal;
  bool _isLoading = false;

  final List<String> _goals = [
    'Weight Loss',
    'General Fitness',
    'Build Muscle',
  ];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid || (_selectedGoal == null && !_isLogin)) {
      if (_selectedGoal == null && !_isLogin) {
        showSnackBar(context, 'Please select a fitness goal.', isError: true);
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        // --- Login ---
        await supabase.auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        // --- Register ---
        final email = _emailController.text.trim();
        final password = _passwordController.text.trim();

        // 1. Sign up the user
        final response = await supabase.auth.signUp(
          email: email,
          password: password,
          // We can add user metadata here, but prefer a separate profile table
          // for structured data like age, weight, goal.
          // data: { 'full_name': _nameController.text.trim() }
        );

        if (response.user == null) {
          throw Exception('Registration failed: No user returned.');
        }

        final userId = response.user!.id;

        // 2. Insert profile data into the 'profiles' table
        await supabase.from('profiles').insert({
          'id': userId, // Link to the auth user
          'full_name': _nameController.text.trim(),
          'age': int.tryParse(_ageController.text.trim()),
          'weight': double.tryParse(_weightController.text.trim()),
          'goal': _selectedGoal,
          // 'assigned_level': null, // Initially null, set by questionnaire
        });
      }

      // Navigate after successful login/registration
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const HomeOrQuestionnaireNavigator(),
          ),
        );
      }
    } on AuthException catch (e) {
      if (mounted) showSnackBar(context, e.message, isError: true);
    } catch (e) {
      if (mounted) {
        showSnackBar(
          context,
          'An unexpected error occurred: ${e.toString()}',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Container(
        // Consistent gradient background
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary.withOpacity(0.1),
              colorScheme.secondary.withOpacity(0.15),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _isLogin ? 'Welcome Back!' : 'Create Account',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _isLogin
                        ? 'Login to continue your journey.'
                        : 'Tell us a bit about yourself.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 35),
                  // --- Registration Only Fields ---
                  if (!_isLogin) ...[
                    // Use spread operator to add list elements
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Please enter your name'
                                  : null,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _ageController,
                            decoration: InputDecoration(
                              labelText: 'Age',
                              prefixIcon: Icon(Icons.calendar_today_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            validator:
                                (value) =>
                                    value == null || int.tryParse(value) == null
                                        ? 'Enter valid age'
                                        : null,
                            textInputAction: TextInputAction.next,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: _weightController,
                            decoration: InputDecoration(
                              labelText: 'Weight (kg)',
                              prefixIcon: Icon(Icons.monitor_weight_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator:
                                (value) =>
                                    value == null ||
                                            double.tryParse(value) == null
                                        ? 'Enter valid weight'
                                        : null,
                            textInputAction: TextInputAction.next,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Fitness Goal:',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children:
                          _goals
                              .map(
                                (goal) => ChoiceChip(
                                  label: Text(goal),
                                  selected: _selectedGoal == goal,
                                  onSelected: (selected) {
                                    setState(
                                      () =>
                                          _selectedGoal =
                                              selected ? goal : null,
                                    );
                                  },
                                  selectedColor: colorScheme.primaryContainer,
                                  labelStyle: TextStyle(
                                    color:
                                        _selectedGoal == goal
                                            ? colorScheme.onPrimaryContainer
                                            : Colors.grey[700],
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                    const SizedBox(height: 20),
                  ],
                  // --- Common Fields ---
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator:
                        (value) =>
                            value == null || !value.contains('@')
                                ? 'Enter a valid email'
                                : null,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    obscureText: true,
                    validator:
                        (value) =>
                            value == null || value.length < 6
                                ? 'Password must be at least 6 characters'
                                : null,
                    onFieldSubmitted:
                        (_) =>
                            _isLoading
                                ? null
                                : _submit(), // Allow submit on keyboard action
                    textInputAction:
                        _isLogin ? TextInputAction.done : TextInputAction.next,
                  ),
                  const SizedBox(height: 30),
                  // --- Submit Button ---
                  _isLoading
                      ? const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 15.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                      : ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: _isLoading ? Colors.grey : null,
                        ),
                        child: Text(_isLogin ? 'LOGIN' : 'REGISTER'),
                      ),
                  const SizedBox(height: 15),
                  // --- Toggle Button ---
                  TextButton(
                    onPressed:
                        _isLoading
                            ? null
                            : () => setState(() => _isLogin = !_isLogin),
                    child: Text(
                      _isLogin
                          ? 'Need an account? Register'
                          : 'Have an account? Login',
                      style: TextStyle(color: colorScheme.secondary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
