import 'package:flutter/material.dart';
import 'package:fomo_fix/Screens/event_listing.dart';
import 'package:fomo_fix/Screens/booking-page.dart';
import 'package:fomo_fix/bottom_nav.dart';
import 'package:fomo_fix/Screens/home_page.dart';
import 'package:fomo_fix/Screens/landing_page.dart';
import 'package:fomo_fix/Screens/login_page.dart';
import 'package:fomo_fix/Screens/signup_page.dart';
import 'package:fomo_fix/splash_screen.dart';
import 'package:google_fonts/google_fonts.dart';

import 'Screens/account_details_page.dart';

void main() {
  runApp(const Main());
}

class Main extends StatefulWidget {
  const Main({super.key});

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(textTheme: GoogleFonts.poppinsTextTheme()),
      debugShowCheckedModeBanner: false,

      routes: {
        '/': (context) => SplashScreen(),
        '/landing': (context) => LoginPage(),
        '/signup': (context) => SignupPage(),
        '/bottomNav': (context) => BottomNavBar(),
        '/accountDetails': (context) => AccountDetailsPage(),
        '/listEvent': (context) => EventListing(),
      },
    );
  }
}
