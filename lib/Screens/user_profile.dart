import 'package:flutter/material.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  bool _isNotificationOn = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView( // Added to prevent overflow
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header Section with Background Image and Profile Picture ---
            Stack(
              clipBehavior: Clip.none, // Allow profile picture to overflow
              alignment: Alignment.topLeft,
              children: [
                // Background Header Image
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: Image(
                    image: const AssetImage("assets/login.jpg"),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(color: Colors.deepPurpleAccent),
                  ),
                ),
                // Profile Picture positioned to overlap
                Positioned(
                  top: 150, // Adjust this value to control overlap
                  left: 16,
                  child: _buildProfilePicture(),
                ),
              ],
            ),

            // --- User Details ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 45), // Space for the overlapping avatar
                  const Text(
                    'Singuliet',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'chingufugga@fuggas.com',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            // --- NEW: Settings Section ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Terms & Condition Section
                  _buildSettingsSection(
                    title: 'General',
                    items: [
                      _buildSettingsItem(Icons.person_2_outlined, 'Account Details'),
                      _buildSettingsItem(Icons.payment_outlined, 'Payment Modes'),
                      _buildSettingsItem(Icons.history, 'Booking history'),
                      _buildSettingsItem(Icons.support_agent_outlined, 'Support'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Accounts & Subscription Section
                  _buildSettingsSection(
                    title: 'Accounts & subscription',
                    items: [
                      _buildToggleItem(Icons.notifications_outlined, 'Notification'),
                      _buildSettingsItem(Icons.logout, 'Logout'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for the profile picture
  Widget _buildProfilePicture() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 3,
            ),
          ),
          child: const CircleAvatar(
            radius: 45,
            backgroundImage: AssetImage("assets/pfp.jpg"),
          ),
        ),
      ],
    );
  }

  // Helper to build a settings group container
  Widget _buildSettingsSection({required String title, required List<Widget> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[900]?.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  // Helper to build a standard settings item with a trailing arrow
  Widget _buildSettingsItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
      onTap: () {
        // Handle tap
        print('$title tapped');
      },
    );
  }

  // Helper to build a settings item with a toggle switch
  Widget _buildToggleItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: Switch(
        value: _isNotificationOn,
        onChanged: (value) {
          setState(() {
            _isNotificationOn = value;
          });
        },
        activeTrackColor: Colors.deepPurpleAccent.withOpacity(0.5),
        activeColor: Colors.deepPurpleAccent,
      ),
    );
  }
}
