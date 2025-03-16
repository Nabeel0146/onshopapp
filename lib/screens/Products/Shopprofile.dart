import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onshopapp/screens/Products/shopedit.dart';
import 'package:url_launcher/url_launcher.dart';

class ShopProfilePage extends StatelessWidget {
  final Map<String, dynamic> shopData;

  const ShopProfilePage({required this.shopData, Key? key}) : super(key: key);

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
              height: 350, // Image height same as screen width
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
                        icon: Icons.phone,
                        text: 'Call',
                        color: Colors.blue,
                        onPressed: () {},
                      ),
                      _buildButton(
                        icon: Icons.chat,
                        text: 'Chat',
                        color: Colors.green,
                        onPressed: () {},
                      ),
                      _buildButton(
                        icon: Icons.share,
                        text: 'Share',
                        color: Colors.amber,
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),

                  // Get Direction Button
                  Container(
                    width: double.infinity,
                    child: _buildButton(
                      icon: Icons.map_outlined,
                      text: 'Get Direction',
                      color: Colors.black,
                      backgroundColor: Colors.white,
                      borderColor: Colors.black,
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Products Section
                  const Text(
                    'Products',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                              0.57, // Decrease this value to make items taller
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

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter Shop ID'),
          content: TextField(
            controller: _shopIdController,
            decoration: const InputDecoration(hintText: 'Shop ID'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
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
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildButton({
    required IconData icon,
    required String text,
    required Color color,
    VoidCallback? onPressed,
    Color backgroundColor = Colors.transparent,
    Color borderColor = Colors.black,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: color, size: 18),
      label: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.w500),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 32),
        backgroundColor: backgroundColor,
        side: BorderSide(color: borderColor, width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

 Widget _buildProductCard(String name, int price, int discountedprice, String imageUrl, String whatsappNumber) {
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
                child: const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
              ),
            ),
          const SizedBox(height: 8),

          // Product Name
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                style: const TextStyle(fontSize: 14, decoration: TextDecoration.lineThrough),
              ),
            ),
          const SizedBox(height: 4),

          // Order Now Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: ElevatedButton(
              onPressed: () {
                String productDetails = "Name: $name\nPrice: ₹$price\nDiscounted Price: ₹$discountedprice";
                String whatsappUrl = "https://wa.me/$whatsappNumber?text=${Uri.encodeComponent(productDetails)}";
                launchUrl(Uri.parse(whatsappUrl));
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
