import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_logic.dart';

class WishlistState extends ChangeNotifier {
  static final WishlistState _instance = WishlistState._internal();
  factory WishlistState() => _instance;
  WishlistState._internal();

  int _itemCount = 0;
  int get itemCount => _itemCount;

  Future<void> updateWishlistCount() async {
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

      // Get wishlist count using count() function
      final response = await Supabase.instance.client
          .from('wishlist')
          .select()
          .eq('customer_username', username);

      _itemCount = response.length;
      notifyListeners();
    } catch (e) {
      print('Error updating wishlist count: $e');
    }
  }
}
