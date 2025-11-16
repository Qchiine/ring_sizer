import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../models/product.dart';
import '../../providers/catalog_provider.dart';

class AddProductScreen extends StatefulWidget {
  final Product? product;

  const AddProductScreen({Key? key, this.product}) : super(key: key);

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _weightController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();

  int? _selectedCarat;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final product = widget.product!;
      _titleController.text = product.title;
      _descController.text = product.description;
      _weightController.text = product.weight.toString();
      _priceController.text = product.price.toString();
      _stockController.text = product.stock.toString();
      _selectedCarat = product.carat;
    }
  }

  Future<void> _pickImage() async {
    // La logique pour choisir une image reste la même
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (image != null) {
      setState(() => _imageFile = File(image.path));
    }
  }

  Future<void> _saveProduct() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final catalogProvider = Provider.of<CatalogProvider>(context, listen: false);

    final productData = {
      'title': _titleController.text.trim(),
      'description': _descController.text.trim(),
      'carat': _selectedCarat!,
      'weight': double.parse(_weightController.text),
      'price': double.parse(_priceController.text),
      'stock': int.parse(_stockController.text),
    };

    final success = _isEditing
        ? await catalogProvider.updateProduct(widget.product!.id, productData)
        : await catalogProvider.createProduct(productData);

    if (!mounted) return;

    final message = success
        ? 'Produit ${_isEditing ? 'mis à jour' : 'créé'} avec succès!'
        : catalogProvider.errorMessage ?? 'Une erreur est survenue.';
    final color = success ? Colors.green : Colors.red;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));

    if (success) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = Provider.of<CatalogProvider>(context).isLoading;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifier le Produit' : 'Nouveau Produit'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // La UI reste la même, elle est bien conçue !
              // ... (tout le reste du code de build est identique)
               GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.deepPurple, width: 2),
                  ),
                  child: _imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(13),
                          child: Stack(
                            children: [
                              Image.file(
                                _imageFile!,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                top: 10,
                                right: 10,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.close, color: Colors.white),
                                    onPressed: () {
                                      setState(() => _imageFile = null);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate, size: 60, color: Colors.deepPurple.shade300),
                            const SizedBox(height: 10),
                            const Text(
                              'Ajouter une photo',
                              style: TextStyle(
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'JPG, PNG, WEBP (max 5MB)',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 25),

              // Titre
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Titre du produit *',
                  hintText: 'Ex: Bague en or 18k',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un titre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Description
              TextFormField(
                controller: _descController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Description détaillée...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Carat
              DropdownButtonFormField<int>(
                value: _selectedCarat,
                decoration: InputDecoration(
                  labelText: 'Carat *',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: [18, 22, 24]
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text('$c carats'),
                        ))
                    .toList(),
                onChanged: (val) => setState(() => _selectedCarat = val),
                validator: (value) {
                  if (value == null) {
                    return 'Veuillez sélectionner le carat';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Poids
              TextFormField(
                controller: _weightController,
                decoration: InputDecoration(
                  labelText: 'Poids (grammes) *',
                  hintText: 'Ex: 5.2',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixText: 'g',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le poids';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Nombre invalide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Prix
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: 'Prix *',
                  hintText: 'Ex: 250',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixText: '€',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le prix';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Nombre invalide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Stock
              TextFormField(
                controller: _stockController,
                decoration: InputDecoration(
                  labelText: 'Stock *',
                  hintText: 'Ex: 10',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixText: 'unités',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le stock';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Nombre invalide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),

              // Bouton créer/modifier
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _saveProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          _isEditing ? 'Enregistrer' : 'Créer le produit',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _weightController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }
}
