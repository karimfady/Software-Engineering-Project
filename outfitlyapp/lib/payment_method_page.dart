import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'payment_page.dart';
import 'shopping_cart_user.dart';

class PaymentMethodPage extends StatelessWidget {
  final int totalPrice;
  final String orderId;

  const PaymentMethodPage({
    Key? key,
    required this.totalPrice,
    required this.orderId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Payment Method'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Choose your payment method',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Card(
              child: ListTile(
                leading: const Icon(Icons.credit_card, size: 40),
                title: const Text(
                  'Credit/Debit Card',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Pay securely with your card'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => PaymentPage(
                            totalPrice: totalPrice,
                            orderId: orderId,
                          ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.local_shipping, size: 40),
                title: const Text(
                  'Pay on Delivery',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Pay when you receive your order'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () async {
                  try {
                    // Update order status to indicate payment on delivery
                    await Supabase.instance.client
                        .from('Order')
                        .update({'status': 'Pending'})
                        .eq('order_id', orderId);

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Order placed successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/home',
                        (route) => false,
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: ${e.toString()}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
              ),
            ),
            const Spacer(),
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
                        'Total Amount:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '\$${(totalPrice / 100).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
