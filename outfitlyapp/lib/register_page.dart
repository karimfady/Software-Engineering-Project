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

  final LoginLogic loginLogic = LoginLogic();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 40.0),
        child: Column(
          children: [
            buildTextField('First Name', Icons.person, firstNameController),
            SizedBox(height: 20),
            buildTextField(
              'Last Name',
              Icons.person_outline,
              lastNameController,
            ),
            SizedBox(height: 20),
            buildTextField(
              'Username',
              Icons.account_circle,
              usernameController,
            ),
            SizedBox(height: 20),
            buildTextField(
              'Email',
              Icons.email,
              emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),
            buildTextField(
              'Password',
              Icons.lock,
              passwordController,
              obscureText: true,
            ),
            SizedBox(height: 20),
            buildTextField(
              'Confirm Password',
              Icons.lock_outline,
              confirmPasswordController,
              obscureText: true,
            ),
            SizedBox(height: 20),
            buildTextField('Country', Icons.public, countryController),
            SizedBox(height: 20),
            buildTextField('City', Icons.location_city, cityController),
            SizedBox(height: 20),
            buildTextField('Street', Icons.streetview, streetController),
            SizedBox(height: 20),
            buildTextField(
              'Postal Code',
              Icons.local_post_office,
              postalCodeController,
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 30),
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
                child: Text('Register'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  textStyle: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(
    String label,
    IconData icon,
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
        border: OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
    );
  }
}
