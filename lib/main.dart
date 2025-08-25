import 'package:flutter/material.dart';
import 'package:fomo_fix/events/event_listing.dart';
import 'package:fomo_fix/auth/login_page.dart';
import 'package:fomo_fix/auth/signup_page.dart';
import 'package:fomo_fix/home/splash_screen.dart';
import 'package:google_fonts/google_fonts.dart';

import 'navigation/bottom_nav.dart';
import 'profile/account_details_page.dart';
import 'profile/booking_history_screen.dart';

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
        '/bookingHistory': (context) => BookingHistoryScreen(),
      },
    );
  }
}
