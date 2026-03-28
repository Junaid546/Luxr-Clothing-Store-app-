import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stylecart/app/theme/app_colors.dart';
import 'package:stylecart/app/theme/app_text_styles.dart';
import 'package:stylecart/core/constants/firestore_schema.dart';
import 'package:stylecart/core/errors/failures.dart';
import 'package:stylecart/core/utils/validators.dart';
import 'package:stylecart/features/admin/products/presentation/providers/admin_product_notifier.dart';
import 'package:stylecart/features/auth/data/providers/auth_providers.dart';
import 'package:stylecart/features/products/data/providers/product_data_providers.dart';
import 'package:stylecart/features/products/domain/entities/product_entity.dart';

class AddEditProductScreen extends ConsumerStatefulWidget {
  final String? productId;

  const AddEditProductScreen({
    this.productId,
    super.key,
  });

  @override
  ConsumerState<AddEditProductScreen> createState() =>
      _AddEditProductScreenState();
}

class _AddEditProductScreenState extends ConsumerState<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountController = TextEditingController();
  final _descController = TextEditingController();
  final _tagsController = TextEditingController();

  List<File> _newImages = [];
  List<String> _existingImageUrls = [];
  List<String> _removedImageUrls = [];

  Map<String, int> _inventory = {
    for (var size in ProductSize.all) size: 0,
  };

  String _selectedCategory = ProductCategory.apparel;
  bool _isFeatured = false;
  bool _isNewArrival = false;
  bool _isLimitedEdition = false;
  List<ProductColorEntity> _colors = [];

  bool _isInitialLoad = true;

  @override
  void initState() {
    super.initState();
    if (widget.productId != null) {
      _loadProduct();
    } else {
      _isInitialLoad = false;
    }
  }

  Future<void> _loadProduct() async {
    // Small delay to ensure ref is ready if needed,
    // but we can use ref.read since it's initState
    final productResult = await ref
        .read(productRepositoryProvider)
        .getProductById(widget.productId!);

    productResult.fold(
      (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(failure.message),
                backgroundColor: AppColors.error),
          );
          context.pop();
        }
      },
      (product) {
        if (mounted) {
          setState(() {
            _nameController.text = product.name;
            _brandController.text = product.brand;
            _priceController.text = product.price.toString();
            _discountController.text = product.discountPct.toString();
            _descController.text = product.description;
            _tagsController.text = product.tags.join(', ');
            _existingImageUrls = List.from(product.imageUrls);
            _inventory = {
              for (var size in ProductSize.all)
                size: product.inventory[size] ?? 0,
            };
            _selectedCategory = product.category;
            _isFeatured = product.isFeatured;
            _isNewArrival = product.isNewArrival;
            _isLimitedEdition = product.isLimitedEdition;
            _colors = List.from(product.colors);
            _isInitialLoad = false;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _descController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialLoad) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        title: Text(
          widget.productId == null ? 'Add Product' : 'Edit Product',
          style: AppTextStyles.titleLarge
              .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () {}, // TODO: Preview mode
            child: const Text('Preview',
                style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageSection(),
              const SizedBox(height: 24),
              _buildFormSection(
                title: 'Product Details',
                children: [
                  _buildTextField('Product Name', _nameController,
                      validator: Validators.validateName),
                  const SizedBox(height: 16),
                  _buildCategoryDropdown(),
                  const SizedBox(height: 16),
                  _buildTextField('Brand', _brandController,
                      validator: (v) => v!.isEmpty ? 'Brand required' : null),
                ],
              ),
              const SizedBox(height: 24),
              _buildFormSection(
                title: 'Pricing',
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          'Price (\$)',
                          _priceController,
                          keyboardType: TextInputType.number,
                          validator: Validators.validatePrice,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          'Discount (%)',
                          _discountController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildFormSection(
                title: 'Description',
                children: [
                  _buildTextField(
                    'Description',
                    _descController,
                    maxLines: 4,
                    hint: 'Details about fabric, fit, etc...',
                    validator: (v) =>
                        v!.length < 10 ? 'Description too short' : null,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildInventorySection(),
              const SizedBox(height: 24),
              _buildColorSection(),
              const SizedBox(height: 24),
              _buildTagsSection(),
              const SizedBox(height: 24),
              _buildFlagsSection(),
              const SizedBox(height: 40),
              _buildSaveButton(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    final totalImages = _existingImageUrls.length + _newImages.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Product Images (Max 8)',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        if (totalImages == 0)
          GestureDetector(
            onTap: _pickImages,
            child: Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.backgroundCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    style: BorderStyle.solid),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_a_photo_outlined,
                      color: AppColors.primary, size: 40),
                  const SizedBox(height: 8),
                  Text('Add Images',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppTextStyles.bodyMedium.color)),
                ],
              ),
            ),
          )
        else
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: totalImages + (totalImages < 8 ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == totalImages) {
                  return GestureDetector(
                    onTap: _pickImages,
                    child: Container(
                      width: 90,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderDefault),
                      ),
                      child: const Icon(Icons.add, color: AppColors.textMuted),
                    ),
                  );
                }

                final bool isExisting = index < _existingImageUrls.length;
                final imageUrl = isExisting ? _existingImageUrls[index] : null;
                final file = !isExisting
                    ? _newImages[index - _existingImageUrls.length]
                    : null;

                return MapEntry(
                    index,
                    Container(
                      width: 90,
                      margin: const EdgeInsets.only(right: 8),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: isExisting
                                ? CachedNetworkImage(
                                    imageUrl: imageUrl!,
                                    width: 90,
                                    height: 90,
                                    fit: BoxFit.cover,
                                  )
                                : Image.file(
                                    file!,
                                    width: 90,
                                    height: 90,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => _removeImage(index, isExisting),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle),
                                child: const Icon(Icons.close,
                                    size: 14, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )).value;
              },
            ),
          ),
      ],
    );
  }

  Widget _buildFormSection(
      {required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
    String? hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                const TextStyle(color: AppColors.textMuted, fontSize: 14),
            filled: true,
            fillColor: AppColors.backgroundCard,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    // Ensure the current category is always in the list to prevent dropdown crash
    final categories = Set<String>.from(ProductCategory.all)
      ..add(_selectedCategory);
    final sortedCategories = categories.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Category',
            style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
              color: AppColors.backgroundCard,
              borderRadius: BorderRadius.circular(12)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCategory,
              dropdownColor: AppColors.backgroundCard,
              isExpanded: true,
              style: const TextStyle(color: Colors.white),
              items: sortedCategories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedCategory = v!),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInventorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Inventory & Sizes',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _inventory.values.any((v) => v > 0)
                    ? AppColors.success.withOpacity(0.1)
                    : AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _inventory.values.any((v) => v > 0)
                    ? 'IN STOCK'
                    : 'OUT OF STOCK',
                style: TextStyle(
                  color: _inventory.values.any((v) => v > 0)
                      ? AppColors.success
                      : AppColors.error,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.5,
          ),
          itemCount: ProductSize.all.length,
          itemBuilder: (context, index) {
            final size = ProductSize.all[index];
            final stock = _inventory[size] ?? 0;

            return Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.backgroundCard,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: stock > 0
                          ? AppColors.primary.withOpacity(0.2)
                          : AppColors.backgroundElevated,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(size,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      initialValue: stock.toString(),
                      key: Key(
                          'inv_$size'), // Ensure it rebuilds with correct value
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                      ),
                      onChanged: (v) {
                        setState(() => _inventory[size] = int.tryParse(v) ?? 0);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildColorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Available Colors',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ..._colors.asMap().entries.map((entry) => _ColorChip(
                  color: entry.value,
                  onRemove: () => setState(() => _colors.removeAt(entry.key)),
                )),
            GestureDetector(
              onTap: _showAddColorDialog,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.backgroundCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borderDefault),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 16, color: AppColors.gold),
                    SizedBox(width: 4),
                    Text('Add Color',
                        style: TextStyle(color: AppColors.gold, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTagsSection() {
    return _buildFormSection(
      title: 'Tags (Optional)',
      children: [
        _buildTextField(
          'Search tags separated by commas',
          _tagsController,
          hint: 'silk, luxury, evening-wear',
        ),
      ],
    );
  }

  Widget _buildFlagsSection() {
    return _buildFormSection(
      title: 'Visibility & Badges',
      children: [
        _buildFlagTile('Featured Product', _isFeatured,
            (v) => setState(() => _isFeatured = v)),
        _buildFlagTile('New Arrival', _isNewArrival,
            (v) => setState(() => _isNewArrival = v)),
        _buildFlagTile('Limited Edition', _isLimitedEdition,
            (v) => setState(() => _isLimitedEdition = v)),
      ],
    );
  }

  Widget _buildFlagTile(
      String label, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      title: Text(label,
          style: const TextStyle(color: Colors.white, fontSize: 14)),
      activeColor: AppColors.gold,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildSaveButton() {
    final isSaving =
        ref.watch(adminProductNotifierProvider.select((s) => s.isSaving));

    return ElevatedButton(
      onPressed: isSaving ? null : _saveProduct,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: isSaving
          ? const CircularProgressIndicator(color: Colors.white)
          : Text(
              widget.productId == null ? 'Create Product' : 'Save Changes',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
    );
  }

  Future<void> _pickImages() async {
    final total = _existingImageUrls.length + _newImages.length;
    if (total >= 8) return;

    final picker = ImagePicker();
    final picked = await picker.pickMultiImage();

    if (picked.isNotEmpty) {
      setState(() {
        final remaining = 8 - total;
        _newImages.addAll(picked.take(remaining).map((p) => File(p.path)));
      });
    }
  }

  void _removeImage(int index, bool isExisting) {
    setState(() {
      if (isExisting) {
        _removedImageUrls.add(_existingImageUrls.removeAt(index));
      } else {
        _newImages.removeAt(index - _existingImageUrls.length);
      }
    });
  }

  void _showAddColorDialog() {
    final nameCtrl = TextEditingController();
    final hexCtrl = TextEditingController(text: '#');

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        title: const Text('Add Color', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Color Name')),
            TextField(
                controller: hexCtrl,
                decoration:
                    const InputDecoration(labelText: 'Hex Code (#...)')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty && hexCtrl.text.startsWith('#')) {
                setState(() => _colors.add(ProductColorEntity(
                    name: nameCtrl.text, hexCode: hexCtrl.text)));
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    if (_existingImageUrls.isEmpty && _newImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('At least one image is required'),
            backgroundColor: AppColors.error),
      );
      return;
    }

    final adminUser = ref.read(currentUserProvider);
    if (adminUser == null) return;

    final name = _nameController.text.trim();
    final brand = _brandController.text.trim();
    final price = double.parse(_priceController.text);
    final discount = int.tryParse(_discountController.text) ?? 0;
    final finalPrice = price * (1 - discount / 100);
    final tags = _tagsController.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    final product = ProductEntity(
      productId: widget.productId ?? '',
      name: name,
      brand: brand,
      description: _descController.text.trim(),
      category: _selectedCategory,
      tags: tags,
      price: price,
      discountPct: discount,
      finalPrice: finalPrice,
      imageUrls: _existingImageUrls,
      thumbnailUrl:
          _existingImageUrls.isNotEmpty ? _existingImageUrls.first : '',
      inventory: _inventory,
      totalStock: _inventory.values.fold(0, (a, b) => a + b),
      lowStockThreshold: int.parse(dotenv.env['LOW_STOCK_THRESHOLD'] ?? '5'),
      colors: _colors,
      isActive: true,
      isFeatured: _isFeatured,
      isNewArrival: _isNewArrival,
      isLimitedEdition: _isLimitedEdition,
      avgRating: 0.0,
      reviewCount: 0,
      soldCount: 0,
      viewCount: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      createdBy: adminUser.uid,
    );

    final notifier = ref.read(adminProductNotifierProvider.notifier);
    final dartz.Either<Failure, dynamic> result;

    if (widget.productId == null) {
      result = await notifier.createProduct(
        product: product,
        imageLocalPaths: _newImages.map((f) => f.path).toList(),
      );
    } else {
      result = await notifier.updateProduct(
        product: product,
        newImagePaths: _newImages.map((f) => f.path).toList(),
        removedUrls: _removedImageUrls,
      );
    }

    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(failure.message), backgroundColor: AppColors.error),
      ),
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(widget.productId == null ? 'Created' : 'Updated'),
              backgroundColor: AppColors.success),
        );
        context.pop();
      },
    );
  }
}

class _ColorChip extends StatelessWidget {
  final ProductColorEntity color;
  final VoidCallback onRemove;

  const _ColorChip({required this.color, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 6, 4, 6),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: Color(int.parse(color.hexCode.replaceFirst('#', '0xFF'))),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(color.name,
              style: const TextStyle(color: Colors.white, fontSize: 12)),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child:
                const Icon(Icons.close, size: 14, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
