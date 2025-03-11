import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:onshopapp/screens/Products/Shopprofile.dart';
import 'package:onshopapp/widgets/listingfloatingbutton.dart';
import 'package:onshopapp/widgets/listingwidgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListingPage extends StatefulWidget {
  final String subcategory;

  const ListingPage({required this.subcategory, Key? key}) : super(key: key);

  @override
  State<ListingPage> createState() => _ListingPageState();
}

class _ListingPageState extends State<ListingPage> {
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
      String subcategory, String? city) async {
    try {
      Query<Map<String, dynamic>> query = FirebaseFirestore.instance
          .collection('shops')
          .where('subcategory', isEqualTo: subcategory)
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

  Future<void> _checkCustomerID(Map<String, dynamic> item) async {
    if (item['associate'] == true) {
      if (item['lock'] == true) {
        String? customerID;
        await showDialog<String>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Enter Customer ID'),
              content: TextField(
                autofocus: true,
                decoration: const InputDecoration(hintText: 'Customer ID'),
                onChanged: (value) {
                  customerID = value;
                },
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, customerID),
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );

        if (customerID != null) {
          // Check if the customerID matches the one in the item's document
          if (item['customerid'] == customerID) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ShopProfilePage(shopData: item),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Invalid Customer ID')),
            );
          }
        }
      } else {
        // Directly navigate to ShopProfilePage if 'lock' is false
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ShopProfilePage(shopData: item),
          ),
        );
      }
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
                            setState(() {}); // Ensure this method is called to reload the page
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
      body: FutureBuilder<void>(
        future: _initializationFuture,
        builder: (context, initializationSnapshot) {
          if (initializationSnapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          return FutureBuilder<List<Map<String, dynamic>>>(
            future: _fetchFilteredItems(widget.subcategory, selectedCity),
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

              return ListView.builder(
                padding: const EdgeInsets.all(4),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return GestureDetector(
                    onTap: () {
                      _checkCustomerID(item);
                    },
                    child: Stack(
                      children: [
                        Card(
                          color: Colors.white,
                          elevation: 5,
                          shadowColor: Colors.grey.withOpacity(0.5),
                          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 14.0, right: 14, bottom: 14, top: 22),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    if (item['image_url'] != null && item['image_url'].toString().isNotEmpty)
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            CachedNetworkImage(
                                              imageUrl: item['image_url'],
                                              width: 80,
                                              height: 80,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) => Container(
                                                width: 80,
                                                height: 80,
                                                color: Colors.grey[300], // Placeholder background
                                                child: const Center(
                                                  child: SizedBox(
                                                    width: 16, // Smaller size
                                                    height: 16, // Smaller size
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2, // Thinner stroke
                                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black), // Black color
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              errorWidget: (context, url, error) => Container(
                                                width: 80,
                                                height: 80,
                                                color: Colors.grey[300],
                                                child: const Icon(Icons.error, color: Colors.red),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    else
                                      Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.image_not_supported, size: 30),
                                      ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(item['name'] ?? 'No Name',
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                          if (item['description'] != null)
                                            Text(item['description'],
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(fontSize: 12)),
                                         
                                          if (item['mobile'] != null)
                                            Text('Mobile: ${item['mobile']}',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(color: Colors.black, fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    ActionButton(
                                      label: 'Call',
                                      color: Colors.blue,
                                      iconPath: 'asset/call.png',
                                      onTap: () {
                                        if (item['mobile'] != null) {
                                          makeCall(item['mobile']);
                                        }
                                      },
                                    ),
                                    const SizedBox(width: 10),
                                    ActionButton(
                                      label: 'WhatsApp',
                                      color: Colors.green,
                                      iconPath: 'asset/whatsapp.png',
                                      onTap: () {
                                        if (item['whatsapp'] != null && item['whatsapp'].isNotEmpty) {
                                          openWhatsApp(context, item['whatsapp']);
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('WhatsApp is not available for this number')),
                                          );
                                        }
                                      },
                                    ),
                                    const SizedBox(width: 10),
                                    ActionButton(
                                      label: 'Share',
                                      color: const Color.fromARGB(255, 242, 222, 38),
                                      iconPath: 'asset/share.png',
                                      onTap: () {
                                        if (item['name'] != null && item['description'] != null && item['mobile'] != null) {
                                          shareDetails(item['name'], item['description'], item['mobile']);
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Unable to share. Missing item details.')),
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (item['associate'] == true)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.only(topRight: Radius.circular(5)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.check, color: Colors.white, size: 16),
                                  SizedBox(width: 4),
                                  Text(
                                    'Onshop Discount Card Accepted',
                                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: AddNewItemButton(
        cities: cities,
        subcategory: widget.subcategory,
      ),
    );
  }
}