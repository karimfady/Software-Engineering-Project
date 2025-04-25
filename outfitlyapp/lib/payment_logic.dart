import 'package:supabase_flutter/supabase_flutter.dart';
import 'payment_config.dart';

class PaymentLogic {
  static Future<bool> verifyCard({
    required String cardName,
    required String cardNumber,
    required String expiryDate,
    required String csv,
  }) async {
    try {
      // Verify card against the card_details table in payment database
      final response =
          await PaymentConfig.paymentClient
              .from('card_details')
              .select()
              .eq('card_number', cardNumber)
              .eq('card_name', cardName)
              .eq('expiry_date', expiryDate)
              .eq('csv', csv)
              .maybeSingle();

      return response != null;
    } catch (e) {
      print('Error verifying card: $e');
      return false;
    }
  }

  static Future<bool> saveCard({
    required String username,
    required String cardName,
    required String cardNumber,
    required String expiryDate,
    required String csv,
  }) async {
    try {
      // First verify the card exists in the payment database
      final isValid = await verifyCard(
        cardName: cardName,
        cardNumber: cardNumber,
        expiryDate: expiryDate,
        csv: csv,
      );

      if (!isValid) {
        return false;
      }

      // Save the card to the user's saved cards in the main database
      await Supabase.instance.client.from('saved_cards').insert({
        'customer_username': username,
        'card_name': cardName,
        'card_number': cardNumber,
        'expiry_date': expiryDate,
        'csv': csv,
      });

      return true;
    } catch (e) {
      print('Error saving card: $e');
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getSavedCards(
    String username,
  ) async {
    try {
      final response = await Supabase.instance.client
          .from('saved_cards')
          .select()
          .eq('customer_username', username);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting saved cards: $e');
      return [];
    }
  }
}
