import 'package:flutter/material.dart';
import '../data/mock_food_items.dart';
import '../models/food_item.dart';
import 'item_detail_page.dart';

class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [...mockFoodItems]
      ..sort((a, b) => a.expiresOn.compareTo(b.expiresOn));

    return Scaffold(
      appBar: AppBar(title: const Text("Inventory")),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) => _FoodRow(item: items[i]),
      ),
    );
  }
}

class _FoodRow extends StatelessWidget {
  final FoodItem item;
  const _FoodRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final days = item.daysUntilExpiry(DateTime.now());

    return Card(
      child: ListTile(
        title: Text(item.name),
        subtitle: Text("${item.quantity} ${item.unit} • ${item.category}"),
        trailing: _ExpiryChip(days: days),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ItemDetailPage(item: item)),
        ),
      ),
    );
  }
}

class _ExpiryChip extends StatelessWidget {
  final int days;
  const _ExpiryChip({required this.days});

  @override
  Widget build(BuildContext context) {
    String label;
    IconData icon;

    if (days < 0) {
      label = "Expired";
      icon = Icons.error_outline;
    } else if (days <= 3) {
      label = "Soon ($days d)";
      icon = Icons.timer_outlined;
    } else {
      label = "Fresh";
      icon = Icons.check_circle_outline;
    }

    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      visualDensity: VisualDensity.compact,
    );
  }
}