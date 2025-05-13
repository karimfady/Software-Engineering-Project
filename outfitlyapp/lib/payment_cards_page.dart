import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_logic.dart';
import 'payment_logic.dart';

class PaymentCardsPage extends StatefulWidget {
  const PaymentCardsPage({Key? key}) : super(key: key);

  @override
  State<PaymentCardsPage> createState() => _PaymentCardsPageState();
}

class _PaymentCardsPageState extends State<PaymentCardsPage> {
  List<Map<String, dynamic>> savedCards = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedCards();
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

      final username = userResponse['user_name'];

      final response = await Supabase.instance.client
          .from('saved_cards')
          .select('*')
          .eq('customer_username', username);

      setState(() {
        savedCards = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      print('Error loading cards: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _addNewCard() async {
    // Show dialog to add new card
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AddCardDialog(),
    );

    if (result != null) {
      try {
        final userEmail = LoginLogic.getLoggedInUserEmail()!;
        final userResponse =
            await Supabase.instance.client
                .from('User')
                .select('user_name')
                .eq('email', userEmail)
                .single();

        final username = userResponse['user_name'];

        // Check if card exists in bank system using PaymentLogic
        final isValid = await PaymentLogic.verifyCard(
          cardName: result['cardHolder'] ?? '',
          cardNumber: result['cardNumber'] ?? '',
          expiryDate: result['expiryDate'] ?? '',
          csv: result['cvv'] ?? '',
        );

        if (!isValid) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Card not found in bank system'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        // Add card to saved_cards if it exists in bank system
        await PaymentLogic.saveCard(
          username: username,
          cardName: result['cardHolder'] ?? '',
          cardNumber: result['cardNumber'] ?? '',
          expiryDate: result['expiryDate'] ?? '',
          csv: result['cvv'] ?? '',
        );

        await _loadSavedCards();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Card added successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error adding card: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteCard(String cardId) async {
    try {
      await Supabase.instance.client
          .from('saved_cards')
          .delete()
          .eq('card_id', cardId);

      await _loadSavedCards();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Card deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting card: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Payment Cards',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xff041511),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Color(0xff041511)),
            onPressed: _addNewCard,
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : savedCards.isEmpty
              ? Center(
                child: Text(
                  'No saved cards',
                  style: TextStyle(fontSize: 16, color: Color(0xff041511)),
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: savedCards.length,
                itemBuilder: (context, index) {
                  final card = savedCards[index];
                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: Color(0xff041511).withOpacity(0.1),
                      ),
                    ),
                    child: ListTile(
                      leading: Icon(
                        Icons.credit_card,
                        color: Color(0xff041511),
                      ),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '**** **** **** ${card['card_number'].toString().substring(card['card_number'].toString().length - 4)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xff041511),
                            ),
                          ),
                          if (card['card_name'] != null)
                            Text(
                              card['card_name'],
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xff041511).withOpacity(0.7),
                              ),
                            ),
                        ],
                      ),
                      subtitle: Text(
                        'Expires: ${card['expiry_date']}',
                        style: TextStyle(
                          color: Color(0xff041511).withOpacity(0.7),
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Color(0xff041511)),
                        onPressed: () => _deleteCard(card['card_id']),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}

class AddCardDialog extends StatefulWidget {
  const AddCardDialog({Key? key}) : super(key: key);

  @override
  State<AddCardDialog> createState() => _AddCardDialogState();
}

class _AddCardDialogState extends State<AddCardDialog> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Add New Card',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xff041511),
        ),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _cardNumberController,
              decoration: InputDecoration(
                labelText: 'Card Number',
                labelStyle: TextStyle(color: Color(0xff041511)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xff041511).withOpacity(0.1),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xff041511)),
                ),
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
            TextFormField(
              controller: _cardHolderController,
              decoration: InputDecoration(
                labelText: 'Card Holder Name',
                labelStyle: TextStyle(color: Color(0xff041511)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xff041511).withOpacity(0.1),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xff041511)),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter card holder name';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _expiryDateController,
              decoration: InputDecoration(
                labelText: 'Expiry Date (MM/YY)',
                labelStyle: TextStyle(color: Color(0xff041511)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xff041511).withOpacity(0.1),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xff041511)),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter expiry date';
                }
                if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) {
                  return 'Please enter in MM/YY format';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _cvvController,
              decoration: InputDecoration(
                labelText: 'CVV',
                labelStyle: TextStyle(color: Color(0xff041511)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xff041511).withOpacity(0.1),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xff041511)),
                ),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter CVV';
                }
                if (value.length != 3) {
                  return 'CVV must be 3 digits';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, {
                'cardNumber': _cardNumberController.text,
                'cardHolder': _cardHolderController.text,
                'expiryDate': _expiryDateController.text,
                'cvv': _cvvController.text,
              });
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
