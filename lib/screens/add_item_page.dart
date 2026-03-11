import 'package:flutter/material.dart';
import '../data/food_store.dart';
import '../models/food_item.dart';
import '../services/image_service.dart';

class AddItemPage extends StatefulWidget {
  final FoodStore store;

  const AddItemPage({super.key, required this.store});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController qtyCtrl = TextEditingController(text: "1");

  String category = "Produce";
  String unit = "pcs";
  DateTime? expiresOn;
  bool isSaving = false;

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
      final name = nameCtrl.text.trim();
      final imageUrl = await ImageService.fetchFoodImage(name);

      final item = FoodItem(
        id: '',
        name: name,
        category: category,
        quantity: int.tryParse(qtyCtrl.text.trim()) ?? 1,
        unit: unit,
        expiresOn: expiresOn!,
        photoUrl: imageUrl,
      );

      await widget.store.addItem(item);

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save item: $e")),
      );
    }
  }

  String _formatDate(DateTime d) {
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return "${d.year}-$mm-$dd";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Item")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: "Item name",
                prefixIcon: Icon(Icons.edit_outlined),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Please enter an item name";
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: category,
              items: const [
                DropdownMenuItem(value: "Produce", child: Text("Produce")),
                DropdownMenuItem(value: "Dairy", child: Text("Dairy")),
                DropdownMenuItem(value: "Meat", child: Text("Meat")),
                DropdownMenuItem(value: "Snacks", child: Text("Snacks")),
                DropdownMenuItem(value: "Drinks", child: Text("Drinks")),
              ],
              onChanged: (value) {
                setState(() => category = value ?? "Produce");
              },
              decoration: const InputDecoration(
                labelText: "Category",
                prefixIcon: Icon(Icons.category_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: qtyCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Quantity",
                prefixIcon: Icon(Icons.numbers_outlined),
              ),
              validator: (value) {
                final parsed = int.tryParse(value ?? "");
                if (parsed == null || parsed <= 0) {
                  return "Enter a valid quantity";
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: unit,
              items: const [
                DropdownMenuItem(value: "pcs", child: Text("pcs")),
                DropdownMenuItem(value: "box", child: Text("box")),
                DropdownMenuItem(value: "bag", child: Text("bag")),
                DropdownMenuItem(value: "carton", child: Text("carton")),
                DropdownMenuItem(value: "lbs", child: Text("lbs")),
                DropdownMenuItem(value: "cups", child: Text("cups")),
              ],
              onChanged: (value) {
                setState(() => unit = value ?? "pcs");
              },
              decoration: const InputDecoration(
                labelText: "Unit",
                prefixIcon: Icon(Icons.straighten_outlined),
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(16),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: "Expiration date",
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                ),
                child: Text(
                  expiresOn == null ? "Tap to select" : _formatDate(expiresOn!),
                  style: TextStyle(
                    color: expiresOn == null ? Theme.of(context).hintColor : null,
                  ),
                ),
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