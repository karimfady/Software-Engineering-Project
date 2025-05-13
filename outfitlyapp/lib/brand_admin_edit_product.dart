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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Edit Product',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xff041511),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.save, color: Color(0xff041511)),
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
                    border: Border.all(
                      color: Color(0xff041511).withOpacity(0.1),
                    ),
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
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image,
                                      size: 50,
                                      color: Color(0xff041511).withOpacity(0.5),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Tap to change image',
                                      style: TextStyle(
                                        color: Color(
                                          0xff041511,
                                        ).withOpacity(0.7),
                                      ),
                                    ),
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
                decoration: InputDecoration(
                  labelText: 'Product Name',
                  labelStyle: TextStyle(color: Color(0xff041511)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Color(0xff041511).withOpacity(0.1),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Color(0xff041511).withOpacity(0.1),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Color(0xff041511)),
                  ),
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
                decoration: InputDecoration(
                  labelText: 'Price',
                  labelStyle: TextStyle(color: Color(0xff041511)),
                  prefixText: '\$',
                  prefixStyle: TextStyle(color: Color(0xff041511)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Color(0xff041511).withOpacity(0.1),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Color(0xff041511).withOpacity(0.1),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Color(0xff041511)),
                  ),
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
                decoration: InputDecoration(
                  labelText: 'Stock',
                  labelStyle: TextStyle(color: Color(0xff041511)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Color(0xff041511).withOpacity(0.1),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Color(0xff041511).withOpacity(0.1),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Color(0xff041511)),
                  ),
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
                decoration: InputDecoration(
                  labelText: 'Color',
                  labelStyle: TextStyle(color: Color(0xff041511)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Color(0xff041511).withOpacity(0.1),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Color(0xff041511).withOpacity(0.1),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Color(0xff041511)),
                  ),
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
                decoration: InputDecoration(
                  labelText: 'Category',
                  labelStyle: TextStyle(color: Color(0xff041511)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Color(0xff041511).withOpacity(0.1),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Color(0xff041511).withOpacity(0.1),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Color(0xff041511)),
                  ),
                ),
                items:
                    categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(
                          category,
                          style: TextStyle(color: Color(0xff041511)),
                        ),
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
                decoration: InputDecoration(
                  labelText: 'Type of Clothing',
                  labelStyle: TextStyle(color: Color(0xff041511)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Color(0xff041511).withOpacity(0.1),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Color(0xff041511).withOpacity(0.1),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Color(0xff041511)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the type of clothing';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Select Sizes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff041511),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children:
                    sizes.map((size) {
                      return FilterChip(
                        label: Text(
                          size,
                          style: TextStyle(
                            color:
                                selectedSizes.contains(size)
                                    ? Colors.white
                                    : Color(0xff041511),
                          ),
                        ),
                        selected: selectedSizes.contains(size),
                        selectedColor: Color(0xff041511),
                        backgroundColor: Colors.white,
                        checkmarkColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: Color(0xff041511).withOpacity(0.1),
                          ),
                        ),
                        onSelected: (selected) => _toggleSize(size),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 16),
              Text(
                'Tags',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff041511),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _tagsController,
                      decoration: InputDecoration(
                        hintText: 'Enter a tag and press +',
                        hintStyle: TextStyle(
                          color: Color(0xff041511).withOpacity(0.5),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Color(0xff041511).withOpacity(0.1),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Color(0xff041511).withOpacity(0.1),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Color(0xff041511)),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add, color: Color(0xff041511)),
                    onPressed: _addTag,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children:
                    tags.map((tag) {
                      return Chip(
                        label: Text(tag, style: TextStyle(color: Colors.white)),
                        backgroundColor: Color(0xff041511),
                        deleteIcon: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 18,
                        ),
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
