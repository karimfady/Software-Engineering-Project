import 'package:flutter/material.dart';
import 'login_logic.dart';
import 'register_page.dart';
import 'brand_admin_register_page.dart';
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
  String _accountType = 'customer';

  // Define theme colors
  final customerTheme = {
    'primary': Colors.blue,
    'background': Colors.grey[100],
    'buttonColor': Colors.blue,
    'iconColor': Colors.blue,
  };

  final brandTheme = {
    'primary': Colors.deepPurple,
    'background': Colors.grey[50],
    'buttonColor': Colors.deepPurple,
    'iconColor': Colors.deepPurple,
  };

  // Get current theme based on account type
  Map<String, dynamic> get currentTheme =>
      _accountType == 'customer' ? customerTheme : brandTheme;

  void _showRegistrationOptions() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Choose Account Type'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Customer'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterPage()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.business),
                  title: const Text('Brand Admin'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BrandAdminRegisterPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: currentTheme['background'],
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
                prefixIcon: Icon(Icons.email, color: currentTheme['iconColor']),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: currentTheme['primary']),
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock, color: currentTheme['iconColor']),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: currentTheme['primary']),
                ),
              ),
            ),
            SizedBox(height: 30),
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
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  textStyle: TextStyle(fontSize: 16),
                  backgroundColor: currentTheme['buttonColor'],
                  foregroundColor:
                      Colors.white, // Added this line to make text white
                ),
                child: Text('Login'),
              ),
            ),
            SizedBox(height: 12),
            TextButton(
              onPressed: _showRegistrationOptions,
              style: TextButton.styleFrom(
                foregroundColor: currentTheme['primary'],
              ),
              child: Text('Don\'t have an account? Register'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _accountType == 'customer' ? 0 : 1,
        onTap: (index) {
          setState(() {
            _accountType = index == 0 ? 'customer' : 'brand_admin';
          });
        },
        selectedItemColor: currentTheme['primary'],
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Customer'),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Brand Owner',
          ),
        ],
      ),
    );
  }
}
