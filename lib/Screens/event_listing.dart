import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../services/api-service.dart';

// --- Model for a single ticket tier (Unchanged) ---
class TicketTier {
  final TextEditingController nameController;
  final TextEditingController priceController;
  final TextEditingController quantityController;

  TicketTier()
    : nameController = TextEditingController(),
      priceController = TextEditingController(),
      quantityController = TextEditingController();

  void dispose() {
    nameController.dispose();
    priceController.dispose();
    quantityController.dispose();
  }
}

class EventListing extends StatefulWidget {
  const EventListing({super.key});

  @override
  State<EventListing> createState() => _EventListingState();
}

class _EventListingState extends State<EventListing> {
  final _formKey = GlobalKey<FormState>();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  // --- NEW: State variables for new features ---
  File? _bannerImage;
  bool _isLoading = false;
  String _selectedCategory = 'CONCERT'; // Default category
  final List<String> _eventCategories = [
    "CONCERT",
    "THEATER",
    "SPORTS",
    "COMEDY",
    "OTHER",
  ];

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  final List<TicketTier> _ticketTiers = [TicketTier()];

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    for (var tier in _ticketTiers) {
      tier.dispose();
    }
    super.dispose();
  }

  // --- NEW: Function to pick an image from the gallery ---
  Future<void> _pickImage() async {
    if (_isLoading) return;
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1920, // Limit image size for better performance
        maxHeight: 1080,
      );
      if (image != null) {
        setState(() {
          _bannerImage = File(image.path);
        });
      }
    } catch (e) {
      print("Error picking image: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  // --- NEW: Function to remove selected image ---
  void _removeImage() {
    setState(() {
      _bannerImage = null;
    });
  }

  // --- DEBUG: Function to test image upload with minimal data ---
  Future<void> _testImageUpload() async {
    if (_bannerImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first')),
      );
      return;
    }

    final token = await _storage.read(key: 'token');
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No authentication token found')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Test with different field name variations
      final Map<String, String> fields = {
        'name': 'Test Event',
        'description': 'Test Description',
        'location': 'Test Location',
        'date': DateTime.now().toIso8601String(),
        'category': 'CONCERT',
        // Try different variations of seatCategories field name
        'seatCategories': jsonEncode([
          {'categoryName': 'General', 'totalSeats': 100, 'pricePerSeat': 50.0},
        ]),
        // Also try alternative field names
        'seat_categories': jsonEncode([
          {'categoryName': 'General', 'totalSeats': 100, 'pricePerSeat': 50.0},
        ]),
        'seatCategoryList': jsonEncode([
          {'categoryName': 'General', 'totalSeats': 100, 'pricePerSeat': 50.0},
        ]),
        // Try alternative date format
        'eventDate': DateTime.now().toIso8601String(),
      };

      final http.MultipartFile imageFile = await http.MultipartFile.fromPath(
        'image',
        _bannerImage!.path,
      );

      print('=== TEST UPLOAD DEBUG ===');
      print('Fields: $fields');
      print('Image path: ${_bannerImage!.path}');
      print('Image field name: ${imageFile.field}');

      final response = await ApiService.uploadFileWithAuth(
        token,
        '/events/with-image',
        fields: fields,
        files: [imageFile],
      );

      print('Test response status: ${response.statusCode}');
      print('Test response body: ${response.body}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Test upload result: ${response.statusCode} - ${response.body}',
            ),
            backgroundColor:
                response.statusCode == 200 || response.statusCode == 201
                ? Colors.green
                : Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Test upload error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Test upload error: $e'),
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

  // --- DEBUG: Function to test image upload without seatCategories ---
  Future<void> _testImageUploadSimple() async {
    if (_bannerImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first')),
      );
      return;
    }

    final token = await _storage.read(key: 'token');
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No authentication token found')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Test with minimal data without seatCategories
      final Map<String, String> fields = {
        'name': 'Test Event',
        'description': 'Test Description',
        'location': 'Test Location',
        'date': DateTime.now().toIso8601String(),
        'category': 'CONCERT',
        // Try without seatCategories to see if that's the issue
      };

      final http.MultipartFile imageFile = await http.MultipartFile.fromPath(
        'image',
        _bannerImage!.path,
      );

      print('=== SIMPLE TEST UPLOAD DEBUG ===');
      print('Fields: $fields');
      print('Image path: ${_bannerImage!.path}');
      print('Image field name: ${imageFile.field}');

      final response = await ApiService.uploadFileWithAuth(
        token,
        '/events/with-image',
        fields: fields,
        files: [imageFile],
      );

      print('Simple test response status: ${response.statusCode}');
      print('Simple test response body: ${response.body}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Simple test result: ${response.statusCode} - ${response.body}',
            ),
            backgroundColor:
                response.statusCode == 200 || response.statusCode == 201
                ? Colors.green
                : Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Simple test upload error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Simple test error: $e'),
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

  // --- DEBUG: Function to test regular event creation (without image) ---
  Future<void> _testRegularEventCreation() async {
    final token = await _storage.read(key: 'token');
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No authentication token found')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Test with the same data structure as regular event creation
      final Map<String, dynamic> jsonData = {
        'name': 'Test Event',
        'description': 'Test Description',
        'location': 'Test Location',
        'date': DateTime.now().toIso8601String(),
        'category': 'CONCERT',
        'seatCategories': [
          {'categoryName': 'General', 'totalSeats': 100, 'pricePerSeat': 50.0},
        ],
      };

      print('=== REGULAR EVENT TEST DEBUG ===');
      print('JSON data: ${jsonEncode(jsonData)}');

      final response = await ApiService.postWithAuth(
        token,
        '/events',
        jsonData,
      );

      print('Regular event test response status: ${response.statusCode}');
      print('Regular event test response body: ${response.body}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Regular event test result: ${response.statusCode} - ${response.body}',
            ),
            backgroundColor:
                response.statusCode == 200 || response.statusCode == 201
                ? Colors.green
                : Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Regular event test error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Regular event test error: $e'),
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

  // --- NEW: Function to handle event submission to the API ---
  Future<void> _submitEvent() async {
    final token = await _storage.read(key: 'token');
    // 1. Validate all form fields
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please correct the errors in the form.')),
      );
      return;
    }

    // 2. Validate non-form fields
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a valid date and time.')),
      );
      return;
    }

    // 3. Validate ticket tiers
    for (int i = 0; i < _ticketTiers.length; i++) {
      final tier = _ticketTiers[i];
      if (tier.nameController.text.isEmpty ||
          tier.priceController.text.isEmpty ||
          tier.quantityController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please fill all fields for ticket tier ${i + 1}.'),
          ),
        );
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 4. Prepare data for the API
      final combinedDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
      final isoDate = combinedDateTime.toIso8601String();

      final List<Map<String, dynamic>> seatCategories = _ticketTiers.map((
        tier,
      ) {
        return {
          'categoryName': tier.nameController.text,
          'totalSeats': int.tryParse(tier.quantityController.text) ?? 0,
          'pricePerSeat': double.tryParse(tier.priceController.text) ?? 0.0,
        };
      }).toList();

      // 5. Create the JSON data structure
      final Map<String, dynamic> jsonData = {
        'name': _titleController.text,
        'description': _descriptionController.text,
        'location': _locationController.text,
        'date': isoDate,
        'category': _selectedCategory,
        'seatCategories': seatCategories, // Keep as proper JSON array
      };

      print('Sending JSON data: ${jsonEncode(jsonData)}');

      http.Response response;

      if (_bannerImage != null) {
        // 5a. If image is provided, use multipart upload with form fields
        final Map<String, String> fields = {
          'name': _titleController.text,
          'description': _descriptionController.text,
          'location': _locationController.text,
          'date': isoDate,
          'category': _selectedCategory,
          'seatCategories': jsonEncode(
            seatCategories,
          ), // JSON string for multipart
        };

        print('Seat categories JSON: ${jsonEncode(seatCategories)}');

        // Validate image file exists and is readable
        if (!_bannerImage!.existsSync()) {
          throw Exception('Selected image file not found');
        }

        final http.MultipartFile imageFile = await http.MultipartFile.fromPath(
          'image', // Field name must match what the Spring Boot controller expects
          _bannerImage!.path,
        );

        print('Uploading image: ${_bannerImage!.path}');
        print('Image file size: ${await _bannerImage!.length()} bytes');
        print('Form fields: $fields');
        print('Image field name: ${imageFile.field}');

        response = await ApiService.uploadFileWithAuth(
          token!,
          '/events/with-image', // Changed endpoint to match controller
          fields: fields,
          files: [imageFile],
        );
      } else {
        // 5b. If no image, use your existing post method which sends JSON
        response = await ApiService.postWithAuth(token!, '/events', jsonData);
      }

      print('Response status: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');

      // 6. Handle the API response
      if (!mounted) return;

      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event Listed Successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      } else {
        final responseBody = jsonDecode(response.body);
        print(responseBody);
        final errorMessage =
            responseBody['message'] ?? 'Failed to create event.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $errorMessage'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      // Handle exceptions (network, timeout, etc.)
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An unexpected error occurred: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _addTicketTier() {
    setState(() {
      _ticketTiers.add(TicketTier());
    });
  }

  void _removeTicketTier(int index) {
    setState(() {
      _ticketTiers[index].dispose();
      _ticketTiers.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text(
          'List Your Event',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildSectionHeader('Basic Info'),
            const SizedBox(height: 16),
            _buildImagePicker(),
            const SizedBox(height: 16),
            _buildTextFormField(controller: _titleController, label: 'Title'),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _descriptionController,
              label: 'Description',
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // --- NEW: Category Dropdown ---
            _buildCategoryDropdown(),
            const SizedBox(height: 24),

            _buildDateTimePicker(),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _locationController,
              label: 'Location / Venue',
            ),
            const SizedBox(height: 24),

            _buildSectionHeader('Ticket Tiers'),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _ticketTiers.length,
              itemBuilder: (context, index) {
                return _buildTicketTierCard(
                  tier: _ticketTiers[index],
                  index: index,
                  onRemove: () => _removeTicketTier(index),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildAddNewTierButton(),
            const SizedBox(height: 32),

            // Debug test buttons (remove these in production)
            if (_bannerImage != null) ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : _testImageUpload,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.orange),
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: const Text(
                    'Test Image Upload (With Seat Categories)',
                    style: TextStyle(fontSize: 14.0, color: Colors.orange),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : _testImageUploadSimple,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.yellow),
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: const Text(
                    'Test Image Upload (Simple - No Seat Categories)',
                    style: TextStyle(fontSize: 14.0, color: Colors.yellow),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : _testRegularEventCreation,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.green),
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: const Text(
                    'Test Regular Event Creation (No Image)',
                    style: TextStyle(fontSize: 14.0, color: Colors.green),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : _submitEvent, // Disable button when loading
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : const Text(
                        'List Event',
                        style: TextStyle(fontSize: 18.0, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // --- UPDATED: Image picker now shows the selected image with remove option ---
  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Event Banner (Optional)",
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
        const SizedBox(height: 8.0),
        Stack(
          children: [
            InkWell(
              onTap: _pickImage,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[800]!),
                  image: _bannerImage != null
                      ? DecorationImage(
                          image: FileImage(_bannerImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _bannerImage == null
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo_outlined,
                              color: Colors.white54,
                              size: 40,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Tap to upload an image (optional)',
                              style: TextStyle(color: Colors.white54),
                            ),
                          ],
                        ),
                      )
                    : null,
              ),
            ),
            if (_bannerImage != null)
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: _removeImage,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  // --- NEW: Dropdown for selecting event category ---
  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category',
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
        const SizedBox(height: 8.0),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCategory,
              isExpanded: true,
              dropdownColor: Colors.grey[850],
              style: const TextStyle(color: Colors.white, fontSize: 16),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white54),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                }
              },
              items: _eventCategories.map<DropdownMenuItem<String>>((
                String value,
              ) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value.substring(0, 1) + value.substring(1).toLowerCase(),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  // --- UPDATED: Flexible TextFormField helper with validation ---
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
        const SizedBox(height: 8.0),
        TextFormField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: 'Enter $label',
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: Colors.grey[900],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          validator:
              validator ??
              (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a $label';
                }
                return null;
              },
        ),
      ],
    );
  }

  Widget _buildDateTimePicker() {
    return Row(
      children: [
        Expanded(
          child: _buildPickerField(
            label: 'Date',
            value: _selectedDate == null
                ? 'Select Date'
                : "${_selectedDate!.toLocal()}".split(' ')[0],
            icon: Icons.calendar_today,
            onTap: () => _selectDate(context),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildPickerField(
            label: 'Time',
            value: _selectedTime == null
                ? 'Select Time'
                : _selectedTime!.format(context),
            icon: Icons.access_time,
            onTap: () => _selectTime(context),
          ),
        ),
      ],
    );
  }

  Widget _buildPickerField({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
        const SizedBox(height: 8.0),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 14.0,
            ),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white54, size: 20),
                const SizedBox(width: 12),
                Text(value, style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTicketTierCard({
    required TicketTier tier,
    required int index,
    required VoidCallback onRemove,
  }) {
    return Card(
      color: Colors.grey[900]?.withOpacity(0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildTextFormField(
                    controller: tier.nameController,
                    label: 'Tier Name (e.g., VIP, General)',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter tier name';
                      }
                      return null;
                    },
                  ),
                ),
                if (_ticketTiers.length >
                    1) // Only show remove button if there's more than one tier
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 24.0,
                    ), // Align with text field
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.redAccent),
                      onPressed: onRemove,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextFormField(
                    controller: tier.priceController,
                    label: 'Price (Rs)',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}'),
                      ),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Enter price';
                      if (double.tryParse(value) == null)
                        return 'Invalid number';
                      if (double.parse(value) <= 0)
                        return 'Price must be greater than 0';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextFormField(
                    controller: tier.quantityController,
                    label: 'Quantity',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Enter quantity';
                      if (int.tryParse(value) == null) return 'Invalid number';
                      if (int.parse(value) <= 0)
                        return 'Quantity must be greater than 0';
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddNewTierButton() {
    return OutlinedButton.icon(
      icon: const Icon(Icons.add, color: Colors.deepPurpleAccent),
      label: const Text(
        'Add New Tier',
        style: TextStyle(color: Colors.deepPurpleAccent),
      ),
      onPressed: _addTicketTier,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.deepPurpleAccent),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}
