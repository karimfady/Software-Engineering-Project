import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_logic.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({Key? key}) : super(key: key);

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  List<Map<String, dynamic>> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  @override
  void dispose() {
    // Clean up any resources here
    super.dispose();
  }

  Future<void> _loadOrders() async {
    if (!LoginLogic.isUserLoggedIn()) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      return;
    }

    try {
      final userEmail = LoginLogic.getLoggedInUserEmail()!;

      // Get username from email
      final userResponse = await Supabase.instance.client
          .from('User')
          .select('user_name')
          .eq('email', userEmail)
          .single();

      if (userResponse == null) {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
        return;
      }

      final username = userResponse['user_name'];

      // First, let's check what columns are available in the Order table
      final tableInfo = await Supabase.instance.client
          .from('Order')
          .select('*')
          .limit(1);

      print('Available columns in Order table: ${tableInfo[0].keys}');

      // Get orders with order items and product details
      final response = await Supabase.instance.client
          .from('Order')
          .select('''
            order_id,
            status,
            date_created,
            country,
            city,
            street,
            postal_code,
            phone_number,
            order_items:order_item (
              item_id,
              quantity,
              price_per_item,
              size,
              product:Product (
                id,
                product_name,
                picture,
                brand_name
              )
            )
          ''')
          .eq('customer_username', username)
          .order('date_created', ascending: false);

      if (mounted) {
        setState(() {
          orders = List<Map<String, dynamic>>.from(response);
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading orders: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  String _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'orange';
      case 'processing':
        return 'blue';
      case 'shipped':
        return 'purple';
      case 'delivered':
        return 'green';
      case 'cancelled':
        return 'red';
      default:
        return 'grey';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!LoginLogic.isUserLoggedIn()) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Orders'), centerTitle: true),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Please login to view your orders'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login').then((_) {
                    if (LoginLogic.isUserLoggedIn()) {
                      _loadOrders();
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
      appBar: AppBar(title: const Text('My Orders'), centerTitle: true),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? const Center(child: Text('No orders found'))
              : RefreshIndicator(
                  onRefresh: _loadOrders,
                  child: ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      final orderItems = order['order_items'] as List<dynamic>;
                      final totalPrice = orderItems.fold(0, (sum, item) {
                        return sum + (item['price_per_item'] as int) * (item['quantity'] as int);
                      });

                      return Card(
                        margin: const EdgeInsets.all(8.0),
                        child: ExpansionTile(
                          title: Text('Order #${order['order_id']}'),
                          subtitle: Text(
                            '${orderItems.length} items • \$${(totalPrice / 100).toStringAsFixed(2)}',
                          ),
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Image.network(
                              orderItems[0]['product']['picture'],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.image);
                              },
                            ),
                          ),
                          trailing: Chip(
                            label: Text(
                              order['status'],
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Color(
                              _getStatusColor(order['status']).hashCode,
                            ).withOpacity(0.7),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Order Details',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text('Date: ${order['date_created']}'),
                                  Text('Status: ${order['status']}'),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Shipping Address',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text('${order['street']}'),
                                  Text('${order['city']}, ${order['country']}'),
                                  Text('Postal Code: ${order['postal_code']}'),
                                  Text('Phone: ${order['phone_number']}'),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Items',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ...orderItems.map((item) {
                                    final product = item['product'];
                                    final priceInDollars = (item['price_per_item'] as int) / 100;
                                    final totalItemPrice = priceInDollars * (item['quantity'] as int);

                                    return ListTile(
                                      leading: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Image.network(
                                          product['picture'],
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return const Icon(Icons.image);
                                          },
                                        ),
                                      ),
                                      title: Text(product['product_name']),
                                      subtitle: Text('Size: ${item['size']}'),
                                      trailing: Text(
                                        '\$${totalItemPrice.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
} 