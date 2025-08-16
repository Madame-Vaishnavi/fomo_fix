import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../api-service.dart';

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

  // --- NEW: State variables for new features ---
  File? _bannerImage;
  bool _isLoading = false;
  String _selectedCategory = 'CONCERT'; // Default category
  final List<String> _eventCategories = [
    'CONCERT',
    'SPORTS',
    'CONFERENCE',
    'THEATER',
    'FESTIVAL',
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
      );
      if (image != null) {
        setState(() {
          _bannerImage = File(image.path);
        });
      }
    } catch (e) {
      print("Error picking image: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error picking image.')));
    }
  }

  // --- NEW: Function to handle event submission to the API ---
  Future<void> _submitEvent() async {
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

      final List<Map<String, dynamic>> seatCategories = _ticketTiers.map((tier) {
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
          'seatCategories': jsonEncode(seatCategories), // JSON string for multipart
        };

        final http.MultipartFile bannerFile = await http.MultipartFile.fromPath(
          'bannerImage',
          _bannerImage!.path,
        );

        response = await ApiService.uploadFile(
          '/events',
          fields: fields,
          files: [bannerFile],
        );
      } else {
        // 5b. If no image, use your existing post method which sends JSON
        response = await ApiService.post('/events', jsonData);
      }

      print('Response status: ${response.statusCode}');
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
        final errorMessage = responseBody['message'] ?? 'Failed to create event.';
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

  // --- UPDATED: Image picker now shows the selected image ---
  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Event Banner (Optional)",
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
        const SizedBox(height: 8.0),
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
