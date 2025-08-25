import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../services/api-service.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

class AccountDetailsPage extends StatefulWidget {
  const AccountDetailsPage({super.key});

  @override
  State<AccountDetailsPage> createState() => _AccountDetailsPageState();
}

class _AccountDetailsPageState extends State<AccountDetailsPage> {
  File? _image;
  final ImagePicker _picker = ImagePicker();

  // Profile loading state
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  bool _isLoadingProfile = true;
  String? _profileError;
  String? _username;
  String? _email;

  // Controllers and editing states
  late TextEditingController _nameController = TextEditingController();
  bool _isEditingName = false;

  // Username update state
  bool _isUpdatingUsername = false;
  String? _usernameError;
  String? _usernameSuccess;

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
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  /// Toggles the editing state for the username field and saves the changes.
  void _toggleNameEdit() async {
    if (_isEditingName) {
      // Save the username when toggling off edit mode
      await _updateUsername();
    } else {
      // Clear any previous errors when starting to edit
      setState(() {
        _usernameError = null;
        _usernameSuccess = null;
        _isEditingName = true;
      });
    }
  }

  /// Cancels username editing and resets to original value
  void _cancelUsernameEdit() {
    setState(() {
      _nameController.text = _username ?? '';
      _isEditingName = false;
      _usernameError = null;
      _usernameSuccess = null;
    });
  }

  /// Validates and updates the username
  Future<void> _updateUsername() async {
    final newUsername = _nameController.text.trim();

    // Validation
    if (newUsername.isEmpty) {
      setState(() {
        _usernameError = 'Username is required';
      });
      return;
    }

    if (newUsername.length < 3) {
      setState(() {
        _usernameError = 'Username must be at least 3 characters';
      });
      return;
    }

    if (newUsername.length > 20) {
      setState(() {
        _usernameError = 'Username must be less than 20 characters';
      });
      return;
    }

    if (newUsername == _username) {
      // No change, just exit editing mode
      setState(() {
        _isEditingName = false;
        _usernameError = null;
      });
      return;
    }

    setState(() {
      _isUpdatingUsername = true;
      _usernameError = null;
      _usernameSuccess = null;
    });

    try {
      final token = await _secureStorage.read(key: 'token');
      if (token == null) {
        setState(() {
          _usernameError = 'Authentication required';
          _isUpdatingUsername = false;
        });
        return;
      }

      final response = await ApiService.updateUsername(token, newUsername);
      print(newUsername);
      print(response.statusCode);
      print(token);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        User? updatedUser;

        // Some backends may return 204 No Content or empty body on success
        if (response.body.isNotEmpty) {
          final data = json.decode(response.body);
          updatedUser = User.fromJson(data);
        } else {
          // Fallback: re-fetch profile to refresh local state
          final profileResponse = await ApiService.getUserProfile(token);
          if (profileResponse.statusCode == 200 &&
              profileResponse.body.isNotEmpty) {
            final data = json.decode(profileResponse.body);
            updatedUser = User.fromJson(data);
          }
        }

        if (updatedUser != null) {
          await AuthService.setAuth(token, updatedUser);
        }

        setState(() {
          _username = newUsername;
          _usernameSuccess = 'Username updated successfully!';
          _isUpdatingUsername = false;
          _isEditingName = false;
        });

        // Clear success message after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _usernameSuccess = null;
            });
          }
        });
      } else {
        String message = 'Failed to update username';
        print(response.body);
        if (response.body.isNotEmpty) {
          try {
            final errorData = json.decode(response.body);
            message = errorData['message']?.toString() ?? message;
          } catch (_) {}
        }
        setState(() {
          _usernameError = message;
          _isUpdatingUsername = false;
        });
      }
    } catch (e) {
      setState(() {
        _usernameError = 'Error updating username: $e';
        print(_usernameError);
        _isUpdatingUsername = false;
      });
    }
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
          title: const Text(
            'Account Details',
            style: TextStyle(color: Colors.white),
          ),
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
          title: const Text(
            'Account Details',
            style: TextStyle(color: Colors.white),
          ),
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
        title: const Text(
          'Account Details',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            _buildProfileImage(),
            const SizedBox(height: 40),
            _buildUsernameField(),
            const SizedBox(height: 20),
            _buildDetailField(
              controller: TextEditingController(text: _email ?? ''),
              label: 'Email',
              icon: Icons.email_outlined,
            ),
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

  /// Builds the username field with inline editing and validation
  Widget _buildUsernameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _nameController,
          readOnly: !_isEditingName,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            labelText: 'Username',
            labelStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: Icon(Icons.alternate_email, color: Colors.grey[400]),
            suffixIcon: _isEditingName
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isUpdatingUsername)
                        const Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.deepPurpleAccent,
                              ),
                            ),
                          ),
                        )
                      else ...[
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: _updateUsername,
                          tooltip: 'Save',
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: _cancelUsernameEdit,
                          tooltip: 'Cancel',
                        ),
                      ],
                    ],
                  )
                : IconButton(
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: Colors.deepPurpleAccent,
                    ),
                    onPressed: _toggleNameEdit,
                    tooltip: 'Edit Username',
                  ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[700]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.deepPurpleAccent),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[800]!),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            fillColor: Colors.grey[900]?.withOpacity(0.5),
            filled: true,
            errorText: _usernameError,
          ),
        ),
        // Success message
        if (_usernameSuccess != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[900]!.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green[300]!),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.green[300]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _usernameSuccess!,
                    style: TextStyle(color: Colors.green[300]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
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
