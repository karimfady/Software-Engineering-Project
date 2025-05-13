import 'package:flutter/material.dart';
import 'login_logic.dart';

class RegisterPage extends StatelessWidget {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController streetController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  final LoginLogic loginLogic = LoginLogic();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xff041511)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Register',
          style: TextStyle(
            color: Color(0xff041511),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
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
            // Registration form
            buildTextField('Username', usernameController),
            SizedBox(height: 20),
            buildTextField(
              'E-mail',
              emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),
            buildTextField('Password', passwordController, obscureText: true),
            SizedBox(height: 20),
            buildTextField('Country', countryController),
            SizedBox(height: 20),
            buildTextField(
              'Phone',
              phoneController,
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 20),
            buildTextField('Street', streetController),
            SizedBox(height: 20),
            buildTextField(
              'Postal Code',
              postalCodeController,
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            buildTextField('City', cityController),
            SizedBox(height: 30),
            // Register button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (passwordController.text ==
                      confirmPasswordController.text) {
                    loginLogic.handleregisteration(
                      firstNameController.text.trim(),
                      lastNameController.text.trim(),
                      usernameController.text.trim(),
                      emailController.text.trim(),
                      passwordController.text,
                      countryController.text.trim(),
                      cityController.text.trim(),
                      streetController.text.trim(),
                      postalCodeController.text.trim(),
                    );
                  } else {
                    print('Make sure the passwords are compatible');
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
                child: Text('Register'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(
    String label,
    TextEditingController controller, {
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 17, fontWeight: FontWeight.w400),
        border: OutlineInputBorder(),
      ),
    );
  }
}
