import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:onshopapp/mainscree.dart';
import 'homepage.dart'; // Make sure to import your homepage.

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _addressController = TextEditingController(); // Added for address
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  String? _selectedCity; // Variable to store selected city
  List<String> _cities = []; // List of cities fetched from Firestore

  @override
  void initState() {
    super.initState();
    _checkIfUserIsAlreadyRegistered();
    _fetchCities();
  }

  Future<void> _fetchCities() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('cities').get();
      List<String> cities = snapshot.docs.map((doc) => doc['name'] as String).toList();
      setState(() {
        _cities = cities;
      });
    } catch (e) {
      print("Error fetching cities: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to load cities.')));
    }
  }

  Future<void> _checkIfUserIsAlreadyRegistered() async {
    User? user = _auth.currentUser;

    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
        );
      }
    }
  }

  Future<void> _register() async {
    if (_selectedCity == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please select a city.')));
      return;
    }

    try {
      UserCredential userCredential = await _auth.signInAnonymously();
      User? user = userCredential.user;

      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'name': _nameController.text.trim(),
          'mobile': _mobileController.text.trim(),
          'city': _selectedCity,
          'address': _addressController.text.trim(), // Added address field
          'email': user.email ?? 'anonymous',
          'createdAt': FieldValue.serverTimestamp(), // Added timestamp
        });

        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('User registered successfully!')));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
        );
      }
    } catch (e) {
      print("Error during registration: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('An error occurred.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Register')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo
              Center(
                child: Image.asset(
                  'asset/onshopnewcurvedlogo.png',
                  height: 250,
                  width: 250,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 30),
              // Name field
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.black), // Black border
                  borderRadius: BorderRadius.circular(8), // Rounded corners
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black), // Black border when focused
                  borderRadius: BorderRadius.circular(8), // Rounded corners
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black), // Black border when enabled
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Mobile number field
              TextField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Mobile Number',
                  border: OutlineInputBorder(borderSide: const BorderSide(color: Colors.black), // Black border
                  borderRadius: BorderRadius.circular(8), // Rounded corners
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black), // Black border when focused
                  borderRadius: BorderRadius.circular(8), // Rounded corners
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black), // Black border when enabled
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              DropdownSearch<String>(
                items: _cities..sort(),
                selectedItem: _selectedCity,
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: "Select City",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                  searchFieldProps: TextFieldProps(
                    decoration: InputDecoration(
                      hintText: "Search city...",
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black), // Black border
                  borderRadius: BorderRadius.circular(8), // Rounded corners
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black), // Black border when focused
                  borderRadius: BorderRadius.circular(8), // Rounded corners
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black), // Black border when enabled
                      ),
                    ),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _selectedCity = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              // Address field
              TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Delivery Address',
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.black), // Black border
                  borderRadius: BorderRadius.circular(8), // Rounded corners
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black), // Black border when focused
                  borderRadius: BorderRadius.circular(8), // Rounded corners
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black), // Black border when enabled
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Searchable City Dropdown
              
              // Register button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 255, 181, 45),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text(
                    'Register',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}