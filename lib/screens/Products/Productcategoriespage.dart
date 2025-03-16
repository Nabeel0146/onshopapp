import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:onshopapp/screens/Products/Productspage.dart'; // Ensure this import is correct

class ProductCategoriesPage extends StatelessWidget {
  Future<String?> _fetchBannerImageUrl() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('shoppagebanners').doc('banner').get();
      final imageUrl = querySnapshot.data()?['imageUrl'] as String?;
      print('Fetched banner image URL: $imageUrl'); // Debugging
      return imageUrl;
    } catch (e) {
      print('Error fetching banner image: $e');
      return null;
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
      body: FutureBuilder<String?>(
        future: _fetchBannerImageUrl(),
        builder: (context, bannerSnapshot) {
          if (bannerSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final bannerImageUrl = bannerSnapshot.data;

          return Column(
            children: [
              // Banner at the top
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  width: 500,
                  height: 150,
                  child: bannerImageUrl != null
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                            imageUrl: bannerImageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                      )
                      : Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('productcategories').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data == null) {
                      return const Center(child: Text("No categories available"));
                    }

                    final categories = snapshot.data!.docs;

                    return GridView.builder(
                      padding: const EdgeInsets.all(16.0),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                        childAspectRatio: 1.0, // Adjust this value to change the aspect ratio of the grid items
                      ),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index].data() as Map<String, dynamic>;
                        final imageUrl = category['image_url'] as String?;
                        final name = category['name'] as String?;

                        return GestureDetector(
                          onTap: () {
                            // Navigate to ProductsPage with the selected category name
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductsPage(category: name ?? 'Category'),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              color: const Color.fromARGB(255, 255, 247, 229),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                imageUrl != null && imageUrl.isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: imageUrl,
                                        width: 64,
                                        height: 64,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => Shimmer.fromColors(
                                          baseColor: Colors.grey[200]!,
                                          highlightColor: Colors.grey[100]!,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) => Shimmer.fromColors(
                                          baseColor: Colors.grey[200]!,
                                          highlightColor: Colors.grey[100]!,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                      )
                                    : const Icon(Icons.category, size: 64),
                                const SizedBox(height: 8.0),
                                Text(
                                  name ?? 'Category',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}