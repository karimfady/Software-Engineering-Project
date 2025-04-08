import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_logic.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController streetController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userEmail = LoginLogic.getLoggedInUserEmail();
      if (userEmail == null) {
        // Handle case where user is not logged in
        return;
      }

      final response = await Supabase.instance.client
          .from('User')
          .select()
          .eq('email', userEmail)
          .single();

      setState(() {
        firstNameController.text = response['first_name'] ?? '';
        lastNameController.text = response['last_name'] ?? '';
        usernameController.text = response['user_name'] ?? '';
        emailController.text = response['email'] ?? '';
        countryController.text = response['country'] ?? '';
        cityController.text = response['city'] ?? '';
        streetController.text = response['street'] ?? '';
        postalCodeController.text = response['postal_code']?.toString() ?? '';
        isLoading = false;
      });
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    try {
      final userEmail = LoginLogic.getLoggedInUserEmail();
      if (userEmail == null) {
        // Handle case where user is not logged in
        return;
      }

      await Supabase.instance.client
          .from('User')
          .update({
            'first_name': firstNameController.text.trim(),
            'last_name': lastNameController.text.trim(),
            'user_name': usernameController.text.trim(),
            'country': countryController.text.trim(),
            'city': cityController.text.trim(),
            'street': streetController.text.trim(),
            'postal_code': int.parse(postalCodeController.text.trim()),
          })
          .eq('email', userEmail);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    } catch (e) {
      print('Error updating profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    countryController.dispose();
    cityController.dispose();
    streetController.dispose();
    postalCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  buildTextField('First Name', Icons.person, firstNameController),
                  const SizedBox(height: 16),
                  buildTextField('Last Name', Icons.person_outline, lastNameController),
                  const SizedBox(height: 16),
                  buildTextField('Username', Icons.account_circle, usernameController),
                  const SizedBox(height: 16),
                  buildTextField('Email', Icons.email, emailController, enabled: false),
                  const SizedBox(height: 16),
                  buildTextField('Country', Icons.public, countryController),
                  const SizedBox(height: 16),
                  buildTextField('City', Icons.location_city, cityController),
                  const SizedBox(height: 16),
                  buildTextField('Street', Icons.streetview, streetController),
                  const SizedBox(height: 16),
                  buildTextField(
                    'Postal Code',
                    Icons.local_post_office,
                    postalCodeController,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _updateProfile,
                    child: const Text('Update Profile'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
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
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
    );
  }
} 