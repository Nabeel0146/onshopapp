import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onshopapp/screens/Products/Productspage.dart';
import 'package:onshopapp/screens/searchresults.dart';
import 'package:onshopapp/utils/appbar.dart';
import 'package:onshopapp/utils/sidebar.dart';
import 'package:onshopapp/widgets/widgets.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? bannerImageUrl;
  String? selectedCity;
  List<String> cities = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _showPopupAfterDelay(); // Trigger the popup
  }

  void _loadInitialData() {
    _fetchBannerImage();
    _fetchCities();
  }

  List<String> bannerImages = [];

Future<void> _fetchBannerImage() async {
  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('Homepage_banner')
        .doc('banner')
        .get();

    // Extract banners and filter out null or empty values
    setState(() {
      bannerImages = [
        snapshot.data()?['banner1'] as String?,
        snapshot.data()?['banner2'] as String?,
        snapshot.data()?['banner3'] as String?,
        snapshot.data()?['banner4'] as String?,
        snapshot.data()?['banner5'] as String?,
        snapshot.data()?['banner6'] as String?,
        snapshot.data()?['banner7'] as String?,
        snapshot.data()?['banner8'] as String?,
        snapshot.data()?['banner9'] as String?,
        snapshot.data()?['banner10'] as String?,
        snapshot.data()?['banner11'] as String?,
        snapshot.data()?['banner12'] as String?,
        snapshot.data()?['banner13'] as String?,
        snapshot.data()?['banner14'] as String?,
        snapshot.data()?['banner15'] as String?,
        snapshot.data()?['banner16'] as String?,
        snapshot.data()?['banner17'] as String?,
        snapshot.data()?['banner18'] as String?,
        snapshot.data()?['banner19'] as String?,
        snapshot.data()?['banner20'] as String?,
        snapshot.data()?['banner21'] as String?,
        snapshot.data()?['banner22'] as String?,
        snapshot.data()?['banner23'] as String?,
        snapshot.data()?['banner24'] as String?,
        snapshot.data()?['banner25'] as String?,
        snapshot.data()?['banner26'] as String?,
        snapshot.data()?['banner27'] as String?,
        snapshot.data()?['banner28'] as String?,
        snapshot.data()?['banner29'] as String?,
        snapshot.data()?['banner30'] as String?,
      ].where((url) => url != null && url.isNotEmpty).cast<String>().toList();
    });
  } catch (error) {
    print("Error fetching banner: $error");
  }
}
Widget buildBanner(List<String> bannerImages) {
  if (bannerImages.isNotEmpty) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 190,
        viewportFraction: 1,
        enableInfiniteScroll: true,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 3),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        enlargeCenterPage: true,
      ),
      items: bannerImages.map((imageUrl) {
        return Builder(
          builder: (BuildContext context) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(0),
              child: Image.network(
                imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            );
          },
        );
      }).toList(),
    );
  } else {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[300],
      ),
      child: const Center(
        child: Text(
          'Loading banners...',
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}

  Future<void> _fetchCities() async {
    try {
      final cityDocs = await FirebaseFirestore.instance.collection('cities').get();
      final cityNames = cityDocs.docs.map((doc) => doc['name'] as String).toList();

      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      final userCity = userSnapshot.data()?['city'] as String?;

      setState(() {
        cities = cityNames;
        selectedCity = cityNames.contains(userCity) ? userCity : cityNames.firstOrNull;
      });
    } catch (error) {
      print("Error fetching cities: $error");
    }
  }

  void _navigateToSearchResults() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SearchResultsPage()),
    );
  }

  void _showPopupAfterDelay() async {
  await Future.delayed(const Duration(seconds: 5));

  try {
    final popupDoc = await FirebaseFirestore.instance
        .collection('Popup')
        .doc('welcomePopup')
        .get();

    final popupData = popupDoc.data();
    final imageUrl = popupData?['imageUrl'] as String?;
    final isActive = popupData?['isActive'] as bool? ?? false;

    if (isActive && imageUrl != null && imageUrl.isNotEmpty) {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return AlertDialog(
              contentPadding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: CachedNetworkImage(
                      imageUrl : imageUrl,
                      width: 400,
                      height: 500,
                      fit: BoxFit.cover,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          },
        );
      }
    }
  } catch (error) {
    print("Error fetching popup data: $error");
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        cities: cities,
        selectedCity: selectedCity,
        onCityChanged: (city) {
          setState(() {
            selectedCity = city;
          });
        },
      ),
      endDrawer: Sidebar(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchButton(),
          const SizedBox(height: 10),
          _buildProductCategories(), // New section for scrollable rectangles
            const SizedBox(height: 26),
            buildBanner(bannerImages),
            const SizedBox(height: 26),

            _buildCategoryTiles(),
            const SizedBox(height: 16),
            _buildOtherCategories(),
            const SizedBox(height: 10,),
            _buildAdsSection()
          ],
        ),
      ),
    );
  }

 Widget _buildAdsSection() {
  return FutureBuilder<DocumentSnapshot>(
    future: FirebaseFirestore.instance.collection('homepageads').doc('ads').get(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      if (!snapshot.hasData || snapshot.data == null || snapshot.data!.data() == null) {
        return const Center(child: Text("No ads available"));
      }

      // Extract ads and filter out null/empty values
      Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
      List<String> adImages = [
        data['ad1'] as String?,
        data['ad2'] as String?,
        data['ad3'] as String?,
        data['ad4'] as String?,
        data['ad5'] as String?,
        data['ad6'] as String?,
        data['ad7'] as String?,
        data['ad8'] as String?,
        data['ad9'] as String?,
        data['ad10'] as String?,
      ].where((url) => url != null && url.isNotEmpty).cast<String>().toList();

      if (adImages.isEmpty) {
        return const Center(child: Text("No ads available"));
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Sponsored Ads",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            CarouselSlider.builder(
              itemCount: adImages.length,
              options: CarouselOptions(

                height: 400, // Square size
                viewportFraction: 1, // Adjusts width for square images
                enableInfiniteScroll: true,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 3),
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                enlargeCenterPage: true,
              ),
              itemBuilder: (context, index, realIndex) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    adImages[index],
                    height: 400,
                    width: 400,
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
            SizedBox(height: 10,)
          ],
        ),
      );
    },
  );
}
Widget _buildProductCategories() {
  return FutureBuilder<QuerySnapshot>(
    future: FirebaseFirestore.instance.collection('productcategories').get(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const SizedBox(
          height: 75,
          child: Center(child: CircularProgressIndicator()),
        );
      }

      if (!snapshot.hasData || snapshot.data == null) {
        return const SizedBox(
          height: 75,
          child: Center(child: Text("No categories available")),
        );
      }

      final categories = snapshot.data!.docs;

      return SizedBox(
        height: 75,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index].data() as Map<String, dynamic>;
            final imageUrl = category['image_url'] as String?;
            final name = category['name'] as String?;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductsPage(category: name ?? 'Category'),
                    ),
                  );
                },
                child: Container(
                  width: 62,
                  height: 65,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 255, 240, 201),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      imageUrl != null && imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              width: 42,
                              height: 42,
                              fit: BoxFit.cover,
                            )
                          : const Icon(Icons.category, size: 32),
                      const SizedBox(height: 4),
                      Text(
                        name ?? 'Category',
                        style: const TextStyle(fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    },
  );
}

  Widget _buildSearchButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: ElevatedButton(
        onPressed: _navigateToSearchResults,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          elevation: 0,
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Icon(Icons.search, color: Colors.grey),
            ),
            const SizedBox(width: 10),
            Text(
              'Search for shops or city...',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

Widget _buildCategoryTiles() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 15),
    child: SizedBox(
      height: 90,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          buildLargeCategoryTile(
            context,
            'Shops',
            'Find Product Stores',
            'asset/shopicon.png',
            Colors.red,
            'shopcategories',
          ),
          buildLargeCategoryTile(
            context,
            'Services',
            'Find Service Stores',
            'asset/serviceicon.png',
            Colors.red,
            'servicecategories',
          ),
        ],
      ),
    ),
  );
}
  Widget _buildOtherCategories() {
    return Container(
      color: Colors.grey[200],
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Other Categories",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              children: [
                buildSmallCategoryTile(
                  context,
                  'Workers',
                  'asset/labour-day.png',
                  'workerscategories',
                ),
                buildSmallCategoryTile(
                  context,
                  'Taxis',
                  'asset/taxi.png',
                  'taxicategories',
                ),
                buildSmallCategoryTile(
                  context,
                  'Hospitals',
                  'asset/medicine.png',
                  'hospitalcategories',
                ),
                buildSmallCategoryTile(
                  context,
                  'Jobs',
                  'asset/suitcase.png',
                  '',
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}