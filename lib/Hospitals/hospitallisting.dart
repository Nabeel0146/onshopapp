import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:onshopapp/Hospitals/hospitalprofile.dart';

import 'package:onshopapp/widgets/hospitalfloatingbutton.dart';
import 'package:onshopapp/widgets/listingwidgets.dart';


class hosListingPage extends StatefulWidget {
  final String subcategory;

  const hosListingPage({required this.subcategory, Key? key}) : super(key: key);

  @override
  State<hosListingPage> createState() => _ListingPageState();
}

class _ListingPageState extends State<hosListingPage> {
  List<String> cities = [];
  late Future<void> _initializationFuture;

  @override
  void initState() {
    super.initState();
    _initializationFuture = _initializeData();
  }

  Future<void> _initializeData() async {
    await _fetchCities();
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

  Future<List<Map<String, dynamic>>> _fetchFilteredItems(String subcategory) async {
    try {
      Query<Map<String, dynamic>> query = FirebaseFirestore.instance
          .collection('hospitallisting')
          .where('subcategory', isEqualTo: subcategory)
          .where('display', isEqualTo: true);

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
              borderRadius:
                  BorderRadius.circular(16), // Curved corners for the dialog
            ),
            backgroundColor: Colors.white, // White background for the dialog
          );
        },
      );

      if (customerID != null) {
        // Check if the customerID matches the one in the item's document
        if (item['customerid'] == customerID) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HospitalProfilePage(
                hospitalData: item,
                shopData: {}, // Pass an empty map for shopData
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid Customer ID')),
          );
        }
      }
    } else {
      // Directly navigate to HospitalProfilePage if 'lock' is false
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HospitalProfilePage(
            hospitalData: item,
            shopData: {}, // Pass an empty map for shopData
          ),
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
                  child:
                      Image.asset("asset/onshopnewcurvedlogo.png", width: 50),
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
            future: _fetchFilteredItems(widget.subcategory),
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
                          margin: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 14.0, right: 14, bottom: 14, top: 22),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    if (item['image_url'] != null &&
                                        item['image_url'].toString().isNotEmpty)
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
                                              placeholder: (context, url) =>
                                                  Container(
                                                width: 80,
                                                height: 80,
                                                color: const Color.fromARGB(
                                                    255,
                                                    235,
                                                    235,
                                                    235), // Placeholder background
                                                child: const Center(
                                                  child: SizedBox(
                                                    width: 16, // Smaller size
                                                    height: 16, // Smaller size
                                                    child:
                                                        CircularProgressIndicator(
                                                      strokeWidth:
                                                          2, // Thinner stroke
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                                  Color>(
                                                              Colors
                                                                  .black), // Black color
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Container(
                                                width: 80,
                                                height: 80,
                                                color: Colors.grey[300],
                                                child: const Icon(Icons.error,
                                                    color: Colors.red),
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
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                            Icons.image_not_supported,
                                            size: 30),
                                      ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(item['name'] ?? 'No Name',
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold)),
                                          if (item['description'] != null)
                                            Text(item['description'],
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    fontSize: 12)),
                                          Text('City: ${item['city'] ?? 'No City'}',
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black)),
                                          if (item['mobile'] != null)
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                    'Mobile: ${item['mobile']}',
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 12)),
                                                Row(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        if (item['mobile'] !=
                                                            null)
                                                          GestureDetector(
                                                              onTap: () {
                                                                makeCall(item[
                                                                    'mobile']);
                                                              },
                                                              child:
                                                                  Image.asset(
                                                                "asset/phone-call.png",
                                                                width: 20,
                                                              )),
                                                        const SizedBox(
                                                            width: 10),
                                                        if (item['whatsapp'] !=
                                                                null &&
                                                            item['whatsapp']
                                                                .isNotEmpty)
                                                          GestureDetector(
                                                            onTap: () {
                                                              openWhatsApp(
                                                                  context,
                                                                  item[
                                                                      'whatsapp']);
                                                            },
                                                            child: Image.asset(
                                                                "asset/whatsapp2.png",
                                                                width: 20),
                                                          ),
                                                        const SizedBox(
                                                            width: 10),
                                                        GestureDetector(
                                                            onTap: () {
                                                              if (item['name'] != null &&
                                                                  item['description'] !=
                                                                      null &&
                                                                  item['mobile'] !=
                                                                      null) {
                                                                shareDetails(
                                                                    item[
                                                                        'name'],
                                                                    item[
                                                                        'description'],
                                                                    item[
                                                                        'mobile']);
                                                              } else {
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(
                                                                  const SnackBar(
                                                                      content: Text(
                                                                          'Unable to share. Missing item details.')),
                                                                );
                                                              }
                                                            },
                                                            child: Image.asset(
                                                              "asset/share2.png",
                                                              width: 20,
                                                            )),
                                                      ],
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
                        if (item['associate'] == true)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 1),
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(5)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.check,
                                      color: Colors.white, size: 16),
                                  SizedBox(width: 4),
                                  Text(
                                    'Verified',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddNewHospitalPage(
                cities: cities,
                subcategory: widget.subcategory,
              ),
            ),
          );
        },
        tooltip: 'Add New Hospital',
        child: const Icon(Icons.add),
      ),
    );
  }
}