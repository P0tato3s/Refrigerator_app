import 'package:flutter/material.dart';
import '../data/food_store.dart';
import '../models/food_item.dart';
import 'item_detail_page.dart';

class InventoryPage extends StatelessWidget {
  final FoodStore store;

  const InventoryPage({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Inventory")),
      body: StreamBuilder<List<FoodItem>>(
        stream: store.watchItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  "Error loading inventory.\n\n${snapshot.error}",
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return const Center(
              child: Text("No items in your fridge yet."),
            );
          }

          final sortedItems = [...items]
            ..sort((a, b) => a.expiresOn.compareTo(b.expiresOn));

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: sortedItems.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) => _FoodRow(
              item: sortedItems[index],
              store: store,
            ),
          );
        },
      ),
    );
  }
}

class _FoodRow extends StatelessWidget {
  final FoodItem item;
  final FoodStore store;

  const _FoodRow({
    required this.item,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    final days = item.daysUntilExpiry(DateTime.now());

    return Card(
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 48,
            height: 48,
            child: item.photoUrl != null && item.photoUrl!.isNotEmpty
                ? Image.network(
              item.photoUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const ColoredBox(
                  color: Color(0xFFF0F0F2),
                  child: Icon(Icons.image_outlined),
                );
              },
            )
                : const ColoredBox(
              color: Color(0xFFF0F0F2),
              child: Icon(Icons.image_outlined),
            ),
          ),
        ),
        title: Text(item.name),
        subtitle: Text("${item.quantity} ${item.unit} • ${item.category}"),
        trailing: _ExpiryChip(days: days),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ItemDetailPage(
              item: item,
              store: store,
            ),
          ),
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