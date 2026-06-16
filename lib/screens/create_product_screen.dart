import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../providers/menu_provider.dart';

class CreateProductScreen extends StatefulWidget {
  const CreateProductScreen({super.key});

  @override
  State<CreateProductScreen> createState() => _CreateProductScreenState();
}

class _CreateProductScreenState extends State<CreateProductScreen> {
  final _formKey = GlobalKey<FormState>();

  String _name = '';
  String _price = '';
  String _category = 'Platos Fuertes';
  String _description = '';
  String _imageUrl = '';
  bool _isAvailable = true;

  File? _imageFile;
  bool _isCreatingCustomCategory = false;

  bool _isSaving = false;

  final List<String> _categories = [
    'Entradas',
    'Platos Fuertes',
    'Bebidas',
    'Postres',
  ];

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
        _imageUrl = ''; // Clear URL if file is picked
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      _isSaving = true;
    });

    try {
      final formData = FormData.fromMap({
        'name': _name,
        'price': _price,
        'category': _category,
        'description': _description,
        'is_available': _isAvailable.toString(),
      });

      if (_imageFile != null) {
        formData.files.add(MapEntry(
          'image',
          await MultipartFile.fromFile(_imageFile!.path, filename: 'upload.jpg'),
        ));
      } else if (_imageUrl.isNotEmpty) {
        formData.fields.add(MapEntry('image_url', _imageUrl));
      }

      final success = await context.read<MenuProvider>().createProduct(formData);

      setState(() {
        _isSaving = false;
      });

      if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Producto creado exitosamente!'), backgroundColor: Colors.green),
      );
      Navigator.of(context).pop(); // Go back to MenuScreen
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al crear el producto.'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ocurrió un error inesperado.'), backgroundColor: Colors.red),
        );
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
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          'Agregar Nuevo Producto',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w900,
            fontSize: 18,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Upload/URL field
              const Text('Imagen del Producto', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (_imageFile != null)
                    Container(
                      width: 64,
                      height: 64,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover),
                      ),
                    ),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.image, size: 18),
                      label: Text(_imageFile != null ? 'Cambiar Foto' : 'Subir Foto'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'O ingresa la URL (ej: https://...)',
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.orange.shade500)),
                ),
                keyboardType: TextInputType.url,
                enabled: _imageFile == null,
                onChanged: (val) {
                  setState(() {
                    _imageUrl = val;
                  });
                },
                onSaved: (val) => _imageUrl = val ?? '',
              ),
              const SizedBox(height: 20),

              // Name Field
              const Text('Nombre', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
              const SizedBox(height: 8),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Ej: Tacos al Pastor',
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.orange.shade500)),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
                onSaved: (val) => _name = val ?? '',
              ),
              const SizedBox(height: 20),

              // Price and Category Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Precio (\$)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                        const SizedBox(height: 8),
                        TextFormField(
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.orange.shade500)),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
                          onSaved: (val) => _price = val ?? '',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Categoría', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _isCreatingCustomCategory ? '__new__' : _category,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.orange.shade500)),
                          ),
                          items: [
                            ..._categories.map((cat) {
                              return DropdownMenuItem(value: cat, child: Text(cat, style: const TextStyle(fontSize: 14)));
                            }),
                            const DropdownMenuItem(value: '__new__', child: Text('+ Nueva categoría...', style: TextStyle(fontSize: 14, color: Colors.orange))),
                          ],
                          onChanged: (val) {
                            setState(() {
                              if (val == '__new__') {
                                _isCreatingCustomCategory = true;
                                _category = '';
                              } else {
                                _isCreatingCustomCategory = false;
                                _category = val!;
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (_isCreatingCustomCategory) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Nombre de la Nueva Categoría', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                      const SizedBox(height: 6),
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Ej: Ensaladas...',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                        validator: (value) => _isCreatingCustomCategory && (value == null || value.isEmpty) ? 'Requerido' : null,
                        onChanged: (val) => _category = val,
                        onSaved: (val) => _category = val ?? '',
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),

              // Description
              const Text('Descripción', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
              const SizedBox(height: 8),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Detalles del platillo...',
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.orange.shade500)),
                ),
                maxLines: 3,
                onSaved: (val) => _description = val ?? '',
              ),
              const SizedBox(height: 20),

              // Availability Switch
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SwitchListTile(
                  title: const Text('Disponible', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text('Disponible para la venta inmediatamente', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  value: _isAvailable,
                  activeColor: Colors.orange.shade600,
                  onChanged: (val) {
                    setState(() {
                      _isAvailable = val;
                    });
                  },
                ),
              ),
              const SizedBox(height: 32),

              // Save Button
              ElevatedButton(
                onPressed: _isSaving ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade600,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text(
                        'Crear Producto',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
