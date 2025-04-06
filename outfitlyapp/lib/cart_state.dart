import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_logic.dart';

class CartState extends ChangeNotifier {
  static final CartState _instance = CartState._internal();
  factory CartState() => _instance;
  CartState._internal();

  int _itemCount = 0;
  int get itemCount => _itemCount;

  Future<void> updateCartCount() async {
    if (!LoginLogic.isUserLoggedIn()) {
      _itemCount = 0;
      notifyListeners();
      return;
    }

    try {
      final userEmail = LoginLogic.getLoggedInUserEmail()!;

      // Get username from email
      final userResponse =
          await Supabase.instance.client
              .from('User')
              .select('user_name')
              .eq('email', userEmail)
              .single();

      if (userResponse == null) {
        _itemCount = 0;
        notifyListeners();
        return;
      }

      final username = userResponse['user_name'];

      // Get cart order
      final orderResponse =
          await Supabase.instance.client
              .from('Order')
              .select('order_id')
              .eq('customer_username', username)
              .eq('status', 'In Cart')
              .maybeSingle();

      if (orderResponse == null) {
        _itemCount = 0;
        notifyListeners();
        return;
      }

      // Get cart items count
      final response = await Supabase.instance.client
          .from('order_item')
          .select('item_id')
          .eq('status', 'In Cart')
          .eq('order_id', orderResponse['order_id']);

      _itemCount = response.length;
      notifyListeners();
    } catch (e) {
      print('Error updating cart count: $e');
    }
  }

  Future<void> addToCart({
    required String productId,
    required int quantity,
    required String size,
    required int pricePerItem,
  }) async {
    if (!LoginLogic.isUserLoggedIn()) {
      throw Exception('User must be logged in to add items to cart');
    }

    try {
      final userEmail = LoginLogic.getLoggedInUserEmail()!;

      // Get username from email
      final userResponse =
          await Supabase.instance.client
              .from('User')
              .select('user_name')
              .eq('email', userEmail)
              .single();

      if (userResponse == null) {
        return;
      }

      final username = userResponse['user_name'];

      // Check if user has an existing cart order
      var orderResponse =
          await Supabase.instance.client
              .from('Order')
              .select('order_id')
              .eq('customer_username', username)
              .eq('status', 'In Cart')
              .maybeSingle();

      String orderId;

      if (orderResponse == null) {
        // Create new order
        final newOrder =
            await Supabase.instance.client
                .from('Order')
                .insert({
                  'customer_username': username,
                  'status': 'In Cart',
                  'payment_status': 'Unpaid',
                  'total_price': 0,
                  'shipping_cost': 0,
                })
                .select()
                .single();

        orderId = newOrder['order_id'];
      } else {
        orderId = orderResponse['order_id'];
      }

      // Add item to cart
      await Supabase.instance.client.from('order_item').insert({
        'order_id': orderId,
        'product_id': productId,
        'quantity': quantity,
        'size': size,
        'price_per_item': pricePerItem,
        'status': 'In Cart',
      });

      // Update cart count
      await updateCartCount();
    } catch (e) {
      print('Error adding to cart: $e');
      rethrow;
    }
  }

  Future<void> removeFromCart(String itemId) async {
    try {
      await Supabase.instance.client
          .from('order_item')
          .delete()
          .eq('item_id', itemId);

      await updateCartCount();
    } catch (e) {
      print('Error removing from cart: $e');
      rethrow;
    }
  }

  Future<void> updateQuantity(String itemId, int newQuantity) async {
    try {
      await Supabase.instance.client
          .from('order_item')
          .update({'quantity': newQuantity})
          .eq('item_id', itemId);

      await updateCartCount();
    } catch (e) {
      print('Error updating quantity: $e');
      rethrow;
    }
  }
}
