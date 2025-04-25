import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_logic.dart';
import 'payment_logic.dart';
import 'shopping_cart_user.dart';

class PaymentPage extends StatefulWidget {
  final int totalPrice;
  final String orderId;

  const PaymentPage({Key? key, required this.totalPrice, required this.orderId})
    : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _formKey = GlobalKey<FormState>();
  final _cardNameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _csvController = TextEditingController();
  bool _saveCard = false;
  bool _isLoading = false;
  List<Map<String, dynamic>> _savedCards = [];
  String? _selectedSavedCard;

  @override
  void initState() {
    super.initState();
    _loadSavedCards();
  }

  @override
  void dispose() {
    _cardNameController.dispose();
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _csvController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedCards() async {
    if (!LoginLogic.isUserLoggedIn()) return;

    try {
      final userEmail = LoginLogic.getLoggedInUserEmail()!;
      final userResponse =
          await Supabase.instance.client
              .from('User')
              .select('user_name')
              .eq('email', userEmail)
              .single();

      if (userResponse != null) {
        final username = userResponse['user_name'];
        final cards = await PaymentLogic.getSavedCards(username);
        if (mounted) {
          setState(() {
            _savedCards = cards;
          });
        }
      }
    } catch (e) {
      print('Error loading saved cards: $e');
    }
  }

  Future<void> _processPayment() async {
    if (_selectedSavedCard == null && !_formKey.currentState!.validate())
      return;

    setState(() => _isLoading = true);

    try {
      final userEmail = LoginLogic.getLoggedInUserEmail()!;
      final userResponse =
          await Supabase.instance.client
              .from('User')
              .select('user_name')
              .eq('email', userEmail)
              .single();

      if (userResponse == null) {
        throw Exception('User not found');
      }

      final username = userResponse['user_name'];
      bool paymentSuccessful;

      if (_selectedSavedCard != null) {
        final card = _savedCards.firstWhere(
          (card) => card['id'] == _selectedSavedCard,
        );
        paymentSuccessful = await PaymentLogic.verifyCard(
          cardName: card['card_name'],
          cardNumber: card['card_number'],
          expiryDate: card['expiry_date'],
          csv: card['csv'],
        );
      } else {
        paymentSuccessful = await PaymentLogic.verifyCard(
          cardName: _cardNameController.text,
          cardNumber: _cardNumberController.text,
          expiryDate: _expiryDateController.text,
          csv: _csvController.text,
        );

        if (paymentSuccessful && _saveCard) {
          // Check if card is already saved
          final existingCards = await PaymentLogic.getSavedCards(username);
          final isCardAlreadySaved = existingCards.any(
            (card) =>
                card['card_number'] == _cardNumberController.text &&
                card['expiry_date'] == _expiryDateController.text &&
                card['csv'] == _csvController.text,
          );

          if (!isCardAlreadySaved) {
            await PaymentLogic.saveCard(
              username: username,
              cardName: _cardNameController.text,
              cardNumber: _cardNumberController.text,
              expiryDate: _expiryDateController.text,
              csv: _csvController.text,
            );
          }
        }
      }

      if (paymentSuccessful) {
        // Update order status to completed
        await Supabase.instance.client
            .from('Order')
            .update({'status': 'Completed'})
            .eq('order_id', widget.orderId);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment successful!'),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate to home page instead of cart
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home', // Make sure this route is defined in your main.dart
          (route) => false,
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment failed. Please check your card details.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_savedCards.isNotEmpty) ...[
                const Text(
                  'Saved Cards',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedSavedCard,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Select a saved card',
                  ),
                  items:
                      _savedCards.map<DropdownMenuItem<String>>((card) {
                        return DropdownMenuItem<String>(
                          value: card['id'].toString(),
                          child: Text(
                            '${card['card_name']} - ****${card['card_number'].substring(card['card_number'].length - 4)}',
                          ),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSavedCard = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                const Center(child: Text('OR')),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: _cardNameController,
                decoration: const InputDecoration(
                  labelText: 'Cardholder Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter cardholder name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cardNumberController,
                decoration: const InputDecoration(
                  labelText: 'Card Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter card number';
                  }
                  if (value.length != 16) {
                    return 'Card number must be 16 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _expiryDateController,
                      decoration: const InputDecoration(
                        labelText: 'Expiry Date (MM/YY)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) {
                          return 'Format: MM/YY';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _csvController,
                      decoration: const InputDecoration(
                        labelText: 'CSV',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (value.length != 3) {
                          return 'Must be 3 digits';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Save this card for future use'),
                value: _saveCard,
                onChanged: (value) {
                  setState(() {
                    _saveCard = value ?? false;
                  });
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child:
                    _isLoading
                        ? const CircularProgressIndicator()
                        : Text(
                          'Pay \$${(widget.totalPrice / 100).toStringAsFixed(2)}',
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
