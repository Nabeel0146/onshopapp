import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shimmer/shimmer.dart';
import 'listing_page.dart';

class SubcategoryGridPage extends StatefulWidget {
  final String collectionName;

  SubcategoryGridPage({required this.collectionName});

  @override
  State<SubcategoryGridPage> createState() => _SubcategoryGridPageState();
}

class _SubcategoryGridPageState extends State<SubcategoryGridPage> {
  final ValueNotifier<int> currentIndex = ValueNotifier<int>(0);

  Future<List<Map<String, dynamic>>> _fetchSubcategories() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection(widget.collectionName)
          .get();
      return querySnapshot.docs
          .map((doc) => {
                'name': doc['name'],
                'icon': doc['icon'],
              })
          .toList();
    } catch (e) {
      print('Error fetching subcategories: $e');
      return [];
    }
  }

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
    List<Color> appBarGradientColors;
    String appBarIconAsset;

    if (widget.collectionName == 'workerscategories' ||
        widget.collectionName == 'taxicategories') {
      appBarGradientColors = [
        const Color.fromARGB(255, 41, 219, 255),
        Colors.white,
      ];
      appBarIconAsset = "asset/citydotcomlogonew copy.png";
    } else {
      appBarGradientColors = [
        const Color.fromARGB(255, 255, 185, 41),
        Colors.white,
      ];
      appBarIconAsset = "asset/onshopoldroundedlogo.png";
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
  backgroundColor: Colors.transparent,
  toolbarHeight: 70,
  elevation: 0,
  flexibleSpace: Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: appBarGradientColors,
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
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(appBarIconAsset, width: 50),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.collectionName == 'workerscategories' || widget.collectionName == 'taxicategories'
                      ? 'City dot com'
                      : 'On Shop',
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
      body: FutureBuilder<List<String>>(
        future: _fetchBannerImageUrls(),
        builder: (context, bannerSnapshot) {
          if (bannerSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final bannerUrls = bannerSnapshot.data ?? [];

          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: bannerUrls.isNotEmpty
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
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
                                        height: 340,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Shimmer.fromColors(
                                      baseColor: Colors.grey[300]!,
                                      highlightColor: Colors.grey[100]!,
                                      child: Container(
                                        height: 340,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8),
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
                                  children:
                                      List.generate(bannerUrls.length, (i) {
                                    return Container(
                                      width: 6,
                                      height: 6,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 3.0),
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
                const SizedBox(height: 1),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _fetchSubcategories(),
                  builder: (context, subcategorySnapshot) {
                    if (subcategorySnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (subcategorySnapshot.hasError) {
                      return Center(
                          child:
                              Text('Error: ${subcategorySnapshot.error}'));
                    } else if (!subcategorySnapshot.hasData ||
                        subcategorySnapshot.data!.isEmpty) {
                      return const Center(child: Text('No subcategories found.'));
                    }

                    final subcategories = subcategorySnapshot.data!;
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1,
                        ),
                        itemCount: subcategories.length,
                        itemBuilder: (context, index) {
                          final subcategory = subcategories[index];
                          return GestureDetector(
                            onTap: () {
                             Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ListingPage(
      subcategory: subcategory['name'],
      collectionName: widget.collectionName, // Pass the collection name
    ),
  ),
);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  width: .5,
                                  color: const Color.fromARGB(255, 217, 217, 217),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CachedNetworkImage(
                                    imageUrl: subcategory['icon'] ?? '',
                                    height: 40,
                                    width: 40,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        Shimmer.fromColors(
                                      baseColor: Colors.grey[300]!,
                                      highlightColor: Colors.grey[100]!,
                                      child: Container(
                                        height: 45,
                                        width: 45,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        const Icon(
                                      Icons.image_not_supported,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    height: 36,
                                    alignment: Alignment.center,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: AutoSizeText(
                                        subcategory['name'] ?? '',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 11,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        minFontSize: 8,
                                        stepGranularity: 1,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}