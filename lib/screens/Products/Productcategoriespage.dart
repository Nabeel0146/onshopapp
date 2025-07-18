import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:onshopapp/screens/Products/Productspage.dart';

class ProductCategoriesPage extends StatefulWidget {
  @override
  State<ProductCategoriesPage> createState() => _ProductCategoriesPageState();
}

class _ProductCategoriesPageState extends State<ProductCategoriesPage> {
  final ValueNotifier<int> currentIndex = ValueNotifier<int>(0);

  Future<List<String>> _fetchBannerImageUrls() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('shoppagebanners')
          .doc('banner')
          .get();
      final data = querySnapshot.data();
      List<String> bannerUrls = [];
      for (int i = 1; i <= 30; i++) {
        final key = 'ad$i';
        if (data != null && data.containsKey(key) && data[key] is String) {
          bannerUrls.add(data[key] as String);
        }
      }
      print('Fetched banner image URLs: $bannerUrls');
      return bannerUrls;
    } catch (e) {
      print('Error fetching banner images: $e');
      return [];
    }
  }

  @override
  void dispose() {
    currentIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        toolbarHeight: 70,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 255, 185, 41),
                Colors.white,
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
                  child: Image.asset("asset/onshopoldroundedlogo.png", width: 50),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
      body: SingleChildScrollView(
        child: FutureBuilder<List<String>>(
          future: _fetchBannerImageUrls(),
          builder: (context, bannerSnapshot) {
            if (bannerSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final bannerUrls = bannerSnapshot.data ?? [];

            return Column(
              children: [
                // Carousel with dot indicators
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16, top: 16),
                  child: bannerUrls.isNotEmpty
                      ? Column(
                          children: [
                            CarouselSlider(
                              items: bannerUrls.map((url) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: CachedNetworkImage(
                                    imageUrl: url,
                                    fit: BoxFit.contain,
                                    placeholder: (context, url) =>
                                        Shimmer.fromColors(
                                      baseColor: Colors.grey[300]!,
                                      highlightColor: Colors.grey[100]!,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Shimmer.fromColors(
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
                                );
                              }).toList(),
                              options: CarouselOptions(
                                height: 340,
                                enlargeCenterPage: true,
                                autoPlay: true,
                                aspectRatio: 16 / 9,
                                autoPlayCurve: Curves.fastOutSlowIn,
                                enableInfiniteScroll: true,
                                autoPlayAnimationDuration:
                                    const Duration(milliseconds: 800),
                                viewportFraction: 1,
                                onPageChanged: (index, reason) {
                                  currentIndex.value = index;
                                },
                              ),
                            ),
                            const SizedBox(height: 10),
                            ValueListenableBuilder<int>(
                              valueListenable: currentIndex,
                              builder: (context, index, _) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(bannerUrls.length, (i) {
                                    return Container(
                                      width: 6,
                                      height: 6,
                                      margin: const EdgeInsets.symmetric(horizontal: 3.0),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: index == i
                                            ? Colors.black
                                            : Colors.grey[400],
                                      ),
                                    );
                                  }),
                                );
                              },
                            ),
                          ],
                        )
                      : Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            height: 340,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                ),

                const SizedBox(height: 16),

                // Grid of product categories
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('productcategories')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data == null) {
                      return const Center(child: Text("No categories available"));
                    }

                    final categories = snapshot.data!.docs;

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16.0),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index].data() as Map<String, dynamic>;
                        final imageUrl = category['image_url'] as String?;
                        final name = category['name'] as String?;

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductsPage(
                                  category: name ?? 'Category',
                                ),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                imageUrl != null && imageUrl.isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: imageUrl,
                                        width: 84,
                                        height: 90,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            Shimmer.fromColors(
                                          baseColor: Colors.grey[200]!,
                                          highlightColor: Colors.grey[100]!,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Shimmer.fromColors(
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
                                // Optional: Add category name here
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}