import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
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
            const Text(
              'Privacy Policy',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Last updated: March 2024',
              style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 24),
            _buildSection(
              '1. Information We Collect',
              'We collect information that you provide directly to us, including:\n\n'
                  '• Name and contact information\n'
                  '• Email address\n'
                  '• Shipping and billing address\n'
                  '• Payment information\n'
                  '• Order history\n'
                  '• Preferences and settings',
            ),
            _buildSection(
              '2. How We Use Your Information',
              'We use the information we collect to:\n\n'
                  '• Process and fulfill your orders\n'
                  '• Communicate with you about your orders\n'
                  '• Send you marketing communications (with your consent)\n'
                  '• Improve our services and website\n'
                  '• Prevent fraud and ensure security',
            ),
            _buildSection(
              '3. Information Sharing',
              'We do not sell your personal information. We may share your information with:\n\n'
                  '• Service providers who assist in our operations\n'
                  '• Payment processors\n'
                  '• Shipping partners\n'
                  '• Legal authorities when required by law',
            ),
            _buildSection(
              '4. Your Rights',
              'You have the right to:\n\n'
                  '• Access your personal information\n'
                  '• Correct inaccurate information\n'
                  '• Request deletion of your information\n'
                  '• Opt-out of marketing communications\n'
                  '• Withdraw consent for data processing',
            ),
            _buildSection(
              '5. Data Security',
              'We implement appropriate security measures to protect your personal information. However, no method of transmission over the internet is 100% secure.',
            ),
            _buildSection(
              '6. Cookies and Tracking',
              'We use cookies and similar tracking technologies to improve your browsing experience and analyze website traffic.',
            ),
            _buildSection(
              '7. Children\'s Privacy',
              'Our services are not intended for children under 13. We do not knowingly collect personal information from children under 13.',
            ),
            _buildSection(
              '8. Changes to This Policy',
              'We may update this privacy policy from time to time. We will notify you of any changes by posting the new policy on this page.',
            ),
            const SizedBox(height: 24),
            const Text(
              'Contact Us',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'If you have any questions about this Privacy Policy, please contact us at:\n\n'
              'Email: privacy@outfitly.com\n'
              'Phone: +1 (555) 123-4567',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(content, style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}
