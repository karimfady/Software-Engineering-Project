import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_page_user.dart'; // For the Product model
import 'login_logic.dart'; // Import the LoginLogic class

class ProductPage extends StatefulWidget {
  final String productName;
  final String picture;
  final double price;
  final String brandName;
  final String color;
  final String category;
  final String typeOfClothing;
  final List<String> sizes;
  final String id;

  const ProductPage({
    Key? key,
    required this.productName,
    required this.picture,
    required this.price,
    required this.brandName,
    required this.color,
    required this.category,
    required this.typeOfClothing,
    required this.sizes,
    required this.id,
  }) : super(key: key);

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  String? selectedSize;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Details'), centerTitle: true),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.grey[200]),
              child: Image.network(
                widget.picture,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(child: Icon(Icons.image, size: 50));
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name and Price
                  Text(
                    widget.productName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${widget.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description Section
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Brand', widget.brandName),
                  _buildInfoRow('Color', widget.color),
                  _buildInfoRow('Category', widget.category),
                  _buildInfoRow('Type', widget.typeOfClothing),
                  const SizedBox(height: 24),

                  // Size Selection
                  const Text(
                    'Select Size',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (widget.sizes.isEmpty)
                    const Text('No sizes available')
                  else
                    Wrap(
                      spacing: 8,
                      children:
                          widget.sizes.map((size) {
                            return ChoiceChip(
                              label: Text(size),
                              selected: selectedSize == size,
                              onSelected: (selected) {
                                setState(() {
                                  selectedSize = selected ? size : null;
                                });
                              },
                            );
                          }).toList(),
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  try {
                    final supabase = Supabase.instance.client;

                    // Check if user is logged in using the LoginLogic class
                    if (!LoginLogic.isUserLoggedIn()) {
                      // Navigate to login page
                      if (!mounted) return;
                      Navigator.pushNamed(context, '/login').then((_) {
                        // After returning from login page, try adding to wishlist again
                        if (LoginLogic.isUserLoggedIn()) {
                          _addToWishlist(LoginLogic.getLoggedInUserEmail()!);
                        }
                      });
                      return;
                    }

                    _addToWishlist(LoginLogic.getLoggedInUserEmail()!);
                  } catch (e) {
                    print('Error adding to wishlist: $e');
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}')),
                    );
                  }
                },
                icon: const Icon(Icons.favorite_border),
                label: const Text('Add to Wishlist'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.black),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed:
                    selectedSize == null
                        ? null
                        : () {
                          // Add to cart functionality will be implemented later
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Added to cart!')),
                          );
                        },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Add to Cart'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  Future<void> _addToWishlist(String userEmail) async {
    try {
      print('Adding to wishlist:');
      print('User email: $userEmail');
      print('Product ID: ${widget.id}');
      print('Price: ${widget.price}');

      // First, get the user's username from the User table
      final userResponse =
          await Supabase.instance.client
              .from('User')
              .select('user_name')
              .eq('email', userEmail)
              .single();

      if (userResponse == null) {
        print('User not found with email: $userEmail');
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Error: User not found')));
        return;
      }

      final username = userResponse['user_name'];
      print('Found username: $username');

      // Convert price to integer (remove decimal places)
      final int priceInCents = (widget.price * 100).round();

      // Insert into wishlist table
      final response =
          await Supabase.instance.client.from('wishlist').insert({
            'customer_username': username, // Use username instead of email
            'product_id': widget.id,
            'price': priceInCents,
          }).select();

      print('Wishlist insert response: $response');

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Added to wishlist!')));
    } catch (e) {
      print('Error adding to wishlist: $e');
      print('Error type: ${e.runtimeType}');
      if (e is PostgrestException) {
        print('Postgrest error details:');
        print('Message: ${e.message}');
        print('Code: ${e.code}');
        print('Details: ${e.details}');
        print('Hint: ${e.hint}');
      }
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }
}
