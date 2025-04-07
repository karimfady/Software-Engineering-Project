import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'view_product_page_user.dart';

// Product model
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
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    String decodedUrl = json['picture'] ?? '';
    if (decodedUrl.startsWith('\\x')) {
      try {
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

    List<String> sizesList = [];
    if (json['size'] != null && json['size'] is List) {
      sizesList = List<String>.from(json['size'].map((s) => s.toString()));
    }

    String productId = '';
    if (json['id'] != null) {
      if (json['id'] is int) {
        productId = json['id'].toString();
      } else if (json['id'] is String) {
        productId = json['id'];
      }
    }

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
    );
  }
}

class search_page extends StatefulWidget {
  const search_page({Key? key}) : super(key: key);

  @override
  State<search_page> createState() => _search_page();
}

class _search_page extends State<search_page> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';
  List<Product> searchResults = [];
  bool isLoading = false;

  void _performSearch() async {
    final supabase = Supabase.instance.client;
    final String query = _searchController.text.trim();

    if (query.isEmpty) return;

    setState(() {
      searchQuery = query;
      isLoading = true;
      searchResults = [];
    });

    try {
      final List<dynamic> response = await supabase
          .from('Product')
          .select(
            'id, product_name, price, picture, brand_name, color, category, type_of_clothing, size, Tags',
          )
          .filter('Tags', 'cs', '{$query}');

      final results = response.map((e) => Product.fromJson(e)).toList();

      setState(() {
        searchResults = results;
        isLoading = false;
      });

      print('Search successful. Found ${results.length} items.');
    } catch (e) {
      print('Search error: $e');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error searching: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: TextField(
              controller: _searchController,
              onSubmitted: (_) => _performSearch(),
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: _performSearch,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Results:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child:
                          searchResults.isEmpty
                              ? Center(
                                child: Text(
                                  searchQuery.isEmpty
                                      ? 'No search made yet.'
                                      : 'No results found for "$searchQuery".',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              )
                              : GridView.builder(
                                shrinkWrap: true,
                                physics: const AlwaysScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: 0.75,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                    ),
                                itemCount: searchResults.length,
                                itemBuilder: (context, index) {
                                  final product = searchResults[index];

                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => ProductPage(
                                                productName:
                                                    product.productName,
                                                picture: product.picture,
                                                price: product.price,
                                                brandName: product.brandName,
                                                color: product.color,
                                                category: product.category,
                                                typeOfClothing:
                                                    product.typeOfClothing,
                                                sizes: product.sizes,
                                                id: product.id,
                                              ),
                                        ),
                                      );
                                    },
                                    child: Card(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.grey[200],
                                                borderRadius:
                                                    const BorderRadius.vertical(
                                                      top: Radius.circular(4),
                                                    ),
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    const BorderRadius.vertical(
                                                      top: Radius.circular(4),
                                                    ),
                                                child: Image.network(
                                                  product.picture,
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                  errorBuilder: (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) {
                                                    return const Center(
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                            Icons.image,
                                                            size: 40,
                                                          ),
                                                          SizedBox(height: 8),
                                                          Text(
                                                            'Failed to load image',
                                                          ),
                                                        ],
                                                      ),
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
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  product.productName,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                                    ),
                                  );
                                },
                              ),
                    ),
                  ],
                ),
      ),
    );
  }
}
