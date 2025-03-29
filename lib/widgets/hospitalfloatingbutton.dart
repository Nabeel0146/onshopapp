import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddNewHospitalPage extends StatefulWidget {
  final List<String> cities;
  final String subcategory;

  const AddNewHospitalPage({
    required this.cities,
    required this.subcategory,
    Key? key,
  }) : super(key: key);

  @override
  State<AddNewHospitalPage> createState() => _AddNewHospitalPageState();
}

class _AddNewHospitalPageState extends State<AddNewHospitalPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  String? _selectedCity;

  Future<void> _addNewHospital() async {
    final name = _nameController.text;
    final description = _descriptionController.text;
    final mobile = _mobileController.text;
    final whatsapp = _whatsappController.text;
    final imageUrl = _imageUrlController.text;
    final city = _selectedCity;

    if (name.isEmpty || description.isEmpty || mobile.isEmpty || city == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all the required fields')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('hospitallisting').add({
        'name': name,
        'description': description,
        'mobile': mobile,
        'whatsapp': whatsapp,
        'image_url': imageUrl,
        'city': city,
        'subcategory': widget.subcategory,
        'display': true,
        'associate': false,
        'lock': false,
        'customerid': '',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hospital added successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding hospital: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Hospital'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            TextFormField(
              controller: _mobileController,
              decoration: const InputDecoration(labelText: 'Mobile'),
            ),
            TextFormField(
              controller: _whatsappController,
              decoration: const InputDecoration(labelText: 'WhatsApp'),
            ),
            TextFormField(
              controller: _imageUrlController,
              decoration: const InputDecoration(labelText: 'Image URL'),
            ),
            DropdownSearch<String>(
              items: widget.cities,
              selectedItem: _selectedCity,
              popupProps: PopupProps.menu(
                showSearchBox: true,
                searchFieldProps: TextFieldProps(
                  decoration: InputDecoration(
                    hintText: "Search city...",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              dropdownButtonProps: const DropdownButtonProps(
                icon: Icon(Icons.arrow_drop_down, color: Colors.black),
              ),
              dropdownDecoratorProps: DropDownDecoratorProps(
                baseStyle: TextStyle(color: Colors.black),
                dropdownSearchDecoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                ),
              ),
              onChanged: (newValue) {
                setState(() {
                  _selectedCity = newValue;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addNewHospital,
              child: const Text('Add Hospital'),
            ),
          ],
        ),
      ),
    );
  }
}