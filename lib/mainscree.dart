import 'package:flutter/material.dart';
import 'package:onshopapp/Categories/shops.dart';
import 'package:onshopapp/screens/Discount%20card/Discountcard.dart';
import 'package:onshopapp/screens/Products/Productcategoriespage.dart';
import 'package:onshopapp/screens/Products/Productspage.dart';
import 'package:onshopapp/screens/homepage.dart';
import 'package:onshopapp/screens/subcategory_page.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);

  final List<Widget> _pages = [
    HomePage(), // Home Page
    ProductCategoriesPage(), // Product Categories Page
    SubcategoryGridPage(collectionName: 'shopcategories'), // Shops Page
    DiscountCardPage(), // Discount Card Page
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index); // Update the PageView to the selected page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: _pages,
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(child: _buildNavItem('asset/home.png', 'Home', 0)),
            VerticalDivider(width: .5, color: const Color.fromARGB(255, 148, 148, 148), thickness: 0.5),
            Expanded(child: _buildNavItem('asset/grocery.png', 'Categories', 1)),
            VerticalDivider(width: .5, color: const Color.fromARGB(255, 148, 148, 148), thickness: 0.5),
            Expanded(child: _buildNavItem('asset/online-shop.png', 'Shops', 2)),
            VerticalDivider(width: .5, color: const Color.fromARGB(255, 148, 148, 148), thickness: 0.5),
            Expanded(child: _buildNavItem('asset/credit-card.png', 'DiscountCard', 3)),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(String assetImage, String label, int index) {
    return InkWell(
      onTap: () => _onItemTapped(index),
      child: Container(
        height: double.infinity,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              assetImage,
              width: 24,
              height: 24,
              color: _selectedIndex == index ? Colors.black : const Color.fromARGB(255, 105, 105, 105),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: _selectedIndex == index ? Colors.black : Color.fromARGB(255, 105, 105, 105),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}