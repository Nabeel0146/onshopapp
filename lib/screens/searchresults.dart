import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SearchResultsPage extends StatefulWidget {
  @override
  _SearchResultsPageState createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  List<DocumentSnapshot> _searchResults = [];
  TextEditingController _searchController = TextEditingController();
  String? selectedCity;
  List<String> cities = [];

  @override
  void initState() {
    super.initState();
    _fetchCities();
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

  Future<void> _searchShops(String query) async {
  if (query.isEmpty) {
    setState(() {
      _searchResults = [];
    });
    return;
  }

  try {
    final shopSnapshot = await FirebaseFirestore.instance
        .collection('shops')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: query + '\uf8ff')
        .get();

    final citySnapshot = await FirebaseFirestore.instance
        .collection('shops')
        .where('city', isGreaterThanOrEqualTo: query)
        .where('city', isLessThanOrEqualTo: query + '\uf8ff')
        .get();

    // Combine results and use a Set to remove duplicates based on 'name' and 'city'
    final uniqueResults = <String, DocumentSnapshot>{};

    for (var doc in shopSnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['display'] == true) { // Filter by `display` field
        final key = '${data['name']}-${data['city']}';
        uniqueResults[key] = doc;
      }
    }

    for (var doc in citySnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['display'] == true) { // Filter by `display` field
        final key = '${data['name']}-${data['city']}';
        uniqueResults[key] = doc;
      }
    }

    setState(() {
      _searchResults = uniqueResults.values.toList();
    });
  } catch (error) {
    print("Error searching for shops: $error");
  }
}

  void _makeCall(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (!await launchUrl(uri)) {
        print('Could not launch $uri');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  void _openWhatsApp(String? phoneNumber) {
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      final formattedPhoneNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
      final uri = 'https://wa.me/$formattedPhoneNumber';
      launch(uri).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Could not open WhatsApp for $formattedPhoneNumber')),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('WhatsApp is not available for this number')),
      );
    }
  }

  void _shareDetails(
      String title, String description, String phoneNumber) async {
    final footer =
        '\n\nShared from Onshop App. Download Onshop App now from Google Playstore / App Store';
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

  Widget _buildActionButton(
      String label, Color color, String iconPath, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(iconPath, width: 24, height: 24),
              const SizedBox(width: 1),
              Text(label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 185, 41),
        toolbarHeight: 70,
        flexibleSpace: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Row(
            children: [
              const SizedBox(width: 45),
              ClipRRect(child: Image.asset('asset/appbarlogo.png',width: 50,)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('On Shop',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (query) {
                _searchShops(query);
              },
              decoration: InputDecoration(
                hintText: 'Search by name or city...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          _searchResults.isEmpty
              ? const Expanded(child: Center(child: Text('No results found')))
              : Expanded(
                  child: ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final shop = _searchResults[index];
                      final data = shop.data() as Map<String, dynamic>?;

                      final name = data?['name'] ?? 'No name available';
                      final city = data?['city'] ?? 'No city available';
                      final description =
                          data?['description'] ?? 'No description available';
                      final phone = data?['mobile'] ?? 'No phone available';
                      final whatsapp =
                          data?['whatsapp'] ?? 'No WhatsApp available';
                      final imageUrl = data?.containsKey('image_url') == true
                          ? data!['image_url']
                          : 'https://onshop.in/categories/unnamed.png'; // Placeholder image

                      return Stack(
  children: [
    Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (imageUrl != null && imageUrl.isNotEmpty)
                  Image.network(
                    imageUrl,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                  )
                else
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.image_not_supported,
                      size: 30,
                    ),
                  ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        city,
                        style: const TextStyle(fontSize: 12),
                      ),
                      if (description.isNotEmpty)
                        Text(
                          'Description: $description',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12),
                        ),
                      if (phone.isNotEmpty)
                        Text(
                          'Phone: $phone',
                          style: const TextStyle(fontSize: 12),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _buildActionButton('Call', Colors.blue, 'asset/call.png', () {
                  _makeCall(phone);
                }),
                const SizedBox(width: 10),
                _buildActionButton('WhatsApp', Colors.green, 'asset/whatsapp.png',
                    () {
                  if (whatsapp != 'No WhatsApp available' &&
                      whatsapp.isNotEmpty) {
                    _openWhatsApp(whatsapp);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'WhatsApp is not available for this number')),
                    );
                  }
                }),
                const SizedBox(width: 10),
                _buildActionButton('Share',
                    const Color.fromARGB(255, 242, 222, 38), 'asset/share.png',
                    () {
                  if (data?['name'] != null &&
                      data?['description'] != null &&
                      data?['mobile'] != null) {
                    _shareDetails(
                        data!['name'], data['description'], data['mobile']);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Unable to share. Missing item details.')),
                    );
                  }
                }),
              ],
            ),
          ],
        ),
      ),
    ),
    // Check if the `associate` field is true
    if (data?['associate'] == true) // Show if 'associate' is true
      Positioned(
        top: 8,
        right: 8,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          decoration: const BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(5),
              bottomLeft: Radius.circular(5),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.check, color: Colors.white, size: 16),
              SizedBox(width: 4),
              Text(
                'Onshop Discount Card Accepted',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
  ],
);
                      
                    },
                  ),
                ),
        ],
      ),
    );
  }
}
