import 'dart:ui'; // Import for ImageFilter
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../services/api-service.dart';
import '../services/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await AuthService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
      print(success);

      if (success) {
        // Login successful
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login successful!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacementNamed(context, '/bottomNav');
        }
      } else {
        // Login failed
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login failed. Please check your credentials.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Network error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get keyboard height to adjust layout
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Image(
              image: const AssetImage("assets/login.jpg"),
              fit: BoxFit.cover,
              width: double.infinity,
              height: 550,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 550,
                  color: Colors.deepPurple,
                  child: const Center(
                    child: Text(
                      'Image not found',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.0),
                      Colors.black.withOpacity(0.8),
                    ],
                    stops: const [0.0, 0.5],
                  ),
                ),
              ),
            ),
            // Wrap content in SingleChildScrollView for keyboard handling
            SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: keyboardHeight > 0 ? keyboardHeight + 20 : 0,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: screenHeight - MediaQuery.of(context).padding.top,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Dynamic top spacing that adjusts based on keyboard
                        SizedBox(
                          height: keyboardHeight > 0
                              ? 40
                              : MediaQuery.of(context).size.height * 0.42,
                        ),
                        const Text(
                          'Sign in',
                          style: TextStyle(color: Colors.white, fontSize: 30),
                        ),
                        const SizedBox(height: 8.0),
                        const Text(
                          'Get an account to fix your FOMO',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 24.0),

                        // --- Blurred Container for Email Input ---
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(
                              sigmaX: 10.0,
                              sigmaY: 10.0,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12.0),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                ),
                              ),
                              child: TextFormField(
                                controller: _emailController,
                                style: const TextStyle(color: Colors.white),
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  hintText: 'Enter E-mail',
                                  hintStyle: TextStyle(color: Colors.white70),
                                  fillColor: Colors.transparent,
                                  filled: true,
                                  border: InputBorder.none,
                                  // --- FIX: Adjusted padding to match phone number box height ---
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 15.5,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Email is required';
                                  }
                                  if (!RegExp(
                                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                  ).hasMatch(value.trim())) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16.0),

                        // --- Blurred Container for Password Input ---
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(
                              sigmaX: 10.0,
                              sigmaY: 10.0,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12.0),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                ),
                              ),
                              child: TextFormField(
                                controller: _passwordController,
                                obscureText: !_isPasswordVisible,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: 'Enter Password',
                                  hintStyle: const TextStyle(
                                    color: Colors.white70,
                                  ),
                                  fillColor: Colors.transparent,
                                  filled: true,
                                  border: InputBorder.none,
                                  // --- FIX: Adjusted padding to match phone number box height ---
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 15.5,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isPasswordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Colors.white54,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isPasswordVisible =
                                            !_isPasswordVisible;
                                      });
                                    },
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Password is required';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16.0),

                        RichText(
                          text: TextSpan(
                            text: 'By logging in, you agree to our ',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: 'terms of use',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.deepPurpleAccent),
                              ),
                              const TextSpan(text: ' and '),
                              TextSpan(
                                text: 'privacy policy',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.deepPurpleAccent),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18.0),
                        Center(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.5,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurpleAccent,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10.0,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : const Text(
                                      'Sign in',
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(
                              child: Text(
                                'or sign in with',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(width: 5.0),
                            Center(
                              child: InkWell(
                                onTap: () {
                                  // TODO: Implement Google Sign-in logic
                                },
                                borderRadius: BorderRadius.circular(12.0),
                                child: Container(
                                  padding: const EdgeInsets.all(4.0),
                                  child: const Image(
                                    image: AssetImage("assets/google.png"),
                                    width: 30,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Don\'t have an account? ',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: Colors.white70),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.pushNamed(context, '/signup');
                              },
                              child: Text(
                                'Sign up',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: Colors.deepPurpleAccent),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
