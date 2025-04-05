import 'package:flutter/material.dart';
import 'shop_page_user.dart';
import 'shopping_cart_user.dart';
import 'wishlist_page_user.dart';
import 'menu_page_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Brand Model
class Brand {
  final String brandName;
  final String brandLogo;

  Brand({required this.brandName, required this.brandLogo});

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(brandName: json['name'] ?? '', brandLogo: json['logo'] ?? '');
  }
}

// Product Model
class Product {
  final String productName;
  final double price;
  final String picture;

  Product({
    required this.productName,
    required this.price,
    required this.picture,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productName: json['product_name'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      picture: json['picture'] ?? '',
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
        children: const [
          HomeContent(),
          ShopPage(),
          CartPage(),
          WishlistPage(),
          MenuPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Shop',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Wishlist',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menu'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({Key? key}) : super(key: key);

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  List<Brand> brands = [];
  List<Product> products = [];
  bool isLoading = true;
  bool isLoadingProducts = true;

  @override
  void initState() {
    super.initState();
    fetchBrands();
    fetchProducts();
  }

  Future<void> fetchBrands() async {
    final supabase = Supabase.instance.client;
    try {
      print('Fetching brands...');
      final List<dynamic> response = await supabase.from('Brand').select();
      print('Response from Supabase: $response');

      if (response.isEmpty) {
        print('No brands found in the database');
      }

      setState(() {
        brands = response.map((brand) => Brand.fromJson(brand)).toList();
        print('Processed brands: ${brands.length}');
        brands.forEach((brand) {
          print('Brand: ${brand.brandName}, Logo: ${brand.brandLogo}');
        });
        isLoading = false;
      });
    } catch (e, stackTrace) {
      print('Error fetching brands: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading brands: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> fetchProducts() async {
    final supabase = Supabase.instance.client;
    try {
      print('Fetching products...');
      final List<dynamic> response = await supabase.from('Product').select();
      print('Products response: $response');

      setState(() {
        products =
            response.map((product) => Product.fromJson(product)).toList();
        print('Processed products: ${products.length}');
        // Print each product's details for debugging
        products.forEach((product) {
          print('Product: ${product.productName}');
          print('Price: ${product.price}');
          print('Picture URL: ${product.picture}');
          print('---');
        });
        isLoadingProducts = false;
      });
    } catch (e) {
      print('Error fetching products: $e');
      setState(() {
        isLoadingProducts = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading products: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Outfitly',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Search functionality will be implemented later
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: fetchBrands,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Brands Section
                const Text(
                  'Top Brands',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 120,
                  child:
                      isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: brands.length,
                            itemBuilder: (context, index) {
                              final brand = brands[index];
                              return Padding(
                                padding: const EdgeInsets.only(right: 16.0),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(40),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(40),
                                        child: Image.network(
                                          brand.brandLogo,
                                          fit: BoxFit.contain,
                                          width: 70,
                                          height: 70,
                                          errorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                            return const Icon(
                                              Icons.store,
                                              size: 40,
                                            );
                                          },
                                          loadingBuilder: (
                                            context,
                                            child,
                                            loadingProgress,
                                          ) {
                                            if (loadingProgress == null) {
                                              return child;
                                            }
                                            return const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(brand.brandName),
                                  ],
                                ),
                              );
                            },
                          ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to all brands
                  },
                  child: const Text('View All Brands'),
                ),

                const SizedBox(height: 20),

                // Most Selling Products Section
                const Text(
                  'Most Selling Products',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: isLoadingProducts ? 4 : products.length,
                  itemBuilder: (context, index) {
                    if (isLoadingProducts) {
                      return Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(4),
                                  ),
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 20,
                                    width: 100,
                                    color: Colors.grey[200],
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    height: 16,
                                    width: 60,
                                    color: Colors.grey[200],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final product = products[index];
                    return Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4),
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4),
                                ),
                                child: Image.network(
                                  product.picture,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (context, error, stackTrace) {
                                    print('Error loading image: $error');
                                    print('Image URL: ${product.picture}');
                                    return const Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.image, size: 40),
                                          SizedBox(height: 8),
                                          Text('Failed to load image'),
                                        ],
                                      ),
                                    );
                                  },
                                  loadingBuilder: (
                                    context,
                                    child,
                                    loadingProgress,
                                  ) {
                                    if (loadingProgress == null) return child;
                                    print('Loading image: ${product.picture}');
                                    print(
                                      'Progress: ${loadingProgress.cumulativeBytesLoaded} / ${loadingProgress.expectedTotalBytes}',
                                    );
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.productName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '\$${product.price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to all products
                  },
                  child: const Text('View All Products'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
