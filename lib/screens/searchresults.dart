import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:onshopapp/screens/Products/Shopprofile.dart';
import 'package:onshopapp/utils/app_functions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SearchResultsPage extends StatefulWidget {
  @override
  _SearchResultsPageState createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  List<DocumentSnapshot> _searchResults = [];
  TextEditingController _searchController = TextEditingController();
  String? selectedCity;
  List<String> cities = [];

  @override
  void initState() {
    super.initState();
    _fetchCities();
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

 Future<void> _searchShops(String query) async {
  if (query.isEmpty) {
    setState(() {
      _searchResults = [];
    });
    return;
  }

  try {
    final shopSnapshot = await FirebaseFirestore.instance
        .collection('shops')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: query + '\uf8ff')
        .get();

    final citySnapshot = await FirebaseFirestore.instance
        .collection('shops')
        .where('city', isGreaterThanOrEqualTo: query)
        .where('city', isLessThanOrEqualTo: query + '\uf8ff')
        .get();

    final shopcodeSnapshot = await FirebaseFirestore.instance
        .collection('shops')
        .where('shopcode', isEqualTo: query)
        .get();

    // Combine results and use a Set to remove duplicates based on 'name' and 'city'
    final uniqueResults = <String, DocumentSnapshot>{};

    for (var doc in shopSnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['display'] == true) { // Filter by `display` field
        final key = '${data['name']}-${data['city']}';
        uniqueResults[key] = doc;
      }
    }

    for (var doc in citySnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['display'] == true) { // Filter by `display` field
        final key = '${data['name']}-${data['city']}';
        uniqueResults[key] = doc;
      }
    }

    for (var doc in shopcodeSnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['display'] == true) { // Filter by `display` field
        final key = '${data['name']}-${data['city']}';
        uniqueResults[key] = doc;
      }
    }

    setState(() {
      _searchResults = uniqueResults.values.toList();
    });
  } catch (error) {
    print("Error searching for shops: $error");
  }
}

  Future<void> _checkCustomerID(Map<String, dynamic> item) async {
    if (item['associate'] == true) {
      if (item['lock'] == true) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        Map<String, String> storedCustomerIDs = {};

        // Safely parse stored customer IDs
        final storedCustomerIDsString = prefs.getString('customerIDs');
        if (storedCustomerIDsString != null &&
            storedCustomerIDsString.isNotEmpty) {
          storedCustomerIDs =
              Map<String, String>.from(jsonDecode(storedCustomerIDsString));
        }

        // Check if the customer ID for the current shop is already stored
        final shopId = item['shopid']; // Correct key name
        print('Shop ID: $shopId'); // Debugging: Print the shop ID

        if (shopId == null) {
          // If shopId is null, show an error message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid shop data')),
          );
          return;
        }

        final storedCustomerID = storedCustomerIDs[shopId];

        if (storedCustomerID != null &&
            storedCustomerID == item['customerid']) {
          print(
              'Navigating to ShopProfilePage with document ID: ${item['documentId']}');

          // If the stored customerID matches, navigate directly to ShopProfilePage
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ShopProfilePage(shopData: item),
            ),
          );
        } else {
          // If no stored customerID or it doesn't match, prompt the user to enter the shopID
          String? customerID;
          await showDialog<String>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Column(
                  children: [
                    const Text('Enter Shop ID'),
                    Text(
                      "Enter the shop id to view Business Profile",
                      style: TextStyle(fontSize: 14),
                    )
                  ],
                ),
                content: TextField(
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Shop ID',
                    border: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.black), // Black border
                      borderRadius: BorderRadius.circular(8), // Rounded corners
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Colors.black), // Black border when focused
                      borderRadius: BorderRadius.circular(8), // Rounded corners
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Colors.black), // Black border when enabled
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    customerID = value;
                  },
                ),
                actions: <Widget>[
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, customerID),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green, // Green background
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(8), // Rounded corners
                        ),
                      ),
                      child: const Text(
                        'Submit',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      16), // Curved corners for the dialog
                ),
                backgroundColor:
                    Colors.white, // White background for the dialog
              );
            },
          );

          if (customerID != null) {
            // Check if the customerID matches the one in the item's document
            if (item['customerid'] == customerID) {
              // Store the customerID for future use
              storedCustomerIDs[shopId] = customerID!;
              await prefs.setString(
                  'customerIDs', jsonEncode(storedCustomerIDs));
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
        automaticallyImplyLeading: false,
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
                const SizedBox(width: 15),
                ClipRRect(
                  child: Image.asset("asset/onshopnewcurvedlogo.png", width: 50),
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
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (query) {
                _searchShops(query);
              },
              decoration: InputDecoration(
                hintText: 'Search by name or city...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          _searchResults.isEmpty
              ? const Expanded(child: Center(child: Text('No results found')))
              : Expanded(
                  child:ListView.builder(
  itemCount: _searchResults.length,
  itemBuilder: (context, index) {
    final shop = _searchResults[index];
    final data = shop.data() as Map<String, dynamic>?;

    final name = data?['name'] ?? 'No name available';
    final city = data?['city'] ?? 'No city available';
    final description = data?['description'] ?? 'No description available';
    final phone = data?['mobile'] ?? 'No phone available';
    final whatsapp = data?['whatsapp'] ?? 'No WhatsApp available';
    final imageUrl = data?.containsKey('image_url') == true
        ? data!['image_url']
        : 'https://onshop.in/categories/unnamed.png'; // Placeholder image
    final associate = data?['associate'] ?? false;
    final approvetext = data?['approvetext'] ?? false;
    final shopcode = data?['shopcode'] ?? ''; // Get shopcode or default to empty string

    return GestureDetector(
      onTap: () {
        _checkCustomerID(data!);
      },
      child: Stack(
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: Colors.grey[400]!, // Border color
                width: 1.0, // Border width
              ),
            ),
            color: const Color.fromARGB(255, 255, 255, 255),
            elevation: 2,
            shadowColor: Colors.grey.withOpacity(0.8),
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.only(left: 14.0, right: 14, bottom: 14, top: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (imageUrl != null && imageUrl.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: imageUrl,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                Container(
                                  width: 80,
                                  height: 80,
                                  color: const Color.fromARGB(255, 235, 235, 235), // Placeholder background
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
                            errorWidget: (context, url, error) =>
                                Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.error, color: Colors.red),
                                ),
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
                            if (shopcode.isNotEmpty)
                              Text(
                                'Shop Code: $shopcode',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            Text(
                              name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (description.isNotEmpty)
                              Text(
                                description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12),
                              ),
                            if (phone.isNotEmpty)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Mobile: $phone',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          makeCall(phone);
                                        },
                                        child: Image.asset(
                                          "asset/phone-call.png",
                                          width: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      if (whatsapp.isNotEmpty)
                                        GestureDetector(
                                          onTap: () {
                                            openWhatsApp(whatsapp);
                                          },
                                          child: Image.asset(
                                            "asset/whatsapp2.png",
                                            width: 20,
                                          ),
                                        ),
                                      const SizedBox(width: 10),
                                      GestureDetector(
                                        onTap: () {
                                          if (data?['name'] != null &&
                                              data?['description'] != null &&
                                              data?['mobile'] != null) {
                                            // shareDetails(
                                            //     data!['name'],
                                            //     data['description'],
                                            //     data['mobile']);
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Unable to share. Missing item details.')),
                                            );
                                          }
                                        },
                                        child: Image.asset(
                                          "asset/share2.png",
                                          width: 20,
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (associate == true)
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
                  children: [
                    if (approvetext == true)
                      const Icon(Icons.check, color: Colors.white, size: 16),
                    if (approvetext == false)
                      Row(
                        children: [
                          const Icon(Icons.check, color: Colors.white, size: 16),
                          const Icon(Icons.check, color: Colors.white, size: 16),
                        ],
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  },
),
                ),
        ],
      ),
    );
  }
}