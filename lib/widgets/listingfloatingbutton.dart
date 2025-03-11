// widgets.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddNewItemButton extends StatelessWidget {
  final List<String> cities;
  final String subcategory;

  const AddNewItemButton({
    required this.cities,
    required this.subcategory,
    Key? key,
  }) : super(key: key);

  Future<void> _addNewItem(BuildContext context) async {
    TextEditingController nameController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    TextEditingController mobileController = TextEditingController();
    TextEditingController whatsappController = TextEditingController();
    bool display = false; // Display is false by default

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Item'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: mobileController,
                  decoration: const InputDecoration(labelText: 'Mobile'),
                ),
                TextField(
                  controller: whatsappController,
                  decoration: const InputDecoration(labelText: 'WhatsApp'),
                ),
                DropdownButton<String>(
                  value: cities.isNotEmpty ? cities.first : null,
                  onChanged: (value) {
                    // No need to set state here
                  },
                  items: cities
                      .map((city) => DropdownMenuItem(value: city, child: Text(city)))
                      .toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance.collection('shops').add({
                    'name': nameController.text,
                    'description': descriptionController.text,
                    'mobile': mobileController.text,
                    'whatsapp': whatsappController.text,
                    'city': cities.isNotEmpty ? cities.first : null,
                    'subcategory': subcategory,
                    'display': display,
                  });

                  // Show confirmation message
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Your Request is submitted to admin. It will be listed after Admin Approve.'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                } catch (e) {
                  print('Error saving item: $e');
                }
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _addNewItem(context),
      child: const Icon(Icons.add),
      backgroundColor: Colors.green,
    );
  }
}