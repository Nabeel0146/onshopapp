import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';

class ShopEditPage extends StatefulWidget {
  final String shopId;
  final Map<String, dynamic> shopData;

  const ShopEditPage({Key? key, required this.shopId, required this.shopData})
      : super(key: key);

  @override
  _ShopEditPageState createState() => _ShopEditPageState();
}

class _ShopEditPageState extends State<ShopEditPage> {
  String? documentId;
  Map<String, dynamic>? shopDetails;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController whatsappController = TextEditingController();

  List<String> categories = [];
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    _fetchShopDocument();
    _fetchCategories();
  }

  File? _selectedImage;

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImageAndUpdateUrl() async {
    if (_selectedImage == null) return;

    try {
      // Upload the image to Firebase Storage
      Reference storageReference = FirebaseStorage.instance.ref().child(
          'shop_images/${widget.shopId}/${DateTime.now().millisecondsSinceEpoch}');
      UploadTask uploadTask = storageReference.putFile(_selectedImage!);
      TaskSnapshot taskSnapshot = await uploadTask;

      // Get the download URL of the uploaded image
      String imageUrl = await taskSnapshot.ref.getDownloadURL();

      // Update the image_url field in Firestore
      await FirebaseFirestore.instance
          .collection('shops')
          .doc(documentId)
          .update({
        'image_url': imageUrl,
      });

      print("Image uploaded and URL updated successfully!");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Image updated successfully")),
      );
    } catch (e) {
      print("Error uploading image: $e");
    }
  }

  Future<void> _fetchShopDocument() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('shops')
          .where('shopid', isEqualTo: widget.shopId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var doc = querySnapshot.docs.first;
        setState(() {
          documentId = doc.id;
          shopDetails = doc.data() as Map<String, dynamic>;

          // Populate text fields with fetched data
          nameController.text = shopDetails?['name'] ?? '';
          descriptionController.text = shopDetails?['description'] ?? '';
          mobileController.text = shopDetails?['mobile'] ?? '';
          whatsappController.text = shopDetails?['whatsapp'] ?? '';
        });
      } else {
        print("Shop not found with shopid: ${widget.shopId}");
      }
    } catch (e) {
      print("Error fetching shop document: $e");
    }
  }

  Future<void> _fetchCategories() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('productcategories')
          .get();

      List<String> fetchedCategories =
          querySnapshot.docs.map((doc) => doc['name'] as String).toList();
      setState(() {
        categories = fetchedCategories;
      });
    } catch (e) {
      print("Error fetching categories: $e");
    }
  }

  Future<void> _updateShopData() async {
    if (documentId == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('shops')
          .doc(documentId)
          .update({
        'name': nameController.text,
        'description': descriptionController.text,
        'mobile': mobileController.text,
        'whatsapp': whatsappController.text,
      });

      print("Shop data updated successfully!");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Shop updated successfully")),
      );
    } catch (e) {
      print("Error updating shop: $e");
    }
  }

  void _deleteProduct(String productId) async {
    await FirebaseFirestore.instance
        .collection('products')
        .doc(productId)
        .delete();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Product deleted")));
  }

  void _editProduct(String productId, Map<String, dynamic> productData) {
    TextEditingController nameController =
        TextEditingController(text: productData['name']);
    TextEditingController descController =
        TextEditingController(text: productData['description']);
    TextEditingController imageUrlController =
        TextEditingController(text: productData['image_url']);
    TextEditingController priceController =
        TextEditingController(text: productData['price']?.toString() ?? '');
    TextEditingController discountedPriceController = TextEditingController(
        text: productData['discountedprice']?.toString() ?? '');
    String? selectedCategory = productData['category'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Product"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField("Product Name", nameController),
              _buildTextField("Description", descController),
              _buildTextField("Image URL", imageUrlController),
              _buildTextField("Price", priceController, isNumeric: true),
              _buildTextField("Discounted Price", discountedPriceController,
                  isNumeric: true),
              DropdownButton<String>(
                value: selectedCategory,
                hint: Text("Select Category"),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCategory = newValue;
                  });
                },
                items: categories.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('products')
                    .doc(productId)
                    .update({
                  'name': nameController.text,
                  'description': descController.text,
                  'image_url': imageUrlController.text,
                  'price': priceController.text.isNotEmpty
                      ? int.tryParse(priceController.text)
                      : null,
                  'discountedprice': discountedPriceController.text.isNotEmpty
                      ? int.tryParse(discountedPriceController.text)
                      : null,
                  'category': selectedCategory,
                });
                Navigator.pop(context);
              },
              child: Text("Save Changes"),
            ),
          ],
        );
      },
    );
  }

  void _addProduct() {
    TextEditingController nameController = TextEditingController();
    TextEditingController descController = TextEditingController();
    TextEditingController imageUrlController = TextEditingController();
    TextEditingController priceController = TextEditingController();
    TextEditingController discountedPriceController = TextEditingController();
    String? selectedCategory;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add New Product"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField("Product Name", nameController),
              _buildTextField("Description", descController),
              _buildTextField("Image URL", imageUrlController),
              _buildTextField("Price", priceController, isNumeric: true),
              _buildTextField("Discounted Price", discountedPriceController,
                  isNumeric: true),
              DropdownButton<String>(
                value: selectedCategory,
                hint: Text("Select Category"),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCategory = newValue;
                  });
                },
                items: categories.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedCategory == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Please select a category")));
                  return;
                }
                await FirebaseFirestore.instance.collection('products').add({
                  'shopid': widget.shopId,
                  'name': nameController.text,
                  'description': descController.text,
                  'image_url': imageUrlController.text,
                  'price': priceController.text.isNotEmpty
                      ? int.tryParse(priceController.text)
                      : null,
                  'discountedprice': discountedPriceController.text.isNotEmpty
                      ? int.tryParse(discountedPriceController.text)
                      : null,
                  'city': shopDetails?['city'] ?? '',
                  'display': true,
                  'category': selectedCategory,
                  'whatsappnumber': shopDetails?['whatsapp'] ?? '',
                });
                Navigator.pop(context);
              },
              child: Text("Add Product"),
            ),
          ],
        );
      },
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      Text(
                        'Edit Business Profile',
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
      backgroundColor: Colors.amber,),
      
      body: shopDetails == null || categories.isEmpty
          ? Center(
              child:
                  CircularProgressIndicator()) // Show loader while fetching data
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Display the current image
                  if (shopDetails?['image_url'] != null &&
                      shopDetails!['image_url'].isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        shopDetails!['image_url'],
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    Icon(Icons.image, size: 100),

                  // Button to pick a new image
                  SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: Text("Change Image"),
                  ),

                  // Display the selected image
                  if (_selectedImage != null)
                    Image.file(_selectedImage!,
                        width: 100, height: 100, fit: BoxFit.cover),

                  SizedBox(height: 20),

                  _buildTextField("Shop Name", nameController),
                  _buildTextField("Description", descriptionController),
                  _buildTextField("Mobile", mobileController),
                  _buildTextField("WhatsApp", whatsappController),

                  SizedBox(height: 20),
                  Container(
                    
                    width: double
                        .infinity, // Make the button width fill the available space
                    height: 50, // Set a fixed height for the button
                    decoration: BoxDecoration(

                      borderRadius:
                          BorderRadius.circular(10), // Rounded corners
                    ),
                    child: ElevatedButton(
                      onPressed: () async {
                        await _uploadImageAndUpdateUrl();
                        await _updateShopData();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(10), // Rounded corners
                        ),
                      ),
                      child: Text("Save Changes", style: TextStyle(color: Colors.white),),
                    ),
                  ),

                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Products",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: Icon(Icons.add, color: Colors.blue),
                        onPressed: _addProduct,
                      ),
                    ],
                  ),

                  _buildProductList(),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool isNumeric = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        decoration:
            InputDecoration(labelText: label, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
      ),
    );
  }

  Widget _buildProductList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('products')
          .where('shopid', isEqualTo: widget.shopId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No products found."));
        }

        var products = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: products.length,
          itemBuilder: (context, index) {
            var product = products[index].data() as Map<String, dynamic>;
            String productId = products[index].id;

            return Card(
              margin: EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: product['image_url'] != null &&
                        product['image_url'].isNotEmpty
                    ? Image.network(product['image_url'],
                        width: 50, height: 50, fit: BoxFit.cover)
                    : Icon(Icons.image, size: 50),
                title: Text(product['name'] ?? 'Unnamed Product'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product['description'] ?? ''),
                    Text(product['category'] ?? ''),
                    if (product['price'] != null)
                      Text("Price: ${product['price']}"),
                    if (product['discountedprice'] != null)
                      Text("Discounted Price: ${product['discountedprice']}"),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _editProduct(productId, product),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteProduct(productId),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
