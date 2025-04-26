import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

class BrandAdminAddProduct extends StatefulWidget {
  final String brandName;
  final VoidCallback onProductAdded;

  const BrandAdminAddProduct({
    Key? key,
    required this.brandName,
    required this.onProductAdded,
  }) : super(key: key);

  @override
  State<BrandAdminAddProduct> createState() => _BrandAdminAddProductState();
}

class _BrandAdminAddProductState extends State<BrandAdminAddProduct> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  String? _selectedSize;
  String? _selectedCategory;
  File? _imageFile;
  Uint8List? _webImage;
  bool _isLoading = false;

  final List<String> _sizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];
  final List<String> _categories = ['Tops', 'Bottoms', 'Accessories'];
  final List<String> sizes = ['XXS', 'XS', 'S', 'M', 'L', 'XL', 'XXL', 'NA'];
  final List<String> selectedSizes = [];
  List<String> tags = [];

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _colorController.dispose();
    _typeController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _toggleSize(String size) {
    setState(() {
      if (selectedSizes.contains(size)) {
        selectedSizes.remove(size);
      } else {
        selectedSizes.add(size);
      }
    });
  }

  void _addTag() {
    final tag = _tagsController.text.trim();
    if (tag.isNotEmpty && !tags.contains(tag)) {
      setState(() {
        tags.add(tag);
        _tagsController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      tags.remove(tag);
    });
  }

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
          _imageFile = File(image.path);
        });
      }
    }
  }

  Future<String> _uploadImage() async {
    if (_imageFile == null && _webImage == null) {
      throw Exception('Please select an image');
    }

    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final filePath = 'products/$fileName';

    if (kIsWeb) {
      if (_webImage == null) throw Exception('No image selected');
      await Supabase.instance.client.storage
          .from('products')
          .uploadBinary(
            filePath,
            _webImage!,
            fileOptions: FileOptions(cacheControl: '3600', upsert: true),
          );
    } else {
      if (_imageFile == null) throw Exception('No image selected');
      await Supabase.instance.client.storage
          .from('products')
          .upload(
            filePath,
            _imageFile!,
            fileOptions: FileOptions(cacheControl: '3600', upsert: true),
          );
    }

    return Supabase.instance.client.storage
        .from('products')
        .getPublicUrl(filePath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Product'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _addProduct,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product Image
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:
                      _imageFile != null || _webImage != null
                          ? kIsWeb
                              ? Image.memory(_webImage!, fit: BoxFit.cover)
                              : Image.file(_imageFile!, fit: BoxFit.cover)
                          : const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate, size: 50),
                                SizedBox(height: 8),
                                Text('Tap to select image'),
                              ],
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 24),
              // Product Details
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a product name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(),
                  prefixText: '\$',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _stockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Stock',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter stock quantity';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _colorController,
                decoration: const InputDecoration(
                  labelText: 'Color',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a color';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items:
                    _categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _typeController,
                decoration: const InputDecoration(
                  labelText: 'Type of Clothing',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the type of clothing';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Select Sizes',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children:
                    sizes.map((size) {
                      return FilterChip(
                        label: Text(size),
                        selected: selectedSizes.contains(size),
                        onSelected: (selected) => _toggleSize(size),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 16),
              const Text(
                'Tags',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _tagsController,
                      decoration: const InputDecoration(
                        hintText: 'Enter a tag and press +',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.add), onPressed: _addTag),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children:
                    tags.map((tag) {
                      return Chip(
                        label: Text(tag),
                        onDeleted: () => _removeTag(tag),
                      );
                    }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageFile == null && _webImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an image'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final imageUrl = await _uploadImage();

      await Supabase.instance.client.from('Product').insert({
        'product_name': _nameController.text.trim(),
        'price': double.parse(_priceController.text),
        'Stock': int.parse(_stockController.text),
        'color': _colorController.text.trim(),
        'category': _selectedCategory,
        'type_of_clothing': _typeController.text.trim(),
        'size': selectedSizes,
        'Tags': tags,
        'brand_name': widget.brandName,
        'picture': imageUrl,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      widget.onProductAdded();
      Navigator.pop(context);
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
}
