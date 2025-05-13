import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'view_product_page_user.dart';
import 'home_page_user.dart'; // For the Product model

class ViewAllProducts extends StatefulWidget {
  const ViewAllProducts({Key? key}) : super(key: key);

  @override
  State<ViewAllProducts> createState() => _ViewAllProductsState();
}

class _ViewAllProductsState extends State<ViewAllProducts> {
  List<Product> products = [];
  List<Product> filteredProducts = [];
  bool isLoading = true;
  String selectedCategory = 'All';

  final List<String> categories = ['All', 'Tops', 'Bottoms', 'Accessories'];

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final supabase = Supabase.instance.client;
    try {
      print('Fetching all products...');
      final List<dynamic> response = await supabase
          .from('Product')
          .select(
            'id, product_name, price, picture, brand_name, color, category, type_of_clothing, size, Stock',
          );

      setState(() {
        products =
            response
                .map(
                  (product) => Product.fromJson({
                    ...product,
                    'stock':
                        product['Stock'], // Map the correct column name to 'stock'
                  }),
                )
                .toList();
        filteredProducts = products;
        print('Fetched ${products.length} products');
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

  void filterProducts(String category) {
    setState(() {
      selectedCategory = category;
      if (category == 'All') {
        filteredProducts = products;
      } else {
        filteredProducts =
            products.where((product) => product.category == category).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'All Products',
          style: TextStyle(
            color: Color(0xff041511),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
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
                        label: Text(
                          category,
                          style: TextStyle(
                            color:
                                selectedCategory == category
                                    ? Colors.white
                                    : Color(0xff041511),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        selected: selectedCategory == category,
                        onSelected: (selected) {
                          if (selected) {
                            filterProducts(category);
                          }
                        },
                        backgroundColor: Colors.grey[200],
                        selectedColor: Color(0xff041511),
                        checkmarkColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
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
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
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
          ),
        ],
      ),
    );
  }
}
