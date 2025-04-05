import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'view_all_brands.dart';
import 'view_all_products.dart';

class ShopPage extends StatelessWidget {
  const ShopPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shop'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // View All Brands Option
            Card(
              child: ListTile(
                leading: const Icon(Icons.store, size: 40),
                title: const Text(
                  'View All Brands',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Browse through all available brands'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ViewAllBrands(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // View All Products Option
            Card(
              child: ListTile(
                leading: const Icon(Icons.shopping_bag, size: 40),
                title: const Text(
                  'View All Products',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Browse through all available products'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ViewAllProducts(),
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
