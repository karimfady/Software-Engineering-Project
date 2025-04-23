import 'package:flutter/material.dart';
import 'shop_page_user.dart';
import 'shopping_cart_user.dart';
import 'wishlist_page_user.dart';
import 'menu_page_user.dart';
import 'view_brand_page_user.dart';
import 'view_product_page_user.dart';
import 'view_all_brands.dart';
import 'view_all_products.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'search_page.dart';
import 'outfit_generator.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class OutfitGeneratorPage extends StatefulWidget {
  const OutfitGeneratorPage({Key? key}) : super(key: key);

  @override
  State<OutfitGeneratorPage> createState() => _OutfitGeneratorPageState();
}

class _OutfitGeneratorPageState extends State<OutfitGeneratorPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose(); // Always dispose your controllers!
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final reservedHeight = 186;
    final availableHeight = screenHeight - reservedHeight;
    final boxSize = (availableHeight - 40) / 3;

    return Scaffold(
      appBar: AppBar(title: const Text('Outfit Generator'), centerTitle: true),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(3, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Center(
                  child: Container(
                    width: boxSize,
                    height: boxSize,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: const Center(
                      child: Text(
                        'Product Slot',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Describe your style or occasion...',
                      prefixIcon: const Icon(Icons.edit),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    parse_by_API(_controller.text);
                    print('User input: $_controller.text');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Async because it will likely fetch from network
  Future<void> parse_by_API(String input) async {
    const apiKey =
        'AIzaSyCDwmSXTT4ARfAOGUaOyBt4-gypnKOQWIw'; // 🔑 Your Gemini key
    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1/models/gemini-1.5-pro:generateContent?key=$apiKey',
    );

    final prompt = '''
You are a PostgreSQL query assistant. Given a user's request, generate a valid SQL WHERE clause using this schema:

Product(id UUID, size TEXT, color VARCHAR, price INT8, brand_name TEXT, Tags TEXT[], picture TEXT, product_name TEXT, category TEXT, type_of_clothing TEXT, stock INT)

Only return the WHERE clause. Do not explain it. Donot include the WHERE keyword in your response

User input: "$input"
''';

    final headers = {'Content-Type': 'application/json'};

    final body = jsonEncode({
      "contents": [
        {
          "parts": [
            {"text": prompt},
          ],
        },
      ],
    });

    try {
      final response = await http.post(uri, headers: headers, body: body);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        print('Full Gemini response:\n$json');

        final candidates = json['candidates'];
        if (candidates != null &&
            candidates.isNotEmpty &&
            candidates[0]['content'] != null &&
            candidates[0]['content']['parts'] != null &&
            candidates[0]['content']['parts'].isNotEmpty) {
          final whereClause = candidates[0]['content']['parts'][0]['text'];
          print('Gemini WHERE clause:\n$whereClause');

          final product = await fetchProductByDeepseekQuery(whereClause.trim());
          if (product != null) {
            print('Product matched: ${product.productName}');
          } else {
            print('No product matched.');
          }
        } else {
          print('Gemini response structure unexpected or empty.');
        }
      } else {
        print('Gemini API failed: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('Error calling DeepSeek API: $e');
    }
  }

  Future<Product?> fetchProductByDeepseekQuery(String query) async {
    final supabase = Supabase.instance.client;
    try {
      print('Running PostgreSQL WHERE clause:\n$query');

      final response = await supabase.rpc(
        'fetch_product_by_deepseek',
        params: {'query': query},
      );

      if (response != null && response is List && response.isNotEmpty) {
        final Map<String, dynamic> row = response.first;
        final product = Product.fromJson(row);
        print('Product found: ${product.productName}');
        return product;
      } else {
        print('No product matched the query.');
        return null;
      }
    } catch (e, stackTrace) {
      print('Error executing DeepSeek query: $e');
      print(stackTrace);
      return null;
    }
  }
}
