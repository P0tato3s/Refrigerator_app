import 'package:flutter/material.dart';

class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final nameCtrl = TextEditingController();
  final qtyCtrl = TextEditingController(text: "1");
  String category = "Produce";
  DateTime? expiresOn;

  @override
  void dispose() {
    nameCtrl.dispose();
    qtyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Item")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: nameCtrl,
            decoration: const InputDecoration(
              labelText: "Item name",
              prefixIcon: Icon(Icons.edit_outlined),
            ),
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
            onChanged: (v) => setState(() => category = v ?? "Produce"),
            decoration: const InputDecoration(
              labelText: "Category",
              prefixIcon: Icon(Icons.category_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: qtyCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Quantity",
              prefixIcon: Icon(Icons.numbers_outlined),
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text("Expiration date"),
            subtitle: Text(expiresOn == null ? "Tap to select" : _formatDate(expiresOn!)),
            leading: const Icon(Icons.calendar_today_outlined),
            onTap: () async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: context,
                firstDate: now.subtract(const Duration(days: 1)),
                lastDate: now.add(const Duration(days: 365)),
                initialDate: expiresOn ?? now,
              );
              if (picked != null) setState(() => expiresOn = picked);
            },
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Save (UI only)"),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return "${d.year}-$mm-$dd";
  }
}