import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Image.asset(
                'assets/images/logo.jpeg',
                height: 120,
                width: 120,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Our Story',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Outfitly was founded in 2024 with a simple mission: to make fashion accessible to everyone. We believe that everyone deserves to look and feel their best, regardless of their budget or location.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            const Text(
              'Our Values',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildValueCard(
              Icons.thumb_up,
              'Quality',
              'We source only the highest quality products from trusted brands and manufacturers.',
            ),
            const SizedBox(height: 16),
            _buildValueCard(
              Icons.attach_money,
              'Affordability',
              'We work directly with brands to bring you the best prices without compromising on quality.',
            ),
            const SizedBox(height: 16),
            _buildValueCard(
              Icons.local_shipping,
              'Fast Delivery',
              'We ensure your orders are processed quickly and delivered to your doorstep in no time.',
            ),
            const SizedBox(height: 16),
            _buildValueCard(
              Icons.headset_mic,
              'Customer Service',
              'Our dedicated support team is always ready to help you with any questions or concerns.',
            ),
            const SizedBox(height: 32),
            const Text(
              'Our Team',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'We are a diverse team of fashion enthusiasts, tech experts, and customer service professionals working together to bring you the best shopping experience.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValueCard(IconData icon, String title, String description) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 40, color: Colors.blue),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 14),
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