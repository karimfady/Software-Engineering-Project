import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart' show kIsWeb;

class CreateBrandPage extends StatefulWidget {
  final Function(String) onBrandCreated;

  const CreateBrandPage({Key? key, required this.onBrandCreated})
    : super(key: key);

  @override
  State<CreateBrandPage> createState() => _CreateBrandPageState();
}

class _CreateBrandPageState extends State<CreateBrandPage> {
  final TextEditingController brandNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  File? _logoFile;
  Uint8List? _webImage;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        setState(() {
          _webImage = bytes;
        });
      } else {
        setState(() {
          _logoFile = File(image.path);
        });
      }
    }
  }

  Future<String> _uploadLogo() async {
    try {
      if (kIsWeb) {
        if (_webImage == null) {
          throw Exception('Please select a logo');
        }
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        final filePath = 'brand.logos/$fileName';

        await Supabase.instance.client.storage
            .from('brand.logos')
            .uploadBinary(
              filePath,
              _webImage!,
              fileOptions: FileOptions(cacheControl: '3600', upsert: true),
            );

        return Supabase.instance.client.storage
            .from('brand.logos')
            .getPublicUrl(filePath);
      } else {
        if (_logoFile == null) {
          throw Exception('Please select a logo');
        }

        final fileExt = path.extension(_logoFile!.path);
        final fileName = '${DateTime.now().millisecondsSinceEpoch}$fileExt';
        final filePath = 'brand.logos/$fileName';

        await Supabase.instance.client.storage
            .from('brand.logos')
            .upload(
              filePath,
              _logoFile!,
              fileOptions: FileOptions(cacheControl: '3600', upsert: true),
            );

        return Supabase.instance.client.storage
            .from('brand.logos')
            .getPublicUrl(filePath);
      }
    } catch (e) {
      print('Upload error: $e');
      rethrow;
    }
  }

  Future<void> _createBrand() async {
    if (!_formKey.currentState!.validate()) return;
    if ((kIsWeb && _webImage == null) || (!kIsWeb && _logoFile == null)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a logo')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Check if brand already exists
      final existingBrands = await Supabase.instance.client
          .from('Brand')
          .select()
          .eq('name', brandNameController.text.trim())
          .limit(1);

      if (existingBrands.isNotEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('A brand with this name already exists'),
          ),
        );
        return;
      }

      final logoUrl = await _uploadLogo();

      await Supabase.instance.client.from('Brand').insert({
        'name': brandNameController.text.trim(),
        'logo': logoUrl,
      });

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Brand created successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Call the callback and pop the page
      widget.onBrandCreated(brandNameController.text.trim());
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Brand')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: brandNameController,
                decoration: const InputDecoration(
                  labelText: 'Brand Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a brand name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:
                      (kIsWeb ? _webImage == null : _logoFile == null)
                          ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate, size: 50),
                                SizedBox(height: 8),
                                Text('Tap to select logo'),
                              ],
                            ),
                          )
                          : kIsWeb
                          ? Image.memory(_webImage!, fit: BoxFit.cover)
                          : Image.file(_logoFile!, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _createBrand,
                child:
                    _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Create Brand'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
