import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductsPage extends StatefulWidget {
  final String category;

  const ProductsPage({required this.category, Key? key}) : super(key: key);

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  String? selectedCity;
  List<String> cities = [];
  late Future<void> _initializationFuture;

  @override
  void initState() {
    super.initState();
    _initializationFuture = _initializeData();
  }

  Future<void> _initializeData() async {
    await _fetchCities();
    await _loadSelectedCity();
  }

  Future<void> _fetchCities() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('cities').get();
      final cityList =
          querySnapshot.docs.map((doc) => doc['name'] as String).toList();
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

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
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

  Future<List<Map<String, dynamic>>> _fetchFilteredItems(
      String category, String? city) async {
    try {
      Query<Map<String, dynamic>> query = FirebaseFirestore.instance
          .collection('products')
          .where('category', isEqualTo: category)
          .where('display', isEqualTo: true);

      if (city != null) {
        query = query.where('city', isEqualTo: city);
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Error fetching items: $e');
      return [];
    }
  }

  void _openWhatsApp(String phoneNumber) async {
    final formattedPhoneNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri.parse('https://wa.me/$formattedPhoneNumber');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open WhatsApp for $phoneNumber')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Transparent to allow gradient
        toolbarHeight: 70,
        elevation: 0, // Remove shadow if not needed
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
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                if (cities.isNotEmpty)
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.black,
                        size: 20,
                      ),
                      const SizedBox(width: 5),
                      SizedBox(
                        width: 150, // Adjust width as needed
                        child: DropdownSearch<String>(
                          items: cities..sort(), // Sort cities alphabetically
                          selectedItem: selectedCity,
                          popupProps: PopupProps.menu(
                            showSearchBox: true, // Enable search functionality
                            searchFieldProps: TextFieldProps(
                              decoration: InputDecoration(
                                hintText: "Search city...",
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          dropdownButtonProps: const DropdownButtonProps(
                            icon: Icon(Icons.arrow_drop_down,
                                color: Colors.black),
                          ),
                          dropdownDecoratorProps: DropDownDecoratorProps(
                            baseStyle: TextStyle(color: Colors.black),
                            dropdownSearchDecoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.transparent,
                            ),
                          ),
                          onChanged: (newValue) {
                            setState(() {
                              selectedCity = newValue;
                            });

                            if (newValue != null) {
                              SharedPreferences.getInstance().then((prefs) {
                                prefs.setString('selectedCity', newValue);
                              });
                            }

                            // Fetch offers for the new city
                            setState(
                                () {}); // Ensure this method is called to reload the page
                          },
                        ),
                      ),
                    ],
                  ),
                const SizedBox(width: 10),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.only(top: 30, left: 10, right: 10),
        child: FutureBuilder<void>(
          future: _initializationFuture,
          builder: (context, initializationSnapshot) {
            if (initializationSnapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            return FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchFilteredItems(widget.category, selectedCity),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
        
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
        
                final items = snapshot.data ?? [];
        
                if (items.isEmpty) {
                  return const Center(
                    child: Text('No items found for this category.',
                        style:
                            TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  );
                }
        
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: items.length,
                 itemBuilder: (context, index) {
          final item = items[index];
          return Container(
            decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey, // You can change the border color as needed
          width: 0.5, // Set the border width to 0.5
        ),
        borderRadius: BorderRadius.circular(8), // Optional: Add rounded corners
            ),
            child: Card(
        elevation: 0, // Remove the default shadow if you want a flat look
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Ensure the Card has rounded corners
        ),
        child: Column(
          children: [
            if (item['image_url'] != null && item['image_url'].toString().isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AspectRatio(
                  aspectRatio: 4 / 4,
                  child: CachedNetworkImage(
                    imageUrl: item['image_url'],
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.error),
                    ),
                  ),
                ),
              )
            else
              AspectRatio(
                aspectRatio: 3 / 3,
                child: Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported),
                ),
              ),
            const SizedBox(height: 8),
            Text(
              item['product_name'] ?? 'No Name',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item['product_description'] ?? 'No Description',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              'Price: ${item['price'] ?? 'N/A'}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                if (item['whatsapp_number'] != null) {
                  _openWhatsApp(item['whatsapp_number']);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Order on Whatsapp', style: TextStyle(color: Colors.white),),
            ),
          ],
        ),
            ),
          );
        },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
