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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Logo
            Center(
              child: Text(
                "Outfitly",
                style: TextStyle(fontSize: 48, fontWeight: FontWeight.w700),
              ),
            ),
            SizedBox(height: 20),
            // Divider
            Container(
              width: 189.41,
              height: 16.47,
              child: Image.asset(
                "assets/images/Rectangle 9.png",
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 40),
            // Login form
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Username',
                labelStyle: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                ),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                ),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 30),
            // Login button
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
                  textStyle: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                  backgroundColor: Color(0xff041511),
                  foregroundColor: Colors.white,
                ),
                child: Text('Login'),
              ),
            ),
            SizedBox(height: 12),
            // Register options
            _accountType == 'customer'
                ? TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterPage()),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Color(0xff041511),
                  ),
                  child: Text(
                    'Register',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                  ),
                )
                : TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BrandAdminRegisterPage(),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Color(0xff041511),
                  ),
                  child: Text(
                    'Register as Brand Owner',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                  ),
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
        selectedItemColor: Color(0xff041511),
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
