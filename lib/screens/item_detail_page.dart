import 'package:flutter/material.dart';
import '../models/food_item.dart';
import '../data/food_store.dart';
import 'add_item_page.dart';

class ItemDetailPage extends StatelessWidget {
  final FoodItem item;
  final FoodStore store;

  const ItemDetailPage({
    super.key,
    required this.item,
    required this.store,
  });

  void _openEdit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddItemPage(
          store: store,
          existingItem: item,
        ),
      ),
    );
  }

  Future<void> _deleteItem(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete item"),
          content: Text("Are you sure you want to delete ${item.name}?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await store.deleteItem(item.id);

    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${item.name} deleted")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final days = item.daysUntilExpiry(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Item Details"),
        actions: [
          IconButton(
            onPressed: () => _openEdit(context),
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.photoUrl != null && item.photoUrl!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      item.photoUrl!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return Container(
                          height: 180,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F0F2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.broken_image_outlined, size: 48),
                        );
                      },
                    ),
                  )
                else
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F0F2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.image_outlined, size: 48),
                  ),
                const SizedBox(height: 16),
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text("Category: ${item.category}"),
                const SizedBox(height: 6),
                Text("Quantity: ${item.quantity} ${item.unit}"),
                const SizedBox(height: 6),
                Text("Expires on: ${_formatDate(item.expiresOn)}"),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text("Status: "),
                    _StatusChip(days: days),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _deleteItem(context),
                        icon: const Icon(Icons.delete_outline),
                        label: const Text("Delete"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => _openEdit(context),
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text("Edit"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return "${d.year}-$mm-$dd";
  }
}

class _StatusChip extends StatelessWidget {
  final int days;

  const _StatusChip({required this.days});

  @override
  Widget build(BuildContext context) {
    String label;
    IconData icon;

    if (days < 0) {
      label = "Expired";
      icon = Icons.error_outline;
    } else if (days <= 3) {
      label = "Expiring soon";
      icon = Icons.timer_outlined;
    } else {
      label = "Fresh";
      icon = Icons.check_circle_outline;
    }

    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}