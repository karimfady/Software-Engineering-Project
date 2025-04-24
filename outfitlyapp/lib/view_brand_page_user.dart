import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_page_user.dart';
import 'view_product_page_user.dart';

class BrandPage extends StatefulWidget {
  final String brandName;
  final String brandLogo;

  const BrandPage({Key? key, required this.brandName, required this.brandLogo})
    : super(key: key);

  @override
  State<BrandPage> createState() => _BrandPageState();
}

class _BrandPageState extends State<BrandPage> {
  List<Product> brandProducts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBrandProducts();
  }

  Future<void> fetchBrandProducts() async {
    final supabase = Supabase.instance.client;
    try {
      print('Fetching products for brand: ${widget.brandName}');
      final List<dynamic> response = await supabase
          .from('Product')
          .select(
            'id, product_name, price, picture, brand_name, color, category, type_of_clothing, size, Stock',
          )
          .eq('brand_name', widget.brandName);
      print('Response from Supabase: $response');

      setState(() {
        brandProducts =
            response
                .map(
                  (product) => Product.fromJson({
                    ...product,
                    'stock':
                        product['Stock'], // Map the correct column name to 'stock'
                  }),
                )
                .toList();
        print('Processed products: ${brandProducts.length}');
        // Print each product's details for debugging
        brandProducts.forEach((product) {
          print('Product: ${product.productName}');
          print('Price: ${product.price}');
          print('Picture URL: ${product.picture}');
          print('Sizes: ${product.sizes}');
          print('Stock: ${product.stock}');
          print('---');
        });
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching products: $e');
      setState(() {
        isLoading = false;
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
      appBar: AppBar(title: Text(widget.brandName), centerTitle: true),
      body: RefreshIndicator(
        onRefresh: fetchBrandProducts,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Brand Header
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(60),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(60),
                        child: Image.network(
                          widget.brandLogo,
                          fit: BoxFit.contain,
                          width: 100,
                          height: 100,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.store, size: 50);
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.brandName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Products Grid
              Padding(
                padding: const EdgeInsets.all(16.0),
                child:
                    isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.75,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                          itemCount: brandProducts.length,
                          itemBuilder: (context, index) {
                            final product = brandProducts[index];
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
                                          typeOfClothing:
                                              product.typeOfClothing,
                                          sizes: product.sizes,
                                          id: product.id,
                                          stock: product.stock, // Add this line
                                        ),
                                  ),
                                );
                              },
                              child: Card(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                                child: Icon(
                                                  Icons.image,
                                                  size: 40,
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
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            '\$${product.price.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            product.stock > 0
                                                ? 'In Stock'
                                                : 'Out of Stock',
                                            style: TextStyle(
                                              color:
                                                  product.stock > 0
                                                      ? Colors.green
                                                      : Colors.red,
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
      ),
    );
  }
}
