import 'package:flutter/material.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Enhanced data with colors and icons
  final List<OnboardingData> _onboardingData = [
    OnboardingData(
      title: "Discover Your Next Event & Enjoy",
      subtitle: "Plan trips, explore destinations. And book unforgettable experiences.",
      imagePath: "assets/intro1.jpg",
      primaryColor: Colors.deepOrange,
      secondaryColor: Colors.orange.shade300,
      icon: Icons.explore,
    ),
    OnboardingData(
      title: "Connect with Amazing People",
      subtitle: "Meet new friends and create lasting memories together.",
      imagePath: "assets/intro2.jpg",
      primaryColor: Colors.deepPurple,
      secondaryColor: Colors.purple.shade300,
      icon: Icons.people,
    ),
    OnboardingData(
      title: "Start Your Journey Today",
      subtitle: "Everything you need to begin your adventure is right here.",
      imagePath: "assets/intro3.jpg",
      primaryColor: Colors.teal,
      secondaryColor: Colors.cyan.shade300,
      icon: Icons.rocket_launch,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // PageView with disabled physics for manual swiping
          PageView.builder(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(), // Disable manual swiping
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
              // Restart animations for new page
              _fadeController.reset();
              _slideController.reset();
              _fadeController.forward();
              _slideController.forward();
            },
            itemCount: _onboardingData.length,
            itemBuilder: (context, index) {
              return OnboardingScreen(
                data: _onboardingData[index],
                fadeAnimation: _fadeAnimation,
                slideAnimation: _slideAnimation,
              );
            },
          ),

          // Enhanced bottom navigation area
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.9),
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Enhanced page indicators with glow effect
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        _onboardingData.length,
                            (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 10,
                          width: _currentPage == index ? 30 : 10,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? _onboardingData[_currentPage].primaryColor
                                : Colors.white.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(5),
                            boxShadow: _currentPage == index
                                ? [
                              BoxShadow(
                                color: _onboardingData[_currentPage]
                                    .primaryColor
                                    .withOpacity(0.6),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Enhanced button with gradient and animation
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage < _onboardingData.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOutCubic,
                          );
                        } else {
                          _handleGetStarted();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _onboardingData[_currentPage].primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 8,
                        shadowColor: _onboardingData[_currentPage]
                            .primaryColor
                            .withOpacity(0.5),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _onboardingData[_currentPage].primaryColor,
                              _onboardingData[_currentPage].secondaryColor,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _currentPage < _onboardingData.length - 1
                                    ? "Next"
                                    : "Get Started",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                _currentPage < _onboardingData.length - 1
                                    ? Icons.arrow_forward
                                    : Icons.rocket_launch,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Enhanced login link
                  if (_currentPage < _onboardingData.length - 1)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextButton(
                        onPressed: () {
                          _handleLogin();
                        },
                        child: RichText(
                          text: const TextSpan(
                            text: "Already have an account? ",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                            children: [
                              TextSpan(
                                text: "Login Now!",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleGetStarted() {
    print("Get Started pressed - Navigate to main app");
  }

  void _handleLogin() {
    print("Login pressed - Navigate to login");
  }
}

// Enhanced OnboardingScreen with animations and visual effects
class OnboardingScreen extends StatelessWidget {
  final OnboardingData data;
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;

  const OnboardingScreen({
    super.key,
    required this.data,
    required this.fadeAnimation,
    required this.slideAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Full-page background image with parallax effect
        Positioned.fill(
          child: AnimatedBuilder(
            animation: fadeAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (fadeAnimation.value * 0.1),
                child: Image.asset(
                  data.imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            data.primaryColor,
                            data.secondaryColor,
                          ],
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          data.icon,
                          size: 120,
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),

        // Enhanced gradient overlay with animated opacity
        AnimatedBuilder(
          animation: fadeAnimation,
          builder: (context, child) {
            return Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.2 * fadeAnimation.value),
                      Colors.black.withOpacity(0.7 * fadeAnimation.value),
                    ],
                  ),
                ),
              ),
            );
          },
        ),

        // Animated text content overlay
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Animated icon
                SlideTransition(
                  position: slideAnimation,
                  child: FadeTransition(
                    opacity: fadeAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: data.primaryColor.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        data.icon,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Animated title and subtitle
                SlideTransition(
                  position: slideAnimation,
                  child: FadeTransition(
                    opacity: fadeAnimation,
                    child: Column(
                      children: [
                        Text(
                          data.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 1.2,
                            letterSpacing: -0.5,
                            shadows: [
                              Shadow(
                                offset: Offset(0, 3),
                                blurRadius: 6,
                                color: Colors.black54,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            data.subtitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              height: 1.6,
                              fontWeight: FontWeight.w300,
                              shadows: [
                                Shadow(
                                  offset: Offset(0, 1),
                                  blurRadius: 3,
                                  color: Colors.black54,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(flex: 3),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Enhanced data model with colors and icons
class OnboardingData {
  final String title;
  final String subtitle;
  final String imagePath;
  final Color primaryColor;
  final Color secondaryColor;
  final IconData icon;

  OnboardingData({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.primaryColor,
    required this.secondaryColor,
    required this.icon,
  });
}