import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class HospitalEditPage extends StatefulWidget {
  final String hospitalId;
  final Map<String, dynamic> hospitalData;

  const HospitalEditPage({
    required this.hospitalId,
    required this.hospitalData,
    Key? key,
  }) : super(key: key);

  @override
  State<HospitalEditPage> createState() => _HospitalEditPageState();
}

class _HospitalEditPageState extends State<HospitalEditPage> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _phoneController;
  late TextEditingController _whatsappController;
  late TextEditingController _imageUrlController;
  late TextEditingController _mapLinkController;

  final TextEditingController _doctorNameController = TextEditingController();
  final TextEditingController _doctorDescriptionController =
      TextEditingController();
  final TextEditingController _doctorTimingController = TextEditingController();
  final TextEditingController _doctorDaysController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.hospitalData['name']);
    _descriptionController =
        TextEditingController(text: widget.hospitalData['description']);
    _phoneController =
        TextEditingController(text: widget.hospitalData['mobile']);
    _whatsappController =
        TextEditingController(text: widget.hospitalData['whatsapp']);
    _imageUrlController =
        TextEditingController(text: widget.hospitalData['image_url']);
    _mapLinkController =
        TextEditingController(text: widget.hospitalData['maplink']);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _imageUrlController.dispose();
    _mapLinkController.dispose();
    _doctorNameController.dispose();
    _doctorDescriptionController.dispose();
    _doctorTimingController.dispose();
    _doctorDaysController.dispose();
    super.dispose();
  }

  Future<void> _updateHospital() async {
    final name = _nameController.text;
    final description = _descriptionController.text;
    final phone = _phoneController.text;
    final whatsapp = _whatsappController.text;
    final imageUrl = _imageUrlController.text;
    final mapLink = _mapLinkController.text;

    if (name.isEmpty || description.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all the required fields')),
      );
      return;
    }

    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('hospitallisting')
          .doc(widget.hospitalId)
          .get();

      if (!snapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hospital document does not exist')),
        );
        return;
      }

      await FirebaseFirestore.instance
          .collection('hospitallisting')
          .doc(widget.hospitalId)
          .update({
        'name': name,
        'description': description,
        'mobile': phone,
        'whatsapp': whatsapp,
        'image_url': imageUrl,
        'maplink': mapLink,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hospital updated successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating hospital: $e')),
      );
    }
  }

  void _showAddDoctorDialog() {
  List<String> daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  String? selectedStartDay = daysOfWeek.first;
  String? selectedEndDay = daysOfWeek.last;

  TimeOfDay? startTime; // Define startTime
  TimeOfDay? endTime; // Define endTime

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Add New Doctor'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _doctorNameController,
                  decoration: InputDecoration(
                    labelText: 'Doctor Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8), // Rounded corners
                      borderSide: const BorderSide(color: Colors.grey, width: 1), // Border color and width
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8), // Rounded corners
                      borderSide: const BorderSide(color: Colors.blue, width: 1), // Focused border color and width
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8), // Rounded corners
                      borderSide: const BorderSide(color: Colors.grey, width: 1), // Enabled border color and width
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _doctorDescriptionController,
                  decoration: InputDecoration(
                    labelText: 'Doctor Description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8), // Rounded corners
                      borderSide: const BorderSide(color: Colors.grey, width: 1), // Border color and width
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8), // Rounded corners
                      borderSide: const BorderSide(color: Colors.blue, width: 1), // Focused border color and width
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8), // Rounded corners
                      borderSide: const BorderSide(color: Colors.grey, width: 1), // Enabled border color and width
                    ),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () async {
                            final TimeOfDay? picked = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (picked != null) {
                              setState(() {
                                startTime = picked; // Update startTime
                              });
                            }
                          },
                          child: Text(
                            startTime == null ? 'Select Start Time' : startTime!.format(context).toString(),
                            style: TextStyle(color: startTime == null ? Colors.grey : Colors.black),
                          ),
                        ),
                      ),
                      const Text('to'),
                      Expanded(
                        child: TextButton(
                          onPressed: () async {
                            final TimeOfDay? picked = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (picked != null) {
                              setState(() {
                                endTime = picked; // Update endTime
                              });
                            }
                          },
                          child: Text(
                            endTime == null ? 'Select End Time' : endTime!.format(context).toString(),
                            style: TextStyle(color: endTime == null ? Colors.grey : Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedStartDay,
                          items: daysOfWeek.map((day) {
                            return DropdownMenuItem<String>(
                              value: day,
                              child: Text(day),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedStartDay = value;
                            });
                          },
                          decoration: const InputDecoration(labelText: 'From'),
                        ),
                      ),
                      const Text('to'),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedEndDay,
                          items: daysOfWeek.map((day) {
                            return DropdownMenuItem<String>(
                              value: day,
                              child: Text(day),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedEndDay = value;
                            });
                          },
                          decoration: const InputDecoration(labelText: 'To'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (startTime != null &&
                      endTime != null &&
                      selectedStartDay != null &&
                      selectedEndDay != null) {
                    _addDoctor(startTime!, endTime!, selectedStartDay!, selectedEndDay!);
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select all time and day fields')),
                    );
                  }
                },
                child: const Text('Add Doctor'),
              ),
            ],
          );
        },
      );
    },
  );
}

  Future<void> _addDoctor(TimeOfDay startTime, TimeOfDay endTime,
      String startDay, String endDay) async {
    final name = _doctorNameController.text;
    final description = _doctorDescriptionController.text;

    if (name.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Please fill all the required fields for the doctor')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('doctors').add({
        'name': name,
        'description': description,
        'timing': '${startTime.format(context)}-${endTime.format(context)}',
        'days': '$startDay-$endDay',
        'hospital': widget.hospitalData['name'],
        'hospitalid': widget.hospitalId,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Doctor added successfully')),
      );
      _doctorNameController.clear();
      _doctorDescriptionController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding doctor: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 255, 185, 41), // Yellow at the top
                Colors.white, // White at the bottom
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      Text(
                        'Edit Hospital Profile',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        backgroundColor: Colors.amber,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Display the current image
            if (widget.hospitalData['image_url'] != null &&
                widget.hospitalData['image_url'].isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  widget.hospitalData['image_url'],
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              )
            else
              Icon(Icons.image, size: 100),

            SizedBox(height: 20),

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
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone'),
            ),
            TextFormField(
              controller: _whatsappController,
              decoration: const InputDecoration(labelText: 'WhatsApp'),
            ),
            TextFormField(
              controller: _imageUrlController,
              decoration: const InputDecoration(labelText: 'Image URL'),
            ),
            TextFormField(
              controller: _mapLinkController,
              decoration: const InputDecoration(labelText: 'Map Link'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateHospital,
              child: const Text('Update Hospital'),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Doctors",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: _showAddDoctorDialog,
                  child: const Text('Add Doctor'),
                ),
              ],
            ),

            const SizedBox(height: 20),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('doctors')
                  .where('hospitalid', isEqualTo: widget.hospitalId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No doctors found."));
                }

                var doctors = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: doctors.length,
                  itemBuilder: (context, index) {
                    var doctor = doctors[index].data() as Map<String, dynamic>;
                    String doctorId = doctors[index].id;

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: Colors.grey, width: 1), // Add a border
                        borderRadius:
                            BorderRadius.circular(10), // Rounded corners
                      ),
                      child: ListTile(
                        title: Text(doctor['name'] ?? 'Unnamed Doctor'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(doctor['description'] ?? ''),
                            Text('Timing: ${doctor['timing'] ?? ''}'),
                            Text('Days: ${doctor['days'] ?? ''}'),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            try {
                              await FirebaseFirestore.instance
                                  .collection('doctors')
                                  .doc(doctorId)
                                  .delete();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Doctor deleted successfully')),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Error deleting doctor: $e')),
                              );
                            }
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
