import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onshopapp/screens/Products/shopedit.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ShopProfilePage extends StatelessWidget {
  final Map<String, dynamic> shopData;

  const ShopProfilePage({required this.shopData, Key? key}) : super(key: key);

  void makeCall(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (!await launchUrl(uri)) {
        print('Could not launch $uri');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  void openWhatsAppChat(String whatsappNumber) async {
    final whatsappUrl = 'https://wa.me/$whatsappNumber';
    try {
      if (!await launchUrl(Uri.parse(whatsappUrl))) {
        print('Could not launch $whatsappUrl');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  void shareDetails(
      String title, String description, String phoneNumber) async {
    final footer =
        '\n\nShared from Onshop App\n\nDownload Onshop App now\nGoogle Playstore: https://play.google.com/store/apps/details?id=com.onshopin.onshopapp&pcampaignid=web_share \nApp Store: https://apps.apple.com/in/app/on-shop/id6740747263 ';
    final shareContent = '''
  $title

  $description

  Contact: $phoneNumber
  $footer
  ''';

    try {
      await Share.share(shareContent,
          subject: 'Check out this item on Onshop!');
      print('Sharing successful');
    } catch (e) {
      print('Error while sharing: $e');
    }
  }

  void openMapLink(BuildContext context, String mapLink) async {
    if (mapLink.isNotEmpty) {
      try {
        if (!await launchUrl(Uri.parse(mapLink))) {
          print('Could not launch $mapLink');
        }
      } catch (e) {
        print('Error occurred: $e');
      }
    } else {
      // Show SnackBar if no map link is available
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No map link available'),
          duration: Duration(seconds: 2), // Duration for the SnackBar
        ),
      );
    }
  }

  Future<String> getUserAddress() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return 'No address provided';
      }

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        return 'No address provided';
      }

      return userDoc.data()?['address'] ?? 'No address provided';
    } catch (e) {
      print('Error fetching user address: $e');
      return 'No address provided';
    }
  }

  Future<void> openWhatsAppWithDetails(
      String whatsappNumber, String name, int price, int discountedprice, String description) async {
    final userAddress = await getUserAddress();

    String productDetails = """
    Name: $name
    Price: ₹$price
    Discounted Price: ₹$discountedprice
    Description: $description
    Address: $userAddress
    """;

    final whatsappUrl = 'https://wa.me/$whatsappNumber?text=${Uri.encodeComponent(productDetails)}';
    if (!await launchUrl(Uri.parse(whatsappUrl))) {
      print('Could not launch $whatsappUrl');
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    // Fetch the shopid from the shopData and print it
    final String shopId = shopData['shopid'] ?? '';
    print('Shop ID: $shopId'); // Debugging: Print the shop ID

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Transparent to allow gradient
        toolbarHeight: 70,
        elevation: 0, // Remove shadow if not needed
        flexibleSpace: Column(
          children: [
            Expanded(
              child: Container(
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
                        child: Image.asset("asset/onshopnewcurvedlogo.png",
                            width: 50),
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
            Container(
              height: 4,
              color: const Color.fromARGB(255, 164, 164, 164),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Full-screen shop image
            CachedNetworkImage(
              imageUrl: shopData['image_url'] ?? '',
              width: double.infinity,
              height: 300, // Image height same as screen width
              fit: BoxFit.cover,
              placeholder: (context, url) =>
                  const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) =>
                  const Icon(Icons.error, color: Colors.red),
            ),

            // Content with Overlapping Effect
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12, blurRadius: 8, spreadRadius: 2)
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Shop Name
                  Text(
                    shopData['name'] ?? 'No Name',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  // Shop Description
                  Text(
                    shopData['description'] ?? 'No Description',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildButton(
                        imagePath: "asset/phone-call.png",
                        text: 'Call',
                        color: Colors.blue,
                        onPressed: () {
                          makeCall(shopData['phone'] ??
                              ''); // Replace with the actual phone number
                        },
                      ),
                      _buildButton(
                        imagePath: "asset/whatsapp2.png",
                        text: 'Chat',
                        color: Colors.green,
                        onPressed: () {
                          openWhatsAppChat(shopData['whatsapp'] ??
                              ''); // Replace with the actual WhatsApp number
                        },
                      ),
                      _buildButton(
                        imagePath: "asset/share2.png",
                        text: 'Share',
                        color: Colors.amber,
                        onPressed: () {
                          shareDetails(
                            shopData['name'] ??
                                'No Name', // Replace with actual title
                            shopData['description'] ??
                                'No Description', // Replace with actual description
                            shopData['phone'] ??
                                '', // Replace with actual phone number
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),

                  // Get Direction Button
                  Container(
                    width: double.infinity,
                    child: _buildButton(
                      imagePath: "asset/google-maps2.png",
                      text: 'Get Direction',
                      color: Colors.black,
                      backgroundColor: Colors.white,
                      borderColor: Colors.black,
                      onPressed: () {
                        openMapLink(context, shopData['maplink'] ?? ''); // Replace with the actual map link
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Products Section
                  Center(
                    child: const Text(
                      'Products',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const Divider(
                    thickness: .5,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),

                  // Fetch and display products from Firestore
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('products')
                        .where('shopid', isEqualTo: shopId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                            child: Text('No products available'));
                      }

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // Keeps 2 items per row
                          crossAxisSpacing: 12, // Increases horizontal spacing
                          mainAxisSpacing: 12, // Increases vertical spacing
                          childAspectRatio:
                              0.50, // Decrease this value to make items taller
                        ),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final product = snapshot.data!.docs[index].data()
                              as Map<String, dynamic>;
                          return _buildProductCard(
                            product['name'] ?? 'No Name',
                            product['price'] ?? 0,
                            product['discountedprice'] ?? 0,
                            product['image_url'] ??
                                'https://via.placeholder.com/150',
                            shopData['whatsapp'] ?? '',
                            product['description'] ??
                                'No Description', // Pass the description field
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showShopIdDialog(context, shopId);
        },
        tooltip: 'Edit Shop',
        child: const Icon(Icons.edit),
      ),
    );
  }

  void _showShopIdDialog(BuildContext context, String shopId) {
    final TextEditingController _shopIdController = TextEditingController();

    showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Column(
            children: [
              const Text('Enter Shop ID'),
              SizedBox(
                height: 20,
              )
            ],
          ),
          content: TextField(
            autofocus: true,
            controller: _shopIdController,
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
          ),
          actions: <Widget>[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ElevatedButton(
                onPressed: () {
                  final enteredShopId = _shopIdController.text;
                  if (enteredShopId == shopId) {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ShopEditPage(
                          shopId: shopData[
                              'shopid'], // Make sure shopid exists in shopData
                          shopData: shopData,
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Incorrect Shop ID')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber, // Green background
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Rounded corners
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
  }

  Widget _buildButton({
    required String imagePath,
    required String text,
    required Color color,
    VoidCallback? onPressed,
    Color backgroundColor = Colors.transparent,
    Color borderColor = Colors.black,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, right: 2),
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 28),
          backgroundColor: backgroundColor,
          side: BorderSide(color: borderColor, width: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              imagePath,
              width: 24,
              height: 24,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(String name, int price, int discountedprice,
      String imageUrl, String whatsappNumber, String description) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey, // Border color
          width: 0.5, // Border width
        ),
        borderRadius: BorderRadius.circular(8), // Rounded corners
      ),
      child: Card(
        elevation: 0, // Flat look
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Rounded corners
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image
            if (imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AspectRatio(
                  aspectRatio: 4 / 4,
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => const Icon(
                      Icons.image_not_supported,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
                ),
              )
            else
              AspectRatio(
                aspectRatio: 3 / 3,
                child: Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported,
                      size: 40, color: Colors.grey),
                ),
              ),
            const SizedBox(height: 8),

            // Product Name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                name,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 2),

            // Product Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                description,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 2),

            // Product Price
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                '₹$price',
                style: const TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(height: 2),

            // Discounted Price
            if (discountedprice > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  'MRP ₹$discountedprice',
                  style: const TextStyle(
                      fontSize: 14, decoration: TextDecoration.lineThrough),
                ),
              ),
            const SizedBox(height: 4),

            // Order Now Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: ElevatedButton(
                onPressed: () {
                  openWhatsAppWithDetails(
                    whatsappNumber,
                    name,
                    price,
                    discountedprice,
                    description,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Order Now",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}