import 'package:flutter/material.dart';
import 'package:fomo_fix/home/home_page.dart';
import 'package:fomo_fix/events/search_page.dart';
import 'package:fomo_fix/profile/user_profile.dart';




class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  // Index of the currently selected tab.
  int _selectedIndex = 0;

  // This function handles tab selection and is passed to the HomePage.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Define the list of pages here.
    // The HomePage is now correctly initialized with the navigation callback.
    final List<Widget> pages = <Widget>[
      HomePage(onNavigate: _onItemTapped), // Pass the function to HomePage
      const SearchPage(),                  // Your SearchPage widget
      const UserProfile(),                 // Your ProfilePage widget
    ];

    return Scaffold(
      // Use IndexedStack to preserve the state of each page when switching tabs.
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      // The bottom navigation bar.
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurpleAccent,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped, // This handles taps on the nav bar items.
        backgroundColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: false,
        showSelectedLabels: true,
      ),
    );
  }
}
