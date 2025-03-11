import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DiscountCardPage extends StatefulWidget {
  @override
  _DiscountCardPageState createState() => _DiscountCardPageState();
}

class _DiscountCardPageState extends State<DiscountCardPage> {
  bool _isLoaded = false;

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
              ],
            ),
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _getUserDataStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Column(
              children: [
                // Static rectangle shape with shimmer effect
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: double.infinity, // Full width
                    height: 240, // Adjust the height as needed
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                SizedBox(height: 16), // Space between the rectangle and the loading indicator
                Center(child: CircularProgressIndicator()), // Loading indicator
              ],
            );
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text("No user data available"));
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final name = userData['name'] as String?;
          final city = userData['city'] as String?;
          final mobile = userData['mobile'] as String?;
          final address = userData['address'] as String?;
          final cardno = userData['cardno'] as String?;
          final expirydate = userData['expirydate'] as String?;

          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('discountcard').doc('global').get(),
            builder: (context, imageSnapshot) {
              if (imageSnapshot.connectionState == ConnectionState.waiting) {
                // Show shimmer effect while fetching the image URL
                return Column(
                  children: [
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        width: double.infinity, // Full width
                        height: 200, // Adjust the height as needed
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                );
              }

              if (!imageSnapshot.hasData || imageSnapshot.data == null) {
                // Show a placeholder if no image URL is available
                return Column(
                  children: [
                    Container(
                      width: double.infinity, // Full width
                      height: 250, // Adjust the height as needed
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                );
              }

              final imageUrl = imageSnapshot.data!['image_url'] as String?;

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (cardno == null)
                        Container(
                          width: double.infinity, // Full width
                          height: 240, // Adjust the height as needed
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              "You don't have a discount card",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        )
                      else if (imageUrl != null)
                        CachedNetworkImage(
                          imageUrl: imageUrl,
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              width: double.infinity, // Full width
                              height: 240, // Adjust the height as needed
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: double.infinity, // Full width
                            height: 240, // Adjust the height as needed
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                "Failed to load image",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          imageBuilder: (context, imageProvider) => Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: double.infinity,
                                height: 240,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 160,
                                left: 60,
                                child: Text(
                                  '$cardno',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 130,
                                left: 70,
                                child: Text(
                                  '$name',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              if (expirydate != null)
                                Positioned(
                                  top: 190,
                                  left: 100,
                                  child: Text(
                                    'Expiry Date: $expirydate',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        )
                      else
                        Container(
                          width: double.infinity, // Full width
                          height: 240, // Adjust the height as needed
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              "Failed to load image",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      SizedBox(height: 16),
                      Text('City: $city', style: TextStyle(fontSize: 16)),
                      SizedBox(height: 8),
                      Text('Mobile: $mobile', style: TextStyle(fontSize: 16)),
                      SizedBox(height: 8),
                      Text('Address: $address', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Stream<DocumentSnapshot> _getUserDataStream() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      throw Exception('No user is currently logged in');
    }
    return FirebaseFirestore.instance.collection('users').doc(userId).snapshots();
  }
}