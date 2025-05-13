import 'package:flutter/material.dart';
import 'shop_page_user.dart';
import 'shopping_cart_user.dart';
import 'wishlist_page_user.dart';
import 'menu_page_user.dart';
import 'view_brand_page_user.dart';
import 'view_product_page_user.dart';
import 'view_all_brands.dart';
import 'view_all_products.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'search_page.dart';
import 'outfit_generator.dart';

// Brand Model
class Brand {
  final String name;
  final String logo;

  Brand({required this.name, required this.logo});

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(name: json['name'] ?? '', logo: json['logo'] ?? '');
  }
}

// Product Model
class Product {
  final String productName;
  final double price;
  final String picture;
  final String brandName;
  final String color;
  final String category;
  final String typeOfClothing;
  final List<String> sizes;
  final String id;
  final int stock; // Add this line

  Product({
    required this.productName,
    required this.price,
    required this.picture,
    required this.brandName,
    required this.color,
    required this.category,
    required this.typeOfClothing,
    required this.sizes,
    required this.id,
    required this.stock, // Add this line
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Decode the hex-encoded URL
    String decodedUrl = json['picture'] ?? '';
    if (decodedUrl.startsWith('\\x')) {
      try {
        // Remove the \x prefix and convert hex to string
        String hexString = decodedUrl.substring(2);
        List<int> bytes = [];
        for (int i = 0; i < hexString.length; i += 2) {
          String hexByte = hexString.substring(i, i + 2);
          bytes.add(int.parse(hexByte, radix: 16));
        }
        decodedUrl = String.fromCharCodes(bytes);
      } catch (e) {
        print('Error decoding URL: $e');
      }
    }

    // Handle sizes array
    List<String> sizesList = [];
    if (json['size'] != null) {
      if (json['size'] is List) {
        sizesList = List<String>.from(
          json['size'].map((size) => size.toString()),
        );
      }
    }

    // Handle id field
    String productId = '';
    if (json['id'] != null) {
      if (json['id'] is int) {
        productId = json['id'].toString();
      } else if (json['id'] is String) {
        productId = json['id'];
      }
    }

    print('Creating Product from JSON:');
    print('ID: $productId');
    print('Product Name: ${json['product_name']}');
    print('Price: ${json['price']}');

    return Product(
      productName: json['product_name'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      picture: decodedUrl,
      brandName: json['brand_name'] ?? '',
      color: json['color'] ?? '',
      category: json['category'] ?? '',
      typeOfClothing: json['type_of_clothing'] ?? '',
      sizes: sizesList,
      id: productId,
      stock: (json['stock'] as num?)?.toInt() ?? 0, // Add this line
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
          OutfitGeneratorPage(),
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
          BottomNavigationBarItem(icon: Icon(Icons.style), label: 'Outfits'),
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
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchBrands();
    fetchProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
          print('Brand: ${brand.name}, Logo: ${brand.logo}');
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
      final List<dynamic> response = await supabase
          .from('Product')
          .select(
            'id, product_name, price, picture, brand_name, color, category, type_of_clothing, size, Stock',
          );
      print('Raw response from Supabase: $response');

      setState(() {
        products =
            response.map((product) {
              print('Processing product: $product');
              print('Product ID: ${product['id']}');
              return Product.fromJson({
                ...product,
                'stock':
                    product['Stock'], // Map the correct column name to 'stock'
              });
            }).toList();
        print('Processed products: ${products.length}');
        // Print each product's details for debugging
        products.forEach((product) {
          print('Product: ${product.productName}');
          print('ID: ${product.id}');
          print('Price: ${product.price}');
          print('Picture URL: ${product.picture}');
          print('Sizes: ${product.sizes}');
          print('Stock: ${product.stock}');
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
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Top Bar with Logo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Center(
              child: Text(
                "Outfitly",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              readOnly: true,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchPage()),
                );
              },
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          // Top Brands Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Top Brands',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ViewAllBrands(),
                          ),
                        );
                      },
                      child: Text(
                        'View All',
                        style: TextStyle(
                          color: Color(0xff041511),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 140,
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
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => BrandPage(
                                              brandName: brand.name,
                                              brandLogo: brand.logo,
                                            ),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Center(
                                            child: Image.network(
                                              brand.logo,
                                              fit: BoxFit.contain,
                                              width: 80,
                                              height: 80,
                                              errorBuilder: (
                                                context,
                                                error,
                                                stackTrace,
                                              ) {
                                                return const Icon(
                                                  Icons.store,
                                                  size: 40,
                                                  color: Color(0xff041511),
                                                );
                                              },
                                              loadingBuilder: (
                                                context,
                                                child,
                                                loadingProgress,
                                              ) {
                                                if (loadingProgress == null)
                                                  return child;
                                                return const Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        brand.name,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                ),
              ],
            ),
          ),

          // Products Section
          Expanded(
            child: RefreshIndicator(
              onRefresh: fetchProducts,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Most Selling Products',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ViewAllProducts(),
                                ),
                              );
                            },
                            child: Text(
                              'View All',
                              style: TextStyle(
                                color: Color(0xff041511),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                        itemCount: isLoadingProducts ? 4 : products.length,
                        itemBuilder: (context, index) {
                          if (isLoadingProducts) {
                            return _buildLoadingProductCard();
                          }

                          final product = products[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => ProductPage(
                                        productName: product.productName,
                                        picture: product.picture,
                                        price: product.price,
                                        brandName: product.brandName,
                                        color: product.color,
                                        category: product.category,
                                        typeOfClothing: product.typeOfClothing,
                                        sizes: product.sizes,
                                        id: product.id,
                                        stock: product.stock,
                                      ),
                                ),
                              );
                            },
                            child: _buildProductCard(product),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingProductCard() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
              ),
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 20, width: 100, color: Colors.grey[200]),
                const SizedBox(height: 4),
                Container(height: 16, width: 60, color: Colors.grey[200]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
                child: Image.network(
                  product.picture,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(Icons.image, size: 40, color: Colors.grey),
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
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        product.stock > 0 ? Colors.green[100] : Colors.red[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    product.stock > 0 ? 'In Stock' : 'Out of Stock',
                    style: TextStyle(
                      color:
                          product.stock > 0
                              ? Colors.green[900]
                              : Colors.red[900],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
