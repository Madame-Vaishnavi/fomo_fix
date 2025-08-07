import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// --- NEW: Model for a single ticket tier ---
class TicketTier {
  final TextEditingController nameController;
  final TextEditingController priceController;
  final TextEditingController quantityController;

  TicketTier()
      : nameController = TextEditingController(),
        priceController = TextEditingController(),
        quantityController = TextEditingController();

  // Method to dispose controllers
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
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  // --- UPDATED: Manage a dynamic list of ticket tiers ---
  final List<TicketTier> _ticketTiers = [TicketTier()]; // Start with one tier

  // Controllers for text fields
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  @override
  void dispose() {
    // Dispose all controllers
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    for (var tier in _ticketTiers) {
      tier.dispose();
    }
    super.dispose();
  }

  // --- Date and Time Picker Logic ---
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

  // --- NEW: Functions to manage ticket tiers ---
  void _addTicketTier() {
    setState(() {
      _ticketTiers.add(TicketTier());
    });
  }

  void _removeTicketTier(int index) {
    setState(() {
      _ticketTiers[index].dispose(); // Dispose controllers before removing
      _ticketTiers.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: GestureDetector(
            onTap:(){
              Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back,color: Colors.white,)),
        title: const Text('List Your Event', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 25)),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // --- Section: Basic Info ---
            _buildSectionHeader('Basic Info'),
            const SizedBox(height: 16),
            _buildImagePicker(),
            const SizedBox(height: 16),
            _buildTextFormField(controller: _titleController, label: 'Title'),
            const SizedBox(height: 16),
            _buildTextFormField(controller: _descriptionController, label: 'Description', maxLines: 3),
            const SizedBox(height: 24),

            _buildDateTimePicker(),
            const SizedBox(height: 16),
            _buildTextFormField(controller: _locationController, label: 'Location / Venue'),
            const SizedBox(height: 24),

            // --- Section: Ticket Tiers (Now Dynamic) ---
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

            // --- Submit Button ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // TODO: Implement event submission logic
                    print('Event Listed Successfully!');
                    // You can access tier data like this:
                    for (var tier in _ticketTiers) {
                      print('Tier: ${tier.nameController.text}, Price: ${tier.priceController.text}, Qty: ${tier.quantityController.text}');
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: const Text('List Event', style: TextStyle(fontSize: 18.0, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold));
  }

  Widget _buildImagePicker() {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_a_photo_outlined, color: Colors.white54, size: 40),
            const SizedBox(height: 8),
            const Text('Upload Event Banner', style: TextStyle(color: Colors.white54)),
          ],
        ),
      ),
    );
  }

  // --- UPDATED: Helper for text fields with label above ---
  Widget _buildTextFormField({required TextEditingController controller, required String label, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 14,),
        ),
        const SizedBox(height: 8.0),
        TextFormField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: 'Enter $label',
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: Colors.grey[900],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a $label';
            }
            return null;
          },
        ),
      ],
    );
  }

  // --- UPDATED: Date/Time picker now uses a custom layout ---
  Widget _buildDateTimePicker() {
    return Row(
      children: [
        Expanded(
          child: _buildPickerField(
            label: 'Date',
            value: _selectedDate == null ? 'Select Date' : "${_selectedDate!.toLocal()}".split(' ')[0],
            icon: Icons.calendar_today,
            onTap: () => _selectDate(context),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildPickerField(
            label: 'Time',
            value: _selectedTime == null ? 'Select Time' : _selectedTime!.format(context),
            icon: Icons.access_time,
            onTap: () => _selectTime(context),
          ),
        ),
      ],
    );
  }

  // --- NEW: Helper for a single date or time picker field ---
  Widget _buildPickerField({required String label, required String value, required IconData icon, required VoidCallback onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 14,),
        ),
        const SizedBox(height: 8.0),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _buildTextFormField(
                    controller: tier.nameController,
                    label: 'Tier Name',
                  ),
                ),
                if (index > 0)
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.redAccent),
                    onPressed: onRemove,
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
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextFormField(
                    controller: tier.quantityController,
                    label: 'Quantity',
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
      label: const Text('Add New Tier', style: TextStyle(color: Colors.deepPurpleAccent)),
      onPressed: _addTicketTier,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.deepPurpleAccent),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}
