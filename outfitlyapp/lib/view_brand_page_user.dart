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
          .ilike('brand_name', widget.brandName);
      print('Response from Supabase: $response');
      print('Searching for brand: ${widget.brandName}');

      setState(() {
        brandProducts =
            response.map((product) {
              print(
                'Processing product: ${product['product_name']} with brand: ${product['brand_name']}',
              );
              return Product.fromJson({...product, 'stock': product['Stock']});
            }).toList();
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.brandName,
          style: const TextStyle(
            color: Color(0xff041511),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
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
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          widget.brandLogo,
                          fit: BoxFit.contain,
                          width: 100,
                          height: 100,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.store,
                              size: 50,
                              color: Color(0xff041511),
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
                        fontWeight: FontWeight.w700,
                        color: Color(0xff041511),
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
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
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
                                          stock: product.stock,
                                        ),
                                  ),
                                );
                              },
                              child: Card(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                    color: Colors.grey.withOpacity(0.2),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                top: Radius.circular(8),
                                              ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                top: Radius.circular(8),
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
                                                  color: Colors.grey,
                                                ),
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
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '\$${product.price.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              color: Color(0xff041511),
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
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
                                                  product.stock > 0
                                                      ? Colors.green[100]
                                                      : Colors.red[100],
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              product.stock > 0
                                                  ? 'In Stock'
                                                  : 'Out of Stock',
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
