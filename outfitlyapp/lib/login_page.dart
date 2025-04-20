import 'package:flutter/material.dart';
import 'login_logic.dart';
import 'register_page.dart';
import 'home_page_user.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final LoginLogic loginLogic = LoginLogic();
  String _accountType = 'customer'; // Default to customer account

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            Center(
              child: Image.asset(
                'assets/images/logo.jpeg',
                height: 120,
                width: 120,
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            SizedBox(height: 20),

            // Password Field
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            SizedBox(height: 20),

            // Account Type Selection
            Card(
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: const Text('Customer Account'),
                    value: 'customer',
                    groupValue: _accountType,
                    onChanged: (String? value) {
                      setState(() {
                        _accountType = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Brand Admin Account'),
                    value: 'brand_admin',
                    groupValue: _accountType,
                    onChanged: (String? value) {
                      setState(() {
                        _accountType = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),

            // Login Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_accountType == 'customer') {
                    loginLogic.handleLogin(
                      emailController.text.trim().toLowerCase(),
                      passwordController.text,
                      context,
                    );
                  } else {
                    loginLogic.handleBrandAdminLogin(
                      emailController.text.trim().toLowerCase(),
                      passwordController.text,
                      context,
                    );
                  }
                },
                child: Text('Login'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  textStyle: TextStyle(fontSize: 16),
                ),
              ),
            ),
            SizedBox(height: 12),

            // Register Button
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterPage()),
                );
              },
              child: Text('Don\'t have an account? Register'),
            ),
          ],
        ),
      ),
    );
  }
}
