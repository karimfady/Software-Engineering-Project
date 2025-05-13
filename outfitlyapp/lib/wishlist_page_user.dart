import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_logic.dart';
import 'view_product_page_user.dart';
import 'wishlist_state.dart';
import 'cart_state.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({Key? key}) : super(key: key);

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  List<Map<String, dynamic>> wishlistItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWishlistItems();
  }

  Future<void> _loadWishlistItems() async {
    if (!LoginLogic.isUserLoggedIn()) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final userEmail = LoginLogic.getLoggedInUserEmail()!;

      // Get username from email
      final userResponse =
          await Supabase.instance.client
              .from('User')
              .select('user_name')
              .eq('email', userEmail)
              .single();

      if (userResponse == null) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      final username = userResponse['user_name'];

      // Get wishlist items with product details
      final response = await Supabase.instance.client
          .from('wishlist')
          .select('''
            id,
            price,
            product:Product (
              id,
              product_name,
              picture,
              brand_name,
              color,
              category,
              type_of_clothing,
              size,
              Stock
            )
          ''')
          .eq('customer_username', username);

      if (mounted) {
        setState(() {
          wishlistItems = List<Map<String, dynamic>>.from(response);
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading wishlist: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _removeFromWishlist(int wishlistId) async {
    try {
      await Supabase.instance.client
          .from('wishlist')
          .delete()
          .eq('id', wishlistId);

      // Refresh the list and update count
      _loadWishlistItems();
      await WishlistState().updateWishlistCount();

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Removed from wishlist!')));
    } catch (e) {
      print('Error removing from wishlist: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  Future<void> _addToCart(String productId, String size) async {
    try {
      // Convert price to cents
      final priceInCents =
          (wishlistItems.firstWhere(
                (item) => item['product']['id'] == productId,
              )['price']
              as int);

      await CartState().addToCart(
        productId: productId,
        quantity: 1,
        size: size,
        pricePerItem: priceInCents,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Added to cart!'),
          action: SnackBarAction(
            label: 'View Cart',
            onPressed: () {
              Navigator.pushNamed(context, '/cart');
            },
          ),
        ),
      );
    } catch (e) {
      print('Error adding to cart: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!LoginLogic.isUserLoggedIn()) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Wishlist',
            style: TextStyle(
              color: Color(0xff041511),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Please login to view your wishlist'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login').then((_) {
                    if (LoginLogic.isUserLoggedIn()) {
                      _loadWishlistItems();
                    }
                  });
                },
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Wishlist',
          style: TextStyle(
            color: Color(0xff041511),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : wishlistItems.isEmpty
              ? const Center(child: Text('Your wishlist is empty'))
              : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: wishlistItems.length,
                itemBuilder: (context, index) {
                  final item = wishlistItems[index];
                  final product = item['product'] as Map<String, dynamic>;
                  final priceInDollars = (item['price'] as int) / 100;

                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey.withOpacity(0.2)),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ProductPage(
                                  productName: product['product_name'],
                                  picture: product['picture'],
                                  price: (item['price'] as int) / 100,
                                  brandName: product['brand_name'],
                                  color: product['color'],
                                  category: product['category'],
                                  typeOfClothing: product['type_of_clothing'],
                                  sizes:
                                      (product['size'] as List<dynamic>)
                                          .cast<String>(),
                                  id: product['id'],
                                  stock: product['Stock'],
                                ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                product['picture'],
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.image,
                                      size: 40,
                                      color: Color(0xff041511),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Product Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              product['product_name'],
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xff041511),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '\$${priceInDollars.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                color: Color(0xff041511),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.favorite,
                                          color: Colors.red,
                                        ),
                                        onPressed:
                                            () =>
                                                _removeFromWishlist(item['id']),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          product['Stock'] > 0
                                              ? Colors.green[100]
                                              : Colors.red[100],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      product['Stock'] > 0
                                          ? 'In Stock'
                                          : 'Out of Stock',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color:
                                            product['Stock'] > 0
                                                ? Colors.green[900]
                                                : Colors.red[900],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        try {
                                          if (!LoginLogic.isUserLoggedIn()) {
                                            if (!mounted) return;
                                            Navigator.pushNamed(
                                              context,
                                              '/login',
                                            ).then((_) {
                                              if (LoginLogic.isUserLoggedIn()) {
                                                _addToCart(
                                                  product['id'],
                                                  product['size'][0],
                                                );
                                              }
                                            });
                                            return;
                                          }

                                          await _addToCart(
                                            product['id'],
                                            product['size'][0],
                                          );
                                        } catch (e) {
                                          if (!mounted) return;
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Error: ${e.toString()}',
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xff041511),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        'Add to Cart',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
