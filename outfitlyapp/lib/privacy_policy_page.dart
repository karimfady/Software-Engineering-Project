import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({Key? key}) : super(key: key);

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
          "Privacy Policy",
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
            Text(
              "Last Updated: March 15, 2024",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xff041511).withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: "Introduction",
              content:
                  "At Outfitly, we take your privacy seriously. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application.",
            ),
            _buildSection(
              title: "Information We Collect",
              content:
                  "We collect information that you provide directly to us, including your name, email address, phone number, and shipping address. We also collect information about your device and how you use our app.",
            ),
            _buildSection(
              title: "How We Use Your Information",
              content:
                  "We use the information we collect to provide, maintain, and improve our services, to process your transactions, and to communicate with you about products, services, and promotional offers.",
            ),
            _buildSection(
              title: "Information Sharing",
              content:
                  "We do not sell or rent your personal information to third parties. We may share your information with service providers who assist us in operating our app and conducting our business.",
            ),
            _buildSection(
              title: "Data Security",
              content:
                  "We implement appropriate technical and organizational measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction.",
            ),
            _buildSection(
              title: "Your Rights",
              content:
                  "You have the right to access, correct, or delete your personal information. You can also object to the processing of your data or request data portability.",
            ),
            _buildSection(
              title: "Cookies and Tracking",
              content:
                  "We use cookies and similar tracking technologies to track activity on our app and hold certain information to improve your experience.",
            ),
            _buildSection(
              title: "Children's Privacy",
              content:
                  "Our app is not intended for children under 13 years of age. We do not knowingly collect personal information from children under 13.",
            ),
            _buildSection(
              title: "Changes to This Policy",
              content:
                  "We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page.",
            ),
            _buildSection(
              title: "Contact Us",
              content:
                  "If you have any questions about this Privacy Policy, please contact us at privacy@outfitly.com.",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
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
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Color(0xff041511),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
