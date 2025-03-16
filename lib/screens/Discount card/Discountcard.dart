import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class DiscountCardPage extends StatefulWidget {
  const DiscountCardPage({super.key});

  @override
  State<DiscountCardPage> createState() => _DiscountCardPageState();
}

class _DiscountCardPageState extends State<DiscountCardPage> with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  TextEditingController _nameController = TextEditingController();
  TextEditingController _cityController = TextEditingController();
  TextEditingController _mobileController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _cardnoController = TextEditingController();
  TextEditingController _expirydateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800), // Duration of the spin animation
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(_flipController);
  }

  @override
  void dispose() {
    _flipController.dispose();
    _nameController.dispose();
    _cityController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
    _cardnoController.dispose();
    _expirydateController.dispose();
    super.dispose();
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
      body: Container(
        padding: EdgeInsets.only(top: 100),
        child: StreamBuilder<DocumentSnapshot>(
          stream: _getUserDataStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildShimmerEffect();
            }
        
            if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text("No user data available"));
            }
        
            final userData = snapshot.data!.data() as Map<String, dynamic>;
            final name = userData['name'] as String?;
            final city = userData['city'] as String?;
            final mobile = userData['mobile'] as String?;
            final address = userData['address'] as String?;
            final cardno = userData['cardno'] as String?;
            final expirydate = userData['expirydate'] as String?;
        
            _nameController.text = name ?? '';
            _cityController.text = city ?? '';
            _mobileController.text = mobile ?? '';
            _addressController.text = address ?? '';
            _cardnoController.text = cardno ?? '';
            _expirydateController.text = expirydate ?? '';
        
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('discountcard').doc('global').get(),
              builder: (context, imageSnapshot) {
                if (imageSnapshot.connectionState == ConnectionState.waiting) {
                  return _buildShimmerEffect();
                }
        
                final imageUrl = imageSnapshot.data?['image_url'] as String?;
        
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (cardno == null)
                        _buildEmptyCard("You don't have a discount card")
                      else if (imageUrl != null)
                        AnimatedBuilder(
                          animation: _flipAnimation,
                          builder: (context, child) {
                            return Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()
                                ..setEntry(3, 2, 0.001)
                                ..rotateY(_flipAnimation.value * 2 * 3.141592653589793),
                              child: CachedNetworkImage(
                                imageUrl: imageUrl,
                                placeholder: (context, url) {
                                  _flipController.forward(); // Start the spin animation
                                  return _buildShimmerEffect();
                                },
                                errorWidget: (context, url, error) => _buildEmptyCard("Failed to load image"),
                                imageBuilder: (context, imageProvider) {
                                  _flipController.stop(); // Stop the spin animation
                                  return Container(
                                    width: double.infinity,
                                    height: 240,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Positioned(
                                          top: 130,
                                          left: 70,
                                          child: Text(
                                            '$name',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 160,
                                          left: 60,
                                          child: Text(
                                            '$cardno',
                                            style: const TextStyle(
                                              fontSize: 26,
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
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      const SizedBox(height: 16),
                      Text('City: $city', style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('Mobile: $mobile', style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('Delivery Address: $address', style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          _showEditDialog(context, userData);
                        },
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: Colors.black, size: 15,),
                            SizedBox(width: 6,),
                            const Text('Edit Details',style: TextStyle(color: Colors.black),),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: double.infinity,
        height: 240,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildEmptyCard(String message) {
    return Container(
      width: double.infinity,
      height: 240,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Stream<DocumentSnapshot> _getUserDataStream() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    return FirebaseFirestore.instance.collection('users').doc(userId).snapshots();
  }

  void _showEditDialog(BuildContext context, Map<String, dynamic> userData) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Details'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: _mobileController,
                  decoration: const InputDecoration(labelText: 'Mobile'),
                ),
                TextField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                ),
                
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final userId = FirebaseAuth.instance.currentUser?.uid;
                if (userId != null) {
                  await FirebaseFirestore.instance.collection('users').doc(userId).update({
                    'name': _nameController.text,
                    
                    'mobile': _mobileController.text,
                    'address': _addressController.text,
                    
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}