import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentConfig {
  static late final SupabaseClient paymentClient;

  static Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    paymentClient = SupabaseClient(url, anonKey);
  }
}
