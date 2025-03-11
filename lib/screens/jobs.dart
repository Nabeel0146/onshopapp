import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class JobsListingPage extends StatefulWidget {
  @override
  _JobsListingPageState createState() => _JobsListingPageState();
}

class _JobsListingPageState extends State<JobsListingPage> {
  String? selectedCity;
  List<String> cities = [];
  List<Map<String, dynamic>> jobs = []; // Store job data
  late Future<void> _initializationFuture;

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _mobileController = TextEditingController();
  final _postedDateController = TextEditingController();
  final _expiryDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializationFuture = _initializeData();
  }

  Future<void> _initializeData() async {
    await _fetchCities();
    await _loadSelectedCity();
    await _fetchJobs(); // Fetch jobs after loading cities and selected city
  }

  Future<void> _fetchCities() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('cities').get();
      final cityList = querySnapshot.docs.map((doc) => doc['name'] as String).toList();
      setState(() {
        cities = cityList;
      });
    } catch (e) {
      print('Error fetching cities: $e');
    }
  }

  Future<void> _loadSelectedCity() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedCity = prefs.getString('selectedCity');
    });

    if (selectedCity == null) {
      await _fetchLoggedInUserCity();
    }
  }

  Future<void> _fetchLoggedInUserCity() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        final userCity = userDoc.data()?['city'] as String?;
        setState(() {
          selectedCity = userCity ?? (cities.isNotEmpty ? cities.first : null);
        });

        final prefs = await SharedPreferences.getInstance();
        if (selectedCity != null) {
          prefs.setString('selectedCity', selectedCity!);
        }
      }
    } catch (e) {
      print('Error fetching user city: $e');
    }
  }

  Future<void> _fetchJobs() async {
  try {
    // Remove the city constraint
    final querySnapshot = await FirebaseFirestore.instance
        .collection('jobs')
        .get(); // Fetch all jobs without filtering by city

    final jobList = querySnapshot.docs.map((doc) {
      return {
        'title': doc['title'],
        'description': doc['description'],
        'mobile': doc['mobile'],
        'posteddate': doc['posteddate'].toDate(),
        'expirydate': doc['expirydate'].toDate(),
        'city': doc['city'],
      };
    }).toList();

    setState(() {
      jobs = jobList;
    });
  } catch (e) {
    print('Error fetching jobs: $e');
  }
}

  // Function to launch phone dialer
void _makeCall(String phoneNumber) async {
  final uri = Uri(scheme: 'tel', path: phoneNumber);
  try {
    if (!await launchUrl(uri)) {
      print('Could not launch $uri');
    }
  } catch (e) {
    print('Error occurred: $e');
  }
}

  Future<void> _addJob() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final title = _titleController.text;
        final description = _descriptionController.text;
        final mobile = _mobileController.text;
        final postedDate = DateFormat('yyyy-MM-dd').parse(_postedDateController.text);
        final expiryDate = DateFormat('yyyy-MM-dd').parse(_expiryDateController.text);

        await FirebaseFirestore.instance.collection('jobs').add({
          'title': title,
          'description': description,
          'mobile': mobile,
          'city': selectedCity,
          'posteddate': postedDate,
          'expirydate': expiryDate,
        });

        // Clear the form after submission
        _titleController.clear();
        _descriptionController.clear();
        _mobileController.clear();
        _postedDateController.clear();
        _expiryDateController.clear();

        // Refresh the job listings
        _fetchJobs();

        // Close the dialog
        Navigator.pop(context);
      } catch (e) {
        print('Error adding job: $e');
      }
    }
  }

  // Date Picker function to show the date picker dialog
  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (selectedDate != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
  backgroundColor: const Color.fromARGB(255, 255, 185, 41),
  toolbarHeight: 70,
  flexibleSpace: Padding(
    padding: const EdgeInsets.only(top: 20),
    child: Row(
      children: [
        const SizedBox(width: 45),
        ClipRRect(
          child: Image.asset("asset/appbarlogo.png", width: 50),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'On Shop',
                style: TextStyle(
                    color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        
        const SizedBox(width: 10),
      ],
    ),
  ),
),
      body: jobs.isEmpty
          ? Center(child: Text("No Jobs Available"))
          : ListView.builder(
              itemCount: jobs.length,
              itemBuilder: (context, index) {
                final job = jobs[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  elevation: 5,
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Job Title
                        Text(
                          job['title'],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Job Description
                        Text(
                          job['description'],
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Mobile Number
                        Row(
                          children: [
                            Text("Mobile: "),
                            const SizedBox(width: 5),

                            Text(
                              job['mobile'],
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                          Row(
                          children: [
                            Text("City: ", style: TextStyle(fontWeight: FontWeight.bold),),
                            const SizedBox(width: 5),

                            Text(
                              job['city'],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        
                        // Posted Date and Expiry Date
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Posted on: ${job['posteddate'].toLocal().toString().split(' ')[0]}', // Show date only
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black45,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Expiry: ${job['expirydate'].toLocal().toString().split(' ')[0]}', // Show date only
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black45,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        
                        // Call Button
                        const SizedBox(height: 15),
                        Align(
                          alignment: Alignment.topLeft,
                          child: TextButton(
                            onPressed: () {
                              _makeCall(job['mobile']);
                            },
                            child: Row(
                              children: [
                                Icon(Icons.phone, size: 20, color: Colors.black54),
                                SizedBox(width: 10),
                                Text(
                                  'Call Now',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Add Job'),
                content: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _titleController,
                          decoration: InputDecoration(labelText: 'Job Title'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a title';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: InputDecoration(labelText: 'Description'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a description';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _mobileController,
                          decoration: InputDecoration(labelText: 'Mobile'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a mobile number';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _postedDateController,
                          decoration: InputDecoration(labelText: 'Posted Date'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the posted date';
                            }
                            return null;
                          },
                          readOnly: true, // Prevent manual input
                          onTap: () => _selectDate(context, _postedDateController), // Show date picker on tap
                        ),
                        TextFormField(
                          controller: _expiryDateController,
                          decoration: InputDecoration(labelText: 'Expiry Date'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the expiry date';
                            }
                            return null;
                          },
                          readOnly: true, // Prevent manual input
                          onTap: () => _selectDate(context, _expiryDateController), // Show date picker on tap
                        ),
                        DropdownButtonFormField<String>(
                          value: selectedCity,
                          onChanged: (newValue) {
                            setState(() {
                              selectedCity = newValue;
                            });
                          },
                          items: cities.map((city) {
                            return DropdownMenuItem<String>(
                              value: city,
                              child: Text(city),
                            );
                          }).toList(),
                          decoration: InputDecoration(labelText: 'Select City'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a city';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _addJob,
                          child: Text('Submit Job'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        child: Icon(Icons.add),
        backgroundColor: const Color.fromARGB(255, 255,185, 41),
      ),
    );
  }
}