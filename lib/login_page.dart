import 'dart:ui'; // Import for ImageFilter

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Image(
            image: const AssetImage("assets/login.jpg"),
            fit: BoxFit.cover,
            width: double.infinity,
            height: 500,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 500,
                color: Colors.deepPurple,
                child: const Center(child: Text('Image not found', style: TextStyle(color: Colors.white))),
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
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.45),
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

                  // --- Blurred Container for Phone Number Input ---
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(left: 12.0),
                              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
                              decoration: BoxDecoration(
                                color: Colors.grey[850]?.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: const Row(
                                children: [
                                  Image(image: AssetImage("assets/india.png"), width: 25),
                                  SizedBox(width: 8.0),
                                  Text(
                                    '+91',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.white54,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            Expanded(
                              child: TextFormField(
                                keyboardType: TextInputType.phone,
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  hintText: '0623691060',
                                  hintStyle: TextStyle(color: Colors.white70),
                                  fillColor: Colors.transparent,
                                  filled: true,
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(vertical: 15.5),
                                  counterText: "",
                                ),
                                maxLength: 10,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // --- Blurred Container for Password/OTP Input ---
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: TextFormField(
                          obscureText: !_isPasswordVisible,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Enter OTP',
                            hintStyle: const TextStyle(color: Colors.white70),
                            fillColor: Colors.transparent,
                            filled: true,
                            border: InputBorder.none,
                            // --- FIX: Adjusted padding to match phone number box height ---
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.5),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                color: Colors.white54,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  RichText(
                    text: TextSpan(
                      text: 'By logging in, you agree to our ',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'terms of use',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.deepPurpleAccent),
                        ),
                        const TextSpan(text: ' and '),
                        TextSpan(
                          text: 'privacy policy',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.deepPurpleAccent),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/bottomNav');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurpleAccent,
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        child: const Text(
                          'Sign in',
                          style: TextStyle(fontSize: 18.0, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  Center(
                    child: Text(
                      'or sign in with',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white54),
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  Center(
                    child: InkWell(
                      onTap: () {
                        // TODO: Implement Google Sign-in logic
                      },
                      borderRadius: BorderRadius.circular(12.0),
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(color: Colors.white.withOpacity(0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Image(image: AssetImage("assets/google.png"), width: 22),
                            const SizedBox(width: 8.0),
                            const Text(
                              "Google",
                              style: TextStyle(fontSize: 14, color: Colors.white),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don\'t have an account? ',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                      ),
                      InkWell(
                        onTap: () {
                          // Handle navigation to sign up page
                        },
                        child: Text(
                          'Sign up',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.deepPurpleAccent),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
