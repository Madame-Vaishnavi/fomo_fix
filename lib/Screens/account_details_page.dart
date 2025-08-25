import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../services/api-service.dart';
import '../services/auth_service.dart';

class AccountDetailsPage extends StatefulWidget {
  const AccountDetailsPage({super.key});

  @override
  State<AccountDetailsPage> createState() => _AccountDetailsPageState();
}

class _AccountDetailsPageState extends State<AccountDetailsPage> {

  File? _image;
  final ImagePicker _picker = ImagePicker();

  // New: state for profile loading
  bool _isLoadingProfile = true;
  String? _profileError;
  String? _username;
  String? _email;

  // Initialize without text, we'll set it after loading
  late TextEditingController _nameController = TextEditingController();
  bool _isEditingName = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }


  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      // Handle any potential errors here, e.g., permissions denied
      print('Error picking image: $e');
    }
  }

  /// Toggles the editing state for the name field and saves the changes.
  void _toggleNameEdit() {
    setState(() {
      if (_isEditingName) {
        // Update the username when saving
        _username = _nameController.text;
        // This is where you would call an API to save the new name
        print('Name saved: ${_nameController.text}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text('Name updated to: ${_nameController.text}'),
          ),
        );
      }
      _isEditingName = !_isEditingName;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while profile is loading
    if (_isLoadingProfile) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.grey[900]?.withOpacity(0.5),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('Account Details', style: TextStyle(color: Colors.white)),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Colors.deepPurpleAccent),
        ),
      );
    }

    // Show error if profile failed to load
    if (_profileError != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.grey[900]?.withOpacity(0.5),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('Account Details', style: TextStyle(color: Colors.white)),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _profileError!,
                style: const TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadUserProfile,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey[900]?.withOpacity(0.5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Account Details', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            _buildProfileImage(),
            const SizedBox(height: 40),
            _buildDetailField(
              controller: _nameController,
              label: 'Name',
              icon: Icons.person_outline,
              isEditable: true,
              isEditing: _isEditingName,
              onEditTap: _toggleNameEdit,
            ),
            const SizedBox(height: 20),
            _buildDetailField(
              controller: TextEditingController(text: _email ?? ''),
              label: 'Email',
              icon: Icons.email_outlined,
            ),
            // const SizedBox(height: 20),
            // _buildDetailField(
            //   controller: TextEditingController(text: _password),
            //   label: 'Phone Number',
            //   icon: Icons.phone_outlined,
            // ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadUserProfile() async {
    try {
      setState(() {
        _isLoadingProfile = true;
        _profileError = null;
      });

      // Read token from secure storage via AuthService or directly if available
      final token =
          AuthService.token ??
              await const FlutterSecureStorage().read(key: 'token');

      if (token == null) {
        setState(() {
          _profileError = 'Not authenticated';
          _isLoadingProfile = false;
        });
        return;
      }

      final response = await ApiService.getUserProfile(token);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        setState(() {
          _username = data['username']?.toString();
          _email = data['email']?.toString();

          // Update the name controller with the loaded username
          _nameController.text = _username ?? '';

          _isLoadingProfile = false;
        });
      } else {
        setState(() {
          _profileError = 'Failed to load profile (${response.statusCode})';
          _isLoadingProfile = false;
        });
      }
    } catch (e) {
      setState(() {
        _profileError = 'Error: $e';
        _isLoadingProfile = false;
      });
    }
  }

  // --- Helper Widgets ---

  /// Builds the circular profile image with an edit button.
  Widget _buildProfileImage() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundImage: _image == null
                ? const AssetImage("assets/pfp.jpg") as ImageProvider
                : FileImage(_image!),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.deepPurpleAccent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a styled TextFormField for displaying user details.
  Widget _buildDetailField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isEditable = false,
    bool isEditing = false,
    VoidCallback? onEditTap,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: !isEditing,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[400]),
        prefixIcon: Icon(icon, color: Colors.grey[400]),
        suffixIcon: isEditable
            ? IconButton(
          icon: Icon(
            isEditing ? Icons.check : Icons.edit_outlined,
            color: Colors.deepPurpleAccent,
          ),
          onPressed: onEditTap,
        )
            : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[700]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.deepPurpleAccent),
        ),
        // A different border for non-editing fields to indicate they are disabled
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[800]!),
        ),
        fillColor: Colors.grey[900]?.withOpacity(0.5),
        filled: true,
      ),
    );
  }
}