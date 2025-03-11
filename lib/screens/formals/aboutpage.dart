import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About OnShop'),
        backgroundColor: const Color.fromARGB(255, 255, 185, 41),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome to the OnShop Application',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Local shop owners are facing challenges with declining sales as more customers turn to online shopping. "
              "OnShop bridges the gap by making it easy for customers to discover nearby shops, explore exciting discounts, "
              "and support their local businesses—all through a single app.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              icon: Icons.local_offer,
              title: "Discounts",
              subtitle: "“Exciting Deals & Discounts”",
              description:
                  "Stay updated with the latest offers and exclusive discounts from your favorite stores.",
            ),
            const SizedBox(height: 16),
            _buildSection(
              icon: Icons.storefront,
              title: "Shops",
              subtitle: "“Explore Local Shops”",
              description:
                  "Find a variety of shops near you, offering everything from daily essentials to unique products.",
            ),
            const SizedBox(height: 16),
            _buildSection(
              icon: Icons.miscellaneous_services,
              title: "Services",
              subtitle: "“Convenient Local Services”",
              description:
                  "Discover trusted services like electricians, plumbers, and more at your fingertips.",
            ),
            const SizedBox(height: 16),
            _buildSection(
              icon: Icons.handyman,
              title: "Workers",
              subtitle: "“Find Workers”",
              description:
                  "Easily connect with professionals and skilled workers for your projects and tasks.",
            ),
            const SizedBox(height: 16),
            _buildSection(
              icon: Icons.apartment,
              title: "Flat/Rooms",
              subtitle: "“Affordable Flats & Rooms”",
              description:
                  "Browse and find the perfect flats or rooms for rent in your area.",
            ),
            const SizedBox(height: 16),
            _buildSection(
              icon: Icons.local_taxi,
              title: "Taxis",
              subtitle: "“Nearby Taxi Services”",
              description:
                  "Book taxis effortlessly for quick and comfortable rides within your city.",
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to build a section
  Widget _buildSection({
    required IconData icon,
    required String title,
    required String subtitle,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 40,
          color: const Color.fromARGB(255, 255, 185, 41),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}