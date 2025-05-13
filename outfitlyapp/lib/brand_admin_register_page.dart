import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'create_brand_page.dart';

class BrandAdminRegisterPage extends StatefulWidget {
  const BrandAdminRegisterPage({Key? key}) : super(key: key);

  @override
  State<BrandAdminRegisterPage> createState() => _BrandAdminRegisterPageState();
}

class _BrandAdminRegisterPageState extends State<BrandAdminRegisterPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController brandNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _checkBrandAndRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Check if brand exists
      final brandResponse =
          await Supabase.instance.client
              .from('Brand')
              .select()
              .eq('name', brandNameController.text.trim())
              .single();

      // If brand exists, proceed with registration
      if (brandResponse != null) {
        await _registerBrandAdmin();
      } else {
        // Show dialog to create brand
        if (!mounted) return;
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Brand Not Found'),
                content: const Text(
                  'The brand you entered does not exist. Would you like to create it?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => CreateBrandPage(
                                onBrandCreated: (brandName) {
                                  brandNameController.text = brandName;
                                  _registerBrandAdmin();
                                },
                              ),
                        ),
                      );
                    },
                    child: const Text('Create Brand'),
                  ),
                ],
              ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _registerBrandAdmin() async {
    try {
      // Create brand admin profile with password
      await Supabase.instance.client.from('brand_admin').insert({
        'username': usernameController.text.trim(),
        'email': emailController.text.trim(),
        'brand_name': brandNameController.text.trim(),
        'password': passwordController.text,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Registration successful!')));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

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
          'Brand Admin Register',
          style: TextStyle(
            color: Color(0xff041511),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
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
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'E-mail',
                  labelStyle: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                  ),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  labelStyle: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                  ),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: brandNameController,
                decoration: InputDecoration(
                  labelText: 'Brand Name',
                  labelStyle: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                  ),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your brand name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => CreateBrandPage(
                            onBrandCreated: (brandName) {
                              brandNameController.text = brandName;
                            },
                          ),
                    ),
                  );
                },
                style: TextButton.styleFrom(foregroundColor: Color(0xff041511)),
                child: Text(
                  'Don\'t have a brand? Create one now.',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _checkBrandAndRegister,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  textStyle: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                  backgroundColor: Color(0xff041511),
                  foregroundColor: Colors.white,
                ),
                child:
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
