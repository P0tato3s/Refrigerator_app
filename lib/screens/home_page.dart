import 'package:flutter/material.dart';
import '../data/mock_food_items.dart';
import '../models/food_item.dart';

import 'add_item_page.dart';
import 'inventory_page.dart';
import 'recipes_page.dart';
import 'item_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int navIndex = 0;
  String selectedCategory = "All";

  @override
  Widget build(BuildContext context) {
    final items = mockFoodItems;

    final categories = <String>{
      "All",
      ...items.map((e) => e.category),
    }.toList();

    return Scaffold(
      body: IndexedStack(
        index: navIndex,
        children: [
          _HomeTab(
            items: items,
            categories: categories,
            selectedCategory: selectedCategory,
            onSelectCategory: (c) => setState(() => selectedCategory = c),
            onOpenInventory: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const InventoryPage()),
            ),
            onOpenRecipes: () => setState(() => navIndex = 2),
          ),
          const InventoryPage(),
          const RecipesPage(),
          const _ProfilePlaceholderPage(),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddItemPage()),
        ),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        height: 64,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavIcon(
              icon: Icons.home_outlined,
              selectedIcon: Icons.home,
              selected: navIndex == 0,
              onTap: () => setState(() => navIndex = 0),
            ),
            _NavIcon(
              icon: Icons.list_alt_outlined,
              selectedIcon: Icons.list_alt,
              selected: navIndex == 1,
              onTap: () => setState(() => navIndex = 1),
            ),
            const SizedBox(width: 38),
            _NavIcon(
              icon: Icons.restaurant_menu_outlined,
              selectedIcon: Icons.restaurant_menu,
              selected: navIndex == 2,
              onTap: () => setState(() => navIndex = 2),
            ),
            _NavIcon(
              icon: Icons.person_outline,
              selectedIcon: Icons.person,
              selected: navIndex == 3,
              onTap: () => setState(() => navIndex = 3),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  final List<FoodItem> items;
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onSelectCategory;
  final VoidCallback onOpenInventory;
  final VoidCallback onOpenRecipes;

  const _HomeTab({
    required this.items,
    required this.categories,
    required this.selectedCategory,
    required this.onSelectCategory,
    required this.onOpenInventory,
    required this.onOpenRecipes,
  });

  @override
  Widget build(BuildContext context) {
    final filtered = selectedCategory == "All"
        ? items
        : items.where((e) => e.category == selectedCategory).toList();

    return SafeArea(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _Header(
            title: "My Fridge",
            subtitle: "What are we cooking today?",
            onProfile: () {},
            onBell: () {},
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: _SearchBar(
              hint: "Search items",
              onChanged: (v) {},
            ),
          ),
          SizedBox(
            height: 46,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, i) {
                final c = categories[i];
                final isSelected = c == selectedCategory;
                return ChoiceChip(
                  label: Text(c),
                  selected: isSelected,
                  onSelected: (_) => onSelectCategory(c),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemCount: categories.length,
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    "Inventory",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
                TextButton(onPressed: onOpenInventory, child: const Text("See all")),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 90),
            child: GridView.builder(
              itemCount: filtered.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.78,
              ),
              itemBuilder: (context, i) => FoodCard(item: filtered[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onProfile;
  final VoidCallback onBell;

  const _Header({
    required this.title,
    required this.subtitle,
    required this.onProfile,
    required this.onBell,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: const BoxDecoration(
        color: Color(0xFFDCE9E2),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(26),
          bottomRight: Radius.circular(26),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onProfile,
            child: const CircleAvatar(radius: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
          IconButton(
            onPressed: onBell,
            icon: const Icon(Icons.notifications_none),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;

  const _SearchBar({required this.hint, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.tune),
        ),
      ),
    );
  }
}

class FoodCard extends StatelessWidget {
  final FoodItem item;
  const FoodCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = item.daysUntilExpiry(now);

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ItemDetailPage(item: item)),
      ),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF0F0F2),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                ),
                child: const Icon(Icons.image_outlined, size: 42),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "${item.quantity} ${item.unit} • ${item.category}",
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  _ExpiryPill(daysUntil: days),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpiryPill extends StatelessWidget {
  final int daysUntil;
  const _ExpiryPill({required this.daysUntil});

  @override
  Widget build(BuildContext context) {
    String text;
    IconData icon;

    if (daysUntil < 0) {
      text = "Expired";
      icon = Icons.error_outline;
    } else if (daysUntil <= 3) {
      text = "Soon ($daysUntil d)";
      icon = Icons.timer_outlined;
    } else {
      text = "Fresh";
      icon = Icons.check_circle_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final bool selected;
  final VoidCallback onTap;

  const _NavIcon({
    required this.icon,
    required this.selectedIcon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(selected ? selectedIcon : icon),
    );
  }
}

class _ProfilePlaceholderPage extends StatelessWidget {
  const _ProfilePlaceholderPage();

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(
        child: Text("Profile / Settings page later"),
      ),
    );
  }
}