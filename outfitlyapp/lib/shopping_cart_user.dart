import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_logic.dart';
import 'cart_state.dart';
import 'view_product_page_user.dart';
import 'checkout_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Map<String, dynamic>> cartItems = [];
  bool isLoading = true;
  int totalPrice = 0;

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  Future<void> _loadCartItems() async {
    if (!LoginLogic.isUserLoggedIn()) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final userEmail = LoginLogic.getLoggedInUserEmail()!;

      // Get username from email
      final userResponse =
          await Supabase.instance.client
              .from('User')
              .select('user_name')
              .eq('email', userEmail)
              .single();

      if (userResponse == null) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      final username = userResponse['user_name'];

      // Get cart order
      final orderResponse =
          await Supabase.instance.client
              .from('Order')
              .select('order_id')
              .eq('customer_username', username)
              .eq('status', 'In Cart')
              .maybeSingle();

      if (orderResponse == null) {
        setState(() {
          cartItems = [];
          _calculateTotal();
          isLoading = false;
        });
        return;
      }

      // Get cart items with product details
      final response = await Supabase.instance.client
          .from('order_item')
          .select('''
            item_id,
            order_id,
            quantity,
            price_per_item,
            size,
            product:Product (
              id,
              product_name,
              picture,
              brand_name
            )
          ''')
          .eq('status', 'In Cart')
          .eq('order_id', orderResponse['order_id']);

      if (mounted) {
        setState(() {
          cartItems = List<Map<String, dynamic>>.from(response);
          _calculateTotal();
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading cart items: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _calculateTotal() {
    totalPrice = cartItems.fold(0, (sum, item) {
      return sum + (item['price_per_item'] as int) * (item['quantity'] as int);
    });
  }

  Future<void> _updateQuantity(String itemId, int newQuantity) async {
    try {
      await CartState().updateQuantity(itemId, newQuantity);
      await _loadCartItems(); // Reload to get updated data
    } catch (e) {
      print('Error updating quantity: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  Future<void> _removeItem(String itemId) async {
    try {
      await CartState().removeFromCart(itemId);
      await _loadCartItems(); // Reload to get updated data
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Item removed from cart')));
    } catch (e) {
      print('Error removing item: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!LoginLogic.isUserLoggedIn()) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cart'), centerTitle: true),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Please login to view your cart'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login').then((_) {
                    if (LoginLogic.isUserLoggedIn()) {
                      _loadCartItems();
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
      appBar: AppBar(title: const Text('Cart'), centerTitle: true),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : cartItems.isEmpty
              ? const Center(child: Text('Your cart is empty'))
              : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        final item = cartItems[index];
                        final product = item['product'] as Map<String, dynamic>;
                        final priceInDollars =
                            (item['price_per_item'] as int) / 100;
                        final totalItemPrice =
                            priceInDollars * (item['quantity'] as int);

                        return Card(
                          margin: const EdgeInsets.all(8.0),
                          child: ListTile(
                            leading: Container(
                              width: 60,
                              height: 60,
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
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Size: ${item['size']}'),
                                Text('\$${totalItemPrice.toStringAsFixed(2)}'),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: () {
                                    final newQuantity =
                                        (item['quantity'] as int) - 1;
                                    if (newQuantity > 0) {
                                      _updateQuantity(
                                        item['item_id'],
                                        newQuantity,
                                      );
                                    } else {
                                      _removeItem(item['item_id']);
                                    }
                                  },
                                ),
                                Text(item['quantity'].toString()),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () {
                                    _updateQuantity(
                                      item['item_id'],
                                      (item['quantity'] as int) + 1,
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _removeItem(item['item_id']),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, -1),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total:',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '\$${(totalPrice / 100).toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (cartItems.isEmpty) return;

                              // Get the order ID from the first item
                              final orderId = cartItems[0]['order_id'];

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => CheckoutPage(
                                        totalPrice: totalPrice,
                                        orderId: orderId,
                                      ),
                                ),
                              ).then((_) {
                                _loadCartItems(); // Reload cart after checkout
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text(
                              'Checkout',
                              style: TextStyle(fontSize: 16),
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
