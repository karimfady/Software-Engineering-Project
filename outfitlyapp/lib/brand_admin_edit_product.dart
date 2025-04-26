import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

class BrandAdminEditProduct extends StatefulWidget {
  final Map<String, dynamic> product;
  final VoidCallback onProductUpdated;

  const BrandAdminEditProduct({
    Key? key,
    required this.product,
    required this.onProductUpdated,
  }) : super(key: key);

  @override
  State<BrandAdminEditProduct> createState() => _BrandAdminEditProductState();
}

class _BrandAdminEditProductState extends State<BrandAdminEditProduct> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  String? _selectedCategory;
  List<String> selectedSizes = [];
  List<String> tags = [];
  File? _imageFile;
  Uint8List? _webImage;
  bool _isLoading = false;
  String? _imageUrl;

  final List<String> sizes = ['XXS', 'XS', 'S', 'M', 'L', 'XL', 'XXL', 'NA'];
  final List<String> categories = ['Tops', 'Bottoms', 'Accessories'];

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.product['product_name'];
    _priceController.text = widget.product['price'].toString();
    _stockController.text = widget.product['Stock'].toString();
    _colorController.text = widget.product['color'];
    _typeController.text = widget.product['type_of_clothing'];
    _selectedCategory = widget.product['category'];
    selectedSizes = List<String>.from(widget.product['size'] ?? []);
    tags = List<String>.from(widget.product['Tags'] ?? []);
    _imageUrl = widget.product['picture'];
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

  Future<String?> _uploadImage() async {
    if (_imageFile == null && _webImage == null) return _imageUrl;

    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = 'products/$fileName';

      if (kIsWeb) {
        if (_webImage == null) return _imageUrl;
        await Supabase.instance.client.storage
            .from('products')
            .uploadBinary(
              filePath,
              _webImage!,
              fileOptions: FileOptions(cacheControl: '3600', upsert: true),
            );
      } else {
        if (_imageFile == null) return _imageUrl;
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
    } catch (e) {
      print('Error uploading image: $e');
      return _imageUrl;
    }
  }

  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String? imageUrl = _imageUrl;
      if (_imageFile != null || _webImage != null) {
        imageUrl = await _uploadImage();
      }

      await Supabase.instance.client
          .from('Product')
          .update({
            'product_name': _nameController.text.trim(),
            'price': double.parse(_priceController.text),
            'Stock': int.parse(_stockController.text),
            'color': _colorController.text.trim(),
            'category': _selectedCategory,
            'type_of_clothing': _typeController.text.trim(),
            'size': selectedSizes,
            'Tags': tags,
            'picture': imageUrl,
          })
          .eq('id', widget.product['id']);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      widget.onProductUpdated();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _updateProduct,
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
                          : Image.network(
                            _imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.image, size: 50),
                                    SizedBox(height: 8),
                                    Text('Tap to change image'),
                                  ],
                                ),
                              );
                            },
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
                    categories.map((category) {
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
}
