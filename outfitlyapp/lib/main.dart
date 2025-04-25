import 'package:flutter/material.dart';
import 'package:outfitlyapp/login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'wishlist_page_user.dart';
import 'shopping_cart_user.dart';
import 'orders_page.dart';
import 'profile_page.dart';
import 'payment_config.dart';
import 'home_page_user.dart';

Future<void> main() async {
  // Initialize main database
  await Supabase.initialize(
    url: 'https://rrnoyixhigxoaykoxhgi.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJybm95aXhoaWd4b2F5a294aGdpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDM3Njk3MjUsImV4cCI6MjA1OTM0NTcyNX0.8drvbmZMq4jkpcQZmeKc5ps1jo_rPREpQOThAOTRtnU',
  );

  // Initialize payment database
  await PaymentConfig.initialize(
    url: 'https://ayrnfhobztwpiuknfhht.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF5cm5maG9ienR3cGl1a25maGh0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDU2MDIwMzAsImV4cCI6MjA2MTE3ODAzMH0.r8CgwbkzLwuWUZX8wGbFEbGRkJlJHjyuUgDOvwXA5Yw',
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: LoginPage(),
      routes: {
        '/wishlist': (context) => const WishlistPage(),
        '/profile': (context) => const ProfilePage(),
        '/cart': (context) => const CartPage(),
        '/orders': (context) => const OrdersPage(),
        '/home': (context) => const HomePage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
