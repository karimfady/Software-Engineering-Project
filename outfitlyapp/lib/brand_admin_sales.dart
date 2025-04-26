import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'login_logic.dart';

class BrandAdminSales extends StatefulWidget {
  const BrandAdminSales({Key? key}) : super(key: key);

  @override
  State<BrandAdminSales> createState() => _BrandAdminSalesState();
}

class _BrandAdminSalesState extends State<BrandAdminSales> {
  List<Map<String, dynamic>> salesData = [];
  bool isLoading = true;
  String? brandName;
  double totalRevenue = 0;
  int totalItemsSold = 0;
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
      await fetchSalesData();
    } catch (e) {
      print('Error getting brand name: $e'); // Debug log
      setState(() {
        errorMessage = 'Error getting brand information: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  Future<void> fetchSalesData() async {
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
      // Get all order items for orders that are not in cart
      final response = await Supabase.instance.client
          .from('order_item')
          .select('''
            *,
            Order (
              order_id,
              status
            )
          ''')
          .neq('status', 'In Cart');

      print('Order items with order details: $response'); // Debug log

      // Get all products for this brand
      final productsResponse = await Supabase.instance.client
          .from('Product')
          .select('*')
          .eq('brand_name', brandName!.toLowerCase());

      print('Products for brand $brandName: $productsResponse'); // Debug log

      // Process the data
      final Map<String, Map<String, dynamic>> productSales = {};
      double totalRev = 0;
      int totalSold = 0;

      // Create a map of product IDs to their details for quick lookup
      final Map<String, Map<String, dynamic>> productMap = {};
      for (var product in productsResponse) {
        productMap[product['id']] = product;
      }

      // Debug: Print product map
      print('Product map: $productMap'); // Debug log

      // Process each order item
      for (var item in response) {
        print('Processing order item: $item'); // Debug log

        // Skip if the status is In Cart
        if (item['status'] == 'In Cart') {
          print('Skipping item with status: In Cart'); // Debug log
          continue;
        }

        final productId = item['product_id'];

        // Only process items that belong to this brand
        if (productMap.containsKey(productId)) {
          final quantity = item['quantity'] as int;
          final price = item['price_per_item'];

          if (!productSales.containsKey(productId)) {
            productSales[productId] = {
              'quantity_sold': 0,
              'revenue': 0.0,
              'product_name': productMap[productId]!['product_name'],
            };
          }

          productSales[productId]!['quantity_sold'] += quantity;
          productSales[productId]!['revenue'] +=
              (price * quantity) / 100; // Convert cents to dollars
          totalRev += (price * quantity) / 100;
          totalSold += quantity;
        } else {
          print('Product $productId not found in brand products'); // Debug log
        }
      }

      print('Final sales data: ${productSales.values.toList()}'); // Debug log

      setState(() {
        salesData = productSales.values.toList();
        totalRevenue = totalRev;
        totalItemsSold = totalSold;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching sales data: $e');
      setState(() {
        errorMessage = 'Error loading sales data';
        isLoading = false;
      });
    }
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
              onPressed: fetchSalesData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: fetchSalesData,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Summary Cards
                      Row(
                        children: [
                          Expanded(
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    const Text(
                                      'Total Revenue',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '\$${totalRevenue.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    const Text(
                                      'Total Items Sold',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      totalItemsSold.toString(),
                                      style: const TextStyle(
                                        fontSize: 24,
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Sales by Product
                      const Text(
                        'Sales by Product',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      salesData.isEmpty
                          ? const Center(child: Text('No sales data found'))
                          : Column(
                            children:
                                salesData.map((product) {
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product['product_name'],
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text('Quantity Sold'),
                                                  Text(
                                                    product['quantity_sold']
                                                        .toString(),
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  const Text('Revenue'),
                                                  Text(
                                                    '\$${product['revenue'].toStringAsFixed(2)}',
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.green,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                          ),
                    ],
                  ),
                ),
              ),
    );
  }
}
