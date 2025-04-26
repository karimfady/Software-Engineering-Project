import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'brand_admin_edit_product.dart';
import 'brand_admin_add_product.dart';
import 'login_logic.dart';

class BrandAdminProducts extends StatefulWidget {
  const BrandAdminProducts({Key? key}) : super(key: key);

  @override
  State<BrandAdminProducts> createState() => _BrandAdminProductsState();
}

class _BrandAdminProductsState extends State<BrandAdminProducts> {
  List<Map<String, dynamic>> products = [];
  bool isLoading = true;
  String selectedCategory = 'All';
  final List<String> categories = ['All', 'Tops', 'Bottoms', 'Accessories'];
  String? brandName;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _getBrandName();
  }

  Future<void> _getBrandName() async {
    try {
      final userEmail = LoginLogic.getLoggedInUserEmail();
      print('Current user email: $userEmail'); // Debug log

      if (userEmail == null) {
        print('No user email found in auth state'); // Debug log
        setState(() {
          errorMessage = 'No user logged in';
          isLoading = false;
        });
        return;
      }

      print('Fetching brand admin data for email: $userEmail'); // Debug log
      // First get the brand_name from brand_admin
      final brandAdminResponse =
          await Supabase.instance.client
              .from('brand_admin')
              .select('brand_name')
              .eq('email', userEmail)
              .maybeSingle();

      if (brandAdminResponse == null) {
        print('No brand admin found for email: $userEmail'); // Debug log
        setState(() {
          errorMessage = 'Brand admin not found';
          isLoading = false;
        });
        return;
      }

      final brandName = brandAdminResponse['brand_name'];
      print('Found brand name: $brandName'); // Debug log

      // Then get the brand details from Brand table
      final brandResponse =
          await Supabase.instance.client
              .from('Brand')
              .select('name')
              .eq('name', brandName)
              .maybeSingle();

      if (brandResponse == null) {
        print('No brand found with name: $brandName'); // Debug log
        setState(() {
          errorMessage = 'Brand not found';
          isLoading = false;
        });
        return;
      }

      setState(() {
        this.brandName = brandName;
      });
      await fetchProducts();
    } catch (e) {
      print('Error getting brand name: $e'); // Debug log
      setState(() {
        errorMessage = 'Error getting brand information: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  Future<void> fetchProducts() async {
    if (brandName == null) {
      setState(() {
        errorMessage = 'Brand name not found';
        isLoading = false;
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      print('Fetching products for brand: $brandName'); // Debug log

      // First, let's check if the brand exists in the Brand table
      final brandCheck =
          await Supabase.instance.client
              .from('Brand')
              .select('name')
              .eq('name', brandName!)
              .maybeSingle();

      print('Brand check response: $brandCheck'); // Debug log

      if (brandCheck == null) {
        print('Brand not found in Brand table'); // Debug log
        setState(() {
          errorMessage = 'Brand not found in database';
          isLoading = false;
        });
        return;
      }

      // Debug: Check all products in the database
      final allProducts = await Supabase.instance.client
          .from('Product')
          .select('*');
      print('All products in database: $allProducts'); // Debug log

      // Now fetch products for this brand
      final response = await Supabase.instance.client
          .from('Product')
          .select('*')
          .eq('brand_name', brandName!.toLowerCase());

      print('Products response for brand $brandName: $response'); // Debug log

      if (response.isEmpty) {
        print('No products found for brand: $brandName'); // Debug log
        setState(() {
          products = [];
          isLoading = false;
        });
        return;
      }

      setState(() {
        products = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching products: $e');
      setState(() {
        errorMessage = 'Error loading products';
        isLoading = false;
      });
    }
  }

  void filterProducts(String category) {
    setState(() {
      selectedCategory = category;
    });
  }

  List<Map<String, dynamic>> get filteredProducts {
    if (selectedCategory == 'All') return products;
    return products
        .where((product) => product['category'] == selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: fetchProducts,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          // Category Filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children:
                  categories.map((category) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(category),
                        selected: selectedCategory == category,
                        onSelected: (selected) {
                          if (selected) {
                            filterProducts(category);
                          }
                        },
                      ),
                    );
                  }).toList(),
            ),
          ),
          // Products Grid
          Expanded(
            child: RefreshIndicator(
              onRefresh: fetchProducts,
              child:
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : products.isEmpty
                      ? const Center(child: Text('No products found'))
                      : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => BrandAdminEditProduct(
                                        product: product,
                                        onProductUpdated: fetchProducts,
                                      ),
                                ),
                              );
                            },
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
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
                                              top: Radius.circular(12),
                                            ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(12),
                                            ),
                                        child: Image.network(
                                          product['picture'],
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
                                          product['product_name'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          '\$${product['price'].toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          'Stock: ${product['Stock']}',
                                          style: TextStyle(
                                            color:
                                                product['Stock'] > 0
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
          ),
        ],
      ),
      floatingActionButton:
          brandName != null
              ? FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => BrandAdminAddProduct(
                            brandName: brandName!,
                            onProductAdded: fetchProducts,
                          ),
                    ),
                  );
                },
                child: const Icon(Icons.add),
              )
              : null,
    );
  }
}
