import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'login_logic.dart';
import 'register_page.dart';
import 'home_page_user.dart';

class LoginLogic {
  Future<void> handleLogin(
    String email,
    String password,
    BuildContext context,
  ) async {
    // Here you can connect to an API, validate fields, etc.
    if (email.isEmpty || password.isEmpty) {
      print("Please fill in all fields.");
    } else {
      print("in loginhandle");
      // send query with name and password to the database if the username
      //doesnt exist print user doesnt exist if user exist but password is
      //incorrect print passwrod is incorrect

      try {
        final response =
            await Supabase.instance.client
                .from('User') // 👈 use your exact table name
                .select('password')
                .eq('email', email)
                .maybeSingle(); // fetches at most 1 row, returns null if none

        if (response == null) {
          print("No user found with that email.");
          // Optionally show error to user
          return;
        }

        final storedPassword = response['password'];

        if (storedPassword == password) {
          print("Login successful!");
          // Navigate to next screen, save session, etc.

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        } else {
          print("Incorrect password.");
        }
      } catch (e) {
        print("Login error: $e");
      }
    }
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
}
