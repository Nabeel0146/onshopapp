import 'package:auto_size_text/auto_size_text.dart';
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
import 'package:shimmer/shimmer.dart';

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
              borderRadius: BorderRadius.circular(0), // No rounded corners for banners
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                width: double.infinity,
                fit: BoxFit.fitWidth, // Ensure the image fits the width without being cut off
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  } else {
    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3, // Number of shimmer placeholders to show
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: MediaQuery.of(context).size.width, // Full width of the screen
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

  Future<void> _fetchCities() async {
    try {
      final cityDocs =
          await FirebaseFirestore.instance.collection('cities').get();
      final cityNames =
          cityDocs.docs.map((doc) => doc['name'] as String).toList();

      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      final userCity = userSnapshot.data()?['city'] as String?;

      setState(() {
        cities = cityNames;
        selectedCity =
            cityNames.contains(userCity) ? userCity : cityNames.firstOrNull;
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
            const SizedBox(height: 10),
            _buildAdsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildAdsSection() {
    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance.collection('homepageads').doc('ads').get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData ||
            snapshot.data == null ||
            snapshot.data!.data() == null) {
          return const Center(child: Text("No ads available"));
        }

        // Extract ads and filter out null/empty values
        Map<String, dynamic> data =
            snapshot.data!.data() as Map<String, dynamic>;
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
                  height:
                      380, // Adjusted height to match the previous reference
                  viewportFraction: 1, // Adjusts width for square images
                  enableInfiniteScroll: true,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 3),
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  enlargeCenterPage: true,
                ),
                itemBuilder: (context, index, realIndex) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                    child: CachedNetworkImage(
                      imageUrl: adImages[index],
                      fit: BoxFit
                          .contain, // Ensure the image fits within the container without being cut off
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
                  );
                },
              ),
              SizedBox(
                height: 10,
              )
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
        return SizedBox(
          height: 75,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5, // Number of placeholders to show
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 62,
                    height: 65,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              );
            },
          ),
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
        height: 75, // Fixed height for the scrollable section
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
                      builder: (context) =>
                          ProductsPage(category: name ?? 'Category'),
                    ),
                  );
                },
                child: Container(
                  width: 62,
                  height: 65,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 255, 246, 224),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      imageUrl != null && imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Container(
                                  width: 42,
                                  height: 42,
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
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            )
                          : const Icon(Icons.category, size: 32),
                      const SizedBox(height: 3),
                     AutoSizeText(
  name ?? 'Category',
  style: const TextStyle(fontSize: 11),
  textAlign: TextAlign.center,
  maxLines: 2,
  overflow: TextOverflow.ellipsis,
  minFontSize: 8, // Minimum font size if the text needs to be resized
  stepGranularity: 1, // Step size for font size reduction
)
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
