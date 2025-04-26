import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'login_logic.dart';
import 'register_page.dart';
import 'home_page_user.dart';

class LoginLogic {
  static String? loggedInUserEmail; // Static variable to track logged-in user

  Future<void> handleLogin(
    String email,
    String password,
    BuildContext context,
  ) async {
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Check credentials
      final response =
          await Supabase.instance.client
              .from('User')
              .select("*")
              .eq('email', email)
              .maybeSingle();

      if (response == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No user found with that email'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final storedPassword = response['password'];

      if (storedPassword == password) {
        print("Login successful!");
        // Set the logged-in user
        loggedInUserEmail = email;

        // Navigate to next screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Incorrect password'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("Login error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Add a method to check if a user is logged in
  static bool isUserLoggedIn() {
    return loggedInUserEmail != null;
  }

  // Add a method to get the logged-in user's email
  static String? getLoggedInUserEmail() {
    return loggedInUserEmail;
  }

  // Add a method to log out
  static void logout() {
    loggedInUserEmail = null;
  }

  Future<void> handleregisteration(
    String first_name,
    String last_name,
    String user_name,
    String email,
    String password,
    String country,
    String city,
    String street,
    String postal_code,
  ) async // add other parameters
  {
    if (email.isEmpty || password.isEmpty || user_name.isEmpty) {
      print("Please fill in all fields.");
    } else {
      int postal = int.parse(postal_code);
      try {
        final response = await Supabase.instance.client
            .from('User') // Replace with your actual table name
            .insert({
              'user_name': user_name,
              'first_name': first_name,
              'last_name': last_name,
              'email': email,
              'password': password, // For real apps, hash the password!
              'country': country,
              'city': city,
              'street': street,
              'postal_code': postal,
            });

        print('User registered: $response');
        // Show success message or navigate to another screen
      } catch (e) {
        print('Error registering user: $e');
        // Show error message
      }
    }
  }

  Future<void> handleBrandAdminLogin(
    String email,
    String password,
    BuildContext context,
  ) async {
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final response =
          await Supabase.instance.client
              .from('brand_admin')
              .select()
              .eq('email', email)
              .single();

      if (response['password'] == password) {
        // Store the logged-in brand admin's email
        loggedInUserEmail = email;

        // TODO: Navigate to brand admin dashboard
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Brand admin login successful!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid password'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error during brand admin login: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
