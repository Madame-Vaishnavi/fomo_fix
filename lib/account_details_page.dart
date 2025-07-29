import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AccountDetailsPage extends StatefulWidget {
  const AccountDetailsPage({super.key});

  @override
  State<AccountDetailsPage> createState() => _AccountDetailsPageState();
}

class _AccountDetailsPageState extends State<AccountDetailsPage> {
  late TextEditingController _nameController;
  File? _image;
  final ImagePicker _picker = ImagePicker();

  // Dummy data - in a real app, this would come from a user model
  final String _email = "chingufugga@fuggas.com";
  final String _phone = "+91 12345 67890";
  bool _isEditingName = false;

  @override
  void initState() {
    super.initState();
    // Initialize the controller with the user's current name
    _nameController = TextEditingController(text: 'Singuliet');
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
              isEditable: true, // This field is editable
              isEditing: _isEditingName,
              onEditTap: _toggleNameEdit,
            ),
            const SizedBox(height: 20),
            _buildDetailField(
              controller: TextEditingController(text: _email),
              label: 'Email',
              icon: Icons.email_outlined,
            ),
            const SizedBox(height: 20),
            _buildDetailField(
              controller: TextEditingController(text: _phone),
              label: 'Phone Number',
              icon: Icons.phone_outlined,
            ),
          ],
        ),
      ),
    );
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