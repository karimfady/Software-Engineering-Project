import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_page_user.dart'; // For the Product model
import 'login_logic.dart'; // Import the LoginLogic class
import 'wishlist_state.dart';

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
  bool isInWishlist = false;

  @override
  void initState() {
    super.initState();
    _checkWishlistStatus();
  }

  Future<void> _checkWishlistStatus() async {
    if (!LoginLogic.isUserLoggedIn()) return;

    try {
      final userEmail = LoginLogic.getLoggedInUserEmail()!;

      // Get username from email
      final userResponse =
          await Supabase.instance.client
              .from('User')
              .select('user_name')
              .eq('email', userEmail)
              .single();

      if (userResponse == null) return;

      final username = userResponse['user_name'];

      // Check if product is in wishlist
      final wishlistResponse =
          await Supabase.instance.client
              .from('wishlist')
              .select()
              .eq('customer_username', username)
              .eq('product_id', widget.id)
              .maybeSingle();

      if (mounted) {
        setState(() {
          isInWishlist = wishlistResponse != null;
        });
      }
    } catch (e) {
      print('Error checking wishlist status: $e');
    }
  }

  Future<void> _removeFromWishlist(String userEmail) async {
    try {
      print('Removing from wishlist:');
      print('User email: $userEmail');
      print('Product ID: ${widget.id}');

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

      // Delete from wishlist table
      await Supabase.instance.client
          .from('wishlist')
          .delete()
          .eq('customer_username', username)
          .eq('product_id', widget.id);

      if (mounted) {
        setState(() {
          isInWishlist = false;
        });
        await WishlistState().updateWishlistCount();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Removed from wishlist!')));
      }
    } catch (e) {
      print('Error removing from wishlist: $e');
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
      setState(() {
        isInWishlist = true;
      });
      await WishlistState().updateWishlistCount();
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

                    final userEmail = LoginLogic.getLoggedInUserEmail()!;
                    if (isInWishlist) {
                      await _removeFromWishlist(userEmail);
                    } else {
                      await _addToWishlist(userEmail);
                    }
                  } catch (e) {
                    print('Error managing wishlist: $e');
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}')),
                    );
                  }
                },
                icon: Icon(
                  isInWishlist ? Icons.favorite : Icons.favorite_border,
                  color: isInWishlist ? Colors.red : Colors.black,
                ),
                label: Text(
                  isInWishlist ? 'Remove from Wishlist' : 'Add to Wishlist',
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  side: BorderSide(
                    color: isInWishlist ? Colors.red : Colors.black,
                  ),
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
}
