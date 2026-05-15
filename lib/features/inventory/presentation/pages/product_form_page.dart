// Screen: Product Form (Criar/Editar Produto)
// User Story: US-23 — Create and Edit Products
// Epic: EPIC 4 — Producer Features
// Routes: POST /products | PUT /products/:id

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:ragro_mobile/core/di/injection.dart';
import 'package:ragro_mobile/core/formatters/input_masks.dart';
import 'package:ragro_mobile/core/theme/app_colors.dart';
import 'package:ragro_mobile/features/inventory/presentation/bloc/product_form_bloc.dart';
import 'package:ragro_mobile/features/inventory/presentation/bloc/product_form_event.dart';
import 'package:ragro_mobile/features/inventory/presentation/bloc/product_form_state.dart';

class ProductFormPage extends StatelessWidget {
  const ProductFormPage({super.key, this.productId});

  final String? productId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<ProductFormBloc>()
            ..add(ProductFormStarted(productId: productId)),
      child: _ProductFormView(isEditMode: productId != null),
    );
  }
}

class _ProductFormView extends StatefulWidget {
  const _ProductFormView({required this.isEditMode});
  final bool isEditMode;

  @override
  State<_ProductFormView> createState() => _ProductFormViewState();
}

class _ProductFormViewState extends State<_ProductFormView> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  String _selectedUnit = 'un';
  double _stockCount = 0;
  bool _initialized = false;
  XFile? _pickedPhoto;
  String? _existingImageUrl;
  List<int> _selectedCategoryIds = [];
  List<Map<String, dynamic>> _availableCategories = [];

  static const _units = ['kg', 'g', 'un', 'maço', 'pacote', 'box', 'liter', 'ml', 'dozen'];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _initFromProduct(ProductFormReady state) {
    if (_initialized) return;
    _initialized = true;
    if (state.product != null) {
      _nameController.text = state.product!.name;
      _descriptionController.text = state.product!.description;
      final format = NumberFormat.currency(
        locale: 'pt_BR',
        symbol: '',
        decimalDigits: 2,
      );
      _priceController.text = format.format(state.product!.price).trim();
      _selectedUnit = state.product!.unit;
      _stockCount = state.product!.stock;
      _existingImageUrl = state.product!.imageUrl;
      _selectedCategoryIds = List.of(state.product!.categoryIds);
    }
    _availableCategories = state.availableCategories;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Câmera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeria'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      final file = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (file != null) {
        setState(() => _pickedPhoto = file);
      }
    }
  }

  void _submit() {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final priceText = _priceController.text
        .trim()
        .replaceAll('.', '')
        .replaceAll(',', '.');
    if (name.isEmpty || priceText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha os campos obrigatórios.'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }
    final price = double.tryParse(priceText) ?? 0.0;
    context.read<ProductFormBloc>().add(
      ProductFormSaved(
        name: name,
        description: description,
        price: price,
        unit: _selectedUnit,
        stock: _stockCount,
        categoryIds: _selectedCategoryIds,
        photo: _pickedPhoto,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProductFormBloc, ProductFormState>(
      listener: (context, state) {
        if (state is ProductFormReady) _initFromProduct(state);
        if (state is ProductFormSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.isEditMode
                    ? 'Produto atualizado com sucesso!'
                    : 'Produto criado com sucesso!',
              ),
              backgroundColor: AppColors.darkGreen,
            ),
          );
          context.pop();
        }
        if (state is ProductFormFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is ProductFormLoading;
        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: AppBar(
            backgroundColor: AppColors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.black),
              onPressed: () => context.pop(),
            ),
            title: Text(
              widget.isEditMode ? 'Editar Produto' : 'Novo Produto',
              style: const TextStyle(
                fontFamily: 'Figtree',
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: AppColors.black,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image picker placeholder
                Container(
                  width: double.infinity,
                  height: 210,
                  decoration: BoxDecoration(
                    color: AppColors.darkGreen.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: _pickedPhoto != null
                            ? Image(
                                image: kIsWeb
                                    ? NetworkImage(_pickedPhoto!.path)
                                    : FileImage(File(_pickedPhoto!.path))
                                        as ImageProvider,
                                width: double.infinity,
                                height: 210,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Center(
                                  child: Icon(
                                    Icons.eco_outlined,
                                    size: 64,
                                    color: AppColors.darkGreen,
                                  ),
                                ),
                              )
                            : (_existingImageUrl != null &&
                                    _existingImageUrl!.isNotEmpty)
                                ? Image.network(
                                    _existingImageUrl!,
                                    width: double.infinity,
                                    height: 210,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Center(
                                      child: Icon(
                                        Icons.eco_outlined,
                                        size: 64,
                                        color: AppColors.darkGreen,
                                      ),
                                    ),
                                  )
                                : const Center(
                                    child: Icon(
                                      Icons.eco_outlined,
                                      size: 64,
                                      color: AppColors.darkGreen,
                                    ),
                                  ),
                      ),
                      Positioned(
                        bottom: 12,
                        child: GestureDetector(
                          onTap: isLoading ? null : _pickImage,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.darkGreen,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.camera_alt_outlined,
                                  size: 16,
                                  color: AppColors.white,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Alterar Foto',
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: AppColors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Nome
                const _FieldLabel('Nome do Produto'),
                const SizedBox(height: 8),
                _TextField(
                  controller: _nameController,
                  hint: 'Ex: Tomate Cereja Orgânico',
                  enabled: !isLoading,
                ),

                const SizedBox(height: 16),

                // Descrição
                const _FieldLabel('Descrição do Produto'),
                const SizedBox(height: 8),
                _TextField(
                  controller: _descriptionController,
                  hint: 'Descreva o produto...',
                  maxLines: 3,
                  enabled: !isLoading,
                ),

                const SizedBox(height: 16),

                // Preço + Unidade
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _FieldLabel(r'Preço (R$)'),
                          const SizedBox(height: 8),
                          _TextField(
                            controller: _priceController,
                            hint: '0,00',
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            enabled: !isLoading,
                            inputFormatters: [CurrencyInputFormatter()],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _FieldLabel('Unidade'),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: AppColors.inputBackground,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.inputBorder),
                            ),
                            child: DropdownButton<String>(
                              value: _selectedUnit,
                              isExpanded: true,
                              underline: const SizedBox.shrink(),
                              items: _units
                                  .map(
                                    (u) => DropdownMenuItem(
                                      value: u,
                                      child: Text(
                                        u,
                                        style: const TextStyle(
                                          fontFamily: 'Manrope',
                                          fontSize: 15,
                                          color: AppColors.black,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: isLoading
                                  ? null
                                  : (val) {
                                      if (val != null) {
                                        setState(() => _selectedUnit = val);
                                      }
                                    },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Estoque
                const _FieldLabel('Quantidade em Estoque'),
                const SizedBox(height: 8),
                _StockStepper(
                  value: _stockCount,
                  onChanged: isLoading
                      ? null
                      : (val) => setState(() => _stockCount = val),
                ),

                if (_availableCategories.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const _FieldLabel('Categorias'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: _availableCategories.map((cat) {
                      final id = cat['id'] as int;
                      final name = (cat['name'] as String?) ?? '';
                      final selected = _selectedCategoryIds.contains(id);
                      return FilterChip(
                        label: Text(
                          name,
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: selected ? AppColors.white : AppColors.darkGreen,
                          ),
                        ),
                        selected: selected,
                        onSelected: isLoading
                            ? null
                            : (checked) {
                                setState(() {
                                  if (checked) {
                                    _selectedCategoryIds.add(id);
                                  } else {
                                    _selectedCategoryIds.remove(id);
                                  }
                                });
                              },
                        selectedColor: AppColors.darkGreen,
                        backgroundColor: AppColors.darkGreen.withValues(alpha: 0.08),
                        checkmarkColor: AppColors.white,
                        side: BorderSide(
                          color: selected
                              ? AppColors.darkGreen
                              : AppColors.darkGreen.withValues(alpha: 0.4),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        showCheckmark: false,
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      );
                    }).toList(),
                  ),
                ],

                const SizedBox(height: 32),

                // Save button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkGreen,
                      foregroundColor: AppColors.white,
                      disabledBackgroundColor: AppColors.darkGreen.withValues(
                        alpha: 0.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.white,
                            ),
                          )
                        : Text(
                            widget.isEditMode
                                ? 'Salvar Alterações'
                                : 'Criar Produto',
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Manrope',
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: AppColors.black,
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.enabled = true,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType keyboardType;
  final bool enabled;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      enabled: enabled,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          fontFamily: 'Manrope',
          fontSize: 15,
          color: AppColors.placeholder,
        ),
        filled: true,
        fillColor: AppColors.inputBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkGreen, width: 1.5),
        ),
      ),
      style: const TextStyle(
        fontFamily: 'Manrope',
        fontSize: 15,
        color: AppColors.black,
      ),
    );
  }
}

class _StockStepper extends StatelessWidget {
  const _StockStepper({required this.value, required this.onChanged});

  final double value;
  final ValueChanged<double>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: value > 0 && onChanged != null
                ? () => onChanged!(value - 1)
                : null,
            child: Container(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.remove,
                size: 20,
                color: value > 0 ? AppColors.darkGreen : AppColors.placeholder,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                value % 1 == 0
                    ? value.toInt().toString()
                    : value.toStringAsFixed(2),
                style: const TextStyle(
                  fontFamily: 'Figtree',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: AppColors.black,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: onChanged != null ? () => onChanged!(value + 1) : null,
            child: Container(
              padding: const EdgeInsets.all(4),
              child: const Icon(
                Icons.add,
                size: 20,
                color: AppColors.darkGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
