import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/food_store.dart';
import '../models/food_item.dart';
import '../services/image_service.dart';
import '../services/notification_service.dart'; // 👇 ADDED IMPORT

class AddItemPage extends StatefulWidget {
  final FoodStore store;
  final FoodItem? existingItem;

  const AddItemPage({
    super.key,
    required this.store,
    this.existingItem,
  });

  bool get isEditMode => existingItem != null;

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController nameCtrl;
  late final TextEditingController qtyCtrl;

  static const List<String> categoryOptions = [
    "Produce", "Dairy", "Meat", "Seafood", "Grains", "Bakery",
    "Frozen", "Canned", "Condiments", "Snacks", "Drinks", "Spices",
    "Prepared Meals", "Desserts", "Other",
  ];

  static const List<String> unitOptions = [
    "pcs", "box", "bag", "carton", "bottle", "can", "jar", "pack",
    "lbs", "oz", "g", "kg", "ml", "L", "cups",
  ];

  late String category;
  late String unit;
  DateTime? expiresOn;

  bool isSaving = false;
  bool isLoadingPreview = false;
  String? previewImageUrl;

  bool _showCategoryHints = true;
  bool _expiryAlertsEnabled = true; // 👇 NEW: Track notification preference

  @override
  void initState() {
    super.initState();

    final item = widget.existingItem;
    nameCtrl = TextEditingController(text: item?.name ?? "");
    qtyCtrl = TextEditingController(
      text: item != null ? item.quantity.toString() : "1",
    );

    category = item?.category ?? "Produce";
    unit = item?.unit ?? "pcs";
    expiresOn = item?.expiresOn;
    previewImageUrl = item?.photoUrl;

    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _showCategoryHints = prefs.getBool('categoryHintsEnabled') ?? true;
        // 👇 Load the actual notification toggle from the profile
        _expiryAlertsEnabled = prefs.getBool('expiryAlertsEnabled') ?? true;
      });
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    qtyCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 3650)),
      initialDate: expiresOn ?? now,
    );

    if (picked != null) {
      setState(() => expiresOn = picked);
    }
  }

  Future<void> _fetchPreviewImage() async {
    final itemName = nameCtrl.text.trim();
    if (itemName.isEmpty) return;

    setState(() => isLoadingPreview = true);

    try {
      final url = await ImageService.fetchFoodImage(itemName);
      if (!mounted) return;
      setState(() => previewImageUrl = url);
    } finally {
      if (mounted) {
        setState(() => isLoadingPreview = false);
      }
    }
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) return;

    if (expiresOn == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an expiration date")),
      );
      return;
    }

    setState(() => isSaving = true);

    try {
      final itemName = nameCtrl.text.trim();
      String? imageUrl = previewImageUrl;
      imageUrl ??= await ImageService.fetchFoodImage(itemName);

      final finalCategory = _showCategoryHints ? category : "Other";
      final finalUnit = _showCategoryHints ? unit : "pcs";

      final item = FoodItem(
        id: widget.existingItem?.id ?? '',
        name: itemName,
        category: finalCategory,
        quantity: int.tryParse(qtyCtrl.text.trim()) ?? 1,
        unit: finalUnit,
        expiresOn: expiresOn!,
        photoUrl: imageUrl,
      );

      // Save to database
      if (widget.isEditMode) {
        await widget.store.updateItem(item);
      } else {
        await widget.store.addItem(item);
      }

      // 👇 SCHEDULE NOTIFICATION LOGIC
      if (_expiryAlertsEnabled) {
        // We use the unique ID of the item so we don't overlap notifications
        await NotificationService.scheduleExpiryNotification(
          id: item.id.hashCode,
          itemName: item.name,
          expiryDate: item.expiresOn,
        );
      }

      if (!mounted) return;
      Navigator.pop(context, item);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save item: $e")),
      );
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  Widget _buildImagePreview() {
    if (isLoadingPreview) {
      return const Center(child: CircularProgressIndicator());
    }

    if (previewImageUrl == null || previewImageUrl!.isEmpty) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.fastfood_outlined, size: 36),
          SizedBox(height: 8),
          Text("Search image from item name"),
        ],
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        previewImageUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return const Center(child: Icon(Icons.broken_image_outlined, size: 36));
        },
      ),
    );
  }

  String _formatDate(DateTime d) {
    return "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.isEditMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? "Edit Item" : "Add Item"),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: _buildImagePreview(),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: "Item name",
                prefixIcon: const Icon(Icons.edit_outlined),
                suffixIcon: IconButton(
                  onPressed: isLoadingPreview ? null : _fetchPreviewImage,
                  icon: const Icon(Icons.image_search_outlined),
                ),
              ),
              validator: (value) => (value == null || value.trim().isEmpty) ? "Enter a name" : null,
              onFieldSubmitted: (_) => _fetchPreviewImage(),
            ),
            const SizedBox(height: 12),
            if (_showCategoryHints) ...[
              DropdownButtonFormField<String>(
                value: categoryOptions.contains(category) ? category : "Other",
                items: categoryOptions.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (value) => setState(() => category = value ?? "Produce"),
                decoration: const InputDecoration(labelText: "Category", prefixIcon: Icon(Icons.category_outlined)),
              ),
              const SizedBox(height: 12),
            ],
            TextFormField(
              controller: qtyCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Quantity", prefixIcon: Icon(Icons.numbers_outlined)),
              validator: (value) => (int.tryParse(value ?? "") ?? 0) <= 0 ? "Enter quantity" : null,
            ),
            const SizedBox(height: 12),
            if (_showCategoryHints) ...[
              DropdownButtonFormField<String>(
                value: unitOptions.contains(unit) ? unit : "pcs",
                items: unitOptions.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                onChanged: (value) => setState(() => unit = value ?? "pcs"),
                decoration: const InputDecoration(labelText: "Unit", prefixIcon: Icon(Icons.straighten_outlined)),
              ),
              const SizedBox(height: 12),
            ],
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(16),
              child: InputDecorator(
                decoration: const InputDecoration(labelText: "Expiration date", prefixIcon: Icon(Icons.calendar_today_outlined)),
                child: Text(expiresOn == null ? "Tap to select" : _formatDate(expiresOn!)),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: isSaving ? null : _saveItem,
              child: Text(isSaving ? "Saving..." : "Save"),
            ),
          ],
        ),
      ),
    );
  }
}