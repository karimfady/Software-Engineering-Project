import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xff041511)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "About Us",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xff041511),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo
            Center(
              child: Text(
                "Outfitly",
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff041511),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // About Us Content
            Text(
              "Welcome to Outfitly",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xff041511),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Outfitly is your premier destination for men's fashion, offering a curated selection of high-quality clothing and accessories. Our mission is to provide a seamless shopping experience with exceptional customer service.",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Color(0xff041511),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Our Story",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xff041511),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Founded with a passion for men's fashion, Outfitly has grown from a small boutique to a leading online destination for men's clothing. We work directly with brands to bring you the latest trends and timeless classics.",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Color(0xff041511),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Our Values",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xff041511),
              ),
            ),
            const SizedBox(height: 16),
            _buildValueItem(
              icon: Icons.verified,
              title: "Quality",
              description:
                  "We carefully select each item to ensure the highest quality for our customers.",
            ),
            _buildValueItem(
              icon: Icons.support_agent,
              title: "Customer Service",
              description:
                  "Our dedicated team is here to provide exceptional support and assistance.",
            ),
            _buildValueItem(
              icon: Icons.eco,
              title: "Sustainability",
              description:
                  "We are committed to sustainable practices and ethical manufacturing.",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValueItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Color(0xff041511), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff041511),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color(0xff041511),
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
