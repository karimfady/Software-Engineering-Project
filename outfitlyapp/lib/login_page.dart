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
            // Status bar time and icons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "12:30",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Row(
                  children: [
                    // Signal strength icon
                    Container(
                      width: 18,
                      height: 12,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                          4,
                          (index) => Container(
                            width: 3.17,
                            height: 4.5 + (index * 2.5),
                            color: Color(0xff041511),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    // WiFi icon
                    Container(
                      width: 16,
                      height: 12,
                      child: Stack(
                        children: [
                          Container(
                            width: 16,
                            height: 5.19,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Color(0xff041511),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 2.5,
                            child: Container(
                              width: 10.42,
                              height: 3.97,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Color(0xff041511),
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8),
                    // Battery icon
                    Container(
                      width: 24,
                      height: 12,
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xff041511), width: 1),
                        borderRadius: BorderRadius.circular(2.66),
                      ),
                      child: Stack(
                        children: [
                          Container(
                            width: 17.75,
                            height: 7.76,
                            decoration: BoxDecoration(
                              color: Color(0xff041511),
                              borderRadius: BorderRadius.circular(1.33),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 40),
            // Welcome text
            Column(
              children: [
                Text(
                  "Shop from your favourite store",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 8),
                Text(
                  "Exclusive everyday men's outfit. Buy two to get one for 50% off.",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            SizedBox(height: 40),
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
