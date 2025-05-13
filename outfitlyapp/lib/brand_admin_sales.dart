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
            Order!inner (
              order_id,
              status
            )
          ''')
          .neq('Order.status', 'In Cart')
          .neq('Order.status', 'Pending'); // Also exclude pending orders

      print('Order items with order details: $response'); // Debug log

      // Get all products for this brand
      final productsResponse = await Supabase.instance.client
          .from('Product')
          .select('*')
          .ilike(
            'brand_name',
            brandName!,
          ); // Changed to case-insensitive comparison

      print('Products for brand $brandName: $productsResponse'); // Debug log

      // Process the data
      final Map<String, Map<String, dynamic>> productSales = {};
      double totalRev = 0;
      int totalSold = 0;

      // Create a map of product IDs to their details for quick lookup
      final Map<String, Map<String, dynamic>> productMap = {};
      for (var product in productsResponse) {
        productMap[product['id'].toString()] =
            product; // Convert ID to string for comparison
      }

      // Debug: Print product map
      print('Product map: $productMap'); // Debug log

      // Process each order item
      for (var item in response) {
        print('Processing order item: $item'); // Debug log

        final productId =
            item['product_id'].toString(); // Convert to string for comparison
        print('Checking product ID: $productId'); // Debug log

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

          print(
            'Updated sales for product $productId: ${productSales[productId]}',
          ); // Debug log
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Sales',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xff041511),
          ),
        ),
        centerTitle: true,
      ),
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
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: Color(0xff041511).withOpacity(0.1),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    Text(
                                      'Total Revenue',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xff041511),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '\$${totalRevenue.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 24,
                                        color: Color(0xff041511),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: Color(0xff041511).withOpacity(0.1),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    Text(
                                      'Total Items Sold',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xff041511),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      totalItemsSold.toString(),
                                      style: TextStyle(
                                        fontSize: 24,
                                        color: Color(0xff041511),
                                        fontWeight: FontWeight.w700,
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
                      Text(
                        'Sales by Product',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xff041511),
                        ),
                      ),
                      const SizedBox(height: 16),
                      salesData.isEmpty
                          ? Center(
                            child: Text(
                              'No sales data found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xff041511),
                              ),
                            ),
                          )
                          : Column(
                            children:
                                salesData.map((product) {
                                  return Card(
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      side: BorderSide(
                                        color: Color(
                                          0xff041511,
                                        ).withOpacity(0.1),
                                      ),
                                    ),
                                    margin: const EdgeInsets.only(bottom: 16),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product['product_name'],
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xff041511),
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
                                                  Text(
                                                    'Quantity Sold',
                                                    style: TextStyle(
                                                      color: Color(
                                                        0xff041511,
                                                      ).withOpacity(0.7),
                                                    ),
                                                  ),
                                                  Text(
                                                    product['quantity_sold']
                                                        .toString(),
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Color(0xff041511),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    'Revenue',
                                                    style: TextStyle(
                                                      color: Color(
                                                        0xff041511,
                                                      ).withOpacity(0.7),
                                                    ),
                                                  ),
                                                  Text(
                                                    '\$${product['revenue'].toStringAsFixed(2)}',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Color(0xff041511),
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
